#!/bin/bash
set -e

echo "$PEM" > pcf.pem
chmod 0600 pcf.pem

CWD=$(pwd)
pushd $CWD
  cd pcf-pipelines/install-pcf/aws/terraform/
  cp $CWD/terraform-state/terraform.tfstate .

  while read -r line
  do
    `echo "$line" | awk '{print "export "$1"="$3}'`
  done < <(terraform output -state *.tfstate)

  export RDS_PASSWORD=`terraform state show aws_db_instance.pcf_rds | grep ^password | awk '{print $3}'`
popd

cat > databases.sql <<EOF
CREATE DATABASE IF NOT EXISTS console;

CREATE DATABASE IF NOT EXISTS locket;
GRANT ALL ON locket.* TO '$DB_LOCKET_USERNAME'@'%' IDENTIFIED BY '$DB_LOCKET_PASSWORD';

CREATE DATABASE IF NOT EXISTS silk;
GRANT ALL ON silk.* TO '$DB_SILK_USERNAME'@'%' IDENTIFIED BY '$DB_SILK_PASSWORD';

CREATE DATABASE IF NOT EXISTS uaa;
GRANT ALL ON uaa.* TO '$DB_UAA_USERNAME'@'%' IDENTIFIED BY '$DB_UAA_PASSWORD';

CREATE DATABASE IF NOT EXISTS ccdb;
GRANT ALL ON ccdb.* TO '$DB_CCDB_USERNAME'@'%' IDENTIFIED BY '$DB_CCDB_PASSWORD';

CREATE DATABASE IF NOT EXISTS notifications;
GRANT ALL ON notifications.* TO '$DB_NOTIFICATIONS_USERNAME'@'%' IDENTIFIED BY '$DB_NOTIFICATIONS_PASSWORD';

CREATE DATABASE IF NOT EXISTS autoscale;
GRANT ALL ON autoscale.* TO '$DB_AUTOSCALE_USERNAME'@'%' IDENTIFIED BY '$DB_AUTOSCALE_PASSWORD';

CREATE DATABASE IF NOT EXISTS app_usage_service;
GRANT ALL ON app_usage_service.* TO '$DB_APP_USAGE_SERVICE_USERNAME'@'%' IDENTIFIED BY '$DB_APP_USAGE_SERVICE_PASSWORD';

CREATE DATABASE IF NOT EXISTS routing;
GRANT ALL ON routing.* TO '$DB_ROUTING_USERNAME'@'%' IDENTIFIED BY '$DB_ROUTING_PASSWORD';

CREATE DATABASE IF NOT EXISTS diego;
GRANT ALL ON diego.* TO '$DB_DIEGO_USERNAME'@'%' IDENTIFIED BY '$DB_DIEGO_PASSWORD';

CREATE DATABASE IF NOT EXISTS account;
GRANT ALL ON account.* TO '$DB_ACCOUNTDB_USERNAME'@'%' IDENTIFIED BY '$DB_ACCOUNT_PASSWORD';

CREATE DATABASE IF NOT EXISTS nfsvolume;
GRANT ALL ON nfsvolume.* TO '$DB_NFSVOLUMEDB_USERNAME'@'%' IDENTIFIED BY '$DB_NFSVOLUMEDB_PASSWORD';

CREATE DATABASE IF NOT EXISTS networkpolicyserver;
GRANT ALL ON networkpolicyserver.* TO '$DB_NETWORKPOLICYSERVERDB_USERNAME'@'%' IDENTIFIED BY '$DB_NETWORKPOLICYSERVERDB_PASSWORD';
EOF

scp -i pcf.pem -o StrictHostKeyChecking=no databases.sql ubuntu@opsman.${ERT_DOMAIN}:/tmp/.
ssh -i pcf.pem -o StrictHostKeyChecking=no ubuntu@opsman.${ERT_DOMAIN} "mysql -h $db_host -u $db_username -p$RDS_PASSWORD < /tmp/databases.sql"
