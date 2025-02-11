provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuredevops" {
  org_service_url       = var.org_url
  personal_access_token = var.pat_token
}

# Get client configuration
data "azurerm_client_config" "tenant" {}

# Define resource group with prefix
resource "azurerm_resource_group" "rg_fabric" {
  name     = "${var.prefix}-rg-001"
  location = var.location
}

# Create a managed identity with prefix
resource "azurerm_user_assigned_identity" "mi_fabric" {
  name                = "${var.prefix}-identity"
  resource_group_name = azurerm_resource_group.rg_fabric.name
  location            = azurerm_resource_group.rg_fabric.location
}

# Assign the managed identity as a Contributor to the subscription
resource "azurerm_role_assignment" "ra_fabric_contributor" {
  principal_id         = azurerm_user_assigned_identity.mi_fabric.principal_id
  role_definition_name = "Contributor"
  scope                = "/subscriptions/${var.subscription_id}"
}

# Data source for the Azure DevOps project
data "azuredevops_project" "project" {
  name = var.project_name
}

# Create a service connection in Azure DevOps using Workload Identity Federation
resource "azuredevops_serviceendpoint_azurerm" "se_fabric" {
  project_id                         = data.azuredevops_project.project.id
  service_endpoint_name              = "${var.prefix}-service-connection"
  description                        = "Service connection for ${var.project_name}"
  azurerm_spn_tenantid               = data.azurerm_client_config.tenant.tenant_id
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"
  credentials {
    serviceprincipalid = azurerm_user_assigned_identity.mi_fabric.client_id
  }
  azurerm_subscription_id = var.subscription_id
  azurerm_subscription_name = "Azure Fabric Accelerator Pod"
}

# Create an empty Git repository in Azure DevOps
resource "azuredevops_git_repository" "repo_fabric" {
  project_id      = data.azuredevops_project.project.id
  name            = var.target_repo_name
  
  initialization {
    init_type = "Uninitialized"
  }
}

# Add the federation section
resource "azurerm_federated_identity_credential" "federation" {
  name                = "example-federated-credential"
  resource_group_name = azurerm_resource_group.rg_fabric.name
  parent_id           = azurerm_user_assigned_identity.mi_fabric.id
  audience            = ["api://AzureADTokenExchange"]
  #issuer              =  "https://vstoken.dev.azure.com/${var.organization_id}"
  #subject             = "sc://${var.organization_id}/${data.azuredevops_project.project.name}/${var.prefix}-service-connection"
  issuer              = azuredevops_serviceendpoint_azurerm.se_fabric.workload_identity_federation_issuer
  subject             = azuredevops_serviceendpoint_azurerm.se_fabric.workload_identity_federation_subject
}
