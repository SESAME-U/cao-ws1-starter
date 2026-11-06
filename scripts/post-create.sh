#!/usr/bin/env bash
# Runs once when the codespace is created. Installs the tools that are not
# available as dev container features. Safe to re-run (idempotent).
set -euo pipefail

echo "==> Installing Ansible (user scope, via pipx)"
if ! command -v ansible >/dev/null 2>&1; then
  command -v pipx >/dev/null 2>&1 || sudo apt-get install -y -qq pipx
  pipx ensurepath >/dev/null
  pipx install --include-deps ansible >/dev/null
else
  echo "    already installed, skipping"
fi

echo "==> Installing ansible-lint (user scope, via pipx)"
command -v ansible-lint >/dev/null 2>&1 || python3 -m pipx install ansible-lint >/dev/null

echo "==> Installing the collections of requirements.yml"
ansible-galaxy collection install -r requirements.yml >/dev/null || echo "    failed: run  make collections  later"

echo "==> Installing lab test tools (pytest, PyYAML, yamllint)"
TOOLS_VENV="$HOME/.local/share/cao-ws1/venv"
python3 -m venv "$TOOLS_VENV"
"$TOOLS_VENV/bin/python" -m pip install --quiet pytest pyyaml yamllint

echo "==> Creating your lab SSH key (~/.ssh/cao_lab) if missing"
[[ -f "$HOME/.ssh/cao_lab" ]] || ssh-keygen -q -t ed25519 -N "" -f "$HOME/.ssh/cao_lab" -C "cao-lab"

echo "==> Installing kind (Kubernetes in Docker)"
KIND_VERSION="v0.27.0"
if ! command -v kind >/dev/null 2>&1; then
  curl -fsSLo /tmp/kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
  sudo install -m 0755 /tmp/kind /usr/local/bin/kind
  rm -f /tmp/kind
else
  echo "    already installed, skipping"
fi

echo "==> Making course scripts executable"
chmod +x scripts/*.sh targets/*.sh

echo
echo "Toolbox ready. Run:  make check"
