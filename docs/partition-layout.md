# Partition Layout

The production router currently uses a larger-than-default root filesystem layout.

Observed state:

| Partition | Size | Purpose |
|---|---:|---|
| `mmcblk0p1` | 128 MB | Boot / FAT |
| `mmcblk0p2` | 2048 MB | Root filesystem |

Build config invariants:

```text
CONFIG_TARGET_KERNEL_PARTSIZE=128
CONFIG_TARGET_ROOTFS_PARTSIZE=2048
```

The public build should preserve this layout unless there is a deliberate migration plan.

## Images

The build should produce both squashfs and ext4 artifacts where OpenWrt supports them. For board testing, ext4 is preferred because it is easier to inspect and resize.
