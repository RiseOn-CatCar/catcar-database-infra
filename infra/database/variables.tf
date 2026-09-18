variable "application_name" {
  description = "DNS-safe application name used in resource names."
  type        = string
  default     = "catcar"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "prod"
}

variable "resource_group_name" {
  description = "Foundation resource group prepared by the Azure bootstrap."
  type        = string
  default     = "CatCar"
}

variable "vnet_name" {
  description = "VNet provisioned by catcar-kubernetes-infra."
  type        = string
  default     = "vnet-catcar-prod"
}

variable "postgresql_subnet_prefix" {
  description = "Dedicated delegated subnet for PostgreSQL Flexible Server."
  type        = string
  default     = "10.20.3.0/24"
}

variable "administrator_login" {
  description = "PostgreSQL administrator login."
  type        = string
  default     = "catcaradmin"
}

variable "administrator_password" {
  description = "PostgreSQL administrator password."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.administrator_password) >= 12
    error_message = "administrator_password must contain at least 12 characters."
  }
}
variable "auth_readonly_login" {
  description = "PostgreSQL login used by auth service for read-only access; this role must exist in the database."
  type        = string
  default     = "auth_readonly"
}

variable "auth_readonly_password" {
  description = "Password for the auth service read-only PostgreSQL role; the role must exist."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.auth_readonly_password) >= 12
    error_message = "auth_readonly_password must contain at least 12 characters."
  }
}

variable "private_endpoint_subnet_id" {
  description = "Optional subnet ID for a private Key Vault endpoint."
  type        = string
  default     = null
  nullable    = true
}

variable "database_name" {
  description = "Logical CatCar database name."
  type        = string
  default     = "catcar"
}

variable "sku_name" {
  description = "PostgreSQL Flexible Server SKU."
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "storage_mb" {
  description = "Allocated PostgreSQL storage in MiB."
  type        = number
  default     = 32768
}

variable "backup_retention_days" {
  description = "Retention window for PostgreSQL backups."
  type        = number
  default     = 7
}

variable "availability_zone" {
  description = "Availability zone for the database server; set null when unavailable in the chosen region."
  type        = string
  default     = "1"
  nullable    = true
}

variable "geo_redundant_backup_enabled" {
  description = "Whether geo-redundant backups are enabled."
  type        = bool
  default     = false
}

variable "firewall_rules" {
  description = "Explicit public IP ranges. They are only effective if public access is intentionally enabled."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags applied to managed Azure resources."
  type        = map(string)
  default     = {}
}
