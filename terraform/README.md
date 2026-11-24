# 🏗️ Terraform: Local Docker Infrastructure as Code (IaC)

This directory contains the Terraform configuration for managing the local Docker resources for the **Doodle-Dash** project.

> [!NOTE]
> This configuration does **NOT** provision virtual machines or cloud servers (AWS/Azure/GCP). It uses the official **Kreuzwerker Docker Provider** to manage local Docker networks and containers on your laptop.

---

## 📁 Directory Files
* **`versions.tf`**: Declares required Terraform version (`>= 1.0.0`) and the `kreuzwerker/docker` provider plugin.
* **`variables.tf`**: Configurable local ports and Docker pipe settings.
* **`main.tf`**: Authoritative definition of the Docker network (`letsdraw_network`) and containers (`backend`, `frontend`, `nagios`).
* **`outputs.tf`**: Displays the active URLs and credentials upon completion.

---

## 🛠️ Step-by-Step Terraform Workflow

Run these commands from inside the `terraform/` directory:

### 1. Initialize Working Directory
```bash
terraform init
```
* **What it does:** Downloads and installs the `kreuzwerker/docker` provider plugin required to interact with your local Docker engine.

### 2. Format Configuration Code
```bash
terraform fmt
```
* **What it does:** Automatically formats HCL configuration files to standard canonical layout and readability.

### 3. Validate Configuration Syntax
```bash
terraform validate
```
* **What it does:** Checks that the configuration syntax is completely valid and that all required attributes are provided without syntax errors.

### 4. Generate Execution Plan
```bash
terraform plan
```
* **What it does:** Compares current Docker state with desired configuration and displays a detailed preview of resources that will be created or modified (without actually applying any changes).

### 5. Apply Changes (Create Resources)
```bash
terraform apply
```
*(Or `terraform apply -auto-approve` to skip the interactive confirmation prompt)*
* **What it does:** Interacts with the local Docker daemon to create the bridge network and launch the `backend`, `frontend`, and `nagios` containers.

### 6. Inspect Outputs
```bash
terraform output
```
* **What it does:** Displays the exported values (frontend URL, backend health endpoint, Nagios dashboard URL, and credentials).

### 7. Teardown Resources
```bash
terraform destroy
```
* **What it does:** Gracefully stops and removes all containers and the network managed by this configuration.
* **⚠️ Warning:** Only execute when you want to stop and remove all application resources.

---

## 🔒 Resource Ownership Rule
* **Terraform is the authoritative owner** of the `backend`, `frontend`, and `nagios` containers and their network.
* **Ansible does NOT recreate or modify** these containers; Ansible's responsibility is solely to perform pre-flight checks, verify container health, and smoke-test endpoints.
