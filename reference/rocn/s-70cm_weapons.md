# ROCN S-70C(M) Weapons Notes

整理日期：2026-07-09

目的：作為 `mod/aircraft/roc_s-70cm.ini` 第二階段武器與任務配置調校依據，並記錄目前已實作的武器映射。

## 結論摘要

- 中華民國海軍 S-70C(M)-1/2 的核心任務是反潛；第二階段應優先做「反潛魚雷 + 聲納浮標」。
- 基準時期使用 Mk 46 Mod 5 輕型反潛魚雷。公開裝備清單可見中華民國海軍在 1990 年代至 2000 年代取得大量 Mk 46 / Mk 46 Mod 5 系列魚雷；模組目前直接呼叫 Sea Power 官方 `usn_mk46_mod5_air` 空射 Mk-46，保留官方數據、外觀資源與百科顯示。
- 2017 年美國對台軍售項目包含將 168 枚 Mk 46 Mod 5 轉換為 Mk 54 LWT configuration 的套件。這適合做成晚期或升級 loadout，但目前本機可讀到的 Sea Power original 沒有 `usn_mk54_air`，若要實作需另建 `rocn_mk54_air`。
- 聲納浮標的 ROCN 精確型號公開資料不足；先以 Sea Power 原版存在的 `usn_ssq-53` 與 `usn_ssq-62` 作為被動/主動浮標近似。
- 沒有可靠公開資料支持 ROCN S-70C(M) 掛載 AGM-119 Penguin、AGM-114 Hellfire、深水炸彈或火箭作為標準配置；第二階段 baseline 不建議加入。

## 可採用項目

### Mk 46 / Mk 46 Mod 5 輕型反潛魚雷

- 用途：S-70C(M) 的主要攻擊武器，用於定位潛艦後空投攻擊。
- 公開資料狀態：中華民國海軍裝備清單列出多批 Mk 46 與 Mk 46 Mod 5 / NEARTIP 系列交付紀錄。
- 遊戲對應：S-70C(M) 直接使用官方 `usn_mk46_mod5_air`；若要做水面艦 Mk 32 發射版本，則使用官方 `usn_mk46_mod5_ship`。兩者差異主要是發射平台、入水/發射限制與特效，不另做 ROCN 專屬魚雷數值。
- 建議：
  - 作為 2005 年左右基隆級 baseline 的預設魚雷。
  - `ASW` / `Default` loadout 可保留 1 至 2 枚 Mk 46，並搭配聲納浮標。
  - `ASWKiller` 可做純魚雷配置。

### 聲納浮標

- 用途：反潛搜索、分類與追蹤；屬於 S-70C(M) 反潛任務的核心消耗品。
- 公開資料狀態：可確認 S-70C(M) 屬反潛直升機，但公開資料未穩定列出 ROCN 實際使用的每一型 sonobuoy。
- 遊戲對應：
  - `usn_ssq-53`：被動 DIFAR 類浮標近似。
  - `usn_ssq-62`：主動 DICASS 類浮標近似。
- 建議：
  - 第二階段先沿用 `usn_ssq-53` / `usn_ssq-62`。
  - 不使用目前 original 未確認存在的 `usn_ssq-41`、`usn_ssq-47`、`usn_ssq-77`，避免航空器因缺彈藥 ID 無法載入。

## 晚期或升級項目

### Mk 54 Lightweight Torpedo

- 用途：Mk 46 後繼/升級型輕型反潛魚雷，可由反潛航空器或艦艇發射。
- 公開資料狀態：2017 年對台軍售包含 168 組 Mk 54 LWT 轉換套件，用於將 Mk 46 Mod 5 升級/轉換為 Mk 54 configuration。
- 遊戲對應：本機可讀到的 original 目前沒有 `usn_mk54_air`。
- 建議：
  - 不放進早期基隆級 baseline。
  - 若要做 2017 年後或現代化版本，新增 `rocn_mk54_air`，可從 `usn_mk46_mod5_air` 複製後調整 seeker、淺水/反反制、可靠性與成本。
  - 可建立 `Late` 或 `Modern` loadout，例如 `DateBased_Torpedo=0,usn_mk46_mod5_air|2017,rocn_mk54_air`。實作前需確認遊戲是否接受航空器 DateBased loadout 以西元年切換。

## 不建議納入 baseline 的項目

### AGM-119 Penguin

- 公開資料常見於希臘 S-70B-6 Aegean Hawk 等衍生型；有資料指出希臘型以 ROCN S-70C(M) 為基礎但可掛 Penguin。
- 這不能直接反推 ROCN S-70C(M) 有 Penguin 實裝或採購。
- 建議：不納入基隆級 baseline；若做架空/外銷衍生研究，另開 experimental 文件。

### AGM-114 Hellfire

