This is a comprehensive technical manifest of your system configuration. You can copy this directly into an **Obsidian** note (e.g., `Vivobook_Power_Config.md`) for your "Second Brain" backups.

---

# 🛠️ System Engineering Manifest: Vivobook Power & Hibernation

**Device:** ASUS Vivobook | **OS:** CachyOS (Linux Kernel 6.19+) | **Bootloader:** Limine
**Battery Health:** 61% (Limited to 80% via `asusctl`)

---

## 1. Real-Time Power Monitoring (`fish` function)

We created a custom function to monitor the discharge rate in Watts. This is the most accurate way to tell if the Nvidia GPU is properly idling.

**The Logic:**

* Path: `/sys/class/power_supply/BAT0/uevent`
* Key: `POWER_SUPPLY_POWER_NOW` (Value is in micro-watts).
* Calculation: $Value / 1,000,000 = Watts$.

```fish
function powerstats
    echo "--- CPU Governor ---"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo "--- GPU Power State ---"
    nvidia-smi -q -d PERFORMANCE | grep "Performance State" || echo "GPU Sleeping or Error"
    echo "--- Battery Discharge ---"
    set -l microwatts (grep "POWER_SUPPLY_POWER_NOW" /sys/class/power_supply/BAT0/uevent | cut -d= -f2)
    if test -n "$microwatts"
        set -l watts (math -s2 "$microwatts / 1000000")
        echo "$watts Watts"
    else
        echo "Charging / AC Power"
    end
end

```

* **Target Value:** **7W – 10W** (Idle/OLED 90Hz).
* **Warning Value:** **>18W** (Indicates Nvidia GPU is stuck in high-power state).

---

## 2. Hybrid Swap Architecture

Since physical RAM is limited to **8GB (7.2Gi available)**, we use a tiered approach.

### Tier 1: zRAM (Virtual)

* **Priority:** 100
* **Function:** Compresses data in RAM to prevent disk swapping during active use.
* **Status:** 14.3G partition (managed by `zram-generator`).

### Tier 2: Physical Swapfile (SSD)

* **Priority:** -1
* **Location:** `/swapfile`
* **Configuration:**
```bash
sudo truncate -s 0 /swapfile
sudo chattr +C /swapfile  # Crucial: Disables CoW for Btrfs
sudo fallocate -l 16G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile

```


* **FSTAB Entry:** `/swapfile none swap defaults 0 0`

---

## 3. Hibernation (Suspend-to-Disk) Setup

This is the "Safety Net" for your 61% health battery. It saves RAM to the `/swapfile` and cuts power completely.

### The Resume Parameters

To find these, we used:

1. **UUID:** `blkid` or `cat /etc/fstab` (Root partition UUID).
* **Value:** `3293bac0-5a72-4c6c-90d8-ae213fa5a4de`


2. **Offset:** Required for Btrfs to find the start of the swapfile.
* **Command:** `sudo btrfs inspect-internal map-swapfile -r /swapfile`
* **Value:** `4050737`



### Limine Configuration (`/boot/limine.conf`)

The `cmdline` must contain:

* `nvme.noacpi=1` (Power saving for SSD)
* `resume=UUID=3293bac0-5a72-4c6c-90d8-ae213fa5a4de`
* `resume_offset=4050737`
* `nvidia.NVreg_PreserveVideoMemoryAllocations=1` (Prevents GPU crash after wake).

---

## 4. Nvidia Recovery Services

To ensure the GPU wakes up in a low-power state and restores its VRAM contents, these **must** be enabled:

```bash
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service

```

---

## 5. Dual-Boot & Maintenance

* **Windows 11 Fix:** Run `powercfg /h off` in CMD (Admin). This prevents NTFS partition locking on `/mnt/shared`.
* **Battery Limit:** Handled by `asusctl`. Check status with `asusctl -p` or `asusctl battery-limit -g`.
* **Initramfs:** Whenever changing hibernation logic, regenerate images: `sudo mkinitcpio -P`.

---
