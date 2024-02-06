#!/bin/bash

#Function checks if the Azure CLI tool has been installed.
check_for_azure_CLI() {
    if command -v az &>/dev/null; then
        echo "Azure CLI is already installed."
    else
        echo "Azure CLI not found. Commencing install..."
        install_azure_CLI
    fi
}

#This function will only be called if the Azure CLI tool is not present and requires an install
install_azure_CLI() {
    echo "Installing Azure CLI..."
    if curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash; then
        echo "Azure CLI installed successfully."
    else
        echo "Error: Failed to install Azure CLI."
        exit 1
    fi
}

#Azure service principal is the prefered method for both authorisation and authentication
login_with_service_principal() {
    # Get values from ENV variables here
    local appid=$SP_APP_ID
    local tenantid=$SP_TENANT_ID
    local secret=$SP_PASSWORD

    echo "Logging in with Azure service principal..."
    if az login --service-principal --username $appid --password $secret --tenant $tenantid ; then
        echo "Successfully authenticated with Azure service principal."
    else
        echo "Error: Failed to authenticate with Azure service principal."
        exit 1
    fi
}

#The script takes two arguments 
#The first is the containername where you want your Blob to go into
#The second is the path to your file(Blob)
upload_file_to_azure_storage() {
    container_name=$1
    file_path=$2

    if [ -z "$container_name" ] || [ -z "$file_path" ]; then
        echo "Error: Container name and file path must be provided as arguments."
        exit 1
    fi

    echo "Uploading file to Azure Storage..."
    if az storage blob upload --account-name mesh1 --container-name "$container_name" --name "$(basename $file_path)" --type block --content-type "application/octet-stream" --type block --max-connections 5 --auth-mode login -f "$file_path" ; then
        echo "File uploaded successfully to this container: '$container_name'."
        # Get the upload URL
        upload_url=$(az storage blob url --account-name mesh1 --container-name "$container_name" --name "$(basename "$file_path")" --auth-mode login --output tsv)
        echo "Uploaded file URL: $upload_url"
    else
        echo "Error: Failed to upload file to Azure Storage."
        exit 1
    fi
}

# lets call our functions
check_for_azure_CLI
login_with_service_principal
upload_file_to_azure_storage "$1" "$2"

# Script completed successfully
exit 0
