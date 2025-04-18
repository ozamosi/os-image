#!/bin/bash

set -ouex pipefail

### Install packages

curl -L https://download.docker.com/linux/fedora/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo

dnf5 install -y gstreamer1-plugins-bad-free-extras docker-ce docker-ce-cli \
     containerd.io docker-buildx-plugin tailscale
