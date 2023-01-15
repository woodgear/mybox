#!/bin/bash
function run() {
  packer build ./centos-7-server.pkr.hcl
  cd ../boxes
  vagrant box add ./centos7-server-base:v0.0.1.box --name centos7-server-base:v0.0.1 --force
}

run
