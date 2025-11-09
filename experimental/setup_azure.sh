#!/usr/bin/env bash
# setup_azure.sh — creates full bookstore stack

# -----------------------------
# Variables (change as needed)
# -----------------------------
RG="bookstore-rg"
LOCATION="northeurope"
APP_SERVICE_PLAN="bookstore-plan"
WEBAPP_NAME="bookstore-api-$RANDOM"
STATICAPP_NAME="bookstore-web-$RANDOM"
STORAGE_NAME="bookstorestorage$RANDOM"
DB_NAME="bookstoredb"
ADMIN_USER="pgadmin"
# replace with a strong password before running script
ADMIN_PASS="7elwaEldonia632!"
CONTAINER_NAME="book-images"

# -----------------------------
# Resource group
# -----------------------------
echo "▶️ Creating resource group..."
az group create --name $RG --location $LOCATION

# -----------------------------
# Storage account
# -----------------------------
echo "▶️ Creating storage account..."
az storage account create \
  --name $STORAGE_NAME \
  --resource-group $RG \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2

# Get storage key
STORAGE_KEY=$(az storage account keys list \
  --resource-group $RG \
  --account-name $STORAGE_NAME \
  --query "[0].value" -o tsv)

# Create a blob container for images Failed
echo "▶️ Creating blob container..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_NAME \
  --account-key $STORAGE_KEY \
  --auth-mode key \
  --public-access blob

# -----------------------------
# Web App (API)
# -----------------------------
#echo "▶️ Creating App Service plan..."
#az appservice plan create \
#  --name $APP_SERVICE_PLAN \
#  --resource-group $RG \
#  --sku F1 \
#  --is-linux
#
#echo "▶️ Creating Node.js web app..."
#az webapp create \
#  --resource-group $RG \
#  --plan $APP_SERVICE_PLAN \
#  --name $WEBAPP_NAME \
#  --runtime "NODE:20-lts"

# -----------------------------
# PostgreSQL database
# -----------------------------
#echo "▶️ Creating PostgreSQL Flexible Server..."
#az postgres flexible-server create \
#  --name $DB_NAME \
#  --resource-group $RG \
#  --location $LOCATION \
#  --admin-user $ADMIN_USER \
#  --admin-password $ADMIN_PASS \
#  --tier Burstable \
#  --sku-name Standard_B1ms \
#  --storage-size 32 \
#  --version 17 \
#  --public-access 0.0.0.0-255.255.255.255

# Get the database connection string
#DB_HOST="${DB_NAME}.postgres.database.azure.com"
#DB_URL="postgresql://${ADMIN_USER}:${ADMIN_PASS}@${DB_HOST}:5432/${DB_NAME}?sslmode=require"

# Set it as environment variable for the API
#echo "▶️ Setting environment variables for Web App..."
#az webapp config appsettings set \
#  --name $WEBAPP_NAME \
#  --resource-group $RG \
#  --settings \
#  DATABASE_URL=$DB_URL \
#  AZURE_STORAGE_ACCOUNT="$STORAGE_NAME" \
#  AZURE_STORAGE_KEY="$STORAGE_KEY" \
#  BLOB_CONTAINER_NAME="$CONTAINER_NAME" \
#  NODE_ENV="production"

# -----------------------------
# Static Web App (Frontend)
# -----------------------------
#echo "▶️ Creating Static Web App..."
#az staticwebapp create \
#  --name $STATICAPP_NAME \
#  --resource-group $RG \
#  --source https://github.com/Sci-Studio/bookstore.webgui \
#  --branch main \
#  --location $LOCATION \
#  --app-location "/" \
#  --output-location "dist" \
#  --sku Free

# -----------------------------
# Summary
# -----------------------------
echo "✅ Deployment complete!"
echo "--------------------------------------------"
echo "Frontend: https://${STATICAPP_NAME}.z01.web.core.windows.net"
echo "API:      https://${WEBAPP_NAME}.azurewebsites.net"
echo "Database: $DB_HOST"
echo "Blob:     https://${STORAGE_NAME}.blob.core.windows.net/$CONTAINER_NAME"
echo ""
echo "Environment variables set on Web App:"
echo " - DATABASE_URL"
echo " - AZURE_STORAGE_ACCOUNT"
echo " - AZURE_STORAGE_KEY"
echo " - BLOB_CONTAINER_NAME"
echo ""
echo "✅ Done!"