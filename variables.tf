variable "subscription_id" {
  description = "Azure Subscription ID"
}

variable "db_admin_password" {
  description = "Password for SQL Server admin"
  type        = string
  sensitive   = true
}
