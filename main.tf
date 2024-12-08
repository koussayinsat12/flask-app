# Provider configuration
provider "azurerm" {
  features {}

  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# Data block to check if the resource group exists
data "azurerm_resource_group" "existing" {
  name = "devops"
}

# Check if the Service Plan already exists
data "azurerm_service_plan" "existing" {
  name                = "flask-app-service-plan"
  resource_group_name = data.azurerm_resource_group.existing.name
}

# Generate a unique suffix for resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Azure Service Plan
resource "azurerm_service_plan" "example" {
  count               = length(data.azurerm_service_plan.existing.id) == 0 ? 1 : 0
  name                = "flask-app-service-plan"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Azure Application Insights
resource "azurerm_application_insights" "example" {
  name                = "flask-app-insights-${random_string.suffix.result}"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  application_type    = "web"
}

# Azure Linux Web App
resource "azurerm_linux_web_app" "example" {
  name                = "web-app-${random_string.suffix.result}" # Ensure a globally unique name
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  service_plan_id     = coalesce(
    try(azurerm_service_plan.example[0].id, null),
    data.azurerm_service_plan.existing.id
  )

  site_config {
    always_on     = false
    http2_enabled = true
  }

  app_settings = {
    "DOCKER_ENABLE_CI"        = "true"
    "DOCKER_CUSTOM_IMAGE_NAME" = var.docker_image
  }

  identity {
    type = "SystemAssigned"
  }
}
