# Define the provider
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id = "Azure Subscription ID"  # Set your Azure Subscription ID here
}

resource "random_id" "web_app" {
  byte_length = 4
}

resource "random_id" "app_service" {
  byte_length = 4
}

resource "random_id" "db_server" {
  byte_length = 4
}

resource "azurerm_resource_group" "main" {
  name     = "kml_rg_main-dc4b08f52add4871"
  location = "East US"  # Update this based on your region
  lifecycle {
    ignore_changes = [
      name,
      location
    ]
  }
}

# Web Tier: Azure App Service (Low-Cost)
resource "azurerm_app_service_plan" "web_plan" {
  name                = "web-service-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Free"  # Or "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "web_app" {
  name                     = "web-app-${random_id.web_app.hex}"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  app_service_plan_id      = azurerm_app_service_plan.web_plan.id
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "14"
  }
}

# App Tier: Azure App Service (Low-Cost)
resource "azurerm_app_service_plan" "app_plan" {
  name                = "app-service-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Free"  # Or "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "app_service" {
  name                     = "app-service-${random_id.app_service.hex}"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  app_service_plan_id      = azurerm_app_service_plan.app_plan.id
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "14"
  }
}

# Database Tier: Azure SQL Database (Low-Cost Basic SKU)
resource "azurerm_mssql_server" "db_server" {
  name                         = "db-server-${random_id.db_server.hex}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "ComplexPassword123!"  # Ensure password complexity
  
}

resource "azurerm_mssql_database" "db" {
  name             = "db"
  server_id        = azurerm_mssql_server.db_server.id
  sku_name         = "Basic"
  max_size_gb      = 5  # Set database size to be within policy (50 GB or less)
    zone_redundant      = false
 
  }