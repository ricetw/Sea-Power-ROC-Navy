# ROCN S-70C(M) Livery Palette

Last updated: 2026-07-10

This livery source is built for the workshop SH-60 mesh used as the current ROCN S-70C(M) stand-in.

## Runtime Textures

- Diffuse: `mod/assets/rocn/aircraft/s-70cm/liveries/roc_s-70cm_sh60_gray.png`
- Specular: `mod/assets/rocn/aircraft/s-70cm/liveries/roc_s-70cm_sh60_spec.png`
- Layered source: `mod/assets/rocn/aircraft/s-70cm/sources/roc_s-70cm_sh60_livery.psd`

## PSD Layers

| Layer | Purpose |
| --- | --- |
| 03 ROCN low visibility roundels corrected UV | Separate low-vis ROCN roundels placed on mirrored side-panel UVs |
| 02 Gray livery restored panel door warning details | ROCN gray finish with workshop-author panel, door, window, vent, landing gear, warning, sonobuoy, chaff/flare, and cockpit details retained |

## Texture Regions

| Region | Purpose | Main colors |
| --- | --- | --- |
| Base gray fuselage | Overall ROCN light-gray paint | `#879296`, `#7F8A8E` |
| Panel and door outlines | Original SH-60 texture luminance retained and lightly strengthened so doors, access panels, vents, and belly openings remain visible | `#46525A` at low opacity |
| Wheels and landing gear | Rubber tires and metal struts | Rubber `#101316`; metal `#7A858A` |
| Side door glass | Smoked cabin-door windows | Deep glass `#121E26`; highlight `#879EAA` |
| Low-vis ROCN roundels | Low-visibility ROC emblem with circular field, 12 separate broad triangular rays, larger center circle, and visible field gaps | Disc `#707E84`; outline `#505C64`; sun `#D2D8DA` |
| Restored original details | Cockpit panels, instrument colors, sonobuoy tubes, chaff/flare colors, belly ports, vents, wheel hub, and warning/stencil marks from the workshop author texture | Original dark/color detail pixels only |

## Notes

- No fuselage serial number is painted in this version.
- The roundel follows the ROC emblem layout from the provided reference: a circular field, 12 separate broad rays, and a larger central circle.
- The roundel placement is corrected from the tail/underside seam to the mirrored main side-panel UVs. The centers are approximately `(602, 410)` and `(602, 706)` on the 1024 px diffuse map, keeping both sides visible behind the rear landing gear.
- Original author texture details are restored with a dark/color mask so functional markings remain visible. US NAVY titles and US national insignia are removed with blended local inpaint patches before ROCN roundels are drawn.
- The side door glass is painted on the diffuse texture because the workshop SH-60 side-door window is part of the main fuselage UV rather than the separate canopy material.
