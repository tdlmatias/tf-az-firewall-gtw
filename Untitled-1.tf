
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "zerotrust" {
  name     = "zerotrust-rg"
  location = "westus"
}

resource "azurerm_virtual_network" "app-vnet" {
  name     = "app-vnet"
  location = azurerm_resource_group.zerotrust.location
  address_prefixes = ["10.0.0.0/16"]

  subnet {
    name         = "app-subnet"
    address_prefix = "10.0.1.0/24"
  }
}

resource "azurerm_application_gateway" "app-gw" {
  name     = "app-gw"
  location = azurerm_resource_group.zerotrust.location
  capacity = 2

  frontend_port {
    name     = "http"
    port     = 80
    protocol = "Http"
  }

  frontend_port {
    name     = "https"
    port     = 443
    protocol = "Https"
  }

  backend_address_pool {
    name = "app-backend-pool"
  }

  frontend_ip_configuration {
    name   = "app-frontend-ip"
    public_ip_address_id = null
  }

  listener {
    name                 = "http-listener"
    protocol             = "Http"
    frontend_port_name   = "http"
    frontend_ip_config_name = "app-frontend-ip"
  }

  listener {
    name                 = "https-listener"
    protocol             = "Https"
    frontend_port_name   = "https"
    frontend_ip_config_name = "app-frontend-ip"
  }

  request_routing_rule {
    name         = "app-http-rule"
    listener_name = "http-listener"
    backend_address_pool_name = "app-backend-pool"
    backend_http_setting_name = "app-http-setting"
  }

  request_routing_rule {
    name         = "app-https-rule"
    listener_name = "https-listener"
    backend_address_pool_name = "app-backend-pool"
    backend_http_setting_name = "app-https-setting"
  }

  backend_http_setting {
    name         = "app-http-setting"
    idle_timeout_in_minutes = 10

    path_rule {
      name         = "app-rule"
      path_patterns = ["/*"]
      backend_pool_name = "app-backend-pool"
      backend_http_setting_name = "app-http-setting"
    }
  }

  backend_http_setting {
    name         = "app-https-setting"
    idle
  }
}