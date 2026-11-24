# 🎨 DOODLE DASH — LOCAL DEVOPS AUTOMATION AND MONITORING

---

## 1. 📌 Project Overview
**Doodle Dash** is a real-time multiplayer drawing and guessing web application (inspired by Skribbl.io). Players join custom game rooms with avatars and nicknames, take turns drawing assigned words using an HTML5 Canvas drawing toolset, and race against the clock to guess what is being illustrated in live chat.

* **Frontend**: React 19, Vite 7, Tailwind CSS v4, HTML5 Canvas API, Socket.io-client.
* **Backend**: Node.js (v20), Express 5, Socket.io, dedicated `/health` check API.

---

## 2. 🎯 Problem Statement & DevOps Objectives

In traditional student projects, web applications are run manually with ad-hoc `npm run dev` commands, leading to configuration drift, deployment inconsistencies, lack of health verification, and zero failure visibility.

### DevOps Objectives:
1. **Containerization (Docker)**: Package the frontend and backend into isolated, reproducible, production-ready containers.
2. **Infrastructure as Code (Terraform)**: Authoritatively manage local Docker virtual networks, images, and container lifecycles using the official `kreuzwerker/docker` provider without reliance on paid cloud platforms (AWS/Azure/GCP).
3. **Configuration Management & Verification (Ansible)**: Automate environment pre-flight checks, smoke-test API endpoints, verify container states, and generate audit reports without conflicting with Terraform.
4. **Monitoring & Alerting (Nagios Core)**: Run a dedicated, containerized Nagios monitoring server performing active HTTP health checks, TCP socket checks, and automated failure/recovery detection.

---

## 3. 🏗️ System Architecture & Technology Responsibilities

```mermaid
graph TD
    subgraph 1. Infrastructure as Code IaC
        TF[Terraform<br/>terraform apply] -->|Official kreuzwerker/docker Provider| NET[Docker Bridge Network<br/>letsdraw_network]
        TF -->|Provisions Containers| B_CONT[Backend Container<br/>Port 5000]
        TF -->|Provisions Containers| F_CONT[Frontend Container<br/>Port 3001]
        TF -->|Provisions Containers| N_CONT[Nagios Core Container<br/>Port 8085]
    end

    subgraph 2. Configuration Management
        AN[Ansible Playbook<br/>ansible-playbook site.yml] -->|connection: local| ENV[Local Host & Docker Engine]
        AN -->|Validates Prerequisites| DOCKER_CHK[Check Docker Engine & Ports]
        AN -->|Post-Deploy Verification| HEALTH_CHK[Validate http://localhost:5000/health]
        AN -->|Generates Audit Log| REPORT[ansible/deployment_report.txt]
    end

    subgraph 3. Application Runtime
        B_CONT -->|Node.js + Express 5| API[/health & REST API]
        B_CONT -->|Socket.io| WS[Real-time Game Sockets]
        F_CONT -->|Vite + React 19| UI[Game Interface]
    end

    subgraph 4. Continuous Monitoring & Alerting
        N_CONT -->|HTTP Check GET /health| B_CONT
        N_CONT -->|TCP Check Port 5000| B_CONT
        N_CONT -->|HTTP Check Port 80| F_CONT
        N_CONT -->|Live Web Dashboard| WEB_UI[Nagios Web Dashboard<br/>http://localhost:8085]
    end
```

### Technology Separation of Concerns:
| Technology | Authoritative Responsibility | What It Does NOT Do |
| :--- | :--- | :--- |
| **Docker** | Packaging microservices into lightweight Alpine images. | Does not orchestrate multi-container dependencies or health policies alone. |
| **Terraform** | **Authoritative owner** of the virtual network, port allocations, and container lifecycles. | Does not provision cloud VMs or perform in-container application verification. |
| **Ansible** | Automated pre-flight checks, container state assertions, `/health` endpoint smoke tests, and audit logging. | Does **NOT** delete, recreate, or compete with Terraform-managed containers. |
| **Nagios Core** | Active, periodic polling of backend health, socket ports, and frontend availability; detects failures and recoveries. | Does not automatically restart containers unless explicit remediation is configured. |

---

## 4. 💻 Prerequisites for Windows

Before starting, ensure the following tools are installed on your Windows laptop:
1. **Docker Desktop for Windows** (with WSL2 backend enabled).
2. **Terraform CLI** (Version >= 1.0.0). Install via Windows Package Manager:
   ```powershell
   winget install HashiCorp.Terraform
   ```
3. **WSL (Ubuntu)** (For running Ansible natively, or run Ansible via Docker container).
4. **Git**.

---

## 5. 🌐 Network & Port Configuration

