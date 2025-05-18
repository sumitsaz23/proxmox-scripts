# import\_ova.sh

**Automates extracting an OVA, converting its disk image to QCOW2, creating a Proxmox VM, importing the disk, and attaching it.**

---

## Description

This script streamlines the process of provisioning a VM in Proxmox from an OVA file. It performs the following steps:

1. Extracts the specified OVA archive.
2. Converts the contained virtual disk (VMDK/VHD) to QCOW2 format.
3. Creates a new Proxmox VM with basic resources.
4. Imports the QCOW2 disk into a specified Proxmox storage.
5. Attaches the imported disk as a SCSI device to the created VM.

---

## Prerequisites

* Proxmox VE with `qm` and `qemu-img` utilities installed and accessible in your PATH.
* Appropriate permissions to create VMs and access storage on the Proxmox host.
* The OVA file and working directory must be readable/writable by the script user.

---

## Usage

```bash
./import_ova.sh <OVA_FILE> <VM_ID> [STORAGE] [TEMPLATE_DIR]
```

| Parameter        | Description                                                                                       |
| ---------------- | ------------------------------------------------------------------------------------------------- |
| `<OVA_FILE>`     | Full OVA filename (including the `.ova` extension)                                                |
| `<VM_ID>`        | Proxmox VM ID to create and import the disk into                                                  |
| `[STORAGE]`      | (Optional) Proxmox storage target for the disk (default: `hdd-vm-data`)                           |
| `[TEMPLATE_DIR]` | (Optional) Directory containing the OVA file and generated images (default: `/var/lib/vz/import`) |

---

## Examples

### Run with required arguments only

```bash
./import_ova.sh my-vm.ova 123
```

This will use defaults:

* `STORAGE` = `hdd-vm-data`
* `TEMPLATE_DIR` = `/var/lib/vz/import`

### Specify a custom storage and template directory

```bash
./import_ova.sh my-vm.ova 123 local-lvm /var/lib/vz/template
```

---

## Download & Run Directly

### Using `curl`

```bash
curl -sSL \
  https://raw.githubusercontent.com/sumitsaz23/proxmox-scripts/main/import_ova/import_ova.sh \
  | bash -s -- my-vm.ova 123 my-storage /var/lib/vz/template
```

### Using `wget`

```bash
wget -qO- \
  https://raw.githubusercontent.com/sumitsaz23/proxmox-scripts/main/import_ova/import_ova.sh \
  | bash -s -- my-vm.ova 123
```

---

## License

MIT License. See [LICENSE](../../LICENSE) for details.
