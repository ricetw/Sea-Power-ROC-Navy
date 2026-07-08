# ROCN S-70C(M) Low-Visibility Placeholder Livery

建立日期：2026-07-09

## 目的

目前 Sea Power 本機可用的 official original 內沒有 SH-60 / S-70C(M) 模型，因此 `roc_s-70cm` 暫時沿用原版 `usn_sh-2f` 模型。這份貼皮是第一階段外觀近似：使用灰色機身與中華民國海軍低視度標示，讓遊戲內識別更接近 ROCN 艦載反潛直升機，而不更動 3D 模型。

## 已新增素材

```text
mod/assets/rocn/aircraft/s-70cm/liveries/roc_s-70cm_lowvis.png
mod/assets/rocn/aircraft/s-70cm/emblems/roc_roundel_lowvis.png
mod/assets/rocn/aircraft/s-70cm/emblems/roc_flag_lowvis.png
mod/assets/rocn/aircraft/s-70cm/serials/701.png
mod/assets/rocn/aircraft/s-70cm/serials/702.png
mod/assets/rocn/aircraft/s-70cm/serials/703.png
mod/assets/rocn/aircraft/s-70cm/serials/705.png
```

## 素材來源與修正

- `roc_roundel_lowvis.png` 與 `roc_flag_lowvis.png` 由本專案既有 `mod/assets/rocn/common/flags/roc.png` 轉製為低視度灰階素材，未使用外部下載圖檔。
- `roc_s-70cm_lowvis.png` 為 SH-2F placeholder 用的灰色底圖；其中白日標誌已改用 `roc.png` 抽出的形狀，避免手繪造成光芒比例不準。
- SH-2F 內建 `Emblem` / `Flag1` 貼花位置與參考照片不符，因此 squadron 檔已停用獨立徽章/旗幟貼花，改由 livery 圖面內嵌低視度國籍標誌。`roc_s-70cm_lowvis.png` 曾放置多個測試標誌，但 SH-2F UV 會把左右測試點映到同一側機身；目前已移除前機身測試標誌與文字，只保留一個對應後機身/尾樑區域的主標誌。
- 機號 `701`、`702`、`703`、`705` 為本模組產生的低視度 placeholder 編號，可依後續實際考證替換。

## 設定入口

`mod/aircraft/roc_s-70cm_squadrons.ini`

```ini
SerialnumberReferences=Modex

[Default]
ResourcesSerialnumberFolder=assets/rocn/aircraft/s-70cm/serials/
SerialnumberTextures=701.png,702.png,703.png,705.png
ResourcesEmblemFolder=
EmblemTexture=
ResourcesLiveryFolder=assets/rocn/aircraft/s-70cm/liveries/
LiveryTexture=roc_s-70cm_lowvis.png
ResourcesFlagFolder=
FlagTexture=
Nation=RoC

[Squadron1]
ResourcesSerialnumberFolder=assets/rocn/aircraft/s-70cm/serials/
SerialnumberTextures=701.png,702.png,703.png,705.png
ResourcesEmblemFolder=
EmblemTexture=
ResourcesLiveryFolder=assets/rocn/aircraft/s-70cm/liveries/
LiveryTexture=roc_s-70cm_lowvis.png
ResourcesFlagFolder=
FlagTexture=
Nation=RoC
```

## 限制

- 這不是 S-70C(M) 真模型，只是 SH-2F placeholder 貼皮。
- `LiveryTexture` 是否完整覆蓋 SH-2F 主材質需進遊戲確認；若遊戲未套用 aircraft 外部 livery，仍會顯示原版 SH-2F 材質。
- 低視度國籍標誌與機號依賴 SH-2F 模型內是否有 `Flag1`、`Emblem`、`Modex` 參照點；若只出現機號或只出現機身灰色，表示該模型可用貼圖參照有限。
- 下一階段若要更準確，需要製作 S-70C(M) 3D 模型與對應 AssetBundle。
