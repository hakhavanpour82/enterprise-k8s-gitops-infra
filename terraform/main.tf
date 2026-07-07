resource "hcloud_ssh_key" "sre_key" {
  name       = "enterprise-sre-key"
  public_key = file("../ansible/secure-keys/id_ed25519.pub")
}

resource "hcloud_server" "k8s_master" {
  name        = "k8s-control-plane"
  image       = var.os_image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.sre_key.id]
}

resource "hcloud_server" "k8s_workers" {
  count       = 2
  name        = "k8s-worker-0${count.index + 1}"
  image       = var.os_image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.sre_key.id]
}

resource "local_file" "ansible_inventory" {
  filename = "../ansible/inventory"
  content  = <<EOT
[masters]
k8s-control-plane ansible_host=${hcloud_server.k8s_master.ipv4_address} ansible_user=root ansible_ssh_private_key_file=./secure-keys/id_ed25519

[workers]
%{ for index, server in hcloud_server.k8s_workers ~}
${server.name} ansible_host=${server.ipv4_address} ansible_user=root ansible_ssh_private_key_file=./secure-keys/id_ed25519
%{ endfor ~}

[k8s_cluster:children]
masters
workers
EOT
}
