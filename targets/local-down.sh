#!/usr/bin/env bash
# Remove the local workshop containers and their network.
set -euo pipefail
docker rm -f web1 db1 >/dev/null 2>&1 || true
docker network rm cao-net >/dev/null 2>&1 || true
echo "Local targets removed."
