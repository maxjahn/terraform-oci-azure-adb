output "ADB_conn_strings" {
  value = ["${module.autonomous-db.conn_strings}"]
}

output "ADB_conn_urls" {
  value = ["${module.autonomous-db.conn_urls}"]
}

output "ADB_OCID" {
  value = "${module.autonomous-db.atp_ocid}"
}

resource "local_file" "conn_string_file" {
  content  = "#!/bin/bash\nexport ATP_CONN_STRING=${lookup(module.autonomous-db.conn_strings[0],"high")}\nexport ATP_OCID=${module.autonomous-db.atp_ocid}\n"
  filename = "./resources/atp_env.sh"
}

output "oci_private_ip_client_instance" {
  value = "${oci_core_instance.client-instance.private_ip}"
}

output "oci_public_ip_client_instance" {
  value = "${oci_core_instance.client-instance.public_ip}"
}

output "azure_private_ip_client_instance" {
  value = "${azurerm_network_interface.client_nic.private_ip_address}"
}

output "azure_public_ip_client_instance" {
  value = "${azurerm_public_ip.client_public_ip.ip_address}"
}

output "azure_private_ip_ref_instance" {
  value = "${azurerm_network_interface.ref_nic.private_ip_address}"
}

output "azure_public_ip_ref_instance" {
  value = "${azurerm_public_ip.ref_public_ip.ip_address}"
}



