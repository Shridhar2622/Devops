# ⚙️ Ansible: Configuration Management & Post-Deployment Verification

This directory contains the Ansible playbooks and configurations for validating and managing the **Doodle-Dash** environment.

---

## 🔒 Separation of Responsibilities (Terraform vs. Ansible)

* **Terraform Owns**: Container creation, port bindings, virtual networks, and container lifecycles.
* **Ansible Owns**: Pre-flight verification (checking Docker daemon), verifying running container states, smoke-testing HTTP/WebSocket endpoints, generating audit logs, and asserting system health.
* **No Resource Conflict**: Ansible does **NOT** recreate, stop, or delete the Terraform-managed containers.

---

## 📁 Directory Structure
```text
ansible/
├── inventory.ini           # Local host definition (connection=local)
├── site.yml                # Main verification and configuration playbook
├── group_vars/
│   └── all.yml             # Global variables (ports, endpoints, retry thresholds)
├── templates/
│   └── deployment_report.j2# Template for generating audit verification reports
└── README.md
```

---

## 🚀 How to Run Ansible

### Option A: Running from WSL Ubuntu (Recommended on Windows)
```bash
# 1. Open WSL terminal
wsl

# 2. Navigate to project ansible directory
cd /mnt/c/Users/21302/OneDrive/Desktop/Desktop/Project/letsdraw/ansible

# 3. Execute playbook
ansible-playbook -i inventory.ini site.yml
```

### Option B: Running via Docker (No WSL setup required)
If Ansible is not installed in WSL, run it instantly via a lightweight Docker container:
```powershell
docker run --rm -v "${PWD}:/work" -w /work/ansible cytopia/ansible:latest ansible-playbook -i inventory.ini site.yml
```

---

## 🔄 Application Update Workflow

When a code change is made to Doodle-Dash (e.g. updating a component in frontend or fixing a route in backend):

1. **Step 1: Build the New Docker Image**
   ```bash
   docker build -t letsdraw-frontend:latest ./frontend
   # (or ./backend for backend updates)
   ```
2. **Step 2: Update Container via Terraform**
   ```bash
   cd terraform
   terraform apply -auto-approve
   ```
   *Terraform detects the updated image and replaces only the affected container smoothly.*
3. **Step 3: Run Ansible Verification**
   ```bash
   cd ../ansible
   ansible-playbook -i inventory.ini site.yml
   ```
   *Ansible verifies that the updated container is listening and returns HTTP 200.*
