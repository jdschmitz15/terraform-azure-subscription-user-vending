variable "location" {
  default = "eastus"
  description = "Azure region where the Resource Group is created"
  type        = string
}

variable "billing_account_name" {  
  description = "billing_account_name"
  type        = string
}

variable "billing_profile_name" {  
  description = "billing_profile_name"
  type        = string
}

variable "invoice_section_name" {  
  description = "invoice_section_name"
  type        = string
}

variable "mg_id" {  
  description = "Management group ID"
  type        = string
}

variable "workload_type" {
  default     = "Production"
  description = "Id of Management Group"
  type        = string
}

variable "client_id" {
  description = "Client ID"
  type        = string
}

variable "client_secret" {
  description = "Client secret"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID"
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
}

variable "tenant_domain" {
  description = "Tenant Domain"
  type        = string
}

variable "user_role" {
  description = "User Role"
  type        = string
}