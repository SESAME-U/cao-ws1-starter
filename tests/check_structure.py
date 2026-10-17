"""Workshop 1: the project is organised in two roles used by site.yml."""
import os
import sys

import yaml

os.chdir(os.path.join(os.path.dirname(__file__), ".."))
errors = []

for role in ("mariadb", "wordpress"):
    base = f"roles/{role}"
    for f in ("tasks/main.yml", "handlers/main.yml", "defaults/main.yml", "meta/main.yml"):
        if not os.path.isfile(f"{base}/{f}"):
            errors.append(f"{base}/{f} is missing")
    tdir = f"{base}/templates"
    if not os.path.isdir(tdir) or not any(n.endswith(".j2") for n in os.listdir(tdir)):
        errors.append(f"{tdir}/ needs at least one .j2 template")

try:
    plays = yaml.safe_load(open("playbooks/site.yml")) or []
except FileNotFoundError:
    plays = []
    errors.append("playbooks/site.yml is missing")


def role_names(play):
    names = []
    for r in play.get("roles") or []:
        names.append(r if isinstance(r, str) else (r.get("role") or r.get("name")))
    return names


uses = {(p.get("hosts"), n) for p in plays if isinstance(p, dict) for n in role_names(p)}
if ("db", "mariadb") not in uses:
    errors.append("site.yml needs a play on hosts: db that uses the role mariadb")
if ("web", "wordpress") not in uses:
    errors.append("site.yml needs a play on hosts: web that uses the role wordpress")

try:
    req = yaml.safe_load(open("requirements.yml")) or {}
    names = [c if isinstance(c, str) else c.get("name") for c in req.get("collections", [])]
    if not any(n and n.startswith(("ansible.mariadb", "ansible.mysql", "community.mysql")) for n in names):
        errors.append("requirements.yml must list the database collection you use")
except FileNotFoundError:
    errors.append("requirements.yml is missing")

if errors:
    print("\n".join("FAIL: " + e for e in errors))
    sys.exit(1)
print("OK: two roles, used by site.yml")
