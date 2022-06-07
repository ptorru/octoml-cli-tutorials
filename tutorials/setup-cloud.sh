#!/bin/bash
set -eu

function install_aws {
    # Install aws cli if not already installed
    if ! command -v aws &> /dev/null; then
        rm -f awscliv2.zip
        curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        rm -fr aws
        unzip awscliv2.zip
        sudo ./aws/install
    fi
}

function install_gcloud {
    # Install gcloud cli if not already installed
    if ! command -v gcloud &> /dev/null; then
        rm -f google-cloud-cli-387.0.0-linux-x86_64.tar.gz
        curl -fsSL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-387.0.0-linux-x86_64.tar.gz -o google-cloud-cli.tar.gz
        rm -rf google-cloud-sdk
        tar -xf google-cloud-cli.tar.gz
        ./google-cloud-sdk/install.sh
    fi
}

function install_azure {
    # Install azure cli if not already installed
    if ! command -v az &> /dev/null; then
        curl -fsSL https://aka.ms/InstallAzureCli -o azure-cli.sh
        bash azure-cli.sh
    fi
}

echo "Choose a cloud cli to install:"
select tool in aws gcloud azure; do
    case $tool in
        aws ) install_aws; break;;
        gcloud ) install_gcloud; break;;
        azure ) install_azure; break;;
        * ) break;;
    esac
done

# Install kubectl if not already installed
if ! command -v kubectl &> /dev/null; then
    curl -fsSL -O "https://dl.k8s.io/release/v1.22.0/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

# Install helm if not already installed
if ! command -v helm &> /dev/null; then
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
fi
