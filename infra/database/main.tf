terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "shared" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "shared" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.shared.name
}

locals {
  name_prefix = "${var.application_name}-${var.environment}"
  tags = merge(var.tags, {
    application = var.application_name
    environment = var.environment
    managed_by  = "terraform"
  })
}

resource "azurerm_subnet" "postgresql" {
  name                 = "snet-postgresql"
  resource_group_name  = data.azurerm_resource_group.shared.name
  virtual_network_name = data.azurerm_virtual_network.shared.name
  address_prefixes     = [var.postgresql_subnet_prefix]

  delegation {
    name = "postgresql-flexible-server"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_private_dns_zone" "postgresql" {
  name                = "private.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.shared.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  name                  = "pdnslink-postgresql-${local.name_prefix}"
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = data.azurerm_virtual_network.shared.id
  resource_group_name   = data.azurerm_resource_group.shared.name
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = "psql-${local.name_prefix}"
  resource_group_name    = data.azurerm_resource_group.shared.name
  location               = data.azurerm_resource_group.shared.location
  version                = "17"
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password
  sku_name               = var.sku_name
  storage_mb             = var.storage_mb
  backup_retention_days  = var.backup_retention_days
  zone                   = var.availability_zone

  delegated_subnet_id           = azurerm_subnet.postgresql.id
  private_dns_zone_id           = azurerm_private_dns_zone.postgresql.id
  public_network_access_enabled = false
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled
  tags                          = local.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgresql]
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_key_vault" "this" {
  name                          = substr("kv-${local.name_prefix}", 0, 24)
  location                      = data.azurerm_resource_group.shared.location
  resource_group_name           = data.azurerm_resource_group.shared.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
  tags                          = local.tags
}
resource "azurerm_private_endpoint" "key_vault" {
  count               = var.private_endpoint_subnet_id == null ? 0 : 1
  name                = "pe-kv-${local.name_prefix}"
  location            = data.azurerm_resource_group.shared.location
  resource_group_name = data.azurerm_resource_group.shared.name
  subnet_id           = var.private_endpoint_subnet_id
  private_service_connection {
    name                           = "psc-kv-${local.name_prefix}"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}

resource "azurerm_key_vault_secret" "postgres_auth_readonly_connection_string" {
  name         = "postgres-auth-readonly-connection-string"
  value        = "Host=${azurerm_postgresql_flexible_server.this.fqdn};Port=5432;Database=${azurerm_postgresql_flexible_server_database.this.name};Username=${var.auth_readonly_login};Password=${var.auth_readonly_password};Ssl Mode=Require;Trust Server Certificate=false"
  key_vault_id = azurerm_key_vault.this.id
  depends_on   = [azurerm_role_assignment.terraform_secrets_officer]
}

resource "azurerm_role_assignment" "terraform_secrets_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "postgres_connection_string" {
  name         = "postgres-connection-string"
  value        = "Host=${azurerm_postgresql_flexible_server.this.fqdn};Port=5432;Database=${azurerm_postgresql_flexible_server_database.this.name};Username=${var.administrator_login};Password=${var.administrator_password};Ssl Mode=Require;Trust Server Certificate=false"
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_role_assignment.terraform_secrets_officer]
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allowed" {
  for_each = var.firewall_rules

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}
