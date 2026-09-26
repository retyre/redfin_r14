# Patches

Every patch to foreign code (leegarchat convention) is stored as a triple:

- `original/<file>` - pristine upstream copy
- `modified/<file>` - our version
- `<name>.patch` - unified diff between them

The live tree must always match the `modified/` snapshot.

Currently empty: this tree fixes decrypt purely through config
(KeyMaster version, VINTF manifest, init rc, consistent prebuilt sets).
No source is patched yet. Candidates if the stall persists:

- vold keymint-service gate (skip instead of hang, cf. leegarchat
  `partitionmanager.cpp: FscryptMountMetadataEncryptedWithTimeout`)
- libfstab multi-device parsing (only if zoned/alias fstabs appear)
