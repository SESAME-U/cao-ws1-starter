#!/usr/bin/env bash
# Autograded checks for Workshop 1, run against the two CI containers.
#   converge   the playbook runs; WordPress and WooCommerce on web1, the
#              database on db1 only
#   idempotent a second run reports changed=0, and the site still works
#   handlers   hand edits of the MariaDB and nginx configs are reverted and
#              trigger the handlers
#   vault      secrets encrypted in Git, hidden from logs, delivered safely
set -uo pipefail
source "$(dirname "$0")/common.sh"
mode="${1:-converge}"

check_state() {
  t=$(curl -fsS http://127.0.0.1:8081/ | grep -o '<title>[^<]*') \
    || { echo "web1: no page on port 8081"; return 1; }
  grep -q "SESAME Shop" <<<"$t" || { echo "web1: site title is not 'SESAME Shop' ($t)"; return 1; }
  wp plugin is-active woocommerce >/dev/null 2>&1 || { echo "web1: WooCommerce is not active"; return 1; }
  docker exec web1 dpkg -s mariadb-server >/dev/null 2>&1 && { echo "web1: MariaDB must run on db1 only"; return 1; }
  docker exec db1 mysql -N -e "SHOW DATABASES LIKE 'wordpress'" 2>/dev/null | grep -q wordpress \
    || { echo "db1: no database named wordpress"; return 1; }
  docker exec web1 grep -Eq "DB_HOST'?,[[:space:]]*'db1'" /var/www/wordpress/wp-config.php \
    || { echo "web1: wp-config.php must use DB_HOST 'db1' (the db host's internal_address)"; return 1; }
  return 0
}

case "$mode" in
  converge)
    play --syntax-check >/dev/null || exit 1
    play || exit 1
    check_state || exit 1
    echo "OK: WordPress and WooCommerce on web1, database on db1"
    ;;
  idempotent)
    out=$(play) || { echo "$out"; exit 1; }
    echo "$out" | sed -n '/PLAY RECAP/,$p'
    if echo "$out" | sed -n '/PLAY RECAP/,$p' | grep -Eq 'changed=[1-9]'; then
      echo "Second run changed something: the playbook is not idempotent."; exit 1
    fi
    check_state >/dev/null || { echo "The hosts are not in the expected state (see the converge check)."; exit 1; }
    echo "OK: second run changed nothing"
    ;;
  handlers)
    docker exec db1 sh -c 'echo "# manual edit" >> /etc/mysql/mariadb.conf.d/60-cao.cnf' \
      || { echo "db1: /etc/mysql/mariadb.conf.d/60-cao.cnf does not exist"; exit 1; }
    docker exec web1 sh -c 'echo "# manual edit" >> /etc/nginx/sites-available/default'
    out=$(play) || { echo "$out"; exit 1; }
    grep -q "RUNNING HANDLER \[mariadb" <<<"$out" || { echo "A changed MariaDB config must notify a handler of the mariadb role."; exit 1; }
    grep -q "RUNNING HANDLER \[wordpress" <<<"$out" || { echo "A changed nginx config must notify a handler of the wordpress role."; exit 1; }
    docker exec db1 grep -q "manual edit" /etc/mysql/mariadb.conf.d/60-cao.cnf && { echo "db1: the manual edit is still there"; exit 1; }
    docker exec web1 grep -q "manual edit" /etc/nginx/sites-available/default && { echo "web1: the manual edit is still there"; exit 1; }
    check_state || exit 1
    echo "OK: drift fixed, handlers ran, site still up"
    ;;
  vault)
    vf=inventory/group_vars/all/vault.yml
    [[ -f $vf ]] || { echo "$vf is missing"; exit 1; }
    head -1 "$vf" | grep -q '^\$ANSIBLE_VAULT;' || { echo "$vf is not encrypted"; exit 1; }
    plain=$(ansible-vault view "$vf") || { echo "cannot decrypt $vf with the workshop vault password"; exit 1; }
    for v in vault_db_password vault_wp_admin_password vault_wp_secret_seed; do
      val=$("${LAB_PYTHON:-python3}" -c "import yaml,sys; print((yaml.safe_load(sys.stdin) or {}).get('$v') or '')" <<<"$plain")
      [[ ${#val} -ge 12 ]] || { echo "$vf must define $v (at least 12 characters)"; exit 1; }
      if grep -rqF --exclude=vault.yml -- "$val" inventory playbooks roles; then
        echo "The value of $v appears in clear text outside vault.yml."; exit 1
      fi
    done
    grep -rq 'no_log: true' roles/mariadb/tasks || { echo "roles/mariadb: the task that sets the DB password needs no_log: true"; exit 1; }
    grep -rq 'no_log: true' roles/wordpress/tasks || { echo "roles/wordpress: tasks that handle passwords need no_log: true"; exit 1; }
    dbpw=$("${LAB_PYTHON:-python3}" -c "import yaml,sys; print(yaml.safe_load(sys.stdin)['vault_db_password'])" <<<"$plain")
    docker exec web1 grep -qF "'$dbpw'" /var/www/wordpress/wp-config.php \
      || { echo "web1: wp-config.php does not contain the vault database password"; exit 1; }
    m=$(docker exec web1 stat -c '%a %U' /var/www/wordpress/wp-config.php)
    [[ $m == "640 www-data" ]] || { echo "web1: wp-config.php is '$m', expected '640 www-data'"; exit 1; }
    echo "OK: secrets encrypted in Git and delivered safely"
    ;;
  *) echo "usage: $0 converge|idempotent|handlers|vault"; exit 2 ;;
esac
