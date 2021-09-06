#!/bin/bash
DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y curl
curl -OL https://github.com/hierynomus/iam-authorized-keys-command/releases/download/v2.0.0/iam-authorized-keys_2.0.0_linux_amd64.tar.gz
tar xvzf iam-authorized-keys_2.0.0_linux_amd64.tar.gz
mkdir -p /opt/iam_helper
cp iam-authorized-keys /opt/iam_helper
