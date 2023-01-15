#!/bin/bash
function run() {
  packer build ./arch-template.json
  cd ../boxes
  vagrant box add ./arch-desktop:v0.0.1.box --name arch-desktop:v0.0.1 --force
}

run
