# TODOs

- sanitize ansible user privileges
  - currently there is `ansible_user`, `home_dir`, `xdg_home_dir`
  - and a lot of `become_user` with `true` or `false`
  - create dedicated users for some tasks/roles
