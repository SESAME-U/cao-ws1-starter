# Shared settings for the Workshop 1 checks. Sourced, not run.
cd "$(dirname "${BASH_SOURCE[0]}")/.."
if [[ -f inventory/ci.ini ]]; then INV="inventory/ci.ini"; else INV="inventory/hosts.ini"; fi
if [[ -f .ci_vault_pass ]]; then export ANSIBLE_VAULT_PASSWORD_FILE="$PWD/.ci_vault_pass"; fi
# EXTRA_ARGS: optional, e.g. download mirrors for an offline classroom.
read -r -a EXTRA <<<"${EXTRA_ARGS:-}"
play() { ansible-playbook -i "$INV" playbooks/site.yml "${EXTRA[@]}" "$@"; }
wp() { docker exec -u www-data web1 wp --path=/var/www/wordpress "$@"; }
