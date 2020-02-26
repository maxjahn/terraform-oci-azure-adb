output "conn_strings" {
   value = ["${oci_database_autonomous_database.atp_db.connection_strings}"]
}

output "conn_urls" {
   value = ["${oci_database_autonomous_database.atp_db.connection_urls}"]
}

output "atp_ocid" {
   value =  "${oci_database_autonomous_database.atp_db.id}"
}



