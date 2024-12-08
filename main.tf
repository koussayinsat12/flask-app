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

# Generate a unique suffix for resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
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
  name                = "flask-app-service-${random_string.suffix.result}"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
  
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"            = "1"
    "PYTHON_VERSION"                      = "3.9"
    "APPINSIGHTS_INSTRUMENTATIONKEY"      = azurerm_application_insights.app_insights.instrumentation_key
  }
}

# Deployment from GitHub
resource "azurerm_app_service_source_control" "flask_app_source_control" {
  app_id                = azurerm_linux_web_app.flask_app_service.id
  branch                = "main"
  repo_url              = "https://github.com/koussayinsat12/flask-app.git"
  use_manual_integration = true
}

# GitHub Token for Deployment
resource "azurerm_source_control_token" "source_control_token" {
  type         = "GitHub"
  token        = var.github_auth_token
  token_secret = var.github_auth_token
}

# Monitoring: Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "flask-app-insights-${random_string.suffix.result}"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  application_type    = "web"
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "log_workspace" {
  name                = "flask-log-workspace-${random_string.suffix.result}"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  sku                 = "PerGB2018"
}

# Monitoring: Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "app_service_diagnostics" {
  name                       = "flask-app-diagnostics"
  target_resource_id         = azurerm_linux_web_app.flask_app_service.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id

  log {
    category = "AppServiceHTTPLogs"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
