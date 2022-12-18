#!/bin/bash

function build() (
  cd ./ubuntu-2004-server
  #   packer build ./ubuntu-2004-server.pkr.hcl
  vagrant box add $PWD/../boxes/ubuntu-2004-server-base:v0.0.1.box --name ubuntu-2004-server-base:v0.0.1
)
build
