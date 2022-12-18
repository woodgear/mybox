# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://docs.vagrantup.com.

Vagrant.configure(2) do |config|
  config.vm.provider :libvirt do |libvirt|
    libvirt.socket = "/var/run/libvirt/libvirt-sock"
  end

  config.vm.define :vm1 do |vm1|
    vm1.vm.provider :libvirt do |domain|
      domain.driver = "kvm"
    end
  end
end
