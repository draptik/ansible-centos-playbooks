# Ansible CentOS Base Setup

This project automates the initial setup of a CentOS Stream 10 VM using Ansible. It prepares the system for container-based workloads (e.g., Podman, Nextcloud) by configuring repositories, installing essential tools, and applying basic system preferences.

## 📚 Requirements

- Ansible 2.14+ (tested with Ansible Core 2.18)
- Python 3 installed on the target (`/usr/bin/python3`)
- SSH access to the CentOS target machine(s)
  - `sudo` access for the remote user (`patrick`)
  - Ensure to `ssh-copy-id ~/.ssh/some-key.pub username@target-system` before applying any playbook.
- Ensure the ansible user has passwordless sudo permissions.
  - The vm user was setup with sudo permissions during the vm setup
  - The vm user is part of the wheel group, then:

    ```sh
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/wheel-nopasswd
    ```

## 📁 Project Structure

```text
ansible-centos-playbooks/
├── ansible.cfg                     # Ansible configuration (inventory, roles path, etc.)
├── inventories/
│   └── development/
│       └── hosts.ini              # List of target hosts
├── playbooks/
│   └── setup-base.yml            # Entry point playbook for base system setup
├── roles/
│   └── common/
│       └── tasks/
│           └── main.yml          # Role logic for base system configuration
├── site.yml                       # Aggregates multiple playbooks (optional)
├── run-playbook-tools.sh          # Shell script to run the base setup playbook
└── README.md                      # This documentation file
```

---

## ✅ What It Does

The `common` role performs the following tasks on the target CentOS VM:

- Enables CRB and EPEL repositories
- Removes the `subscription-manager` package
- Installs development tools group
- Installs common CLI utilities:
  - git
  - tmux
  - jq
  - bat
  - ripgrep
- Sets a global shell alias:

  ```bash
  alias l='ls -alh'
  ```
- Prepares the system for running containerized services like Podman and Nextcloud

---

## 🚀 Usage

### 1. Set up your inventory

Edit `inventories/development/hosts.ini` to list your VM(s). Example:

```ini
[moth]
moth ansible_host=192.168.1.100 ansible_user=patrick
```

Make sure the `patrick` user is in the `wheel` group and has `sudo` access.

### 2. Run the base setup playbook

```bash
./run-playbook-tools.sh
```

This will run the `playbooks/setup-base.yml` playbook, which applies the `common` role to the target VM.

---

## 🛠️ Next Steps

Extend the project by adding more roles and playbooks:

- `roles/podman` – Install and configure rootless Podman
- `roles/nextcloud` – Deploy and manage a Nextcloud instance
- `roles/database` – Set up MariaDB or PostgreSQL
- `roles/reverse_proxy` – Handle HTTPS with Caddy, Nginx, or Traefik

Other enhancements:

- Add separate inventories for staging and production
- Use `ansible-vault` to secure secrets
- Modularize common setup tasks into reusable roles
