variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}
variable "docker_image" {
    default = "nginx:latest"
}
variable "location" {
  default = "France Central" 
}
