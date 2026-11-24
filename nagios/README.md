# 🔍 Nagios Core: Local Application Monitoring & Failure Detection

This directory contains the Nagios Core container configuration and service check definitions for the **Doodle-Dash** application.

---

## 🏗️ Monitoring Architecture

```text
Local Docker Engine (letsdraw_network)
|
|-- Doodle-Dash Backend Container (:5000)
|   |-- GET /health  --> returns {"status":"UP"}
|   |-- TCP Port 5000 --> WebSocket connections
|
|-- Doodle-Dash Frontend Container (:80 / :3001)
|   |-- GET /        --> Nginx serves React SPA
|
|-- Nagios Monitoring Container (:80 / :8085)
    |-- Active HTTP Check on http://backend:5000/health
    |-- Active TCP Check on backend:5000
    |-- Active HTTP Check on http://frontend:80
    |-- Monitoring Web Dashboard at http://localhost:8085
```

---

## 📁 Configuration Details
* **`Dockerfile`**: Builds on `jasonrivers/nagios:latest` and bakes custom configuration directly into `/opt/nagios/etc/conf.d/letsdraw.cfg`.
* **`etc/objects/letsdraw.cfg`**:
  * **Hosts Defined**: `backend` (IP address resolves via Docker's internal DNS bridge) and `frontend`.
  * **Services Defined**:
    1. **`Backend Health Check`**: Periodically runs `check_http -p 5000 -u /health` expecting `HTTP 200 OK` and `"status":"UP"`.
    2. **`Frontend Website Check`**: Periodically runs `check_http -p 80` validating that Nginx serves the game UI.

---

## 📊 Accessing the Nagios Dashboard
* **URL**: `http://localhost:8085` or `http://localhost:8085/nagios/`
* **Username**: `nagiosadmin`
* **Password**: `nagiosadmin`

### Key Dashboard Views:
* **Tactical Overview**: High-level summary of all monitored hosts and services.
* **Services**: Table showing status (`OK`, `WARNING`, `CRITICAL`, `UNKNOWN`), check latency, and last check time.
* **Host Map**: Visual relationship tree showing the Nagios server connected to the `backend` and `frontend` hosts.
