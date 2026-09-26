# OrangeFox vendorsetup for redfin (Pixel 5, sm7250, QTI tree)
# No add_lunch_combo - lunch choices come from
# COMMON_LUNCH_CHOICES in AndroidProducts.mk.

FDEVICE="redfin"

fox_get_target_device() {
	local script_path="${BASH_SOURCE[0]}"
	if echo "$script_path" | grep -q "$FDEVICE"; then
		FOX_BUILD_DEVICE="$FDEVICE"
	elif echo "$0" | grep -q "$FDEVICE"; then
		FOX_BUILD_DEVICE="$FDEVICE"
	fi
}

if [ -z "$FOX_BUILD_DEVICE" ]; then
	fox_get_target_device
fi

if [ "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then
	echo "Detected build device: $FOX_BUILD_DEVICE"
	export ALLOW_MISSING_DEPENDENCIES=true
	export LC_ALL=C
	export FOX_AB_DEVICE=1
	export FOX_USE_BASH_SHELL=1
	export FOX_USE_TAR_BINARY=1
	export FOX_USE_SED_BINARY=1
	export FOX_USE_LZ4_BINARY=1
	export FOX_USE_ZSTD_BINARY=1
	export FOX_USE_XZ_UTILS=1
	export FOX_DELETE_AROMAFM=1
	export FOX_VARIANT=A14
else
	echo "I: vendorsetup.sh skipped; device mismatch or environment issue."
fi
