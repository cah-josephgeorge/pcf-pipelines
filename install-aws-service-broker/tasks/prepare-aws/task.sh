#!/bin/bash

set -ex

terraform plan \
  -state terraform-state/terraform.tfstate \
  -var "prefix=${TERRAFORM_PREFIX}" \
  -out terraform.tfplan \
  pcf-pipelines/install-aws-service-broker/terraform

terraform apply \
  -state-out terraform-state-output/terraform.tfstate \
  terraform.tfplan
