#cloud-config
users:
  - name: ${host_ssh_username}
    home: /home/${host_ssh_username}
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - ${host_ssh_public_key}

cloud_final_modules:
- [scripts-user, always]
