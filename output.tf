# Output the user information
output "new_user_principal_name" {
  description = "The principal name of the newly created user."
  value       = azuread_user.new_user.user_principal_name
}

output "new_user_password" {
  description = "The password for the newly created user."
  value       = random_password.new_user_password.result
  sensitive   = true
}

output "login_url" {
  description = "The login URL for the newly created user."
  value       = "https://portal.azure.com"
}