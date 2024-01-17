#!/bin/bash

set -x
export TF_LOG="Debug"
export TF_LOG_PATH="./terraform.log"

ENV=prod
TF_PLAN="${ENV}.tfplan"


if command -v checkov &>/dev/null; then
    echo "Checkov is already installed."
else
    echo "Checkov is not installed. Installing with brew..."
    brew install checkov
    if [ $? -eq 0 ]; then
        echo "Checkov has been installed successfully."
    else
        echo "Error: Failed to install Checkov with brew."
        exit 1
    fi
fi


[ -d .terraform ] && rm -rf .terraform
rm -f *.tfplan
sleep 2


terraform fmt -recursive
terraform init
terraform validate
terraform plan -out="${TF_PLAN}"

terraform fmt -recursive
terraform init
terraform plan -out="${TF_PLAN}"
terraform show -json ${TF_PLAN} | jq '.' > ${TF_PLAN}.json
checkov -f ${TF_PLAN}.json


if [ "$?" -eq "0" ]; then
    echo "Your configuration is valid"
else
    echo "Your code needs some work!"
    exit 1
fi

terraform plan -out="${TF_PLAN}"

if [ ! -f "${TF_PLAN}" ]; then
    echo "***The plan does not exit. Exiting***"
    exit 1
fi

