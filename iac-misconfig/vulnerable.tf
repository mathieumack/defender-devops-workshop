# ---------------------------------------------------------------------------
# iac-misconfig/vulnerable.tf — Terraform Misconfiguration Example
# ---------------------------------------------------------------------------
# Intentionally misconfigured Terraform for IaC scanning demos.
# Each issue is marked. See the inline comments for fixes.
# ---------------------------------------------------------------------------

provider "azurerm" {
  features {}
}

variable "location" {
  default = "eastus"
}

variable "resource_group_name" {
  default = "rg-terraform-demo"
}

resource "azurerm_resource_group" "demo" {
  name     = var.resource_group_name
  location = var.location
}

# ── ISSUE 1: Storage account — HTTP allowed, public access, old TLS ─────────
# FIX: enable_https_traffic_only = true, allow_blob_public_access = false,
#      min_tls_version = "TLS1_2"
resource "azurerm_storage_account" "vulnerable" {
  name                     = "stvulnterraform"
  resource_group_name      = azurerm_resource_group.demo.name
  location                 = azurerm_resource_group.demo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # VULNERABLE settings:
  enable_https_traffic_only = false    # Allows unencrypted HTTP traffic
  allow_blob_public_access  = true     # Anonymous blob reads
  min_tls_version           = "TLS1_0" # Outdated TLS
}

# ── ISSUE 2: Key Vault — no purge protection, no soft-delete ────────────────
# FIX: purge_protection_enabled = true, soft_delete_retention_days = 90
resource "azurerm_key_vault" "vulnerable" {
  name                = "kv-vuln-demo"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  tenant_id           = "00000000-0000-0000-0000-000000000000"
  sku_name            = "standard"

  purge_protection_enabled   = false   # VULNERABLE: deleted secrets can be purged
  soft_delete_retention_days = 7       # VULNERABLE: too short retention

  network_acls {
    default_action = "Allow"           # VULNERABLE: open to all networks
    bypass         = "None"
  }
}

# ── ISSUE 3: NSG allowing SSH from anywhere ─────────────────────────────────
# FIX: Restrict source_address_prefix to a known CIDR
resource "azurerm_network_security_group" "vulnerable" {
  name                = "nsg-vuln-tf"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"             # VULNERABLE: SSH from anywhere
    destination_address_prefix = "*"
  }
}
