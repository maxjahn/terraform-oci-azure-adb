module "interconnect" {
  source = "./modules/interconnect"

  oci_compartment_ocid = "${var.oci_compartment_ocid}"
  oci_vcn_cidr         = "${var.oci_service_vcn_cidr}"
  oci_subnet_id        = "${oci_core_subnet.client_subnet.id}"
  oci_vcn_id                     = "${oci_core_virtual_network.service_vcn.id}"
  oci_vcn_default_route_table_id = "${oci_core_virtual_network.service_vcn.default_route_table_id}"

  oci_azure_provider_ocid     = "${var.oci_azure_provider_ocid}"

  arm_resource_group_location = "${azurerm_resource_group.connect.location}"
  arm_resource_group_name     = "${azurerm_resource_group.connect.name }"

  arm_vnet_cidr        = "${var.arm_vnet_cidr}"
  arm_gw_subnet_id     = "${azurerm_subnet.gateway_subnet.id}"
  arm_subnet_id     = "${azurerm_subnet.client_subnet.id}"
  arm_expressroute_sku = "${var.arm_expressroute_sku}"
  arm_expressroute_peering_location = "${var.arm_expressroute_peering_location}"

  peering_net = "${var.peering_net}"
}

module "autonomous-db" {
  source = "./modules/autonomous-db"

  oci_compartment_ocid   = "${var.oci_compartment_ocid}"
  oci_atp_admin_password = "${var.oci_atp_admin_password}"
  oci_atp_db_name        = "${var.oci_atp_db_name}"
  oci_atp_db_displayname = "${var.oci_atp_db_displayname}"
  oci_atp_db_workload    = "${var.oci_atp_db_workload}"
  oci_atp_cores          = "${var.oci_atp_db_cores}"
  oci_atp_storage_tb     = "${var.oci_atp_db_storage_tb}"
}

## basic networking setup

resource "oci_core_virtual_network" "service_vcn" {
  cidr_block     = "${var.oci_service_vcn_cidr}"
  dns_label      = "servicevcn"
  compartment_id = "${var.oci_compartment_ocid}"
  display_name   = "service-vcn"
}

resource "oci_core_subnet" "client_subnet" {
  cidr_block        = "${var.oci_client_subnet_cidr}"
  compartment_id    = "${var.oci_compartment_ocid}"
  vcn_id            = "${oci_core_virtual_network.service_vcn.id}"
  display_name      = "client-subnet"
  dns_label         = "clientsubnet"
  security_list_ids = ["${oci_core_security_list.connect_sl.id}"]
}

resource "oci_core_security_list" "connect_sl" {
  compartment_id = "${var.oci_compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.service_vcn.id}"
  display_name   = "public-security-list"

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "1"
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"

    tcp_options {
      min = "22"
      max = "22"
    }
  }
  egress_security_rules {
    destination   = "0.0.0.0/0"
    protocol = "all"
    }
}

resource "azurerm_resource_group" "connect" {
  name     = "connect"
  location = "${var.arm_region}"
}

resource "azurerm_virtual_network" "connect_vnet" {
  name                = "connect-network"
  resource_group_name = "${azurerm_resource_group.connect.name}"
  location            = "${azurerm_resource_group.connect.location}"
  address_space       = ["${var.arm_vnet_cidr}"]
}

resource "azurerm_subnet" "client_subnet" {
  name                 = "client-subnet"
  resource_group_name  = "${azurerm_resource_group.connect.name}"
  virtual_network_name = "${azurerm_virtual_network.connect_vnet.name}"
  address_prefix       = "${var.arm_client_subnet_cidr}"
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = "${azurerm_resource_group.connect.name}"
  virtual_network_name = "${azurerm_virtual_network.connect_vnet.name}"
  address_prefix       = "${var.arm_gw_subnet_cidr}"
}

data "template_file" "client" {
  template = "${file("templates/adb_client.tpl")}"
}

resource "azurerm_public_ip" "client_public_ip" {
  name                = "client-public-ip"
  location            = "${azurerm_resource_group.connect.location}"
  resource_group_name = "${azurerm_resource_group.connect.name}"
  allocation_method   = "Dynamic"
}

data "azurerm_public_ip" "client_public_ip" {
  name                = "${azurerm_public_ip.client_public_ip.name}"
  resource_group_name = "${azurerm_resource_group.connect.name}"
}

