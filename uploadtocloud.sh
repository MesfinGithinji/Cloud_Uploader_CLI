#!/bin/bash

check_for_azure_CLI() {
    if command -v az &>/dev/null; then
        echo "Azure CLI is already installed."
    else
        echo "Azure CLI not found. Commencing install..."
        #install_azure_CLI
    fi
}

install_azure_CLI() {
    echo "Installing Azure CLI..."
    if curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash; then
        echo "Azure CLI installed successfully."
    else
        echo "Error: Failed to install Azure CLI."
        exit 1
    fi
}

login_with_service_principal() {
    #declare variables here

    echo "Logging in with Azure service principal..."
    if az login --service-principal --username $appid --password $secret --tenant $tenantid; then
        echo "Successfully authenticated with Azure service principal."
    else
        echo "Error: Failed to authenticate with Azure service principal."
        exit 1
    fi
}

upload_file_to_azure_storage() {
    container_name=$1
    file_path=$2

    if [ -z "$container_name" ] || [ -z "$file_path" ]; then
        echo "Error: Container name and file path must be provided as arguments."
        exit 1
    fi

    echo "Uploading file to Azure Storage..."
    if az storage blob upload --account-name mesh1 --container-name "$container_name" --name "$(basename $file_path)" --type block --content-type "application/octet-stream" --type block --max-connections 5 --auth-mode login -f "$file_path"; then
        echo "\nFile uploaded successfully to this container: '$container_name'."
        echo "Uploaded file path: https://<storage_account_name>.blob.core.windows.net/$container_name/$(basename $file_path)"
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

