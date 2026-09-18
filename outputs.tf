output "postgresql_server_id" {
  description = "PostgreSQL Flexible Server resource ID."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "postgresql_fqdn" {
  description = "Private PostgreSQL server hostname."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_name" {
  description = "Provisioned CatCar database name."
  value       = azurerm_postgresql_flexible_server_database.this.name
}

output "key_vault_id" {
  description = "Key Vault resource ID."
  value       = azurerm_key_vault.this.id
}

output "key_vault_uri" {
  description = "Key Vault URI for workload identity clients."
  value       = azurerm_key_vault.this.vault_uri
}

output "key_vault_name" {
  description = "Key Vault name used by deployment workflows."
  value       = azurerm_key_vault.this.name
}

output "postgres_connection_secret_name" {
  description = "Key Vault secret name containing the PostgreSQL connection string."
  value       = azurerm_key_vault_secret.postgres_connection_string.name
}