resource "azurerm_network_interface" "client_nic" {
  name                = "client-nic"
  location            = "${azurerm_resource_group.connect.location}"
  resource_group_name = "${azurerm_resource_group.connect.name}"

  ip_configuration {
    name                          = "client-nic-config"
    subnet_id                     = "${azurerm_subnet.client_subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.client_public_ip.id}"
  }
}

resource "azurerm_virtual_machine" "client_instance" {
  name                  = "client-instance"
  location              = "${azurerm_resource_group.connect.location}"
  resource_group_name   = "${azurerm_resource_group.connect.name}"
  network_interface_ids = ["${azurerm_network_interface.client_nic.id}"]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.arm_image_publisher}"
    offer     = "${var.arm_image_offer}"
    sku       = "${var.arm_image_sku}"
    version   = "${var.arm_image_version}"
  }

  storage_os_disk {
    name              = "client_osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "az-client"
    admin_username = "azure"
    admin_password = "Welcome-1234"
    custom_data    = "${data.template_file.client.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = "${var.ssh_public_key}"
      path     = "/home/azure/.ssh/authorized_keys"
    }
  }
}

data "oci_identity_availability_domains" "connect_ads" {
  compartment_id = "${var.oci_compartment_ocid}"
}

resource "oci_core_instance" "client-instance" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.connect_ads.availability_domains[0],"name")}"
  compartment_id      = "${var.oci_compartment_ocid}"
  shape               = "VM.Standard2.1"

  create_vnic_details {
    subnet_id              = "${oci_core_subnet.client_subnet.id}"
    assign_public_ip       = true
    skip_source_dest_check = true
  }

  display_name = "oci-client"

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(data.template_file.client.rendered)}"
  }

  source_details {
    source_id   = "${var.oci_base_image}"
    source_type = "image"
  }
  preserve_boot_volume = false
}

##########################################################################
### VNet without access to interconnect, to be used as reference when 
### testing ADB.

resource "azurerm_virtual_network" "ref_vnet" {
  name                = "reference-network"
  resource_group_name = "${azurerm_resource_group.connect.name}"
  location            = "${azurerm_resource_group.connect.location}"
  address_space       = ["${var.arm_vnet_cidr}"]
}

resource "azurerm_subnet" "ref_subnet" {
  name                 = "ref-subnet"
  resource_group_name  = "${azurerm_resource_group.connect.name}"
  virtual_network_name = "${azurerm_virtual_network.ref_vnet.name}"
  address_prefix       = "${var.arm_client_subnet_cidr}"
}

resource "azurerm_public_ip" "ref_public_ip" {
  name                = "ref-pub-ip"
  location            = "${azurerm_resource_group.connect.location}"
  resource_group_name = "${azurerm_resource_group.connect.name}"
  allocation_method   = "Dynamic"
}

data "azurerm_public_ip" "ref_public_ip" {
  name                = "${azurerm_public_ip.ref_public_ip.name}"
  resource_group_name = "${azurerm_resource_group.connect.name}"
}

resource "azurerm_network_interface" "ref_nic" {
  name                = "ref-nic"
  location            = "${azurerm_resource_group.connect.location}"
  resource_group_name = "${azurerm_resource_group.connect.name}"

  ip_configuration {
    name                          = "ref-nic-config"
    subnet_id                     = "${azurerm_subnet.ref_subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.ref_public_ip.id}"
  }
}

resource "azurerm_virtual_machine" "ref_instance" {
  name                  = "ref-instance"
  location              = "${azurerm_resource_group.connect.location}"
  resource_group_name   = "${azurerm_resource_group.connect.name}"
  network_interface_ids = ["${azurerm_network_interface.ref_nic.id}"]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.arm_image_publisher}"
    offer     = "${var.arm_image_offer}"
    sku       = "${var.arm_image_sku}"
    version   = "${var.arm_image_version}"
  }

  storage_os_disk {
    name              = "ref_osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "ref-client"
    admin_username = "azure"
    admin_password = "Welcome-1234"
    custom_data    = "${data.template_file.client.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = "${var.ssh_public_key}"
      path     = "/home/azure/.ssh/authorized_keys"
    }
  }
}


