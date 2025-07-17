terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "= 1.15.0"  
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 3.0.2"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id     = var.client_id      # Azure AD Application Client ID
  client_secret = var.client_secret  # Azure AD Application Client Secret
  tenant_id     = var.tenant_id      # Azure AD Tenant ID
  use_cli       = false
}

provider "azuread" {
  client_id     = var.client_id      # Azure AD Application Client ID
  client_secret = var.client_secret  # Azure AD Application Client Secret
  tenant_id     = var.tenant_id      # Azure AD Tenant ID
  use_cli       = false
}

provider "azapi" {
  client_id     = var.client_id      # Azure AD Application Client ID
  client_secret = var.client_secret  # Azure AD Application Client Secret
  tenant_id     = var.tenant_id      # Azure AD Tenant ID
  use_cli       = false
}


resource "random_id" "randomsubscription" {
  byte_length = 8
}

module "lz_vending" {
  source  = "Azure/lz-vending/azurerm"
  version = "=4.1.0" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  # Set the default location for resources
  location = "${var.location}"

  # subscription variables
  subscription_alias_enabled = true
  subscription_billing_scope = "/providers/Microsoft.Billing/billingAccounts/${var.billing_account_name}/billingProfiles/${var.billing_profile_name}/invoiceSections/${var.invoice_section_name}"
  subscription_display_name  = "azr-illumiotr-${lower(random_id.randomsubscription.hex)}"
  subscription_alias_name    = "azr-illumiotr-${lower(random_id.randomsubscription.hex)}"
  subscription_workload      = "${var.workload_type}"

  # Network Watcher
  network_watcher_resource_group_enabled = true

  # management group association variables
  subscription_management_group_association_enabled = true
  subscription_management_group_id                  = "${var.mg_id}"

  # virtual network variables
  #virtual_network_enabled = false

  # role assignments
  #role_assignment_enabled = false
}

resource "azuread_user" "new_user" {
  user_principal_name = "azr-illumiotr-${lower(random_id.randomsubscription.hex)}@${var.tenant_domain}"
  display_name        = "azr-illumiotr-${lower(random_id.randomsubscription.hex)}"
  mail_nickname       = "azr-illumiotr-${lower(random_id.randomsubscription.hex)}"
  password            = "${random_password.new_user_password.result}"
  force_password_change = false
}


resource "random_password" "new_user_password" {
  length  = 16
  special = false
}

# Add data resource for subscription
data "azurerm_subscription" "created_subscription" {
  subscription_id = module.lz_vending.subscription_id
}

resource "azurerm_role_assignment" "owner_assignment" {
  scope                = data.azurerm_subscription.created_subscription.id
  role_definition_name = var.user_role
  principal_id         = azuread_user.new_user.object_id
}

locals {
  encoded_password = base64encode(random_password.new_user_password.result)
}

resource "null_resource" "save_password" {
  provisioner "local-exec" {
    command = "echo ${local.encoded_password} | base64 --decode > password.txt"
  }
  depends_on = [azuread_user.new_user]
}

# ───── CREATE SERVICE PRINCIPAL ───────
resource "azuread_application" "app" {
  display_name = "sp-app-${random_password.new_user_password.result}"
}

resource "azuread_service_principal" "sp" {
  client_id = azuread_application.app.application_id
}

resource "azuread_service_principal_password" "sp_password" {
  service_principal_id = azuread_service_principal.sp.id
  value                = random_password.sp_pw.result
  end_date_relative    = "8760h" # 1 year
}

resource "random_password" "sp_pw" {
  length  = 24
  special = true
}

# ───── ASSIGN SP AS OWNER TO SUB ──────
resource "azurerm_role_assignment" "sp_subscription_owner" {
  scope                = module.lz_vending.subscription_id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.sp.id

  depends_on = [module.lz_vending]
}

