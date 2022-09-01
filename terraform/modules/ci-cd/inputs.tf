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

variable "resource_group_id" {
  type        = string
  description = "ID of the Azure Resource Group."
}

variable "project_name" {
  type        = string
  description = "Name of the Azure Devops Project."
}

variable "repo_name" {
  type        = string
  description = "Name of the Azure Devops Repository."
}

variable "repo_branch" {
  type        = string
  description = "Name of the Azure Devops Repository branch which triggers a build."
}

variable "random" {
  type        = string
  description = "Random string for resource naming."
}

variable "subscription_name" {
  type        = string
  description = "Name of the Azure subscription."
}

variable "subscription_id" {
  type        = string
  description = "ID of the Azure subscription."
}

variable "sp_tenant_id" {
  type        = string
  description = "ID of the service principal tenant."
}

variable "sp_app_id" {
  type        = string
  description = "ID of the service principal app."
}

variable "sp_secret" {
  type        = string
  description = "Secret Key of the service principal."
}

variable "timestamp" {
  type        = string
  description = "Current timestamp."
}

variable "function_subnet_id" {
  type        = string
  description = "Subnet ID for function operations."
}
