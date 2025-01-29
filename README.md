# Azure_3_tier_app_terraform
Deploy 3 tier app using Terraform in azure

Resource Group: Defines the container for all resources.
App Services: Two separate App Services are defined, one for a web app and the other for an application, both using free-tier App Service Plans in Linux.
SQL Server and Database: A SQL Server and a basic database are defined, with a 5GB size limit.



1. Provider Configuration:
hcl
Copy
Edit
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id = "Azure Subscription ID"  # Set your Azure Subscription ID here
}
This configures the Azure Resource Manager (azurerm) provider. The features {} block is a required but empty configuration for the provider.
resource_provider_registrations = "none" means that no resource provider registration is happening for this provider. This could be useful in scenarios where the provider is already registered.
subscription_id should be set to your actual Azure subscription ID, so the resources are deployed under the correct account.
2. Random ID Resources:
hcl
Copy
Edit
resource "random_id" "web_app" {
  byte_length = 4
}

resource "random_id" "app_service" {
  byte_length = 4
}

resource "random_id" "db_server" {
  byte_length = 4
}
The random_id resources generate random IDs, each with a byte length of 4. These are used for generating unique names for the web app, app service, and database server.
random_id.web_app.hex, random_id.app_service.hex, and random_id.db_server.hex generate unique suffixes for the resource names.
3. Resource Group Configuration:
hcl
Copy
Edit
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
This defines an Azure Resource Group where all resources will be placed.
The lifecycle block with ignore_changes ensures that Terraform ignores any changes to the name or location of the resource group once it's created.
4. Web Tier (Azure App Service - Web Application):
App Service Plan (Linux):
hcl
Copy
Edit
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
The App Service Plan defines the environment for hosting the web application. It's a Linux-based plan with a free tier (Free tier and B1 size), which is suitable for low-cost applications or development environments.
Web Application:
hcl
Copy
Edit
resource "azurerm_app_service" "web_app" {
  name                     = "web-app-${random_id.web_app.hex}"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  app_service_plan_id      = azurerm_app_service_plan.web_plan.id
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "14"
  }
}
App Service (Web Application): The azurerm_app_service resource deploys a web application to the Azure App Service using the plan defined earlier.
It uses the unique name (web-app-${random_id.web_app.hex}) and the environment defined in the App Service Plan. The app is configured to use Node.js version 14.
5. App Tier (Azure App Service - Application):
App Service Plan (Linux):
hcl
Copy
Edit
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
Another App Service Plan for hosting an application, also in Linux, with the same free-tier configuration.
App Service (Application):
hcl
Copy
Edit
resource "azurerm_app_service" "app_service" {
  name                     = "app-service-${random_id.app_service.hex}"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  app_service_plan_id      = azurerm_app_service_plan.app_plan.id
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "14"
  }
}
This is another App Service resource for hosting an application, similar to the web app, but this time with a different unique name (app-service-${random_id.app_service.hex}).
6. Database Tier (Azure SQL Database):
SQL Server (Azure SQL Database):
hcl
Copy
Edit
resource "azurerm_mssql_server" "db_server" {
  name                         = "db-server-${random_id.db_server.hex}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "ComplexPassword123!"  # Ensure password complexity
}
SQL Server: This resource defines an Azure SQL Server to host a database.
It uses a unique name for the server (db-server-${random_id.db_server.hex}) and sets the version to 12.0 (SQL Server 2017).
The administrator login and password are specified, but ensure the password meets Azure's complexity requirements.
SQL Database:
hcl
Copy
Edit
resource "azurerm_mssql_database" "db" {
  name             = "db"
  server_id        = azurerm_mssql_server.db_server.id
  sku_name         = "Basic"
  max_size_gb      = 5  # Set database size to be within policy (50 GB or less)
  zone_redundant   = false
}
SQL Database: This resource creates a database on the SQL Server defined earlier.
It uses the Basic SKU for a low-cost option and sets a maximum size of 5GB for the database.
zone_redundant = false means that the database will not be zone redundant (not multi-zone).
