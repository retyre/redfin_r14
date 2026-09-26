# Tree guide: redfin_r14 (OrangeFox R14 / Android 14 manifest)

leegarchat-style layout, adapted for Snapdragon (no Tensor specifics).
R14 port: A14-era vold/keystore client code so KeyMaster request tags
match what the A14 TZ enforces (the 12.1-built stack gets
INVALID_KEY_BLOB on the metadata unwrap; see decrypt.en.md).

| Path | Read by | Purpose |
|---|---|---|
| `BoardConfig.mk` | build | arch, kernel, partitions, crypto flags (round-2 fixes kept) |
| `fox_redfin.mk` | build | product + `OF_DEFAULT_KEYMASTER_VERSION := 4.0` (the A14 decrypt fix) |
| `device.mk` | build | packages, `TARGET_SYSTEM_PROP`, vendor `.keep` rsync hack |
| `modules.mk` | build | first-stage fstab copy |
| `system.prop` | build -> `/system/build.prop` | `vendor.gatekeeper.disable_spu`, adb, platform |
| `qti.json` | humans | single config source; `.mk` values mirror it |
| `recovery.fstab` | recovery + first-stage | proven A14 fstab (inlinecrypt v2, keydirectory) |
| `recovery/root/` | ramdisk merge | init rc, touch KOs, system libs, **vendor/ HAL namespace** |
| `recovery/root/vendor/` | ramdisk merge | QTI services + libs + schema-2.0 manifest (sphal namespace) |
| `include/vintf/manifest.xml` | (source of the ramdisk copy) | keymaster 4.0 + gatekeeper 1.0, schema 2.0 |
| `prebuilt/` | build | stock kernel, dtb, first-stage modules (stock order) |
| `patches/` | humans | `original/` + `modified/` + `.patch` triples (empty: nothing patched yet) |
| `docs/decrypt.en.md` | humans | QSEE decrypt architecture + franken-lib rule |

## Lunch / build (Custom-Recovery-Builder)

- `DEVICE_PATH=device/google/redfin`, `DEVICE_NAME=redfin`,
  `BUILD_TARGET=vendorboot`, `MANIFEST_BRANCH=14.1`
  (the clone destination MUST be `device/google/redfin` - lunch resolves
  the board config by directory name; `redfin_r14` is only the repo name)
- lunch `fox_redfin-eng` (same product name as the old tree - the two
  trees never coexist in one sync, so there is no collision in the cloud)
- targets: `mka adbd recoveryimage vendorbootimage`

## Blob provenance (all pulled Sep 2026 from slot-`_b` A14 stock)

- `recovery/root/system/lib64`: 8 stock A14 libs (round 2, keystore2 link
  deps) + 17 round-3 stock libs (full keystore2/km_compat support set,
  stock keymasterutils + keymasterdeviceutils) + carried-over proven set
  from the round-2 tree (citadel/weaver dropped; binder/utils/
  keystore_aidl+binder+parcelables stay as built - swapping them SIGILLs
  recovery)
- `recovery/root/vendor/lib64`: 10 stock vendor libs (QSEE/userspace) +
  round-3 `librpmb` + `libssd` (qseecomd listeners) + stock
  `libkeymasterutils`
- `recovery/root/vendor/lib64/hw/`: stock gatekeeper `-impl-qti.so`
  (passthrough shim requirement, verified via logcat dlopen trace)
- `recovery/root/vendor/bin/hw`: qseecomd, keymaster@4.0-qti,
  gatekeeper@1.0-qti (relocated from system layout to stock layout)
- `recovery/root/system/etc/vintf/manifest.xml`: framework VINTF shell
  (schema 2.0; without it AIDL servicemanager reports NULL framework
  manifest and refuses keystore2 registration - verified live)
- `recovery/root/vendor/build.prop`: minimal vendor props (platform,
  vendor patch, crypto method/version) for hybrid boots where stock
  vendor isn't mounted
- `prebuilt/`: stock boot_b kernel + vendor_boot dtb + module set
