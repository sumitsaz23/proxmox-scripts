# ==============================================================================
# Script: import_ova.sh
# Description:
#   Automates extracting an OVA file (provided with extension), converting its disk
#   image to QCOW2, creating a standard Proxmox VM, importing the disk, and attaching
#   it to the newly created VM.
# Usage:
#   ./import_ova.sh <OVA_FILE> <VM_ID> [STORAGE] [TEMPLATE_DIR]
#     OVA_FILE     Full OVA filename (including .ova extension)
#     VM_ID        Proxmox VM ID to create and import the disk into
#     STORAGE      (Optional) Proxmox storage target for disk (default: hdd-vm-data)
#     TEMPLATE_DIR (Optional) Directory containing the OVA and images
#                  (default: /var/lib/vz/import)
# ===============================================================================

# Using curl

curl -sSL \
  https://raw.githubusercontent.com/sumitsaz23/proxmox-scripts/main/import_ova.sh \
| bash -s -- my-vm.ova 123 local-lvm /var/lib/vz/template

# Using wget

wget -qO- \
  https://raw.githubusercontent.com/sumitsaz23/proxmox-scripts/main/import_ova.sh \
| bash -s -- my-vm.ova 123
