#!/bin/bash

mkdir ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

if [[ -z "$PUBLIC_KEY" ]]; then
  ln -sf /dev/stderr /tmp/key
  ln -sf ~/.ssh/authorized_keys /tmp/key.pub
  yes | ssh-keygen -t rsa -b 2048 -N '' -qf /tmp/key > /dev/null
  rm /tmp/key*
else
  echo "$PUBLIC_KEY" > ~/.ssh/authorized_keys
fi

mkdir -p /var/run/sshd
/usr/sbin/sshd -D -e
