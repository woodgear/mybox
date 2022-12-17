#!/bin/bash

# Update first
apt update -y

# Set build date
date > /etc/vagrant_box_build_time

# Install Vagrant SSH key
mkdir -pm 700 /home/vagrant/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys && chown -R vagrant:vagrant /home/vagrant/.ssh

# Seal the system
rm -f /etc/ssh/ssh_host_*
rm -rf /tmp/*


#disable reverse dns lookups on sshd
echo "UseDNS no" >> /etc/ssh/sshd_config
ip addr
whoami
apt install vim tmux -y

echo "vagrant ALL=NOPASSWD:ALL" >/etc/sudoers.d/vagrant
cat /etc/sudoers.d/vagrant
rm /etc/machine-id
touch /etc/machine-id
netcfg=$(
  cat <<EOF
network:
  ethernets:
    all-en:
      match:
        name: "ens*"
      dhcp4: true
      dhcp-identifier: mac
  version: 2
EOF
  )
echo "$netcfg" | tee /etc/netplan/02-use-mac-when-dhcp.yaml
cat /etc/netplan/02-use-mac-when-dhcp.yaml
sudo rm /etc/machine-id
sudo touch /etc/machine-id
sudo ssh-keygen -A
sudo service ssh --full-restart

exit 0