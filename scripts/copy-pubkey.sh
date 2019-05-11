#!/bin/bash

if ! [ -f ~/.ssh/ansible.pub ]; then
  echo "No ansible.pub key found"
  exit 1
fi

input=${1:-$(cat inventory/hosts)}

for host in $input; do
  echo -n "$host username: "
  read user
  cat ~/.ssh/ansible.pub | ssh $host -l $user "mkdir -p .ssh; cat >> ~/.ssh/authorized_keys;"

  if ! grep -q "Host $host" ~/.ssh/config; then
    echo >> ~/.ssh/config
    echo "Host $host" >> ~/.ssh/config
    echo "IdentityFile ~/.ssh/ansible" >> ~/.ssh/config
  fi
done
