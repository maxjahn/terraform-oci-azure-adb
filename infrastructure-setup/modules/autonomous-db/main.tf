resource "oci_database_autonomous_database" "atp_db" {
  display_name             = var.oci_atp_db_displayname
  admin_password           = var.oci_atp_admin_password
  compartment_id           = var.oci_compartment_ocid
  cpu_core_count           = var.oci_atp_cores
  data_storage_size_in_tbs = var.oci_atp_storage_tb
  db_name                  = var.oci_atp_db_name

  db_workload             = var.oci_atp_db_workload
  is_auto_scaling_enabled = false
  is_dedicated            = false
  is_free_tier            = false
}

