#!/bin/bash

# Prompt user for parameters
read -p "Enter namespace (default: user01): " NAMESPACE
NAMESPACE=${NAMESPACE:-user01}

read -p "Enter image organization (default: hiondal): " IMAGE_ORG
IMAGE_ORG=${IMAGE_ORG:-hiondal}

read -p "Enter image version (default: 1.0.0): " IMAGE_VERSION
IMAGE_VERSION=${IMAGE_VERSION:-1.0.0}

# Override default values with provided arguments
NAMESPACE="$1"
IMAGE_ORG="$2"
IMAGE_VERSION="$3"

# Define the deploy directory
DEPLOY_DIR="deploy"

# List of yaml files to process
yaml_files=("${DEPLOY_DIR}/config.yaml" "${DEPLOY_DIR}/eureka.yaml" "${DEPLOY_DIR}/front.yaml" "${DEPLOY_DIR}/scg.yaml" "${DEPLOY_DIR}/subrecommend.yaml")

# Update namespace and ingress host in all yaml files
for file in "${yaml_files[@]}"; do
  sed -i'' "s/user00/${NAMESPACE}/g" "$file"
done

# Update image full path in each yaml file
sed -i'' "s@docker.io/hiondal/.*@docker.io/${IMAGE_ORG}/config:${IMAGE_VERSION}@g" ${DEPLOY_DIR}/config.yaml
sed -i'' "s@docker.io/hiondal/.*@docker.io/${IMAGE_ORG}/eureka:${IMAGE_VERSION}@g" ${DEPLOY_DIR}/eureka.yaml
sed -i'' "s@docker.io/hiondal/.*@docker.io/${IMAGE_ORG}/subride-front:${IMAGE_VERSION}@g" ${DEPLOY_DIR}/front.yaml
sed -i'' "s@docker.io/hiondal/.*@docker.io/${IMAGE_ORG}/scg:${IMAGE_VERSION}@g" ${DEPLOY_DIR}/scg.yaml
sed -i'' "s@docker.io/hiondal/.*@docker.io/${IMAGE_ORG}/subrecommend:${IMAGE_VERSION}@g" ${DEPLOY_DIR}/subrecommend.yaml

# Notify the user that the changes are complete
echo "################ Completed ######################"
echo "Namespace, ingress host, and image paths updated successfully."

echo "################ 주의사항 #######################"
echo "config.yaml의ConfigMap과Secret 정의 수정 필요 "
echo "Git 관련 설정값 변경: GIT_URL, GIT_USERNAME, GIT_TOKEN"

