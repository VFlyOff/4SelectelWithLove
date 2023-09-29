resource "openstack_compute_keypair_v2" "shared" {
  name = "shared"
  public_key = file("<path_to_public_key>") 
}

resource "openstack_compute_instance_v2" "web-server" {
  name = "nginx_instance"
  availability_zone = "<pool>"
  key_pair = "shared"
  user_data = <<-EOF
    #!/bin/bash
    apt-get upgrade -y && apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx.service && systemctl start nginx.service  
    echo '<h1>Iurii Naumov / <a href='https://github.com/VFlyOff/4SelectelWithLove'>GitHub</a></h1>' > /var/www/html/index.nginx-debian.html
  EOF
}
