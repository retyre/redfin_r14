# Data decryption: QTI QSEE (redfin is Snapdragon, NOT Tensor) — R14 tree

## Why R14

The 12.1-built stack reaches the TA and gets `INVALID_KEY_BLOB` (-33) on
the metadata unwrap despite a fully working HAL set (both QSEE keymasters
register, keystore2 serves). Evidence points at request construction: the
12.1-era vold/keystore client omits tags the A14 TZ mandates (12.1 code
vs A14 TA; A11-code-vs-A12-TA worked). This tree builds against the
Android 14 manifest (OrangeFox R14) so vold, libfscrypt, keystore2-client
and km_compat are A14-era and speak the TA's language natively.

This tree uses the stock-consistent **HIDL** crypto stack. There is no
KeyMint-AIDL HAL, no Rust HAL, no Titan/weaver daemon on the FBE path.
Stock `/vendor/etc/vintf/manifest.xml` (v7.0) declares exactly:

- `android.hardware.keymaster @4.0::IKeymasterDevice/default` (QSEE)
- `android.hardware.gatekeeper @1.0::IGatekeeper/default` (QSEE)

Citadel/weaver binaries exist on stock but serve StrongBox, not FBE, and
are deliberately excluded from this tree.

## How it is wired

1. `OF_DEFAULT_KEYMASTER_VERSION := 4.0` (fox_redfin.mk). The 4.1 default
   finds no HAL, so recovery loops at `Using additional fstab` forever.
2. `include/vintf/manifest.xml` (schema **2.0** only - recovery carries
   libvintf 8.0; newer schemas break HAL registration lookups) is staged
   to ramdisk `/vendor/etc/vintf/manifest.xml`.
3. `init.recovery.redfin.rc` starts `qseecomd` FIRST, then `keymaster-4-0`
   + `gatekeeper-1-0`, from `/vendor/bin/hw` (stock layout, sphal linker
   namespace) on `init`. Order matters: the HALs register with
   hwservicemanager only once qseecomd's listener services are up
   (`QSEECOM DAEMON RUNNING` in logcat). qseecomd itself needs
   `librpmb.so` + `libssd.so` in `/vendor/lib64` - without them it exits
   silently and nothing registers (verified live).
4. Gatekeeper is a passthrough shim: its `-impl-qti.so` MUST sit in
   `vendor/lib64/hw/` (stock layout), and it dlopens against stock
   `libkeymasterdeviceutils.so` (provides
   `keymasterutils::KeymasterUtils::isOldKeyblob`, missing from the
   build-era copy - verified via readelf). Both are in this tree.
5. `keystore2` (base ramdisk binary + rc) links against the **stock A14**
   system lib set shipped in `recovery/root/system/lib64`: the 8 round-2
   libs (libkeymint + 4 NDK + messages + portable + puresoftkeymasterdevice)
   PLUS the round-3 set (keystore2_crypto/apc_compat/aaid,
   keystore2-V3-ndk/V1-cpp, keymint-V1-cpp/V1-ndk, keymint_support,
   keymaster_keymint_utils, legacykeystore-ndk, keystore-engine,
   km_compat + km_compat_service, confirmationui-V1-ndk, compat-ndk) and
   stock `libkeymasterutils` + `libkeymasterdeviceutils`. It reaches
   KeyMaster through `km_compat` once `keymaster-4-0` is up.

## The franken-lib rule (verified live, Sep 2026)

`/system/lib64` must never mix build-era and stock versions of the
keymaster/keystore/binder set in one linker namespace: recovery dies
with SIGILL/SEGV crash-loops. Safe procedure, used for this tree:

- swap ONE stock lib at a time, restart recovery, require the
  `Starting OrangeFox` count in `/tmp/recovery.log` to grow by exactly 1
- the 8 stock libs in this tree each passed that gate; `libbinder` /
  `libutils` / `libkeystore_{aidl,binder,parcelables}` swaps did NOT and
  are intentionally left as built
- vendor HALs + their libs stay under `recovery/root/vendor` (separate
  linker namespace), never in `/system`

## PIN / weaver (phase 2, not in this tree)

PIN-locked decrypt needs weaver (Titan M, protobuf path). Blocked on the
`libnos_*` dependency chain (`atrace_begin` needs a newer libbinder than
recovery tolerates). Default-password (PIN-free) decrypt does not need it.

## Boot HAL (phase 2, not in this tree)

Stock ships `android.hardware.boot@1.2-service` (pulled, kept out of tree
in `qti_pull/hw`). The bramble tree carries Lineage `bootctrl/` +
`gpt-utils` sources - the intended donor when slot ops are wired up.