- 美國 SH-60B/MH-60R 系列可見 Hellfire 反小艇/反水面能力。
- 未找到 ROCN S-70C(M) 標準掛載 Hellfire 的可靠公開資料。
- 建議：不納入 baseline。

### 深水炸彈、火箭、航空炸彈

- 現有 Sea Power SH-2F 模板中有 `usn_mk54_dc` 之類歷史/遊戲 loadout，但不代表 ROCN S-70C(M) 使用。
- 建議：從 S-70C(M) 第二階段 baseline 移除；若未來做特殊任務再另考證。

### 機槍 / 門槍

- 可作為自衛或警戒裝備討論，但不是基隆級艦載反潛任務的核心武裝。
- 未找到足夠穩定的 ROCN S-70C(M) 標準門槍公開資料。
- 建議：先不實作；避免把 ASW placeholder 做成泛用武裝直升機。

## 感測器與任務系統備註

這些不是「武裝」，但會影響 Sea Power 內的 S-70C(M) 玩法。

- S-70C(M)-1/2 公開資料常見描述為具備機鼻下方雷達與垂吊式聲納的反潛型。
- SH-60B/SH-60F 衍生脈絡可提供玩法參考：聲納浮標、雷達、MAD/或垂吊聲納、艦機協同資料鏈。
- 目前 `roc_s-70cm.ini` 仍沿用 SH-2F 模型與多數掛點位置；感測器命名如 `LN-66`、`AN/ASQ-81V2` 需要第三階段再做精修。

## Sea Power 第二階段建議映射

### 現階段可直接採用

```ini
DateBased_Torpedo=0,usn_mk46_mod5_air
DateBased_Buoy1=0,usn_ssq-53
DateBased_Buoy2=0,usn_ssq-62
DateBased_Buoy3=0,usn_ssq-53
```

建議 loadout：

- `Default` / `ASW`：2 x Mk 46 + 被動/主動聲納浮標。
- `ASWKiller`：2 x Mk 46。
- `ASWHunter`：聲納浮標，不掛魚雷。
- `ASWHunterLight`：少量聲納浮標，不掛外掛油箱。
- `ASWLongRange`：目前不放外掛油箱；待確認 S-70C(M) 外掛油箱模型/掛點後再調。
- `Transport`：最小可行版保留空掛或純任務占位。

### 未來可新增

```ini
DateBased_Torpedo=0,usn_mk46_mod5_air|2017,rocn_mk54_air
```

前提：

- 新增 `mod/ammunition/rocn_mk54_air.ini`。
- 確認航空器 DateBased loadout 在 Sea Power 中可依年份正確切換。
- 若做基隆級 2005 baseline，不啟用 Mk 54。

## 本機 original 可用性檢查

目前在相鄰 official original 資料夾可確認存在：

```text
ammunition/usn_mk46_mod5_air.ini
ammunition/usn_ssq-53.ini
ammunition/usn_ssq-62.ini
```

目前未確認存在：

```text
ammunition/usn_mk54_air.ini
ammunition/usn_mk46_mod5_air.ini
ammunition/usn_ssq-41.ini
ammunition/usn_ssq-47.ini
ammunition/usn_ssq-77.ini
ammunition/usn_tank_60gal_sh-2.ini
```

因此第二階段不應直接引用未確認存在的 ID。

## 參考來源

- 中華民國海軍裝備清單，魚雷項目列出 Mk 46 與 Mk 54：<https://en.wikipedia.org/wiki/List_of_equipment_of_the_Republic_of_China_Navy>
- 對台軍售列表，2017-06-29 Mk 54 LWT conversion kits 條目：<https://en.wikipedia.org/wiki/List_of_U.S._arms_sales_to_Taiwan>
- SH-60 Seahawk 條目，S-70C(M)-1/2 版本與 SH-60B/F 任務/武器脈絡：<https://en.wikipedia.org/wiki/Sikorsky_SH-60_Seahawk>
- S-70 條目，ROCN S-70C(M)-1/2 與希臘 S-70B-6/Penguin 衍生關係：<https://zh.wikipedia.org/wiki/%E8%A5%BF%E7%A7%91%E6%96%AF%E5%9F%BAS-70%E7%9B%B4%E5%8D%87%E6%A9%9F>
- Mk 46 輕型反潛魚雷規格與用途：<https://en.wikipedia.org/wiki/Mark_46_torpedo>
- Mk 54 輕型反潛魚雷規格與用途：<https://en.wikipedia.org/wiki/Mark_54_lightweight_torpedo>

## 待確認

- ROCN S-70C(M)-1 與 S-70C(M)-2 是否在武器掛載或聲納浮標數量上有公開可用差異。
- 2017 年 Mk 54 轉換套件完成後，是否全部可供 S-70C(M) 空射，或主要用於艦射 Mk 32 / P-3C 等平台。
- Sea Power 是否已有隱藏或新版 `usn_mk54_air`，需以使用者實際官方 original 資料夾再次確認。
