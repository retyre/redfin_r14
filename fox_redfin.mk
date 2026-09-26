# OrangeFox product for redfin (QTI tree)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)
$(call inherit-product-if-exists, vendor/fox/config/common.mk)
$(call inherit-product, device/google/redfin/device.mk)

PRODUCT_DEVICE := redfin
PRODUCT_NAME := fox_redfin
PRODUCT_BRAND := google
PRODUCT_MODEL := Pixel 5
PRODUCT_MANUFACTURER := Google

# Fox flags - encryption KEPT (Snapdragon QSEE)
# OF_DEFAULT_KEYMASTER_VERSION is THE fix for the A14 stall: stock redfin
# uses HIDL keymaster@4.0 (QSEE, per stock manifest v7.0). The old 4.1
# default finds no HAL, so recovery loops at "Using additional fstab"
# forever and never attempts the unwrap.
FOX_AB_DEVICE := 1
OF_DEFAULT_KEYMASTER_VERSION := 4.0
FOX_RECOVERY_BOOT_PARTITION := boot
FOX_BUILD_TYPE := Unofficial
FOX_VARIANT := A14
OF_KEEP_DM_VERITY := 1
OF_NO_TREBLE_COMPATIBILITY_CHECK := 1
OF_USE_LZ4_COMPRESSION := 1
OF_DONT_PATCH_ENCRYPTED_DEVICE := 1
OF_SKIP_FBE_DECRYPTION := 0
OF_FBE_METADATA_MOUNT_IGNORE := 0
