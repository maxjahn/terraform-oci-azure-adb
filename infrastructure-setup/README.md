# Instructions for setting environment up using terraform

## Environment Variables

The file resources/set_env.sh contains a couple of environment variables that need to be set. Before starting terraform source this file (`. resources/set_env.sh`). The following variables need to be adapted.

### General

`TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)`

### OCI

`TF_VAR_oci_tenancy_ocid="ocid1.tenancy.oc1.."`

`TF_VAR_oci_user_ocid="ocid1.user.oc1.."`

`TF_VAR_oci_compartment_ocid="ocid1.compartment.oc1.."`

`TF_VAR_oci_fingerprint= ...`

`TF_VAR_oci_private_key_path=.oci/oci_api_key.pem`

### Azure

`TF_VAR_arm_client_id= ...`

`TF_VAR_arm_client_secret= ...`

`TF_VAR_arm_tenant_id= ...`

`TF_VAR_arm_subscription_id= ...`

`TF_VAR_arm_expressroute_sku="..."` default value "Standard". Use "Ultraperformance" to see FastPath feature enabled.

### Interconnect Region

To use a different region (e.g. Ashburn/Washington DC or Toronto) some values need to be changed. In OCI several resources are dependent on the region, so you have to look up the proper OCIDs and use these values. 

`TF_VAR_oci_region=eu-amsterdam-1`

`TF_VAR_arm_region="West Europe"`

`TF_VAR_arm_expressroute_peering_location="Amsterdam2"`

`TF_VAR_oci_base_image= ...` base image to use for OCI VMs created. Make sure to use an image with an OCID for the region you are trying to set up the interconnect in.

`TF_VAR_oci_azure_provider_ocid= ...` OCID of Azure provider in the region. Look this up using OCI CLI `oci network fast-connect-provider-service list --compartment-id YOUR_COMPARTMENT_OCID --region REGION --all`

## Caveats

- There is an issue with public IPs assignment in Azure. These will be assigned only after the VNICs are using these IPs and therefore might not be available to the terraform scripts in time. In case your `terraform apply` fails, just repeat this step.
- When tearing down the infrastructure there is an issue that FastConnect will be in FAILED state and not in TERMINATED state as expected by terraform. In this case you need to terminate/delete the FastConnect circuit and the DRG manually in OCI GUI. You also will need to tear down the ExpressRoute circuit manually in Azure UI, or just delete the whole resource group.

