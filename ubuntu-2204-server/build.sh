#!/bin/bash
function build() (
  cd ./ubuntu-2204-server
  packer build ./ubuntu-2204-server.pkr.hcl
)
build
