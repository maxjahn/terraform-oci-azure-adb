#!/bin/sh

. ../infrastructure-setup/resources/atp_env.sh

oci db autonomous-database generate-wallet --autonomous-database-id "${ATP_OCID}" --password "${ATP_WALLET_PASS}" --file wallet.zip --region "${TF_VAR_oci_region}"

echo "
wallet.zip should now be copied to your current directory. Next steps:

(1) Transfer wallet.zip to your target host using scp.
(2) On the target host unzip wallet.zip.
(3) On the target host Edit sqlnet.ora and replace ?/network/admin with the directory tnsnames.ora resides, e.g. /home/azure
(4) On the target host set environment variable TNS_ADMIN to the directory tnsnames.ora resides, e.g.
\t\e[92mexport TNS_ADMIN=/home/azure\e[39m
(5) On the target host connect to Autonomous DB with
\t\e[92msqlplus admin/${TF_VAR_oci_atp_admin_password}@${TF_VAR_oci_atp_db_name}_tp\e[39m
"

