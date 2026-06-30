output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.k3s.id
}

output "public_ip" {
  description = "Elastic public IP for the k3s node."
  value       = aws_eip.k3s.public_ip
}

output "ssh_command" {
  description = "SSH command for the k3s node."
  value       = "ssh -i \"${var.private_key_path}\" ubuntu@${aws_eip.k3s.public_ip}"
}

output "k3s_api_url" {
  description = "Kubernetes API endpoint."
  value       = "https://${aws_eip.k3s.public_ip}:6443"
}

output "app_url" {
  description = "Zuri Market frontend URL after Kubernetes manifests are deployed."
  value       = "http://${aws_eip.k3s.public_ip}:30080"
}

output "security_group_id" {
  description = "Security group ID."
  value       = aws_security_group.k3s.id
}
