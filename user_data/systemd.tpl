#!/bin/bash
cat << EOF > /etc/systemd/system/sshd_worker.socket
[Unit]
Description=SSH Socket for Per-Connection docker ssh container

[Socket]
ListenStream=${bastion_ssh_port}
Accept=true
MaxConnections=1024

[Install]
WantedBy=sockets.target
EOF

cat << EOF > /etc/systemd/system/sshd_worker@.service
[Unit]
Description=SSH Per-Connection docker ssh container

[Service]
Type=simple
ExecStart=/bin/sh -ec "/usr/bin/docker run --rm -i --hostname ${bastion_host_name}-\$(echo %i | cut -d- -f1) -v /dev/log:/dev/log -v /opt/iam_helper:/opt:ro sshd_worker"
StandardInput=socket
RuntimeMaxSec=43200

[Install]
WantedBy=multi-user.target
EOF

#set host sshd to run on port ${host_ssh_port} and restart service
sed -i 's/#Port[[:blank:]]22/Port\ ${host_ssh_port}/'  /etc/ssh/sshd_config
systemctl restart sshd.service
systemctl enable sshd_worker.socket
systemctl start sshd_worker.socket
systemctl daemon-reload

cat << EOF > /etc/cron.hourly/sshd_failed_connection_cleanup
#!/bin/sh
systemctl reset-failed "sshd_worker@*.service"
EOF
chmod 755 /etc/cron.hourly/sshd_failed_connection_cleanup

#set hostname to match dns
hostnamectl set-hostname ${bastion_host_name}
