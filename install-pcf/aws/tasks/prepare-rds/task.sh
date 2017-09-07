#!/bin/bash
set -eu

echo "$PEM" > pcf.pem
chmod 0600 pcf.pem

output_json=$(terraform output --json -state terraform-state/terraform.tfstate)

db_host=$(echo $output_json | jq --raw-output '.db_host.value')
db_username=$(echo $output_json | jq --raw-output '.db_username.value')
db_password=$(echo $output_json | jq --raw-output '.db_password.value')

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

scp -i pcf.pem -o StrictHostKeyChecking=no databases.sql "ubuntu@${OPSMAN_DOMAIN_OR_IP_ADDRESS}:/tmp/."
ssh -i pcf.pem -o StrictHostKeyChecking=no "ubuntu@${OPSMAN_DOMAIN_OR_IP_ADDRESS}" "mysql -h $db_host -u $db_username -p$db_password < /tmp/databases.sql"
