# 成功級巡防艦 Perry 底盤選擇筆記

## 結論

Sea Power 原版同時提供 Oliver Hazard Perry 短船體與長船體：

- `usn_ffg_oliver_hazard_perry.ini`
- `usn_ffg_oliver_hazard_perry_variants.ini`
- `usn_ffg_oliver_hazard_perry_longhull.ini`
- `usn_ffg_oliver_hazard_perry_longhull_variants.ini`

中華民國海軍的成功級巡防艦與後續購入的銘傳、逢甲艦，建議都以 `usn_ffg_oliver_hazard_perry_longhull.ini` 作為模型與系統起點，不使用短船體。

## 為什麼不用短船體

Oliver Hazard Perry 級有短船體與長船體兩種。短船體較接近早期搭配 SH-2 Seasprite / LAMPS I 的版本；長船體則為了 SH-60 Seahawk / LAMPS III 作業調整飛行甲板與艉部配置。

成功級設計上是派里級授權生產衍生型，航空操作需求對應 S-70C(M)-1/2；銘傳與逢甲則是美國退役後移交的後期 OHP 艦，也屬於長船體脈絡。因此兩者都應以長船體為基準。

## 建議拆分

### 台灣自造成功級 / PFG-1101 系列

建議新增獨立檔案，例如：

- `mod/vessels/roc_ffg_cheng_kung.ini`
- `mod/vessels/roc_ffg_cheng_kung_variants.ini`

基礎使用原版 long-hull Perry，再改成中華民國海軍本土成功級配置：

- ROCN 旗幟、舷號、艦名與語系資料
- S-70C(M)-1/2 艦載機
- HF-2 / HF-3 反艦飛彈罐，依年代建立 variant
- 成功級特有的艦側 40mm 快砲配置，並注意田單艦等例外
- ROCN 本土化電戰、通信、射控與升級差異

### 美艦移交銘傳 / 逢甲

建議不要和本土成功級混在同一個 variant 裡，另建一組，例如：

- `mod/vessels/roc_ffg_ming_chuan.ini`
- `mod/vessels/roc_ffg_ming_chuan_variants.ini`

同樣使用原版 long-hull Perry，但配置應較接近後期美製 OHP 移交狀態：

- 銘傳 PFG-1112、逢甲 PFG-1115
- 原美艦艦體與部分系統基線
- OTO 76mm、Phalanx Block 1B、Mk 13 相關配置依可考年代調整
- 不直接套用本土成功級艦側 40mm 與 HF-2/HF-3 罐裝配置，除非後續找到明確改裝依據

## 參考來源

- Sea Power original vessel data under `Sea Power_Data/StreamingAssets/original/vessels/`
- Oliver Hazard Perry-class frigate: https://en.wikipedia.org/wiki/Oliver_Hazard_Perry-class_frigate
- Cheng Kung-class frigate: https://en.wikipedia.org/wiki/Cheng_Kung-class_frigate
- 成功級巡防艦: https://zh.wikipedia.org/wiki/%E6%88%90%E5%8A%9F%E7%B4%9A%E5%B7%A1%E9%98%B2%E8%89%A6