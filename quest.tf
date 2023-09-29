resource "openstack_compute_instance_v2" "remote-exec" {
  name = "test"
  connection {
    type = "ssh"
    user = "root"
    private_key = file("<path_to_secret>")
    host = "<serv_ip>"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '<h3>Open ports:' >> /var/www/html/index.nginx-debian.html",
      "echo `ss -tulpn | awk '{print $5}' | tail -n +2 | sed 's|.*:||' | sort | uniq -c | awk '{print $2}'` >> /var/www/html/index.nginx-debian.html",
      "echo '</h3>' >> /var/www/html/index.nginx-debian.html"
    ]
  }
}
