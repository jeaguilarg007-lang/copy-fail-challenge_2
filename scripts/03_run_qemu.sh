cat << 'EOF' > scripts/03_run_qemu.sh
#!/usr/bin/env bash
# Arranca la VM vulnerable en QEMU (modo consola serial)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KERNEL_DIR="$WORKSPACE_ROOT/kernel"
BUILD_DIR="$KERNEL_DIR/build"
INITRAMFS_SRC="$KERNEL_DIR/initramfs"

# Asegurar que el directorio build exista
mkdir -p "$BUILD_DIR"

echo "Empaquetando initramfs de forma directa..."
cd "$INITRAMFS_SRC"
find . -print0 | cpio --null -ov --format=newc 2>/dev/null | gzip -9 > "$BUILD_DIR/initramfs.cpio.gz"
cd "$WORKSPACE_ROOT"

BZIMAGE="$BUILD_DIR/bzImage_vuln"
INITRAMFS="$BUILD_DIR/initramfs.cpio.gz"

STUDENT_ID="${STUDENT_ID:-$(git config user.name 2>/dev/null | tr ' ' '-' | tr -cd '[:alnum:]-' | head -c 16)}"
STUDENT_ID="${STUDENT_ID:-unknown}"

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Arrancando VM vulnerable — CVE-2026-31431                  ║${NC}"
echo -e "${GREEN}║   Salir de QEMU: Ctrl+A  luego  X                            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

exec qemu-system-x86_64 \
  -nographic \
  -no-reboot \
  -kernel "$BZIMAGE" \
  -initrd "$INITRAMFS" \
  -append "console=ttyS0 init=/bin/sh quiet STUDENT_ID=${STUDENT_ID}" \
  -m 2048M \
  -smp 4
EOF