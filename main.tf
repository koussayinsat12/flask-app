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

# Azure Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = "flask-app-service-plan"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Azure Linux Web App for Flask App
resource "azurerm_linux_web_app" "flask_app_service" {
  name                = "flask-app-service"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    app_command_line = "gunicorn --bind 0.0.0.0:8000 app:app"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  depends_on = [azurerm_service_plan.app_service_plan]
}

# Deployment from GitHub
resource "azurerm_app_service_source_control" "flask_app_source_control" {
  app_id   = azurerm_linux_web_app.flask_app_service.id
  branch   = "main" # Update branch if necessary
  repo_url = "https://github.com/koussayinsat12/flask-app.git"

  # Automatic integration enabled by default
}
