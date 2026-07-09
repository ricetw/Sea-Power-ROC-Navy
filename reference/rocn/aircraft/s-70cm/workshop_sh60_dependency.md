# S-70C(M) Workshop SH-60 Local Dependency Notes

This project currently tests `roc_s-70cm` with the SH-60 visual model from Steam Workshop item `3737267013`.

The ROC Navy mod does not bundle that third-party model or texture set. For local testing, keep the Workshop item installed and enabled alongside this mod. For public redistribution, either obtain permission from the asset author(s), declare the item as a dependency where allowed, or replace the visual model with self-owned S-70C(M) assets.

Local source path inspected:

```text
D:\RiceBall\steam\steamapps\workshop\content\1286220\3737267013
```

Integrated into:

```text
mod/aircraft/roc_s-70cm.ini
```

Reference direction:

- Public references describe the ROCN S-70C(M)-1/2 Thunderhawk as an export Seahawk with undernose radar and dipping sonar.
- Chinese SH-60/S-70 variant notes describe the ROCN S-70C(M)-1/2 as based on SH-60F airframe features while integrating SH-60B functions.
- This mod therefore uses a hybrid gameplay fit: SH-60B-style left-side passive sonobuoy launchers plus SH-60F-style belly dipping sonar and belly passive sonobuoy chute.
- AN/AQS-18(V)3 is modeled as a dipping sonar sensor, not a weapon store. In game terms it is approximated from SH-60F/AQS-13F behavior.
- Passive sonobuoys are modeled as `usn_ssq-53` only: one left-side 5x5 block with 25 tubes, plus 6 belly-launched stores. Active DICASS sonobuoys are omitted for the ROCN S-70C(M) baseline.
- Mk 46 Mod 5 torpedo stations are moved outward; the left station is moved forward to sit closer to the visible stub wing.
- Chaff is modeled as 25 rounds from the aft dorsal countermeasure dispenser.
- The current prototype livery is a clean weathered gray-blue placeholder based on ROCN S-70C(M) public photos. External Modex/Emblem overlays remain disabled because the Workshop overlay meshes place ROCN markings in wrong USN-emblem locations; accurate ROCN markings need a proper SH-60 UV pass.

Useful public references:

- Sikorsky SH-60 Seahawk variant notes, including S-70C(M)-1/2 and SH-60B/SH-60F context: https://en.wikipedia.org/wiki/Sikorsky_SH-60_Seahawk
- Chinese SH-60 Seahawk variant notes, including left-side 25-tube SH-60B launcher and ROCN S-70C(M)-1/2 hybrid description: https://zh.wikipedia.org/wiki/SH-60%E6%B5%B7%E9%B7%B9%E7%9B%B4%E5%8D%87%E6%A9%9F
- AN/AQS-13 / AQS-18 export-family dipping sonar background: https://en.wikipedia.org/wiki/AN/AQS-13