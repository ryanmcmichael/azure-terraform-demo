# Project must be created manually
data "azuredevops_project" "project" {
  name = var.project_name
}

data "azuredevops_group" "project-admins" {
  project_id = data.azuredevops_project.project.id
  name       = "Build Administrators"
}

resource "azuredevops_serviceendpoint_azurerm" "endpointazure" {
  project_id                = data.azuredevops_project.project.id
  service_endpoint_name     = "${var.environment}-cicd"
  description               = "Managed by Terraform"
  #resource_group            = azurerm_resource_group.cicd.id
  credentials {
    serviceprincipalid  = var.sp_app_id
    serviceprincipalkey = var.sp_secret
  }
  azurerm_spn_tenantid      = var.sp_tenant_id
  azurerm_subscription_id   = var.subscription_id
  azurerm_subscription_name = var.subscription_name
}

resource "azurerm_storage_account" "cicd" {
  name = "${var.environment}cicd${var.random}"
  resource_group_name = var.resource_group
  location = var.region
  account_tier = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
    ResourceType = "Data" # App, Data, Security, Networking
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

data "azurerm_storage_account_sas" "cicd" {
  connection_string = azurerm_storage_account.cicd.primary_connection_string
  https_only = true
  start = "2021-01-01"
  expiry = "2031-12-31"
  resource_types {
    object = true
    container = true
    service = true
  }
  services {
    blob = true
    queue = true
    table = true
    file = true
  }
  permissions {
    read = true
    write = true
    delete = true
    list = true
    add = true
    create = true
    update = true
    process = true
  }
}

resource "azurerm_storage_container" "deployments" {
  name = "function-releases"
  storage_account_name = azurerm_storage_account.cicd.name
  container_access_type = "private"
}

resource "azurerm_app_service_plan" "cicd" {
  name = "${var.environment}-cicd"
  resource_group_name = var.resource_group
  location = var.region
  kind = "FunctionApp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }

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

resource "azurerm_application_insights" "cicd" {
  name                = "${var.environment}-cicd"
  location            = var.region
  resource_group_name = var.resource_group
  application_type    = "web"

  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/1303
  tags = {
    "hidden-link:${var.resource_group_id}/providers/Microsoft.Web/sites/${var.environment}-pms-service" = "Resource"
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