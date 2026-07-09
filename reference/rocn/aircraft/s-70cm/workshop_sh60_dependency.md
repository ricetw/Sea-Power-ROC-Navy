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
- MH-60R-only systems such as modern FLIR/laser/Hellfire are not copied into the ROCN S-70C(M) baseline; the active ASW fit is modeled separately as an AN/AQS-18(V)3-style dipping sonar.
- ROCN visible ASW loadouts remain conservative: Mk 46 Mod 5 torpedoes plus 25 passive AN/SSQ-53 DIFAR sonobuoys from the left dispenser. Active DICASS sonobuoys are not used for the S-70C(M) baseline.
- The current SH-60 prototype livery is a clean darker gray placeholder generated without USN markings. External Modex/Emblem overlays are disabled because the Workshop overlay meshes place ROCN markings in the wrong USN-emblem locations; accurate ROCN markings need a proper SH-60 UV pass.
- Passive sonobuoys now use the left-side dispenser layout; the active system is represented by a belly-mounted dipping-sonar sensor and AQS-13 visual proxy. Chaff is modeled as 25 rounds from the aft dorsal dispenser using the SH-60 countermeasure behavior.
