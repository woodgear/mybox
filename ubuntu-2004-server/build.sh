#!/bin/bash

function build() (
  packer build ./ubuntu-2004-server.pkr.hcl
  cd ../boxes
  vagrant box add ./ubuntu-2004-server-base:v0.0.1.box --name ubuntu-2004-server-base:v0.0.1 --force
)
build
