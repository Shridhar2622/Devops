variable "docker_host" {
  description = "Docker daemon connection endpoint (npipe for Windows Docker Desktop, unix socket for Linux/Mac)"
  type        = string
  default     = "npipe:////./pipe/docker_engine"
}

variable "backend_port" {
  description = "Port on localhost for the Backend API"
  type        = number
  default     = 5000
}

variable "frontend_port" {
  description = "Port on localhost for the Frontend Web UI"
  type        = number
  default     = 3001
}

variable "nagios_port" {
  description = "Port on localhost for the Nagios Monitoring Dashboard"
  type        = number
  default     = 8085
}
