#!/usr/bin/env bash
echo 'root:vagrant' | chpasswd

useradd vagrant --user-group --create-home
echo 'vagrant:vagrant' | chpasswd

echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_vagrant
/usr/bin/chmod 0440 /etc/sudoers.d/10_vagrant
/usr/bin/systemctl start sshd.service
