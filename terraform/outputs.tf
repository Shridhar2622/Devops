output "frontend_url" {
  description = "Access URL for the Doodle-Dash Game Web Interface"
  value       = "http://localhost:${var.frontend_port}"
}

output "backend_health_url" {
  description = "Direct URL for the Backend /health API Endpoint"
  value       = "http://localhost:${var.backend_port}/health"
}

output "nagios_dashboard_url" {
  description = "Access URL for the Nagios Core Web Monitoring Interface"
  value       = "http://localhost:${var.nagios_port}"
}

output "nagios_credentials" {
  description = "Default credentials for the Nagios Dashboard"
  value       = "Username: nagiosadmin | Password: nagiosadmin"
}
