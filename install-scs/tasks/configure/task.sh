#!/bin/bash
set -eu

export OPSMAN_DOMAIN_OR_IP_ADDRESS="opsman.$pcf_ert_domain"

cf_network=$(
  jq -n \
    --arg iaas $pcf_iaas \
    --arg singleton_availability_zone "$pcf_az_1" \
    --arg other_availability_zones "$pcf_az_1,$pcf_az_2,$pcf_az_3" \
    '
    {
      "network": {
        "name": (if $iaas == "aws" then "deployment" else "ert" end),
      },
      "other_availability_zones": ($other_availability_zones | split(",") | map({name: .})),
      "singleton_availability_zone": {
        "name": $singleton_availability_zone
      }
    }
    '
)

cf_resources='
    {
      "deploy-service-broker": {"internet_connected": false},
      "register-service-broker": {"internet_connected": false},
      "run-smoke-tests": {"internet_connected": false},
      "destroy-service-broker": {"internet_connected": false}
    }
    '


cf_properties='
    {
      ".properties.deploy-service-broker.broker_max_instances": { "value": 100 },
      ".properties.deploy-service-broker.buildpack": { "value": "" },
      ".properties.deploy-service-broker.disable_cert_check": { "value": false },
      ".properties.deploy-service-broker.instances_app_push_timeout": { "value": "" },
      ".properties.register-service-broker.enable_global_access": { "value": true },
    }
    '

om-linux \
  --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
  --username $OPS_MGR_USR \
  --password $OPS_MGR_PWD \
  --skip-ssl-validation \
  configure-product \
  --product-name cf \
  --product-properties "$cf_properties" \
  --product-network "$cf_network" \
  --product-resources "$cf_resources"
