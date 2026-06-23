variable "environment" {
  description = "Environment name: dev, staging, or prod"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westeurope"
}

variable "prefix" {
  description = "Unique prefix for all resource names to avoid conflicts"
  type        = string
}

variable "sql_admin_password" {
  description = "Admin password for Azure SQL Server — never hardcode this"
  type        = string
  sensitive   = true
}
