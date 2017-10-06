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
      "mysql": {"internet_connected": false},
      "backup-prepare": {"internet_connected": false},
      "proxy": {"internet_connected": false},
      "monitoring": {"internet_connected": false},
      "cf-mysql-broker": {"internet_connected": false},
      "broker-registrar": {"internet_connected": false},
      "deregister-and-purge-instances": {"internet_connected": false},
      "rejoin-unsafe": {"internet_connected": false},
      "smoke-tests": {"internet_connected": false},
      "bootstrap": {"internet_connected": false}
    }
    '

cf_properties='
   {
    ".properties.backup_options": { "value": "disable" },
    ".properties.backups": {"value": "disable" },
    ".properties.optional_protections": { "value": "enable" },
    ".properties.optional_protections.enable.recipient_email": { "value": "G-Fuse-CoreDM@cardinalhealth.com" },
    ".properties.syslog": { "value": "enabled" },
    ".properties.syslog.enabled.address": { "value": "dev-cflogstash.cahcommtech.com" },
    ".properties.syslog.enabled.port": { "value": 1514 }
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