| Service | Container Port | Host Port | Protocol | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Frontend** | `80` (Nginx) | `3001` | HTTP | Doodle-Dash Game Interface |
| **Backend** | `5000` (Node) | `5000` | HTTP / WS | Game Logic, WebSockets & `/health` API |
| **Nagios** | `80` (Apache) | `8085` | HTTP | Nagios Core Monitoring Dashboard |

All containers communicate with each other over the internal Docker bridge network (`letsdraw_network`) using internal container names (`http://backend:5000/health`, `http://frontend:80`).

---

## 6. 🚀 Step-by-Step Deployment Instructions

Open your terminal (PowerShell or Git Bash):

### Step 1: Ensure Docker Desktop is Running
```powershell
# In PowerShell:
docker context use default
docker ps
```

### Step 2: Build the Container Images (Phase 2)
```powershell
# Build Backend
docker build -t letsdraw-backend:latest ./backend

# Build Frontend
docker build -t letsdraw-frontend:latest ./frontend

# Build Nagios Monitor
docker build -t letsdraw-nagios:latest ./nagios
```

### Step 3: Provision Infrastructure with Terraform (Phase 3)
```powershell
cd terraform

# Initialize provider plugins
terraform init

# Validate configuration syntax
terraform validate

# Review the execution plan
terraform plan

# Apply infrastructure changes
terraform apply -auto-approve

# View active outputs
terraform output
```

### Step 4: Verify Deployment with Ansible (Phase 4)

#### In WSL (Ubuntu):
```bash
cd /mnt/c/Users/21302/OneDrive/Desktop/Desktop/Project/letsdraw/ansible
ansible-playbook -i inventory.ini site.yml
```

#### Or in Windows PowerShell (via Docker):
```powershell
cd ansible
docker run --rm -v "${PWD}/..:/work" -w /work/ansible cytopia/ansible:latest ansible-playbook -i inventory.ini site.yml
```

---

## 7. 🧪 Phase 6: Failure and Recovery Demonstration

Follow these steps to demonstrate the system's monitoring and resilience during project evaluations:

### Test 1: Verify Baseline Healthy State
1. Open the game in your browser: `http://localhost:3001` (confirm avatar picker and game lobby load).
2. Open the Backend Health endpoint: `http://localhost:5000/health` (verify HTTP 200 with `"status":"UP"`).
3. Open Nagios: `http://localhost:8085/nagios/` (User: `nagiosadmin`, Pass: `nagiosadmin`).
4. Click **Services** in the left sidebar: confirm `Backend Health Check` and `Frontend Website Check` show green **OK**.

---

### Test 2: Application Failure Simulation
Simulate a sudden crash of the backend application:
```powershell
# In Windows PowerShell:
docker stop backend
```
1. Try refreshing `http://localhost:5000/health` (connection refused).
2. Go to the Nagios Dashboard (`http://localhost:8085/nagios/` ➔ **Services**).
3. Within 1 minute, Nagios detects the outage:
   - Status switches from **OK** to **CRITICAL** (Red).
   - Status Information displays: `Connection refused` or `HTTP CRITICAL`.

---

### Test 3: Application Recovery Simulation
Recover the failed service:
```powershell
# In Windows PowerShell:
docker start backend
```
1. Verify `http://localhost:5000/health` responds again with `"status":"UP"`.
2. Go back to Nagios (**Services** view).
3. On the next check cycle, Nagios detects recovery:
   - Status changes back from **CRITICAL** to **OK** (Green).
   - Status Information displays: `HTTP OK: HTTP/1.1 200 OK`.

---

### Test 4: Ansible Repeatability & Idempotency
Run the Ansible playbook a second time while containers are running:
```bash
ansible-playbook -i inventory.ini site.yml
```
* **Expected Result**: The playbook completes with `failed=0`. It verifies running container states and checks endpoint health without restarting services or causing downtime.

---

## 8. 🧹 Teardown & Cleanup Instructions

When you are finished demonstrating the project:

```powershell
# In the terraform directory:
cd terraform
terraform destroy -auto-approve
```
* **What this does:** Safely stops and removes all 3 containers (`backend`, `frontend`, `nagios`) and deletes the virtual bridge network (`letsdraw_network`).

---

## 9. ⚠️ Troubleshooting & Known Limitations

1. **Docker Pipe Error on Windows**:
   - *Symptom*: `open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.`
   - *Fix*: Run `docker context use default` to switch to the active Docker pipe (`npipe:////./pipe/docker_engine`).
2. **Port Conflicts**:
   - Ensure ports `5000`, `3001`, and `8085` are not being used by other software before running `terraform apply`.
3. **Single Laptop Limitation**:
   - All services run on a single machine. While containers provide process and network isolation, host-level hardware issues (e.g. laptop going to sleep) will pause all containers equally.
