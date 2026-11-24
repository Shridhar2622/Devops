# 📄 PROJECT SYNOPSIS

## **Title:** Local DevOps Automation, Infrastructure as Code, and Continuous Monitoring for Doodle-Dash

---

### 1. 📌 Introduction

**Doodle-Dash (LetsDraw)** is a real-time multiplayer drawing and guessing web application modeled after games like *Skribbl.io*. In Doodle-Dash, players join interactive lobbies using unique avatars, take turns illustrating assigned words on a dynamic HTML5 Canvas, and race against an active countdown timer while other players guess in live chat.

While the application itself represents a complex, event-driven web architecture, modern software engineering demands that applications be supported by predictable, automated, and observable operational workflows. This project extends Doodle-Dash into an end-to-end, industry-standard **DevOps pipeline** implemented entirely within a local environment. By leveraging **Docker**, **Terraform**, **Ansible**, and **Nagios Core**, the project demonstrates containerization, declarative Infrastructure as Code (IaC), automated configuration management, and proactive service monitoring without any reliance on paid cloud platforms.

---

### 2. ❗ Problem Statement

In conventional academic and startup development setups, web applications are deployed manually via ad-hoc terminal commands (`npm run dev`, direct host scripts). This approach introduces several critical challenges:

1. **Environment Discrepancy & Configuration Drift**: Variations in operating systems, Node runtime versions, and local dependencies cause the notorious *"it works on my machine"* dilemma.
2. **Lack of Infrastructure Reproducibility**: Deploying networks, environment variables, and ports manually is error-prone, unversioned, and impossible to replicate consistently.
3. **Cloud Over-Reliance & Financial Risk**: Relying on public cloud providers (AWS, Azure, GCP) introduces steep setup complexity, billing risks, and strict credit card requirements that are unnecessary for local demonstrations and evaluation.
4. **Absence of Real-Time Health Observability**: Applications running without dedicated monitoring suffer from silent failures. If the backend WebSocket server crashes or an API hangs, operators remain unaware until end-users experience service interruption.

---

### 3. 🎯 Objectives

The primary objective of this project is to construct a **100% local, reproducible, and cloud-free DevOps automation pipeline** for the Doodle-Dash multiplayer platform:

* **Containerization**: Isolate the frontend and backend into lightweight, standardized Alpine-based Docker images with optimized multi-stage build pipelines.
* **Infrastructure as Code (IaC)**: Use **Terraform** with the official Docker provider (`kreuzwerker/docker`) to declaratively provision and manage virtual bridge networks, container lifecycles, and port mappings.
* **Configuration Management & Deployment Verification**: Employ **Ansible** to automate pre-flight system checks, verify container runtime states, assert endpoint health, and generate audit reports without conflicting with Terraform's resource ownership.
* **Continuous Health Monitoring & Alerting**: Implement **Nagios Core** in a dedicated container to continuously probe the backend `/health` endpoint, verify WebSocket port responsiveness, check frontend web delivery, and provide visual alerts during outages.
* **Strict Separation of Concerns**: Establish clear boundaries where Terraform acts as the authoritative resource owner, Ansible serves as the configuration verifier, and Nagios acts as the failure-detection watchdog.

---

### 4. 🏗️ Proposed System Architecture

The proposed architecture organizes the application and DevOps lifecycle into four tightly integrated layers operating over a shared local Docker bridge network (`letsdraw_network`):

```text
+-----------------------------------------------------------------------------------+
|                           LOCAL WORKSTATION / DOCKER ENGINE                       |
+-----------------------------------------------------------------------------------+
                                        |
    +-----------------------------------+-----------------------------------+
    |                                   |                                   |
    v                                   v                                   v
[ 1. TERRAFORM (IaC) ]       [ 2. ANSIBLE (Config) ]             [ 3. RUNTIME APP ]
- kreuzwerker/docker         - localhost (connection=local)      - Backend (Port 5000)
- Provisions letsdraw_network - Asserts container states         - Frontend (Port 3001)
- Launches Backend, Frontend, - Smoke-tests /health (HTTP 200)   - Dedicated /health API
  and Nagios Containers      - Generates audit report            - Shared Bridge Network
                                                                            |
                                                                            v
                                                                 [ 4. NAGIOS MONITOR ]
                                                                 - Active HTTP checks
                                                                 - TCP 5000 socket checks
                                                                 - Failure & recovery detection
                                                                 - Web UI at :8085
```

### Operational Workflow:
1. **Provisioning**: Running `terraform apply` instructs the local Docker daemon to create the bridge network and instantiate the three container services (`backend`, `frontend`, and `nagios`).
2. **Verification & Audit**: Running `ansible-playbook -i inventory.ini site.yml` verifies Docker engine health, confirms all target containers are running, validates that `http://localhost:5000/health` returns `HTTP 200 OK` (`"status":"UP"`), and outputs a deployment audit report.
3. **Observability**: Nagios Core probes the backend and frontend every minute. If the backend is terminated (`docker stop backend`), Nagios detects the failure and flags the service as **CRITICAL (RED)**. Upon container restart (`docker start backend`), Nagios automatically flags recovery to **OK (GREEN)**.

---

### 5. 🛠️ Technology Stack & DevOps Tools Breakdown

| Domain | Technology | Role & Responsibility in Doodle-Dash |
| :--- | :--- | :--- |
| **Frontend Application** | **React 19 & Vite 7** | Single Page Application (SPA), responsive UI, and state management. |
| **Canvas & Graphics** | **HTML5 Canvas API & Tailwind CSS v4** | Normalized resolution drawing engine, flood-fill algorithm, shapes overlay, and styling. |
| **Backend Application** | **Node.js 20 & Express 5** | REST API, in-memory room management, and automated `/health` telemetry endpoint. |
| **Real-Time Networking** | **Socket.io (v4.8)** | Low-latency, bidirectional WebSocket communication for synchronized drawing and chat guesses. |
| **Web Server / Reverse Proxy** | **Nginx (Alpine)** | High-performance static asset web server inside the frontend container with SPA fallback routing. |
| **Containerization** | **Docker & Docker Compose** | Multi-stage image builds, `.dockerignore` optimization, and container isolation. |
| **Infrastructure as Code** | **Terraform (v1.16+)** | Declarative management of Docker networks, container instances, environment variables, and ports using the `kreuzwerker/docker` provider. |
| **Configuration Management** | **Ansible Core (v2.20+)** | Agentless deployment verification, pre-flight checks, HTTP response assertions, and Jinja2 audit report templating. |
| **Monitoring & Alerting** | **Nagios Core (v4.5+)** | Continuous polling of application endpoints, socket availability, host responsiveness, and tactical web dashboard visualization (`:8085`). |

---

### 6. 🏁 Conclusion

The modernized **Doodle-Dash DevOps project** successfully bridges the gap between full-stack application development and enterprise infrastructure engineering. By containerizing the application with **Docker**, managing resources declaratively through **Terraform**, validating configuration and health via **Ansible**, and implementing failure detection with **Nagios Core**, the project establishes a robust, professional DevOps lifecycle. 

Crucially, this system proves that industry-standard DevOps principles—Infrastructure as Code, configuration verification, and continuous monitoring—can be executed **100% locally on a single developer workstation without cloud subscription costs, credential exposure, or external dependencies**.