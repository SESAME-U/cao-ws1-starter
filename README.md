# Cloud Automation and Orchestration - Workshop 1

SESAME University, Computer Engineering, ING5. Week 4: an Ansible e-commerce playbook.

Deploy WordPress and WooCommerce on two servers with Ansible roles:

- `db1` runs MariaDB, created by the role `mariadb`;
- `web1` runs nginx, PHP-FPM, WordPress and WooCommerce, configured by the role `wordpress`.

Variables are in the inventory, secrets in Ansible Vault, configuration changes go through handlers, and a second run reports `changed=0`.

Individual work. About two hours in class; you can finish until the start of the week 5 session.

## Start

1. Open this repository in a Codespace, wait for `Toolbox ready`, run `make check`.
2. `make collections` installs the collection listed in `requirements.yml`.
3. Follow the Workshop 1 handout.

## Two ways to get servers

| Path | Command | Servers |
| --- | --- | --- |
| Azure (default) | `make azure-up` | web1 and db1, `Standard_B1s`, in one virtual network |
| Local (fallback) | `make local-up` | web1 and db1 as containers on one Docker network |

**Before you leave:** `make azure-down` (or `make local-down`), then stop your Codespace.

## What you write

| Path | What |
| --- | --- |
| `inventory/hosts.ini` | groups `web` and `db` |
| `inventory/group_vars/all/vars.yml` | variables that wire the two roles together |
| `inventory/group_vars/all/vault.yml` | three secrets, encrypted with `ansible-vault` |
| `roles/mariadb/`, `roles/wordpress/` | the two roles (`reference/` has boilerplate templates) |
| `playbooks/site.yml` | two plays, one per tier |
| `SUBMISSION.md` | answers |

## Grading

Autograded part, 16 points, on every push:

| Check | Points |
| --- | --- |
| Structure: two roles with tasks, handlers, defaults, meta and templates, used by `site.yml` | 2 |
| `ansible-lint` passes with the moderate profile | 2 |
| Converge: WordPress titled "SESAME Shop" with WooCommerce active on web1, the database on db1 only | 4 |
| Second run reports `changed=0`, and the site still works | 3 |
| Hand edits of the MariaDB and nginx configuration are reverted and trigger the handlers | 1 |
| Vault: secrets encrypted, never in clear, `no_log` on password tasks, `wp-config.php` mode 640 | 2 |
| `SUBMISSION.md` complete | 2 |

Instructor part, 4 points: you explain two lines of your code chosen by the instructor (2), and the quality of your answers and code organisation (2). Total 20.

The autograder runs your playbook against two fresh containers on GitHub, not against your Azure VMs. Run the same checks yourself with `make test`.
