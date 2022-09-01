# GLOBAL RESOURCES
resource "azurerm_resource_group" "main" {
  name = "${local.ENVIRONMENT}-main"
  location = local.REGION

  tags = {
    Environment = local.ENVIRONMENT
    ResourceType = "App" # App, Data, Security, Networking
    ServiceNowTicket = "xxxx"
    CreationDate = local.TIMESTAMP
    DataClassification = "xxxx" # PCI, CCPA
  }

lifecycle {
  ignore_changes = [
    tags["CreationDate"]
  ]
}

}

resource "random_string" "random" {
  length           = 8
  special          = false
  upper            = false
}

resource "azurerm_storage_account" "main" {
  name = "${local.ENVIRONMENT}main${random_string.random.result}"
  resource_group_name = azurerm_resource_group.main.name
  location = local.REGION
  account_tier = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = local.ENVIRONMENT
    ResourceType = "Data" # App, Data, Security, Networking
    ServiceNowTicket = "xxxx"
    CreationDate = local.TIMESTAMP
    DataClassification = "xxxx" # PCI, CCPA
  }

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "azurerm_storage_container" "main" {
  name = "tfstate"
  storage_account_name = azurerm_storage_account.main.name
  container_access_type = "private"
}


terraform {
  backend "azurerm" {
    # MUST CONFORM TO OTHER VALUES IN MAIN MODULE
    # NO VARIABLES OR SUBSTITUTIONS ALLOWED HERE
    resource_group_name  = "dev-main"
    storage_account_name = "xxxxx"
    container_name       = "tfstate"
    key                  = "dev-terraform.tfstate"
  }
}

####################
# CI/CD
module "ci-cd" {
  #TODO: pull modules from git

  # Other ways to define the source for faster dev-test cycles
  source = "../../modules/ci-cd/"

  environment = local.ENVIRONMENT
  resource_group = azurerm_resource_group.main.name
  resource_group_id = azurerm_resource_group.main.id
  timestamp = local.TIMESTAMP
  region      = local.REGION
  project_name = local.PROJECT_NAME
  repo_name     = local.REPO_NAME
  repo_branch = local.REPO_BRANCH
  random      = random_string.random.result
  subscription_id = local.SUBSCRIPTION_ID
  subscription_name = local.SUBSCRIPTION_NAME
  sp_tenant_id = local.SP_TENANT_ID
  sp_app_id = local.SP_APP_ID
  sp_secret =  local.SP_KEY
  function_subnet_id = module.network.private_subnet_id
}

# NETWORK
module "network" {
  #TODO: pull modules from git

  # Other ways to define the source for faster dev-test cycles
  source = "../../modules/network/"

  environment = local.ENVIRONMENT
  timestamp = local.TIMESTAMP
  region      = local.REGION
  resource_group = azurerm_resource_group.main.name
  subnet_prefix = local.SUBNET_PREFIX
}