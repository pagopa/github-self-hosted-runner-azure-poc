resource "azuread_application" "environment_ci" {
  display_name = "${local.app_name}-ci"
}

resource "azuread_service_principal" "environment_ci" {
  application_id = azuread_application.environment_ci.application_id
}

resource "azuread_application_federated_identity_credential" "environment_ci" {
  application_object_id = azuread_application.environment_ci.object_id
  display_name          = "github-federated"
  description           = "github-federated"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github.org}/${var.github.repository}:environment:${var.env}-ci"
}

resource "azurerm_role_assignment" "environment_ci_subscription" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = var.environment_ci_roles.subscription
  principal_id         = azuread_service_principal.environment_ci.object_id
}

resource "azurerm_role_assignment" "environment_ci_tfstate_inf" {
  scope                = data.azurerm_storage_account.tfstate_inf.id
  role_definition_name = var.environment_cd_roles.tfstate_inf
  principal_id         = azuread_service_principal.environment_ci.object_id
}

resource "azurerm_role_assignment" "environment_ci_github_runner_rg" {
  scope                = data.azurerm_resource_group.github_runner_rg.id
  role_definition_name = var.environment_ci_roles.github_runner_rg
  principal_id         = azuread_service_principal.environment_ci.object_id
}

output "azure_environment_ci" {
  value = {
    app_name       = "${local.app_name}-ci"
    client_id      = azuread_service_principal.environment_ci.application_id
    application_id = azuread_service_principal.environment_ci.application_id
    object_id      = azuread_service_principal.environment_ci.object_id
  }
}