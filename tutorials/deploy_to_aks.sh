#!/bin/bash
set -eu

MODEL_NAME=$1
SUBSCRIPTION_ID=$2
DOCKER_IMAGE_TAG=$3
CLUSTER_NAME=$4
RESOURCE_GROUP_NAME=$5

registry="${MODEL_NAME}.azurecr.io/${MODEL_NAME}"

# Create ACR registry for $MODEL_NAME if it doesn't already exist
if ! az acr list --resource-group "$RESOURCE_GROUP_NAME" --subscription "$SUBSCRIPTION_ID" | grep "$MODEL_NAME"; then
    az acr create --resource-group "$RESOURCE_GROUP_NAME" --name "$MODEL_NAME" --sku Basic --subscription "$SUBSCRIPTION_ID"
fi

# Docker login:
az acr login --name "$MODEL_NAME" --subscription "$SUBSCRIPTION_ID"

# Attach ACR to AKS cluster for image pull authentication
az aks update -n "$CLUSTER_NAME" -g "$RESOURCE_GROUP_NAME" --attach-acr "$MODEL_NAME"

# Get image name from container generated by cli package + Tag the local image with its corresponding repository hostname
docker tag "${MODEL_NAME}:latest" "${registry}:${DOCKER_IMAGE_TAG}"

# Check if image tag exists
if ! az acr repository show-tags --name "$MODEL_NAME" --repository "$MODEL_NAME" --subscription "$SUBSCRIPTION_ID" | grep "$DOCKER_IMAGE_TAG"; then
  # Push docker image to ECR
  docker push "${registry}:${DOCKER_IMAGE_TAG}"
fi

# Confirm that image got pushed
az acr repository show-tags --name "$MODEL_NAME" --repository "$MODEL_NAME" --subscription "$SUBSCRIPTION_ID" | grep "$DOCKER_IMAGE_TAG"

# Set kubectl context to azure aks cluster
az aks get-credentials --resource-group "$RESOURCE_GROUP_NAME" --name "$CLUSTER_NAME"

cat << EOF > "values-${MODEL_NAME}.yaml"
imageName: $registry
imageTag: $DOCKER_IMAGE_TAG
imagePullSecret:
EOF

# Install helm chart to the AKS cluster via helm
if ! helm repo list | grep octoml-cli-tutorials; then
  helm repo add octoml-cli-tutorials https://octoml.github.io/octoml-cli-tutorials
fi

helm repo update octoml-cli-tutorials

helm install "$MODEL_NAME" octoml-cli-tutorials/demo -n "$MODEL_NAME" --create-namespace --values "values-${MODEL_NAME}.yaml" --atomic --timeout 7m

rm "values-$MODEL_NAME.yaml"