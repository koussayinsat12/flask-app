output "app_service_url" {
  value = azurerm_app_service.flask_app_service.default_site_hostname
}
