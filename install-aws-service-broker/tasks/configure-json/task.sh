#!/bin/bash

set -e

json_file_template="pcf-pipelines/install-aws-service-broker/tasks/configure-json/aws-template.json"

if [ ! -f "$json_file_template" ]; then
  echo "Error: can't find file=[${json_file_template}]"
  exit 1
fi

json_file="json_file/aws.json"

cp ${json_file_template} ${json_file}

OPS_MGR_HOST="opsman.$pcf_ert_domain"
OPS_MGR_USR="$pcf_opsman_admin"
OPS_MGR_PWD="$pcf_opsman_admin_passwd"

sed -i \
  -e "s/{{pcf_az_1}}/${pcf_az_1}/g" \
  -e "s/{{pcf_az_2}}/${pcf_az_2}/g" \
  -e "s/{{pcf_az_3}}/${pcf_az_3}/g" \
  -e "s/{{pcf_ert_domain}}/${pcf_ert_domain}/g" \
  -e "s/{{terraform_prefix}}/${terraform_prefix}/g" \
  -e "s/{{db_aws_service_broker_username}}/${db_aws_service_broker_username}/g" \
  -e "s/{{db_aws_service_broker_password}}/${db_aws_service_broker_password}/g" \
  ${json_file}

db_creds=(
  db_aws_service_broker_username
  db_aws_service_broker_password
)

for i in "${db_creds[@]}"
do
   eval "templateplaceholder={{${i}}}"
   eval "varname=\${$i}"
   eval "varvalue=$varname"
   echo "replacing value for ${templateplaceholder} in ${json_file} with the value of env var:${varname} "
   sed -i -e "s/$templateplaceholder/${varvalue}/g" ${json_file}
done
