# Ansible Playbooks for CentOS Stream 10

Some ideas for setting up CentOS VMs with Ansible...

- Ensure to `ssh-copy-id ~/.ssh/id_rsa.pub username@target-system` before applying any playbook.
- Ensure the ansible user has passwordless sudo permissions.
  - The vm user was setup with sudo permissions during the vm setup
  - The vm user is part of the wheel group, then:
    ```sh
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/wheel-nopasswd
    ```
