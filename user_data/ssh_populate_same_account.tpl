#!/bin/bash
mkdir -p /opt/iam_helper/
cat << 'EOF' > /opt/iam_helper/ssh_populate.sh
#!/bin/bash
export AWS_REGION="${aws_region}"
(
/opt/iam-authorized-keys | while read line
do
    username=$( echo $line | sed -e 's/^# //' -e 's/+/plus/g' -e 's/=/equal/g' -e 's/,/comma/g' -e 's/@/at/g' -e 's/\./dot/g' )
    useradd -m -s /bin/bash -k /etc/skel $username
    usermod -a -G sudo $username
    echo $username\ 'ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$username
    chmod 0440 /etc/sudoers.d/$username
    mkdir /home/$username/.ssh
    read line2
    echo $line2 >> /home/$username/.ssh/authorized_keys
    chown -R $username:$username /home/$username/.ssh
    chmod 700 /home/$username/.ssh
    chmod 0600 /home/$username/.ssh/authorized_keys
done

) > /dev/null 2>&1

/usr/sbin/sshd -i
EOF
chmod 0700 /opt/iam_helper/ssh_populate.sh
