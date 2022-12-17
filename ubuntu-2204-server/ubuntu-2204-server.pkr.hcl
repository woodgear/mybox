variable "md5sum" {
  type    = string
  default = "e8d2a77c51b599c10651608a5d8c286f"
}

variable "mirror" {
  type    = string
  default = "http://0.0.0.0:8000/ubuntu-22.04.1-live-server-amd64.iso"
}

variable "name" {
  type    = string
  default = "ubuntu-22.04.1-live-server-amd64.iso" 
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
  default = "ubuntu-2204-server.ks.cfg"
}
source "qemu" "ubuntu-2204-server-base" {
   headless         = false
  accelerator      = "kvm"
  boot_command     = [
      "<wait>",
      "c<enter>",
      "linux /casper/vmlinuz quiet",
      " autoinstall",
      " \"ds=nocloud-net",
      ";s=http://{{.HTTPIP}}:{{.HTTPPort}}/\"",
      " ---",
      "<enter><wait>",
      "initrd /casper/initrd",
      "<enter><wait>",
      "boot<enter><wait>"
    ]
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
  sources = ["source.qemu.ubuntu-2204-server-base"]

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = ["data/ubuntu-2204-server.provision.sh"]
  }

  post-processor "vagrant" {
    include = ["data/Vagrantfile.spec"]
    output  = "../boxes/ubuntu-2204-server-base:v0.0.1.box"
  }
}
