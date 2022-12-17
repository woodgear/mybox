variable "md5sum" {
  type    = string
  default = ""
}

variable "mirror" {
  type    = string
  default = "ubuntu-22.04.1-desktop-amd64.autoinstall.iso"
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

source "qemu" "ubuntu-2204-desktop-base" {
   headless         = false
  accelerator      = "kvm"
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
  ssh_timeout      = "20m"
  ssh_username     = "${var.user}"
}

build {
  sources = ["source.qemu.ubuntu-2204-desktop-base"]

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = ["data/ubuntu-2204-desktop.provision.sh"]
  }

  post-processor "vagrant" {
    include = ["data/Vagrantfile.spec"]
    output  = "../boxes/ubuntu-2204-desktop-base:v0.0.1.box"
  }
}
