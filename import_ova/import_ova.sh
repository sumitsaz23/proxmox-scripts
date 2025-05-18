#!/bin/bash

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

# Validate argument count (2 to 4 args)
if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
  echo "Usage: $0 <OVA_FILE> <VM_ID> [STORAGE] [TEMPLATE_DIR]"
  exit 1
fi

# ---------------------------
# Parse arguments
# ---------------------------
ova_file="$1"                        # Full OVA filename
vm_id="$2"                           # Proxmox VM ID for create/import
storage="${3:-local-lvm}"           # Proxmox storage target (default)
template_dir="${4:-/var/lib/vz/import}"  # Working directory (default)

# ---------------------------
# Derive base name and related filenames
# ---------------------------
base_name="${ova_file%.*}"                                          # Strip extension for reuse

# ---------------------------
# Change to working directory
# ---------------------------
echo "-> Changing to directory: ${template_dir}"
cd "${template_dir}" || {
  echo "Error: Cannot cd to ${template_dir}" >&2
  exit 1
}

# ---------------------------
# Extract the OVA archive
# ---------------------------
echo "-> Extracting OVA: ${ova_file}"
tar -xf "${ova_file}" || {
  echo "Error: Failed to extract ${ova_file}" >&2
  exit 1
}


# ---------------------------
# Try to find VMDK or VHD file
# ---------------------------

cd "${template_dir}" || {
  echo "Error: Cannot cd to ${template_dir}" >&2
  exit 1
}

disk_image=$(ls ${base_name}*.vmdk 2>/dev/null | head -n 1)
format="vmdk"
if [ -z "$disk_image" ]; then
  disk_image=$(ls ${base_name}*.vhd 2>/dev/null | head -n 1)
  format="vpc"
fi

if [ -z "$disk_image" ]; then
  echo "Error: No disk image found matching ${base_name}*.vmdk or *.vhd" >&2
  exit 1
fi

#vmdk_image=$(ls ${base_name}*.vmdk 2>/dev/null | head -n 1)         # Disk image inside OVA (change extension if needed)

qcow2_image="${base_name}.qcow2"       # Converted QCOW2 filename
disk_name="vm-${vm_id}-disk-0"        # Proxmox disk identifier

# ---------------------------
# Convert disk image to QCOW2
# ---------------------------
echo "-> Converting ${disk_image} to ${qcow2_image}"
qemu-img convert -f "${format}" -O qcow2 "${disk_image}" "${qcow2_image}" || {
  echo "Error: Conversion from ${format} to QCOW2 failed" >&2
  exit 1
}

# ---------------------------
# Create a standard Proxmox VM
# ---------------------------
echo "-> Creating VM ${vm_id} named ${base_name}"
qm create "${vm_id}" \
  --name "${base_name}" \
  --memory 2048 \
  --cores 2 \
  --net0 virtio,bridge=vmbr0 \
  --scsihw virtio-scsi-pci \
  --boot c \
  --bootdisk scsi0 || {
  echo "Error: qm create failed" >&2
  exit 1
}

# ---------------------------
# Import the QCOW2 disk into Proxmox storage
# ---------------------------
echo "-> Importing ${qcow2_image} into VM ${vm_id} on storage ${storage}"
qm importdisk "${vm_id}" "${template_dir}/${qcow2_image}" "${storage}" || {
  echo "Error: qm importdisk failed" >&2
  exit 1
}

# ---------------------------
# Attach the imported disk to the VM
# ---------------------------
echo "-> Attaching disk as SCSI0"
qm set "${vm_id}" -scsi0 "${storage}:${disk_name}" || {
  echo "Error: qm set failed to attach disk" >&2
  exit 1
}

# ---------------------------
# Completion message
# ---------------------------
echo "Success: VM ${vm_id} created, disk imported and attached."
