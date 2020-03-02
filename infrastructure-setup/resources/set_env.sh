### oci
export TF_VAR_oci_tenancy_ocid="ocid1.tenancy.xxxxxxxxxxxx"
export TF_VAR_oci_user_ocid="ocid1.user.oc1.xxxxxxxxx"
export TF_VAR_oci_compartment_ocid="ocid1.compartment.oc1.xxxxxxxxx"
export TF_VAR_oci_fingerprint=xxxxxxxxxxxxxxx
export TF_VAR_oci_private_key_path=.oci/oci_api_key.pem
export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)

export TF_VAR_oci_region=eu-amsterdam-1

# generate a password, e.g. using
# apg -m 12 -n 1 -M SCNL 
export TF_VAR_oci_atp_admin_password=""
export ATP_WALLET_PASS=""

export TF_VAR_oci_atp_db_name="demodb"
export TF_VAR_oci_atp_db_displayname="demo-db"
export TF_VAR_oci_atp_db_workload="OLTP"
export TF_VAR_oci_atp_db_cores="1"
export TF_VAR_oci_atp_db_storage_tb="1"

export TF_VAR_oci_azure_provider_ocid="ocid1.providerservice.oc1.eu-amsterdam-1.aaaaaaaa63ndgdif5mke7gvq57hxmqhyg3cg2szzb3zseroieonof35fyajq"

export TF_VAR_oci_service_vcn_cidr="10.0.0.0/16"
export TF_VAR_oci_client_subnet_cidr="10.0.1.0/24"
export TF_VAR_peering_net="10.99.0"

# centos7 
export TF_VAR_oci_base_image="ocid1.image.oc1.eu-amsterdam-1.aaaaaaaat32fvq5hsmbljrvy77gr2xel7i3l3oc6g3bcnnd6mimzz5jqa7ka"

## Azure
export TF_VAR_arm_client_id="xxxxxxxxxxxxxx"
export TF_VAR_arm_client_secret="xxxxxxxxxxxxxx"
export TF_VAR_arm_tenant_id="xxxxxxxxxxxx"
export TF_VAR_arm_subscription_id="xxxxxxxxxxxx"
export TF_VAR_arm_region="West Europe"

export TF_VAR_arm_vnet_cidr="10.1.0.0/16"
export TF_VAR_arm_client_subnet_cidr="10.1.1.0/24"
export TF_VAR_arm_gw_subnet_cidr="10.1.99.0/24"

# vm image to use, make sure that it supports cloud-init!
# Centos 7
export TF_VAR_arm_image_publisher="OpenLogic"
export TF_VAR_arm_image_offer="CentOS-CI"
export TF_VAR_arm_image_sku="7-CI"
export TF_VAR_arm_image_version="latest"

# use Standard or UltraPerformance (which will enable fastpath)
export TF_VAR_arm_expressroute_sku="Standard"
#export TF_VAR_arm_expressroute_sku="UltraPerformance"

