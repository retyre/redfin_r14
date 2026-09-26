# Copyright (C) 2026 The OrangeFox Recovery Project
# SPDX-License-Identifier: Apache-2.0
#
# Device: Google Pixel 5 (redfin) - sm7250 (lito), Snapdragon QTI crypto path
# OrangeFox R14 (Android 14 manifest) - A14-era vold/keystore client code so
# the KeyMaster request tags match what the A14 TZ enforces (the 12.1-built
# stack gets INVALID_KEY_BLOB on the metadata unwrap; see docs/decrypt.en.md).
# Android 14, A/B, recovery into vendor_boot, prebuilt kernel
#
# QTI tree (redfin_qti): HIDL keymaster@4.0 + gatekeeper@1.0 on QSEE.
# Stock /vendor/etc/vintf/manifest.xml (v7.0) declares exactly these two as
# the FBE backend; citadel/weaver is StrongBox-only and intentionally absent.
# Vendor HALs live in recovery/root/vendor (linker sphal namespace) so
# /system/lib64 never mixes build-era and stock lib versions in one
# namespace (that mix SIGILL/SIGSEGV-crashes recovery - verified live).
#
# Adapted from device/google/redfin (round-2 cloud fixes kept) +
# leegarchat/twrp_device_google_pixels principles (config-over-code,
# schema-2.0 VINTF, no franken-libs) + bramble harvest (boot HAL note,
# gatekeeper SPU flag, fuller cmdline reference in qti.json).

DEVICE_PATH := device/google/redfin

# Android 14 release config (build/make r14 requires TARGET_RELEASE or a
# release-qualified lunch combo; ap2a is the listed valid release)
TARGET_RELEASE := ap2a

ALLOW_MISSING_DEPENDENCIES := true

# Architecture (kryo475)
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a76

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a76

TARGET_USES_64_BIT_BINDER := true
ENABLE_CPUSETS := true
ENABLE_SCHEDBOOST := true

# Bootloader / platform (Qualcomm lito)
TARGET_BOARD_PLATFORM := lito
TARGET_BOOTLOADER_BOARD_NAME := redfin
TARGET_NO_BOOTLOADER := true
TARGET_USES_UEFI := true
QCOM_BOARD_PLATFORMS += lito
BOARD_USES_QCOM_HARDWARE := true

# Kernel - prebuilt stock A14 (boot_b 9.3MB lz4 + vendor_boot dtb)
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilt
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
BOARD_KERNEL_IMAGE_NAME := Image.lz4
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_INCLUDE_DTB_IN_BOOTIMG := true

# Boot header v3 (matches stock dumps)
BOARD_BOOT_HEADER_VERSION := 3
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE)
BOARD_RAMDISK_USE_LZ4 := true
TARGET_COPY_OUT_VENDOR_RAMDISK := vendor_ramdisk
# First-stage kernel modules for vendor_boot (storage/display/input set;
# list lives in prebuilt/modules/modules.load, stock order). Goes through
# the kernel-module rules, not raw copies.
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/prebuilt/modules/modules.load))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(addprefix $(DEVICE_PATH)/prebuilt/modules/,$(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD))
BOARD_KERNEL_CMDLINE := console=ttyMSM0,115200n8 androidboot.console=ttyMSM0 printk.devkmsg=on
BOARD_KERNEL_CMDLINE += androidboot.memcg=1 cgroup.memory=nokmem
BOARD_KERNEL_CMDLINE += androidboot.usbcontroller=a600000.dwc3 swiotlb=2048
BOARD_KERNEL_CMDLINE += androidboot.boot_devices=soc/1d84000.ufshc
BOARD_KERNEL_CMDLINE += loop.max_part=7
BOARD_KERNEL_CMDLINE += twrpfastboot=1

# Recovery into vendor_boot (stock boots recovery from vendor_boot on redfin;
# avoids the boot-image ramdisk assembly that chokes on the vendor symlink)
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    vendor_boot \
    system \
    vbmeta \
    dtbo \
    product \
    vbmeta_system \
    system_ext \
    vendor \
    vendor_dlkm

# Partitions (from redbull tree + dump sizes)
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x06000000
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 0x06000000
BOARD_DTBOIMG_PARTITION_SIZE := 16777216
BOARD_SUPER_PARTITION_SIZE := 9755951104
BOARD_GOOGLE_DYNAMIC_PARTITIONS_SIZE := 4873781248
BOARD_GOOGLE_DYNAMIC_PARTITIONS_PARTITION_LIST := system vendor product system_ext
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Crypto / FBE - Snapdragon QTI path (NOT Tensor/KeyMint-AIDL)
# Stock manifest: keymaster@4.0 + gatekeeper@1.0 (QSEE). OF default MUST be
# 4.0 (see fox_redfin.mk) - 4.1 finds no HAL and decrypt never starts.
PLATFORM_VERSION := 14.0.0
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
BOOT_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
BOARD_USES_METADATA_PARTITION := true
BOARD_USES_QCOM_FBE_DECRYPTION := true
TW_USE_FSCRYPT_POLICY := 2

# Recovery
BOARD_ROOT_EXTRA_FOLDERS += vendor
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_HAS_NO_SELECT_BUTTON := true
RECOVERY_SDCARD_ON_DATA := true
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_QCOM_RTC_FIX := true

# Display (Pixel panel0-backlight; max verified post-boot like aito)
TW_THEME := portrait_hdpi
TW_BRIGHTNESS_PATH := "/sys/class/backlight/panel0-backlight/brightness"
TW_SECONDARY_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 1023
TW_DEFAULT_BRIGHTNESS := 80
TW_NO_SCREEN_BLANK := true
TW_EXCLUDE_APEX := true

# Touch (focaltech/sec dual-source, proven present in stock vendor_boot)
TW_LOAD_VENDOR_MODULES := "ftm5.ko sec_touch.ko"

# Fastbootd
TW_INCLUDE_FASTBOOTD := true

# Other TWRP
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_INCLUDE_NTFS_3G := true
TW_USE_TOOLBOX := true
TARGET_USES_MKE2FS := true
TW_NO_LEGACY_PROPS := true
TW_NO_BIND_SYSTEM := true
TW_USE_MODEL_HARDWARE_ID_FOR_DEVICE_ID := true
TW_EXTRA_LANGUAGES := false
TW_DEFAULT_LANGUAGE := en
TW_INCLUDE_REPACKTOOLS := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true
TW_INCLUDE_LPTOOLS := true
TW_INCLUDE_LPDUMP := true
TARGET_USES_LOGD := true
TWRP_INCLUDE_LOGCAT := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_NO_HAPTICS := true
TW_CUSTOM_CPU_TEMP_PATH := /sys/devices/virtual/thermal/tz-by-name/cpu-0-0-step/temp
TW_EXCLUDE_ENCRYPTED_BACKUPS := false
TW_RECOVERY_ADDITIONAL_RELINK_BINARY_FILES += $(TARGET_OUT_EXECUTABLES)/strace
TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += $(TARGET_OUT_SHARED_LIBRARIES)/android.hardware.authsecret@1.0.so
TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += $(TARGET_OUT_SHARED_LIBRARIES)/android.hardware.oemlock@1.0.so
