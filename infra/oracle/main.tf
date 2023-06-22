terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  # Rest of the authentication parameters are configure via environment variables.
  region = "eu-frankfurt-1"
}

variable "compartment_id" {
  default = "ocid1.tenancy.oc1..aaaaaaaazilgo52o57gc4nonjd6ixk2xsffoosru3g4gcti75x5nugor4uaa"
}

variable "subnet_id" {
  default = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaayi3lwfv6xnettqwqwa2bvmn6gj63ljakmgwqjfcirgv4xwcdctba"
}

resource "oci_core_instance" "delphi" {
  agent_config {
    is_management_disabled = "false"
    is_monitoring_disabled = "false"
    plugins_config {
      desired_state = "DISABLED"
      name          = "Vulnerability Scanning"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Compute Instance Monitoring"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Bastion"
    }
  }
  availability_config {
    is_live_migration_preferred = "true"
    recovery_action             = "RESTORE_INSTANCE"
  }
  availability_domain = "tQrM:EU-FRANKFURT-1-AD-1"
  compartment_id      = var.compartment_id
  create_vnic_details {
    assign_private_dns_record = "true"
    assign_public_ip          = "true"
    subnet_id                 = var.subnet_id
  }
  display_name = "delphi"
  instance_options {
    are_legacy_imds_endpoints_disabled = "false"
  }
  metadata = {
    "ssh_authorized_keys" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESHraJJ0INX/OAXOQUR4UuLEre/2N70Uh3H5YkFC5zz marie@archlinux"
  }
  shape = "VM.Standard.A1.Flex"
  shape_config {
    memory_in_gbs = "24"
    ocpus         = "4"
  }
  source_details {
    boot_volume_size_in_gbs = "100"
    boot_volume_vpus_per_gb = "20"
    source_id               = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaavv2mpdlhnbt6zehvubcorl4oqkrzthc5ustlfs7npfhkk7r6xyq"
    source_type             = "image"
  }
}

resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_id
  cidr_block     = "10.0.0.0/16"
}

resource "oci_core_security_list" "sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }
  # Allow ssh traffic
  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"
    tcp_options {
      max = 22
      min = 22
    }
  }
  # Allow http traffic
  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"
    tcp_options {
      max = 80
      min = 80
    }
  }
  # Allow https traffic
  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"
    tcp_options {
      max = 443
      min = 443
    }
  }
  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6"
    tcp_options {
      max = 25565
      min = 25565
    }
  }
  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "17"
    udp_options {
      max = 25565
      min = 25565
    }
  }
  ingress_security_rules {
    source   = "${var.artemis-ip}/32"
    protocol = "17"
    udp_options {
      max = 51820
      min = 51820
    }
  }
}
