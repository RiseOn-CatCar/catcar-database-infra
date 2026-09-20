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
  description = "Resource group for CatCar database and secrets infrastructure."
  type        = string
  default     = "catcar-prod"
}

variable "vnet_name" {
  description = "VNet provisioned by catcar-kubernetes-infra."
  type        = string
  default     = "vnet-catcar-prod"
}

variable "postgresql_subnet_prefix" {
  description = "Dedicated delegated subnet for PostgreSQL Flexible Server."
  type        = string
  default     = "10.20.2.0/24"
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

variable "database_name" {
  description = "Logical CatCar database name."
  type        = string
  default     = "catcar"
}

variable "sku_name" {
  description = "PostgreSQL Flexible Server SKU."
  type        = string
  default     = "B_Standard_B1ms"
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
  description = "Availability zone for the database server; set null when unpinned."
  type        = string
  default     = null
  nullable    = true
}

variable "geo_redundant_backup_enabled" {
  description = "Whether geo-redundant backups are enabled."
  type        = bool
  default     = false
}

variable "jwt_secret" {
  description = "Signing key used by administrative staff JWT authentication."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.jwt_secret) >= 32
    error_message = "jwt_secret must contain at least 32 characters."
  }
}

variable "customer_jwt_signing_key" {
  description = "Signing key used by customer JWT authentication."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.customer_jwt_signing_key) >= 32
    error_message = "customer_jwt_signing_key must contain at least 32 characters."
  }
}

variable "gateway_backend_key" {
  description = "Shared secret key required by backend workloads from APIM."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.gateway_backend_key) >= 32
    error_message = "gateway_backend_key must contain at least 32 characters."
  }
}

variable "tags" {
  description = "Additional tags applied to managed Azure resources."
  type        = map(string)
  default     = {}
}
