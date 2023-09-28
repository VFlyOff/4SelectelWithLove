resource "selectel_vpc_project_v2" "remote-exec" {
  name = "test"
  connection {
    type = "ssh"
    user = "root"
    private_key = file("<file_to_key>")
    host = "188.68.218.136"
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get upgrade -y && apt-get update -y",
      "apt-get install -y nginx",
      "systemctl enable nginx.service && systemctl start nginx.service",
      "echo '<h1>Iurii Naumov / <a href='https://github.com/VFlyOff/4SelectelWithLove'>GitHub</a></h1>' > /var/www/html/index.nginx-debian.html",
      "echo '<h3>Open ports:' >> /var/www/html/index.nginx-debian.html",
      "echo `ss -tulpn | awk '{print $5}' | tail -n +2 | sed 's|.*:||' | sort | uniq -c | awk '{print $2}'` >> /var/www/html/index.nginx-debian.html",
      "echo '</h3>' >> /var/www/html/index.nginx-debian.html"
    ]
  }
}
