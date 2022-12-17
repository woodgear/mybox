#!/bin/bash
set -Eeuo pipefail
# https://github.com/covertsh/ubuntu-preseed-iso-generator

function cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  if [ -n "${tmpdir+x}" ]; then
    # rm -rf "$tmpdir"
    log "🚽 Deleted temporary working directory $tmpdir"
  fi
}

trap cleanup SIGINT SIGTERM ERR EXIT
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

function log() {
  echo >&2 -e "[$(date +"%Y-%m-%d %H:%M:%S")] ${1-}"
}

function build() (
  local source_iso="$1"
  local destination_iso="$2"
  local user_data_file="$3"
  export EFI_IMAGE="ubuntu-original.efi"
  export MBR_IMAGE="ubuntu-original.mbr"
  local tmpdir=$(mktemp -d)
  xorriso -osirrox on -indev "${source_iso}" -extract / "$tmpdir" &>/dev/null
  ls $tmpdir
  cat $tmpdir/boot/grub/grub.cfg
  chmod -R u+w "$tmpdir"
  rm -rf "$tmpdir/"'[BOOT]'

  log "👍 Extracted to $tmpdir"

  dd if="${source_iso}" bs=1 count=446 of="${tmpdir}/${MBR_IMAGE}" &>/dev/null
  log "👍 Extracted to ${tmpdir}/${MBR_IMAGE}"

  log "🔧 Extracting EFI image..."
  START_BLOCK=$(fdisk -l "${source_iso}" | fgrep '.iso2 ' | awk '{print $2}')
  SECTORS=$(fdisk -l "${source_iso}" | fgrep '.iso2 ' | awk '{print $4}')
  dd if="${source_iso}" bs=512 skip="${START_BLOCK}" count="${SECTORS}" of="${tmpdir}/${EFI_IMAGE}" &>/dev/null
  log "👍 Extracted to ${tmpdir}/${EFI_IMAGE}"

  log "🧩 Adding autoinstall parameter to kernel command line..."
  sed -i -e 's/---/ autoinstall  ---/g' "$tmpdir/boot/grub/grub.cfg"
  sed -i -e 's/---/ autoinstall  ---/g' "$tmpdir/boot/grub/loopback.cfg"
  log "👍 Added parameter to UEFI and BIOS kernel command lines."

  log "🧩 Adding user-data and meta-data files..."
  mkdir "$tmpdir/nocloud"
  cp "$user_data_file" "$tmpdir/nocloud/user-data"
  touch "$tmpdir/nocloud/meta-data"
  sed -i -e 's,---, ds=nocloud\\\;s=/cdrom/nocloud/  ---,g' "$tmpdir/boot/grub/grub.cfg"
  sed -i -e 's,---, ds=nocloud\\\;s=/cdrom/nocloud/  ---,g' "$tmpdir/boot/grub/loopback.cfg"
  log "👍 Added data and configured kernel command line."
  cat $tmpdir/boot/grub/grub.cfg
  cat $tmpdir/nocloud/user-data

  log "📦 Repackaging extracted files into an ISO image..."
  cd "$tmpdir"
  xorriso -as mkisofs \
    -r -V "ubuntu-autoinstall" -J -joliet-long -l \
    -iso-level 3 \
    -partition_offset 16 \
    --grub2-mbr "${tmpdir}/${MBR_IMAGE}" \
    --mbr-force-bootable \
    -append_partition 2 0xEF "${tmpdir}/${EFI_IMAGE}" \
    -appended_part_as_gpt \
    -c boot.catalog \
    -b boot/grub/i386-pc/eltorito.img \
    -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
    -eltorito-alt-boot \
    -e '--interval:appended_partition_2:all::' \
    -no-emul-boot \
    -o "${destination_iso}" "./" &>/dev/null
  log "👍 Repackaged into ${destination_iso}"
  log "✅ Completed." 0
)

OLDPWD=$(pwd)
log $OLDPWD
cd ./ubuntu-2204-desktop
# build $PWD/ubuntu-22.04.1-desktop-amd64.iso $PWD/ubuntu-22.04.1-desktop-amd64.autoinstall.iso $PWD/data/user-data
md5iso=($(md5sum $PWD/ubuntu-22.04.1-desktop-amd64.autoinstall.iso))
log $md5iso
set -x
packer build  -var "md5sum=$md5iso" ./ubuntu-2204-desktop.pkr.hcl
cd "$OLDPWD"
