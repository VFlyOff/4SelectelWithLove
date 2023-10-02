terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.49.0"
    }
  }
}

provider "openstack" {
  domain_name = "${var.domain_name}"
  tenant_name = "${var.project_name}"
  user_name   = "${var.user_name}"
  password    = "${var.user_password}"
  auth_url    = "https://api.selvpc.ru/identity/v3"
  region      = "${var.region}"
}

resource "openstack_compute_flavor_v2" "flavor_1" {
  name      = "flavor-1cpu-1g-0hdd"
  ram       = "1024"
  vcpus     = "1"
  disk      = "0"
  is_public = false

  lifecycle {
    create_before_destroy = false
  }
}

resource "openstack_compute_keypair_v2" "terraform_key" {
  name       = "terraform_key"
  region     = "${var.region}"
  public_key = "${var.public_key}"
}

data "openstack_images_image_v2" "image_ubuntu_18_04" {
  most_recent = true
  properties = {
    x_sel_image_source_file = "ubuntu-bionic-amd64-selectel-master-product-0.1.img"
  }
  visibility = "public"
}

data "openstack_networking_network_v2" "external_net" {
  name = "external-network"
}

resource "openstack_networking_router_v2" "router_1" {
  name                = "router_1"
  external_network_id = "${data.openstack_networking_network_v2.external_net.id}"
}

resource "openstack_networking_network_v2" "network_1" {
  name = "network_1"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  network_id = "${openstack_networking_network_v2.network_1.id}"
  name       = "192.168.0.0/24"
  cidr       = "192.168.0.0/24"
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = "${openstack_networking_router_v2.router_1.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
}

resource "openstack_networking_port_v2" "port_1" {
  name       = "${var.server_name}-eth0"
  network_id = "${openstack_networking_network_v2.network_1.id}"

  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
  }
}

resource "openstack_networking_floatingip_v2" "floatingip_1" {
  pool = "external-network"
}

resource "openstack_blockstorage_volume_v3" "volume_1" {
  name              = "volume-for-${var.server_name}"
  size              = "10"
  image_id          = "${data.openstack_images_image_v2.image_ubuntu_18_04.id}"
  volume_type       = "${var.volume_type}"
  availability_zone = "${var.az_zone}"

  lifecycle {
    ignore_changes = ["image_id"]
  }
}

resource "openstack_compute_instance_v2" "instance_1" {
  name              = "${var.server_name}"
  flavor_id         = "${openstack_compute_flavor_v2.flavor_1.id}"
  key_pair          = "${openstack_compute_keypair_v2.terraform_key.id}"
  availability_zone = "${var.az_zone}"

  network {
    port = "${openstack_networking_port_v2.port_1.id}"
  }

  block_device {
    uuid             = "${openstack_blockstorage_volume_v3.volume_1.id}"
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

resource "openstack_networking_floatingip_associate_v2" "association_1" {
  port_id     = "${openstack_networking_port_v2.port_1.id}"
  floating_ip = "${openstack_networking_floatingip_v2.floatingip_1.address}"
}

resource "selectel_vpc_project_v2" "remote-exec" {
  name = "test"
  connection {
    type = "ssh"
    user = "root"
    private_key = file("<path_to_secret>")
    host = "<serv_ip>"
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get upgrade -y && apt-get update -y"
      "apt-get install -y nginx"
      "systemctl enable nginx.service && systemctl start nginx.service"
      "echo '<h1>Iurii Naumov / <a href='https://github.com/VFlyOff/4SelectelWithLove'>GitHub</a></h1>' > /var/w>
      "echo '<h3>Open ports:' >> /var/www/html/index.nginx-debian.html",
      "echo `ss -tulpn | awk '{print $5}' | tail -n +2 | sed 's|.*:||' | sort | uniq -c | awk '{print $2}'` >> />
      "echo '</h3>' >> /var/www/html/index.nginx-debian.html"
    ]
  }
}
