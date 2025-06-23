# Ansible CentOS Setup with Rootless Podman

This repository automates the setup of a CentOS Stream 10 VM using Ansible. It performs:

- CentOS base system setup (repositories, dev tools)
- General Linux configuration (aliases, CLI utilities)
- Rootless Podman installation and integration
- Readeck in container

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
├── inventories
│   └── development
│       ├── group_vars
│       │   ├── all
│       │   │   ├── all.yml        # Variables
│       │   │   └── vault.yml      # Ansible vault
│       │   └── readeck
│       │       ├── 0_setup.yml    # Readeck setup variables
│       │       └── 1_backup.yml   # Readeck backup variables
│       └── hosts.ini              # Inventory file for development environment
├── playbooks
│   ├── install-caddy.yml          # Playbook: Caddy install and config
│   ├── install-cockpit.yml        # Playbook: Cockpit install and config
│   ├── install-podman.yml         # Playbook: Podman install and config
│   ├── install-readeck-backup.yml # Playbook: Readeck backup
│   ├── install-readeck.yml        # Playbook: Readeck setup
│   └── setup-base.yml             # Playbook: Base system setup (common + system)
├── roles
│   ├── caddy
│   │   ├── tasks
│   │   │   └── main.yml           # Reverse Proxy
│   │   └── templates
│   │       └── Caddyfile.j2       # Caddy's config file
│   ├── cockpit
│   │   └── tasks
│   │       └── main.yml           # Podman's cockpit
│   ├── common
│   │   └── tasks
│   │       └── main.yml           # CentOS-specific setup (repos, dev tools)
│   ├── podman
│   │   └── tasks
│   │       └── main.yml           # Rootless Podman setup
│   ├── readeck
│   │   ├── tasks
│   │   │   └── main.yml           # Readeck setup
│   │   └── templates
│   │       └── config.toml.j2     # Readeck config
│   ├── readeck-backup
│   │   ├── tasks
│   │   │   └── main.yml           # Readeck backup
│   │   └── templates
│   │       ├── backup.sh.j2
│   │       └── restore.sh.j2
│   └── system
│       └── tasks
│           └── main.yml           # General config (CLI tools, aliases)
├── site.yml                       # Aggregates all playbooks
├── run-all.sh                     # Script to run all playbooks
└── README.md                      # This documentation
```

---

## ✅ What It Does

### CentOS Setup (`common` role)

- Enables CRB and EPEL repositories
- Removes `subscription-manager`
- Installs the "Development Tools" group

### General Linux Setup (`system` role)

- Installs useful CLI tools:
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

### Cockpit Setup (`cockpit` role)

- Installs `cockpit` (dashboard for `podman`)

### Caddy Setup (`caddy` role)

- Installs `caddy` (reverse proxy)
- Since Caddy's builtin support for Let's Encrypt requires port 80 to renew the certificates, we have to run this container as root.

### Readeck Setup (roles `readeck` and `readeck-backup`)

- Readeck is a "read-it-later" service ("Pocket" replacement)
- Backup via `restic`
  - Prerequisites: working ssh connection to backup server

---

## 🚀 Usage

### 1. Inventory Setup

Edit `inventories/development/hosts.ini`:

```ini
[centos]
moth
```

Make sure:

- The `ansible_user` user exists
- `ansible_user` is in the `wheel` group with passwordless sudo
- SSH access is available

---

### 2. Adapt the Ansible Vault

The file `inventories/development/group_vars/all/all.yml` references some variables from the vault. All these variables start with `vault_`.

```bash
ansible-vault edit inventories/development/group_vars/all/vault.yml
```

The `ansible-vault` command requires a file `vault_pass.txt`, which is obviously excluded from git.

---

### 3. Adapt home network settings

Not part of this documentation (i.e. Router settings, domain name, etc).

---

### 4. Run Full Setup

```bash
./run-all.sh
```

This runs all roles. In case one wishes to run only certain playbooks: comment the other playbooks in file `site.yml`.
