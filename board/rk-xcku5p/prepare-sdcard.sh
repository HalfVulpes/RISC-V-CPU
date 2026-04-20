#!/bin/bash
# Prepare a MicroSD card for the RK-XCKU5P RISC-V Linux SoC.
#
# Usage:   sudo ./prepare-sdcard.sh /dev/sdX
# Example: sudo ./prepare-sdcard.sh /dev/sda
#
# The card will be wiped and partitioned as:
#   sdX1   FAT32, 200 MB   -- BOOT.ELF, Image, system.dtb, extlinux.conf
#   sdX2   ext4,  rest     -- Debian rootfs
#
# Required files (must exist before running this script):
#   workspace/boot.elf
#   linux-stable/arch/riscv/boot/Image
#   workspace/rocket64b4/system-rk-xcku5p.dts
#   debian-riscv64/rootfs.tar.gz
#
# All are produced by the standard 'make ... bitstream / linux / bootloader'
# and 'make debian-riscv64/rootfs.tar.gz' targets.

set -euo pipefail

DEV="${1:-}"
CONFIG="${CONFIG:-rocket64b4}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

err() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }
info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m✓\033[0m  %s\n' "$*"; }

# --- sanity checks ---
[[ -z "${DEV}" ]]  && err "usage: $0 /dev/sdX (e.g. /dev/sda)"
[[ "$(id -u)" -ne 0 ]] && err "must run as root (sudo $0 ${DEV})"
[[ ! -b "${DEV}" ]] && err "${DEV} is not a block device"

if mountpoint -q / && findmnt -n -o SOURCE / | grep -q "^${DEV}"; then
  err "${DEV} is the host's root disk — refusing to wipe"
fi

case "${DEV}" in
  /dev/nvme*|/dev/mmcblk0) err "${DEV} looks like an internal device — refusing" ;;
esac

BOOT_ELF="${PROJECT_ROOT}/workspace/boot.elf"
KERNEL="${PROJECT_ROOT}/linux-stable/arch/riscv/boot/Image"
DTS="${PROJECT_ROOT}/workspace/${CONFIG}/system-rk-xcku5p.dts"
ROOTFS="${PROJECT_ROOT}/debian-riscv64/rootfs.tar.gz"

for f in "${BOOT_ELF}" "${KERNEL}" "${DTS}" "${ROOTFS}"; do
  [[ -f "${f}" ]] || err "missing artifact: ${f}"
done

SIZE=$(lsblk -bdn -o SIZE "${DEV}")
SIZE_GIB=$(( SIZE / 1024 / 1024 / 1024 ))
MODEL=$(lsblk -dn -o MODEL "${DEV}" | xargs)
TRAN=$(lsblk -dn -o TRAN "${DEV}")

info "Target device : ${DEV} (${SIZE_GIB} GiB, ${TRAN}, ${MODEL})"

(( SIZE_GIB >= 4 ))  || err "card must be ≥ 4 GB (got ${SIZE_GIB} GiB)"
(( SIZE_GIB <= 256 )) || err "device is ${SIZE_GIB} GiB — suspiciously large for an SD card, refusing"

printf '\n\033[1;33mTHIS WILL WIPE ALL DATA ON %s\033[0m\n' "${DEV}"
printf 'Type YES to continue: '
read -r reply
[[ "${reply}" == "YES" ]] || err "cancelled"

# --- unmount anything mounted from this device ---
info "Unmounting any existing partitions from ${DEV}"
for p in $(lsblk -nr -o NAME "${DEV}" | tail -n +2); do
  umount "/dev/${p}" 2>/dev/null || true
done

# --- partition ---
info "Partitioning ${DEV} (GPT, 200 MB FAT32 + rest ext4)"
sgdisk --zap-all "${DEV}"
sgdisk --new=1:0:+200M --typecode=1:EF00 --change-name=1:BOOT   "${DEV}"
sgdisk --new=2:0:0     --typecode=2:8300 --change-name=2:rootfs "${DEV}"
partprobe "${DEV}"
sleep 2

# Partition device names differ for sd* vs mmcblk*/nvme*
if [[ "${DEV}" =~ [0-9]$ ]]; then
  P1="${DEV}p1"; P2="${DEV}p2"
else
  P1="${DEV}1";  P2="${DEV}2"
fi

# --- filesystems ---
info "Formatting ${P1} as FAT32"
mkfs.vfat -F 32 -n BOOT "${P1}"

info "Formatting ${P2} as ext4"
mkfs.ext4 -F -L rootfs "${P2}"

# --- compile DTB ---
DTB="${PROJECT_ROOT}/workspace/${CONFIG}/system.dtb"
info "Compiling device tree → ${DTB}"
dtc -O dtb -o "${DTB}" "${DTS}"

# --- populate FAT boot partition ---
MNT=$(mktemp -d)
info "Populating boot partition (${P1} → ${MNT})"
mount "${P1}" "${MNT}"
cp "${BOOT_ELF}" "${MNT}/BOOT.ELF"
cp "${KERNEL}"   "${MNT}/Image"
cp "${DTB}"      "${MNT}/system.dtb"
mkdir -p "${MNT}/extlinux"
cat > "${MNT}/extlinux/extlinux.conf" <<'EOF'
DEFAULT linux
LABEL linux
    KERNEL /Image
    FDT    /system.dtb
    APPEND earlycon console=ttyAU0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait locale.LANG=en_US.UTF-8
EOF
ls -la "${MNT}" "${MNT}/extlinux"
umount "${MNT}"
ok "boot partition ready"

# --- populate rootfs ---
info "Extracting Debian rootfs (${P2} → ${MNT}, ~1 GB — takes a couple minutes)"
mount "${P2}" "${MNT}"
tar -xzf "${ROOTFS}" -C "${MNT}"
sync
umount "${MNT}"
rmdir  "${MNT}"
ok     "rootfs extracted"

info  "Final flush (sync)"
sync
ok    "Done. Safe to unplug ${DEV}."
echo
echo  "Next steps:"
echo  "  1. Insert the card into the board's MicroSD slot"
echo  "  2. Power-cycle the board"
echo  "  3. sudo picocom -b 115200 /dev/ttyUSB1"
echo  "  4. Log in as root / root  (or debian / debian)"
