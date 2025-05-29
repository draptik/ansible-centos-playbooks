# Ansible CentOS Setup with Rootless Podman

This repository automates the setup of a CentOS Stream 10 VM using Ansible. It performs:

- Base system setup with useful tools and configuration
- Rootless Podman installation integration

---

## 📚 Requirements

- Ansible 2.14+ (tested with Ansible Core 2.18)
- CentOS Stream 10 VM
- Python 3 installed on the VM (`/usr/bin/python3`)
- SSH access to the VM using a non-root user (e.g., `ansible_user`)
- The Ansible user **must be in the `wheel` group with passwordless sudo**
  - This is required for Ansible to run privileged tasks non-interactively
  - You can configure it manually with:

    ```bash
    usermod -aG wheel ansible_user
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel-nopasswd
    chmod 0440 /etc/sudoers.d/wheel-nopasswd
    ```


---

## 📁 Project Structure

```text
ansible-centos-playbooks/
├── ansible.cfg                    # Ansible config (inventory path, roles path, etc.)
├── inventories/
│   └── development/
│       └── hosts.ini              # Inventory file for development environment
├── playbooks/
│   ├── setup-base.yml             # Playbook: Base system setup
│   └── install-podman.yml         # Playbook: Podman install and config
├── roles/
│   ├── common/
│   │   └── tasks/
│   │       └── main.yml           # Tasks for CentOS base system setup
│   └── podman/
│       └── tasks/
│           └── main.yml           # Tasks for rootless Podman setup
├── site.yml                       # Aggregates both playbooks
├── run-playbook-tools.sh          # Script to run setup-base.yml
└── README.md                      # This documentation
```

---

## ✅ What It Does

### CentOS Base Setup (`common` role)

- Enables CRB and EPEL repositories
- Removes `subscription-manager`
- Installs development tools group
- Installs CLI tools:
  - `git`
  - `tmux`
  - `jq`
  - `bat`
  - `ripgrep`
- Adds a global alias:

  ```bash
  alias l='ls -alh'
  ```

### Podman Setup (`podman` role)

- Installs `podman`, `slirp4netns`, and `fuse-overlayfs`
- Enables systemd lingering for the user so containers can run after logout
- Creates `~/.config/systemd/user/`
- Starts and enables `podman.socket` (rootless API socket)
- Uses systemd user scope and sets `XDG_RUNTIME_DIR` automatically

---

## 🚀 Usage

### 1. Inventory Setup

Edit `inventories/development/hosts.ini`:

```ini
[centos]
moth ansible_host=192.168.1.100 ansible_user=ansible_user
```

Make sure:

- The `ansible_user` user exists
- `ansible_user` is in the `wheel` group
- SSH access is available

---

### 2. Run Base Setup Only

```bash
./run-playbook-tools.sh
```

This runs `playbooks/setup-base.yml` via the `common` role.

---

### 3. Run Podman Setup Only

```bash
ansible-playbook playbooks/install-podman.yml
```

This runs the `podman` role to configure rootless Podman.

---

### 4. Run Full Setup

```bash
ansible-playbook site.yml
```

This runs both the base system and Podman setup.

---

## 🔍 Verifying Podman Setup

SSH into the target system as the user (e.g., `ansible_user`), and run:

```bash
podman info --log-level=error
systemctl --user status podman.socket
```

You can also test with:

```bash
podman run --rm docker.io/library/hello-world
```

---

## 🤝 License

MIT License – use and adapt freely.
