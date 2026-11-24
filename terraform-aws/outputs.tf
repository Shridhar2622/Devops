# =============================================================================
# TERRAFORM AWS OUTPUTS
# =============================================================================
output "ec2_public_ip" {
  description = "Public IP address of the AWS EC2 instance"
  value       = aws_instance.letsdraw_server.public_ip
}

output "ssh_command" {
  description = "Command to SSH into your AWS EC2 instance"
  value       = "ssh -i shridhar_key.pem ubuntu@${aws_instance.letsdraw_server.public_ip}"
}

output "frontend_game_url" {
  description = "Live game URL on AWS"
  value       = "http://${aws_instance.letsdraw_server.public_ip}:3001"
}

output "backend_health_url" {
  description = "Live backend /health telemetry URL on AWS"
  value       = "http://${aws_instance.letsdraw_server.public_ip}:5000/health"
}

output "nagios_dashboard_url" {
  description = "Live Nagios Core dashboard on AWS"
  value       = "http://${aws_instance.letsdraw_server.public_ip}:8085/nagios/"
}
