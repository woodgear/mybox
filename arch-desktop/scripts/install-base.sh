#!/usr/bin/env bash

# stop on errors
set -eux

whoami
timedatectl status
DISK='/dev/vda'

# FQDN='vagrant-arch.vagrantup.com'
KEYMAP='us'
LANGUAGE='en_US.UTF-8'
# TIMEZONE='UTC'

ROOT_PARTITION="${DISK}1"
TARGET_DIR='/mnt'
COUNTRY=${COUNTRY:-CN}
MIRRORLIST="https://archlinux.org/mirrorlist/?country=${COUNTRY}&protocol=http&protocol=https&ip_version=4&use_mirror_status=on"

ip addr
ping www.bing.com -c 5
curl www.bing.com
curl www.google.com

echo ">>>> install-base.sh: Clearing partition table on ${DISK}.."
/usr/bin/sgdisk --zap ${DISK}

echo ">>>> install-base.sh: Destroying magic strings and signatures on ${DISK}.."
/usr/bin/dd if=/dev/zero of=${DISK} bs=512 count=2048
/usr/bin/wipefs --all ${DISK}

echo ">>>> install-base.sh: Creating /root partition on ${DISK}.."
/usr/bin/sgdisk --new=1:0:0 ${DISK}

echo ">>>> install-base.sh: Setting ${DISK} bootable.."
/usr/bin/sgdisk ${DISK} --attributes=1:set:2

echo ">>>> install-base.sh: Creating /root filesystem (ext4).."
/usr/bin/mkfs.ext4 -O ^64bit -F -m 0 -q -L root ${ROOT_PARTITION}

echo ">>>> install-base.sh: Mounting ${ROOT_PARTITION} to ${TARGET_DIR}.."
/usr/bin/mount -o noatime,errors=remount-ro ${ROOT_PARTITION} ${TARGET_DIR}

echo ">>>> install-base.sh: Setting pacman ${COUNTRY} mirrors.."
curl -s "$MIRRORLIST" | sed 's/^#Server/Server/' >/etc/pacman.d/mirrorlist
cat /etc/pacman.d/mirrorlist

echo ">>>> install-base.sh: Bootstrapping the base installation.."
/usr/bin/pacstrap -K ${TARGET_DIR} base linux linux-firmware syslinux gptfdisk networkmanager sudo dhcpcd

/usr/bin/arch-chroot ${TARGET_DIR} syslinux-install_update -i -a -m
/usr/bin/sed -i "s|sda3|${ROOT_PARTITION##/dev/}|" "${TARGET_DIR}/boot/syslinux/syslinux.cfg"
/usr/bin/sed -i 's/TIMEOUT 50/TIMEOUT 10/' "${TARGET_DIR}/boot/syslinux/syslinux.cfg"

echo ">>>> install-base.sh: Generating the filesystem table.."
/usr/bin/genfstab -U ${TARGET_DIR} >"${TARGET_DIR}/etc/fstab"

cat <<-EOF >"${TARGET_DIR}/init.sh"
  set -x
  echo "init start"
  cat /etc/fstab
  ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
  hwclock --systohc
  locale-gen
  echo 'LANG=en_US.UTF-8' >/etc/locale.conf
  cat /etc/locale.conf
  echo 'KEYMAP=${KEYMAP}' >/etc/vconsole.conf
  cat /etc/vconsole.conf

  echo 'root:vagrant' | chpasswd

  useradd vagrant --user-group --create-home
  echo 'vagrant:vagrant' | chpasswd

  cat /etc/shadow

  mkdir -pm 700 /home/vagrant/.ssh
  echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys
  chmod 0600 /home/vagrant/.ssh/authorized_keys && chown -R vagrant:vagrant /home/vagrant/.ssh

  echo "vagrant ALL=NOPASSWD:ALL" >/etc/sudoers.d/vagrant
  cat /etc/sudoers.d/vagrant
  sudo systemctl enable NetworkManager.service
  sudo pacman -S openssh --noconfirm
  sudo systemctl enable sshd.service

  sudo pacman -S gnome --noconfirm
  sudo systemctl enable gdm.service
EOF

cat /mnt/init.sh
echo ">>>> install-base.sh: Entering chroot and configuring system.."
/usr/bin/arch-chroot ${TARGET_DIR} bash /init.sh
cat /etc/fstab
/usr/bin/umount ${TARGET_DIR}
