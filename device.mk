# Device config for redfin (QTI tree)
LOCAL_PATH := device/google/redfin

include $(LOCAL_PATH)/modules.mk

# system.prop (gatekeeper SPU flag, adb, platform) -> /system/build.prop
TARGET_SYSTEM_PROP := $(LOCAL_PATH)/system.prop

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

PRODUCT_PACKAGES += \
    otapreopt_script \
    update_engine \
    update_verifier

PRODUCT_PACKAGES += \
    android.hardware.health-service.example_recovery \
    fastbootd \
    android.hardware.fastboot-service.example_recovery

# Workaround for ramdisk assembly: the base stages recovery/root/vendor/
# (contexts + HAL manifests) as a real dir while root/ staging carries a
# vendor symlink - rsync chokes replacing the dir. Forcing a real vendor/
# dir on the sender side makes it merge cleanly instead. Harmless 0-byte
# file, ignored at boot.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/root-vendor-keep:root/vendor/.keep
