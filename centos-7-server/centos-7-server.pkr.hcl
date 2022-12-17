variable "md5sum" {
  type    = string
  default = "a4711c4fa6a1fb32bd555fae8d885b12"
}

variable "mirror" {
  type    = string
  default = "http://0.0.0.0:8000/CentOS-7-x86_64-Minimal-2009.iso"
}

variable "password" {
  type    = string
  default = "vagrant"
}

variable "size" {
  type    = string
  default = "50G"
}

variable "user" {
  type    = string
  default = "vagrant"
}
variable "kickstart" {
  type    = string
  default = "centos-7-server.ks.cfg"
}

source "qemu" "centos7-server-base" {
  headless         = false
  accelerator      = "kvm"
  boot_command     = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.kickstart}<enter><wait>"]
  boot_wait        = "5s"
  disk_interface   = "virtio"
  disk_size        = "${var.size}"
  memory           = 8096
  format           = "qcow2"
  http_directory   = "data"
  iso_checksum     = "md5:${var.md5sum}"
  iso_url          = "${var.mirror}"
  shutdown_command = "echo '${var.password}'|sudo -S shutdown -P now"
  ssh_password     = "${var.password}"
  ssh_port         = 22
  ssh_timeout      = "10m"
  ssh_username     = "${var.user}"
}

build {
  sources = ["source.qemu.centos7-server-base"]

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = ["data/centos-7-server.provision.sh"]
  }

  post-processor "vagrant" {
    include = ["data/Vagrantfile.spec"]
    output  = "../boxes/centos7-server-base:v0.0.1.box"
  }
}
