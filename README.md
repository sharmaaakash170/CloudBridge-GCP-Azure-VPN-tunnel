
# CloudBridge-GCP-Azure-VPN-tunnel 🌉  
**Azure ↔ GCP Site-to-Site VPN (Active‑Active, BGP) with Terraform**

This repository documents my **end‑to‑end, real‑world troubleshooting journey** of building a **production‑style Site‑to‑Site VPN** between **Microsoft Azure** and **Google Cloud Platform (GCP)** using **Terraform**, including **Active‑Active VPN gateways, BGP, and HA tunnels**.

This README intentionally includes **mistakes, issues, and fixes**, because that is how real DevOps work happens.

---

## 🧭 Project Overview

### What this project does
- Creates **Azure VNet** with GatewaySubnet + VM subnet
- Creates **GCP VPC** with VM subnet
- Provisions **Linux VMs** in both clouds
- Establishes **Active‑Active Site‑to‑Site VPN**
- Uses **BGP for dynamic routing**
- Validates connectivity using **private IPs**
- Handles **Terraform destroy edge cases**
- Written in **modular Terraform (GitHub‑ready)**

---

## 🛠️ Tech Stack

- Terraform
- Azure: VNet, Subnets, NSG, VPN Gateway, Local Network Gateway
- GCP: VPC, Firewall, HA VPN, Cloud Router (BGP)
- Linux (Ubuntu)
- BGP (eBGP over IPsec)

---

## 📁 Repository Structure

```
.
├── modules/
│   ├── azure/
│   │   ├── network/
│   │   ├── vpn/
│   │   └── vm/
│   └── gcp/
│       ├── network/
│       ├── vpn/
│       └── vm/
├── environments/
│   └── dev/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
├── .gitignore
└── README.md
```

---

## 🚀 Step‑by‑Step Implementation

### 1️⃣ Azure Networking
- Created VNet `10.20.0.0/16`
- Created **GatewaySubnet** → `10.20.255.0/27`
- Created **VM subnet** → `10.20.1.0/24`
> ⚠️ GatewaySubnet **must not** be used for VMs

### 2️⃣ Azure VPN Gateway
- Route‑based VPN
- SKU: `VpnGw1`
- **Active‑Active enabled**
- BGP ASN: `65515`
- Custom APIPA BGP IPs:
  - `169.254.21.1`
  - `169.254.22.1`

### 3️⃣ GCP Networking
- VPC CIDR: `10.10.0.0/16`
- VM subnet: `10.10.1.0/24`
- Firewall rules for:
  - SSH (22)
  - ICMP
  - HTTP (80)

### 4️⃣ GCP HA VPN + BGP
- HA VPN with **2 interfaces**
- Cloud Router ASN: `65001`
- Two VPN tunnels:
  - tunnel‑1 → Azure IP1
  - tunnel‑2 → Azure IP2
- Router interfaces:
  - `169.254.21.2/30`
  - `169.254.22.2/30`

---

## 🔍 How VPN Validation Was Done (Correct Way)

### ❌ Wrong Validation
- Public IP ping
- SSH over internet

### ✅ Correct Validation
```bash
# From GCP VM
ping 10.20.1.4   # Azure VM private IP
```

BGP verification:
```bash
gcloud compute routers get-status gcp-router --region asia-south1
az network vnet-gateway list-bgp-peer-status --resource-group vpn-rg --name azure-vpn-gateway
```

---

## 🧩 Issues Faced & Solutions (VERY IMPORTANT)

### ❌ Issue 1: BGP stayed DOWN on one tunnel
**Symptom**
- `azure-peer2` status: DOWN
- `NO_INCOMING_PACKETS` on GCP tunnel

**Root Cause**
- Azure Local Network Gateway pointing to **wrong GCP IP**
- Using HA VPN interface IP instead of **GCP VPN tunnel interface IP**

✅ **Fix**
- Used `gcp_vpn_interface_ips[0]` and `[1]`
- Correct APIPA mapping on both sides

---

### ❌ Issue 4: VM subnet deletion failed during `terraform destroy`
**Error**
```
InUseSubnetCannotBeDeleted
```

**Reason**
NIC still attached to VM

✅ **Fix**
- Ensured proper dependency order
- Explicit VM → NIC → Subnet teardown

---

### ❌ Issue 5: GCP VPC not deleting
**Error**
```
network is already being used by firewall
```

✅ **Fix**
- Terraform dependencies ensured:
```hcl
depends_on = [google_compute_firewall.allow_http]
```

---

### ❌ Issue 6: GatewaySubnet selected for VM
**Error**
```
GatewaySubnet (the selected subnet is not supported)
```

✅ **Fix**
- Created **separate VM subnet**
- GatewaySubnet is **VPN‑only**

---

### ❌ Issue 7: Curl / Ping failed even when VPN was UP
**Reason**
- NSG / Firewall missing
- Service not running on VM

✅ **Fix**
- Allowed ICMP + TCP/80
- Installed web server on Azure VM

---

## 🔐 Security Practices

- No secrets committed
- `.tfvars` ignored
- SSH keys only
- Private IP communication

---

## 🧠 Key Learnings

- VPN up ≠ traffic flowing
- BGP correctness > tunnel status
- GatewaySubnet rules are strict
- Terraform destroy needs dependency planning
- Active‑Active VPN is **not trivial**

---

## 🚧 Future Improvements

- GitHub Actions CI
- Ansible configuration
- Private‑only VMs
- Monitoring (BGP + Tunnel health)

---

## 🙌 Final Note

This project reflects **real DevOps debugging**, not just happy‑path Terraform.

If you understand this repo, you understand **multi‑cloud networking deeply**.

---

**Author:** Aakash Sharma  
**Project:** CloudBridge-GCP-Azure-VPN-tunnel 🌉
