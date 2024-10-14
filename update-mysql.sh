#!/bin/bash

# Prompt user for parameters
read -p "Enter namespace (default: user01): " NAMESPACE
NAMESPACE=${NAMESPACE:-user01}

# Define the deploy directory
DEPLOY_DIR="mysql"

sed -i'' "s/user[0-9]\{2\}/${NAMESPACE}/g" "${DEPLOY_DIR}/mysql.yaml"

echo "Updated successfully."

