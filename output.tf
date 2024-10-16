# Output the user information
output "new_subscription_id" {
  description = "ID of the newly created subscription."
  value       = module.lz_vending.subscription_id
}

output "tenant_id" {
  description = "Azure Tenant ID."
  value       = var.tenant_id
}

output "new_user_email" {
  description = "The email ID of the newly created Azure AD user."
  value       = azuread_user.new_user.user_principal_name
}

output "new_user_password" {
  description = "The password for the newly created Azure AD user."
  value       = random_password.new_user_password.result
  sensitive   = true
}
