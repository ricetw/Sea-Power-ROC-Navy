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
- S-70C(M) low-visibility SH-2F placeholder livery: `assets/rocn/aircraft/s-70cm/`
- Unit reference/profile image: `ui/profiles/roc_ddg_kee_lung.png`
- SAM fit: custom `rocn_rim-66k-2` SM-2MR Block IIIA, using vanilla `usn_rim-66g` visual assets
- Anti-ship fit: custom `rocn_rgm-84l` Harpoon Block II, using vanilla `usn_rgm-84d` visual assets
- Helicopter: custom `roc_s-70cm` S-70C(M), using vanilla `usn_sh-2f` visual assets with a low-visibility gray ROCN placeholder livery and the official `usn_mk46_mod5_air` Mk 46 Mod 5 torpedo loadout

Mod folder conventions:

- Keep `vessels/` and `ui/profiles/` flat unless Sea Power confirms recursive lookup for those directories.
- Put shared ROCN assets under `assets/rocn/common/`.
- Put ship-class-specific custom assets under `assets/rocn/ships/<class_id>/`.
- Reference vanilla Sea Power assets by their built-in `ships/...` resource paths instead of bundling extracted original files.

Image credit:

- `ui/profiles/roc_ddg_kee_lung.png` is cropped from the ROC Navy official Kee Lung-class ship introduction image:
  https://navy.mnd.gov.tw/aboutus/other_info.aspx?aid=30035&id=1
