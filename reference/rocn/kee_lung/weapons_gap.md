# 基隆級武裝與 Sea Power 原版缺口盤點

本文件盤點中華民國海軍基隆級飛彈驅逐艦公開資料中的武裝，並比對目前本機 Sea Power 原版資料夾內已有的彈藥、武器與航空器代號。

比對時間：2026-07-08
遊戲資料來源：`D:\RiceBall\steam\steamapps\common\Sea Power\Sea Power_Data\StreamingAssets\original`
模組目前單位：`mod/vessels/roc_ddg_kee_lung.ini`

## 判定標準

- 「遊戲有」：Sea Power 原版已有同型或足夠接近的彈藥/系統，可直接引用。
- 「遊戲沒有精確型號」：同系列存在，但基隆級實際型號、Block 或平台版本不存在。
- 「遊戲沒有」：原版沒有該武器、載台或可接受的近似模型/彈藥。
- 「待考證」：公開資料提到，但不適合列入全級 baseline，應做成特定年份或特定艦的可選 loadout。

## 結論摘要

基隆級大部分 Kidd class 原始武裝在 Sea Power 裡都有可用近似品。真正需要優先補的是：

1. `SM-2MR Block IIIA`，公開資料常見記載為 `RIM-66K-2`，目前遊戲只有 `usn_rim-66g` 可近似。
2. `RGM-84L Harpoon Block II`，目前遊戲只有 `usn_rgm-84a/c/d`，模組暫用 `usn_rgm-84d`。
3. `S-70C(M)-1/2` 反潛直升機，遊戲沒有此航空器，目前只能暫用 `usn_sh-2f` 或其他美軍直升機。
4. `12.7mm M2HB` 類機槍，若要表現艦上近距離自衛火力，遊戲沒有合適的美式艦載 12.7mm 機槍系統。
5. `AN/SLQ-25 Nixie` 拖曳式魚雷反制系統，遊戲有 noisemaker 類彈藥可替代，但沒有精確 Nixie 系統。

## 詳細表

| 基隆級武裝/載台 | 公開資料狀態 | Sea Power 原版狀態 | 目前模組處理 | 建議優先度 |
|---|---|---|---|---|
| SM-2MR Block IIIA，公開資料常見記載為 RIM-66K-2 | 基隆級主要區域防空飛彈，由 Mk 26 發射 | 沒有精確型號；有 `usn_rim-66g`、`usn_rim-66a/b/c/d/e` | 暫用 `usn_rim-66g` | 高 |
| RGM-84L Harpoon Block II | 對艦飛彈，公開資料常見記載隨艦移交 32 枚 | 沒有 `usn_rgm-84l`；有 `usn_rgm-84a/c/d` | 暫用 `usn_rgm-84d` | 高 |
| S-70C(M)-1/2 反潛直升機 | ROCN 反潛直升機，基隆級可搭載使用 | 沒有 S-70C/MH-60/SH-60；有 `usn_sh-2f`、`usn_sh-3h` 等 | 暫用 `usn_sh-2f` | 高 |
| 12.7mm M2HB 機槍 | 公開資料列有艦上機槍 | 沒有合適的美式艦載 M2HB；彈藥列表無 `usn_cal_12.7mm` 類項目 | 未建模 | 中低 |
| AN/SLQ-25 Nixie 魚雷誘餌 | Kidd/基隆級反魚雷拖曳誘餌 | 沒有精確 Nixie；有 `usn_adc_mk1_noisemaker` | 暫用 noisemaker | 中低 |
| Mk 15 Phalanx CIWS Block 差異 | 基隆級有 20mm 方陣；Block 型號公開資料不一 | 有 `MK15` 系統與 `usn_cal_20mm`，但沒有細分 Block 0/1/1A/1B 行為 | 沿用原版 Kidd | 低 |
| Mk 45 5吋艦砲 | 兩座 Mk 45 127mm 艦砲 | 有 `MK45` 與 `usn_cal_127mm` | 已沿用 | 已足夠 |
| RUR-5 ASROC | Mk 26 可發射 ASROC，作為中距離反潛武器 | 有 `usn_rur-5` | 已使用 | 已足夠 |
| Mk 32 / Mk 46 輕型魚雷 | 近距離反潛魚雷 | 有 `usn_mk46_ship`、`usn_mk46_mod5_ship` | 已使用 `usn_mk46_mod5_ship` | 已足夠 |
| Mk 36 SRBOC / RR-144 chaff | 干擾彈發射器 | 有 `Mk_36_SRBOC` 與 `usn_rr144_chaff` | 已使用 | 已足夠 |

