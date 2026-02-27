#!/usr/bin/env bash
set -euo pipefail

echo "=== Setting up ClawHub Workbench ==="

# Install npm + molthub globally
npm install -g npm@latest
npm install -g molthub

# Install Python pyyaml for frontmatter validation
pip install --quiet pyyaml

# Create wrapper that intercepts 'molthub install' with a warning
# Blocks third-party skill installs unless ALLOW_INSTALL=1 is set
cat > /usr/local/bin/molthub-safe <<'WRAPPER'
#!/usr/bin/env bash
if [[ "${1:-}" == "install" && "${ALLOW_INSTALL:-0}" != "1" ]]; then
  echo ""
  echo "  BLOCKED: molthub install is disabled in this workbench."
  echo ""
  echo "  11.9% of ClawHub skills were malicious during ClawHavoc."
  echo "  To install anyway: ALLOW_INSTALL=1 molthub install <skill>"
  echo ""
  exit 1
fi
exec molthub "$@"
WRAPPER
chmod +x /usr/local/bin/molthub-safe

# Set up alias in shell profile
echo 'alias molthub="molthub-safe"' >> ~/.bashrc

echo ""
echo "  Workbench ready."
echo "  Run 'make help' to see available commands."
echo ""
