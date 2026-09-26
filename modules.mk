# Vendor ramdisk first-stage files. Kernel modules themselves go through
# BOARD_VENDOR_RAMDISK_KERNEL_MODULES (no timestamp check that way);
# only the fstab is a plain copy.
PRODUCT_COPY_FILES += $(LOCAL_PATH)/recovery.fstab:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.sm7250
