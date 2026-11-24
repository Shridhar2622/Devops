# =============================================================================
# TERRAFORM MAIN: LOCAL CONTAINER ORCHESTRATION
# Manages:
# 1. Docker virtual bridge network
# 2. Doodle-Dash Backend container (:5000)
# 3. Doodle-Dash Frontend container (:3001)
# 4. Nagios Monitoring container (:8085)
# =============================================================================

# 1. Private virtual network for container communication
resource "docker_network" "app_network" {
  name   = "letsdraw_network"
  driver = "bridge"
}

# 2. Doodle-Dash Backend Container
resource "docker_container" "backend" {
  name  = "backend"
  image = "letsdraw-backend:latest"

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 5000
    external = var.backend_port
  }

  env = [
    "PORT=5000",
    "NODE_ENV=production"
  ]
}

# 3. Doodle-Dash Frontend Container
resource "docker_container" "frontend" {
  name  = "frontend"
  image = "letsdraw-frontend:latest"

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 80
    external = var.frontend_port
  }

  depends_on = [
    docker_container.backend
  ]
}

# 4. Nagios Core Monitoring Container
resource "docker_container" "nagios" {
  name  = "nagios"
  image = "letsdraw-nagios:latest"

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 80
    external = var.nagios_port
  }

  env = [
    "NAGIOSADMIN_USER=nagiosadmin",
    "NAGIOSADMIN_PASS=nagiosadmin"
  ]

  depends_on = [
    docker_container.backend,
    docker_container.frontend
  ]
}
