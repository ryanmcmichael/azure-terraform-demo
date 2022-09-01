locals {
  AZURE_ENDPOINTS   = [
    "Microsoft.AzureActiveDirectory",
    "Microsoft.AzureCosmosDB",
    "Microsoft.KeyVault",
    "Microsoft.ServiceBus",
    "Microsoft.Storage",
    "Microsoft.Web"
  ]
}

variable "environment" {
  type        = string
  description = "Unique name of the environment these resources belong to. Ex: \"dev\"."
  validation {
    condition     = contains(["dev","test", "prod"], var.environment)
    error_message = "The region value must be either \"dev\", \"test\", or \"prod\"."
  }
}

variable "region" {
  type        = string
  description = "Azure name of the region/location where the resources will be created. Ex: \"eastus\"."
  validation {
    condition     = contains(["centralus","eastus", "eastus2", "westus", "southcentralus"], var.region)
    error_message = "The region value must be either \"centralus\",\"eastus\", \"eastus2\", \"westus\", or \"southcentralus\"."
  }
}

variable "resource_group" {
  type        = string
  description = "Name of the Azure Resource Group."
}

variable "subnet_prefix" {
  type        = string
  description = "Subnet prefix. Ex: \"1\", \"2\", \"3\", etc."
}

variable "timestamp" {
  type        = string
  description = "Current timestamp."
}
