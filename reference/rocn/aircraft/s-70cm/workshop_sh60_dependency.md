# S-70C(M) Workshop SH-60B Local Dependency Notes

This project currently tests `roc_s-70cm` with the SH-60B visual model from Steam Workshop item `3737267013`.

The ROC Navy mod does not bundle that third-party model or texture set. For local testing, keep the Workshop item installed and enabled alongside this mod. For public redistribution, either obtain permission from the asset author(s), declare the item as a dependency where allowed, or replace the visual model with self-owned S-70C(M) assets.

Local source path inspected:

```text
D:\RiceBall\steam\steamapps\workshop\content\1286220\3737267013
```

Integrated into:

```text
mod/aircraft/roc_s-70cm.ini
```

Notes:

- `usn_sh-60b.ini` is used as the visual/animation baseline because it is closer to the ROCN S-70C(M)-1/2 era and ASW fit than `usn_mh-60r.ini`.
- MH-60R-only systems such as modern FLIR/laser/Hellfire and dipping sonar are not copied into the ROCN S-70C(M) baseline.
- ROCN loadouts remain conservative: Mk 46 Mod 5 torpedoes and vanilla sonobuoys.
- The existing ROCN livery is a placeholder and may not align with the Workshop SH-60 UV layout.