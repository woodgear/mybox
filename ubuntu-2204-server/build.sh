#!/bin/bash
function build() (
  packer build ./ubuntu-2204-server.pkr.hcl
  cd ../boxes
  vagrant box add ./ubuntu-2204-server-base:v0.0.1.box --name ubuntu-2204-server-base:v0.0.1 --force
)
build
