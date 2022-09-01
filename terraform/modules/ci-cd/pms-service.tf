####################
# PMS-SERVICE

# Load a specific Git repository by name
data "azuredevops_git_repository" "pms-service" {
  project_id = data.azuredevops_project.project.id
  name       = "pms-service"
}

resource "azurerm_storage_blob" "pms-service" {
  #Only for initial deployment
  source = "../../../functions/pms-service/dummy.zip"

  name = "pms-service.zip"
  storage_account_name = azurerm_storage_account.cicd.name
  storage_container_name = azurerm_storage_container.deployments.name
  type = "Block"
}

resource "azuredevops_variable_group" "pms-service" {
  project_id   = data.azuredevops_project.project.id
  name         = "${var.environment}-pms-service"
  description  = "Managed by Terraform"
  allow_access = true

  variable {
    name  = "TEST"
    value = "VALUE"
  }
}

resource "azuredevops_build_definition" "pms-service" {
  project_id = data.azuredevops_project.project.id
  name = "${var.environment}-pms-service"
  agent_pool_name = "Azure Pipelines"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type = "TfsGit"
    repo_id = data.azuredevops_git_repository.pms-service.id
    branch_name = var.repo_branch
    yml_path = "azure-pipelines.yml"
  }

  variable_groups = [azuredevops_variable_group.pms-service.id]

  variable {
    name = "TEST2"
    value = "VALUE2"
  }
}

resource "azuredevops_build_definition_permissions" "pms-service" {
  project_id  = data.azuredevops_project.project.id
  principal   = data.azuredevops_group.project-admins.id

  build_definition_id = azuredevops_build_definition.pms-service.id

  permissions = {
    ViewBuilds       = "Allow"
    ManageBuildQueue = "Allow"
    DeleteBuilds     = "Allow"
    StopBuilds       = "Allow"
    EditBuildDefinition = "Allow"
    AdministerBuildPermissions = "Allow"
  }
}

resource "azurerm_function_app" "pms-service" {
  name                       = "${var.environment}-pms-service"
  location                   = var.region
  resource_group_name        = var.resource_group
  app_service_plan_id        = azurerm_app_service_plan.cicd.id
  storage_account_name       = azurerm_storage_account.cicd.name
  storage_account_access_key = azurerm_storage_account.cicd.primary_access_key
  https_only                 = true
  version                    = "~3"
  #os_type                    = "linux"

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"              = "1"
    "FUNCTIONS_WORKER_RUNTIME"              = "python"
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.cicd.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = "InstrumentationKey=${azurerm_application_insights.cicd.instrumentation_key};IngestionEndpoint=https://useast-0.in.applicationinsights.azure.com/"
  }

  /*site_config {
    linux_fx_version = "PYTHON|3.6"
    ftps_state       = "Disabled"
  }*/

  # Enable if you need Managed Identity
  # identity {
  #   type = "SystemAssigned"
  # }

  tags = {
    Environment = var.environment
    ResourceType = "App" # App, Data, Security, Networking
    ServiceNowTicket = "xxxx"
    CreationDate = var.timestamp
    DataClassification = "xxxx" # PCI, CCPA
  }

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "pms-service" {
  app_service_id = azurerm_function_app.pms-service.id
  subnet_id      = var.function_subnet_id
}

resource "azurerm_api_management" "pms-service" {
  name                = "${var.environment}-pms-service"
  location            = var.region
  resource_group_name = var.resource_group
  publisher_name      = "LTCG"
  publisher_email     = "publisher@ltcg.com"

  sku_name = "Consumption_0"

  tags = {
    Environment = var.environment
    ResourceType = "App" # App, Data, Security, Networking
    ServiceNowTicket = "xxxx"
    CreationDate = var.timestamp
    DataClassification = "xxxx" # PCI, CCPA
  }

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}
