#!/usr/bin/env bash
# Used by the autograder (and by "make test"): start web1 and db1 as fresh
# containers and write a CI inventory next to yours, so your group_vars apply.
# The GitHub runner cannot reach your Azure VMs, so it never uses hosts.ini.
set -euo pipefail
cd "$(dirname "$0")/.."

export KEY="$PWD/.ci_key"
rm -f "$KEY" "$KEY.pub"
ssh-keygen -q -t ed25519 -N "" -f "$KEY"
./targets/local-up.sh >/dev/null

cat > inventory/ci.ini <<INI
[web]
web1 ansible_host=127.0.0.1 ansible_port=2221 ansible_ssh_private_key_file=$KEY internal_address=web1 wordpress_site_url=http://localhost:8081

[db]
db1 ansible_host=127.0.0.1 ansible_port=2222 ansible_ssh_private_key_file=$KEY internal_address=db1
INI

# The workshop vault password (see the handout). Lab only: in real life a
# vault password comes from a secret store, never from a script in Git.
printf '%s\n' "sesame-cao-ws1" > .ci_vault_pass
chmod 600 .ci_vault_pass

for p in 2221 2222; do
  for _ in $(seq 1 30); do
    ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -i "$KEY" -p "$p" azureuser@127.0.0.1 true && break
    sleep 1
  done
done
echo "CI targets ready."