## 特定時期或待考證項目

這些項目不建議放進基隆級 baseline，但可以做成之後的 `Late`、`Experimental` 或單艦變體。

| 項目 | 狀態 | Sea Power 狀態 | 建議 |
|---|---|---|---|
| 雄風三型反艦飛彈，HF-3 | 公開資料曾提到蘇澳艦被觀察到以 HF-3 取代魚叉，但不適合作為全級通用狀態 | 遊戲沒有 HF-3 | 可做 `DDG-1802 Su Ao Late/Observed` 變體，需另做飛彈資料與發射箱 |
| 雄風二E / 雄昇類巡弋飛彈 | 2025 年公開資料有基隆級可能升級傳聞，仍應視為未定或未實裝規劃 | 遊戲沒有 HF-2E / Hsiung Sheng 類對地巡弋飛彈 | 先列研究項，不放進現版 |
| 海弓/天弓艦載防空飛彈 | 公開推測較多，且 Mk 26 相容版本未確認 | 遊戲沒有 | 不建議製作，除非取得更可靠資料 |

## Sea Power 原版可用近似品

目前 Sea Power 原版已確認存在的相關彈藥/航空器：

```text
ammunition/usn_rim-66g.ini
ammunition/usn_rgm-84d.ini
ammunition/usn_rur-5.ini
ammunition/usn_mk46_mod5_ship.ini
ammunition/usn_mk46_mod5_air.ini
ammunition/usn_cal_127mm.ini
ammunition/usn_cal_20mm.ini
ammunition/usn_rr144_chaff.ini
ammunition/usn_adc_mk1_noisemaker.ini
aircraft/usn_sh-2f.ini
aircraft/usn_sh-3h.ini
```

目前缺少的精確代號或載台：

```text
rocn_rim-66k-2 或 rocn_sm-2mr_block_iiia
rocn_rgm-84l
rocn_s-70cm
rocn_cal_12_7mm_m2hb 或 rocn_m2hb_ship
rocn_an_slq-25_nixie
rocn_hf-3
rocn_hf-2e
```

## 建議製作順序

1. 先複製 `usn_rim-66g` 做 `rocn_rim-66k-2` 或 `rocn_sm-2mr_block_iiia`，調整射程、機動、年代與顯示名稱。
2. 複製 `usn_rgm-84d` 做 `rocn_rgm-84l`，調整為 Harpoon Block II 的顯示名稱與必要參數。
3. 暫時保留 `usn_sh-2f` 作為 placeholder；等確定航空器複製與模型替代方式後，再做 `rocn_s-70cm`。
4. 12.7mm M2HB、Nixie、Phalanx Block 差異可以晚一點處理，對第一版可玩性影響較小。
5. HF-3 / HF-2E 僅做研究分支或可選 late loadout，不放進基隆級標準版。

## 參考來源

- 中華民國海軍官方基隆級介紹頁：<https://navy.mnd.gov.tw/aboutus/other_info.aspx?aid=30035&id=1>
- Kidd class / Kee Lung class 公開武裝整理：<https://en.wikipedia.org/wiki/Kidd-class_destroyer>
- ROCS Kee Lung 公開武裝整理：<https://en.wikipedia.org/wiki/ROCS_Kee_Lung>
- RIM-66 Standard / SM-2 版本整理：<https://en.wikipedia.org/wiki/RIM-66_Standard>
- 基隆級中文公開整理：<https://zh.wikipedia.org/wiki/%E5%9F%BA%E9%9A%86%E7%B4%9A%E9%A9%85%E9%80%90%E8%89%A6>

公開資料對部分型號會有差異，尤其是 SM-2 的 RIM-66K/L 細分與後續升級傳聞。實作前應再依目標年份決定採用哪一種設定。