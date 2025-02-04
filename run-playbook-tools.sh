#!/bin/bash

INVENTORY='inventory.ini'
PLAYBOOK='playbook-tools.yml'

ansible-playbook \
  --inventory "${INVENTORY}" \
  "${PLAYBOOK}"
