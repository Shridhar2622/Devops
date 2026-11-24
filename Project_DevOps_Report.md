# Doodle-Dash (LetsDraw) - Project & DevOps Architecture Report

## 1. Introduction to the Project
**Project Name:** Doodle-Dash (LetsDraw)

**Concept:** 
Doodle-Dash is a highly interactive, real-time multiplayer drawing and guessing game, inspired by popular games like Skribbl.io. Players join custom game rooms using unique avatars, take turns drawing assigned words using a robust set of canvas tools, and race against the clock to guess what the current drawer is illustrating.

**Core Mechanics & Features:**
* **Real-time Canvas Syncing:** Players see strokes, shapes, and colors exactly as they are being drawn with near-zero latency.
* **Advanced Drawing Engine:** Custom HTML5 Canvas implementation featuring continuous stroke drawing, geometric shape rendering, and a complex Flood Fill (Paint Bucket) algorithm that seamlessly identifies color boundaries.
* **Turn-based Logic:** The server manages game states, turns, timer ticks, and scoring, ensuring robust state management even if players disconnect or put the game in the background.

**Technology Stack:**
* **Frontend:** React.js (Vite), TailwindCSS, GSAP/Framer Motion, HTML5 Canvas API, and Socket.io-client.
* **Backend:** Node.js, Express.js, and Socket.io with dedicated `/health` endpoint.

---

## 2. Overview of Modernized DevOps Architecture
To guarantee automated provisioning, consistent configurations, and enterprise monitoring without dependence on paid cloud services, the DevOps architecture is built upon four foundational pillars:

1. **Terraform** (Infrastructure as Code - Local Docker Provider)
2. **Ansible** (Configuration Management & Deployment Orchestration)
3. **Nagios Core** (Host & Service Health Monitoring & Alerting)
4. **Docker & Docker Compose** (Containerization & Multi-Service Virtual Network)
5. **Git & GitHub Actions** (Version Control & Continuous Integration)

---

## 3. Detailed Breakdown of DevOps Tools Used

### 3.1 Terraform (Infrastructure as Code - IaC)
* **What it is:** HashiCorp's declarative infrastructure orchestration tool.
* **Implementation:** Configured in `terraform/main.tf` using the official `kreuzwerker/docker` provider.
* **Role in Project:** 
  * Eliminates the need for paid cloud infrastructure (e.g., AWS, GCP) by directly managing the local Docker Engine as an infrastructure provider.
  * Provisions a dedicated bridge network (`letsdraw_network`) connecting all microservices.
  * Builds and manages the lifecycle of the `backend`, `frontend`, and `nagios` container instances.
  * Exports service endpoints via `outputs.tf` for seamless integration.

### 3.2 Ansible (Configuration Management & Automation)
* **What it is:** An open-source, agentless configuration management and deployment automation engine.
* **Implementation:** Defined in `ansible/playbook.yml` with `ansible/inventory.ini`.
* **Role in Project:**
  * Selected over Puppet due to its agentless architecture (no master or agent daemons required) and readable YAML syntax.
  * Executes automated pre-flight checks (verifies Docker daemon health and port availability).
  * Automates container stack orchestration and executes post-deployment smoke tests.
  * Queries the backend `/health` endpoint to assert that the service is `UP` (HTTP 200) before marking deployment complete.

### 3.3 Nagios Core (Enterprise Monitoring & Alerting)
* **What it is:** The industry-standard open-source host and service monitoring system.
* **Implementation:** Built via `nagios/Dockerfile` with customized check definitions in `nagios/etc/objects/letsdraw.cfg`.
* **Role in Project:**
  * Runs as an isolated container on the shared virtual network, accessible on port `8085`.
  * **Backend HTTP Health Check:** Probes `http://backend:5000/health` every minute to ensure API readiness.
  * **Backend TCP Socket Check:** Directly checks port `5000` to verify WebSocket connectivity for real-time multiplayer drawing.
  * **Frontend Web Check:** Monitors HTTP port `80` to guarantee the web UI is responsive.
  * **Container Ping Checks:** Tracks container latency and packet loss.
  * Provides an administrative web interface (`nagiosadmin` / `nagiosadmin`) featuring tactical overviews, host maps, and outage alerts.

### 3.4 Docker & Docker Compose (Containerization)
* **What it is:** Container virtualization engine and multi-container orchestration.
* **Implementation:** `Dockerfile`s for each service + root `docker-compose.yml`.
* **Role in Project:**
  * Guarantees 100% environment parity across development, testing, and production.
  * Packages microservices into lightweight Alpine-based containers (`node:20-alpine`, `nginx:alpine`).
  * Enables one-command local startup via `docker compose up -d --build`.

### 3.5 Git & GitHub Actions (Version Control & CI)
* **What it is:** Distributed version control and automated workflow execution.
* **Implementation:** `.github/workflows/ci.yml`.
* **Role in Project:**
  * Triggers automated linting and build validation on pushes to `master`.
  * Verifies dependency installation and Vite compilation before any production merge.

---

## 4. Operational Run Guide

### Quick Start with Docker Compose
```bash
docker compose up -d --build
```

### Provision with Terraform (IaC)
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### Automate & Verify with Ansible
```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

### Endpoints
* 🎮 **Frontend Game UI:** `http://localhost:3001`
* ⚙️ **Backend Health Check:** `http://localhost:5000/health`
* 📊 **Nagios Dashboard:** `http://localhost:8085` (User: `nagiosadmin` | Pass: `nagiosadmin`)
