# Republic of China Navy Pack

Standalone Sea Power mod package for Republic of China Navy units.

Install by copying the contents of this `mod` folder as a Sea Power mod folder, or by creating a local mod through the in-game mod tools and copying these files into it.

Current unit scope:

- Unit ID: `roc_ddg_kee_lung`
- Class: Kee Lung-class guided-missile destroyer
- Variants: DDG-1801 Kee Lung, DDG-1802 Su Ao, DDG-1803 Tso Ying, DDG-1805 Ma Kong
- Base model and animations: original USN Kidd class
- Custom ROCN flag: `assets/rocn/common/flags/roc.png`
- Custom Kee Lung-class hull numbers: `assets/rocn/ships/kee_lung/hullnumbers/`
- S-70C(M) SH-60 visual prototype livery, serial, and emblem assets: `assets/rocn/aircraft/s-70cm/` (weathered gray-blue placeholder livery without USN markings; external markings are disabled until SH-60 UV placement is mapped)
- Unit reference/profile image: `ui/profiles/roc_ddg_kee_lung.png`
- SAM fit: custom `rocn_rim-66k-2` SM-2MR Block IIIA, using vanilla `usn_rim-66g` visual assets
- Anti-ship fit: custom `rocn_rgm-84l` Harpoon Block II, using vanilla `usn_rgm-84d` visual assets
- Standalone weapon data: custom `rocn_hf-3` Hsiung Feng III supersonic ASM, using bundled `assets/rocn/weapons/hf-3/` high-poly visual assets; not mounted on Kee Lung-class by default
- Helicopter: custom `roc_s-70cm` S-70C(M) local prototype, using Workshop item `3737267013` SH-60B visual resources when that mod is enabled locally; third-party model/texture assets are not bundled for redistribution
- Unit ID: `roc_ffg_cheng_kung`
- Class: ROC-built Cheng Kung-class guided-missile frigate
- Variants: PFG-1101, 1103, 1105, 1106, 1107, 1108, and 1109
- Base model and animations: vanilla long-hull Oliver Hazard Perry class
- Original fit through 2006: 40 SM-1MR in Mk 13 and eight HF-2 missiles in two four-cell launchers
- 2007+ fit: four HF-2 and four HF-3 missiles; the exact conversion year is used as a class-wide gameplay boundary
- ROCN additions: two 40 mm gun systems and two S-70C(M) helicopters
- Known visual approximations: vanilla Mk 141-style boxes for indigenous launchers, vanilla single 40 mm mount geometry, and a Harpoon body for HF-2
- Unit ID: `roc_ffg_tien_tan`; PFG-1110 is separate so her omitted 40 mm mounts can be represented correctly

Mod folder conventions:

- Keep `vessels/` and `ui/profiles/` flat unless Sea Power confirms recursive lookup for those directories.
- Put shared ROCN assets under `assets/rocn/common/`.
- Put ship-class-specific custom assets under `assets/rocn/ships/<class_id>/`.
- Reference vanilla Sea Power assets by their built-in `ships/...` resource paths instead of bundling extracted original files.

Image credit:

- `ui/profiles/roc_ddg_kee_lung.png` is cropped from the ROC Navy official Kee Lung-class ship introduction image:
  https://navy.mnd.gov.tw/aboutus/other_info.aspx?aid=30035&id=1
- `ui/profiles/roc_ffg_cheng_kung.png` is cropped from the ROC Navy official Cheng Kung-class ship introduction page image:
  https://navy.mnd.gov.tw/AboutUs/Other_Info.aspx?AID=30033&ID=1
