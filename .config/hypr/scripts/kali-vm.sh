#!/bin/bash

ISO="$HOME/ISO/kali-linux-2025.3-installer-amd64.iso"
DISK="$HOME/VMs/kali.qcow2"
RAM=2048
CPUS=4

case "$1" in
  install)
    echo "[*] Booting Kali installer..."
    qemu-system-x86_64 \
      -enable-kvm \
      -m $RAM \
      -smp $CPUS \
      -cpu host \
      -drive file=$DISK,if=virtio,format=qcow2 \
      -device virtio-net-pci,netdev=net0 \
      -netdev user,id=net0,hostfwd=tcp::2222-:22 \
      -boot d \
      -cdrom "$ISO" \
      -display gtk
    ;;
  gui)
    echo "[*] Booting Kali with GUI..."
    qemu-system-x86_64 \
      -enable-kvm \
      -m $RAM \
      -smp $CPUS \
      -cpu host \
      -drive file=$DISK,if=virtio,format=qcow2 \
      -device virtio-net-pci,netdev=net0 \
      -netdev user,id=net0,hostfwd=tcp::2222-:22 \
      -display gtk
    ;;
  headless)
    echo "[*] Booting Kali headless (SSH on port 2222)..."
    qemu-system-x86_64 \
      -enable-kvm \
      -m $RAM \
      -smp $CPUS \
      -cpu host \
      -drive file=$DISK,if=virtio,format=qcow2 \
      -device virtio-net-pci,netdev=net0 \
      -netdev user,id=net0,hostfwd=tcp::2222-:22 \
      -daemonize -display none
    ;;
  stop)
    echo "[*] Stopping Kali VM..."
    PID=$(pgrep -f "qemu-system-x86_64.*$DISK")
    if [ -n "$PID" ]; then
      kill "$PID"
      echo "[+] VM stopped (PID $PID)."
    else
      echo "[!] No running Kali VM found."
    fi
    ;;
  *)
    echo "Usage: $0 {install|gui|headless|stop}"
    exit 1
    ;;
esac
