#!/bin/bash
DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y curl
curl -OL https://github.com/hierynomus/iam-authorized-keys-command/releases/download/v${iam_authorized_keys_version}/iam-authorized-keys_${iam_authorized_keys_version}_linux_amd64.tar.gz
tar xvzf iam-authorized-keys_${iam_authorized_keys_version}_linux_amd64.tar.gz
mkdir -p /opt/iam_helper
cp iam-authorized-keys /opt/iam_helper
chmod 400 /opt/iam_helper
