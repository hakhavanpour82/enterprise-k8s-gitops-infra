output "master_public_ip" {
  description = "The public IP of the Kubernetes control plane node"
  value       = hcloud_server.k8s_master.ipv4_address
}

output "worker_public_ips" {
  description = "The public IPs of the Kubernetes worker nodes"
  value       = hcloud_server.k8s_workers[*].ipv4_address
}
