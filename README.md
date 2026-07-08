# Sea Power ROC Navy

`Sea Power ROC Navy` 是一個以《Sea Power》為目標的中華民國海軍艦艇模組工作區。專案目標是逐步建立可在遊戲中使用的 ROCN 艦艇包，包含艦艇資料、變體、舷號、旗幟、單位圖、中文/英文名稱，以及必要的遊戲設定檔。

目前已完成的第一個單位是中華民國海軍基隆級飛彈驅逐艦，使用遊戲原版美國海軍 Kidd class 作為模型與動畫基礎，並加入 ROCN 旗幟、四艦舷號、中文/英文單位名稱與單位資料圖。

GitHub 倉庫：<https://github.com/ricetw/Sea-Power-ROC-Navy.git>

## 目前狀態

本專案仍在製作中。現階段重點是建立穩定的資料夾規範與第一批可用單位，後續再逐步擴充成功級、康定級、濟陽級、錦江級、沱江級等中華民國海軍艦艇。

目前內容：

- 單位 ID：`roc_ddg_kee_lung`
- 艦級：基隆級飛彈驅逐艦
- 變體：`DDG-1801 基隆`、`DDG-1802 蘇澳`、`DDG-1803 左營`、`DDG-1805 馬公`
- 基礎模型：遊戲原版 `usn_ddg_kidd`
- 自製素材：ROCN 旗幟、基隆級四艦舷號、單位資料圖
- 語言資料：繁體中文與英文
- 目標遊戲版本：Sea Power `v0.8.0` 左右，之後需依遊戲更新持續檢查相容性

## 資料夾結構

```text
ROC-Navy/
├─ mod/                         # 遊戲或 Steam Workshop 實際要載入的模組根目錄
│  ├─ _info.ini                  # 模組名稱、描述與相容版本
│  ├─ README.md                  # 發佈包內的簡短說明
│  ├─ assets/rocn/               # ROCN 自製素材
│  │  ├─ common/flags/           # 共用旗幟、徽章等素材
│  │  └─ ships/<class_id>/       # 各艦級專用素材
│  ├─ language_cn/               # 繁體中文名稱與描述
│  ├─ language_en/               # 英文名稱與描述
│  ├─ ui/profiles/               # 單位資料圖；目前維持平放以確保遊戲可讀取
│  └─ vessels/                   # 艦艇 INI；目前維持平放以確保遊戲可掃描
├─ source/ships/<class_id>/      # 官方圖、裁切素材、考證資料與工作檔
├─ reference/original/<navy>/    # 原版 Sea Power INI 參考檔
├─ scratch/ships/<class_id>/     # 暫存截圖、比較圖與實驗輸出，不進版控
├─ dist/                         # 打包輸出，不進版控
└─ README.md                     # 本文件
```

目前基隆級相關素材位置：

- 舷號貼圖：`mod/assets/rocn/ships/kee_lung/hullnumbers/`
- ROCN 旗幟：`mod/assets/rocn/common/flags/roc.png`
- S-70C(M) 低視度 SH-2F placeholder 貼皮：`mod/assets/rocn/aircraft/s-70cm/`
- 單位資料圖：`mod/ui/profiles/roc_ddg_kee_lung.png`
- 艦艇設定：`mod/vessels/roc_ddg_kee_lung.ini`
- 變體設定：`mod/vessels/roc_ddg_kee_lung_variants.ini`
- 原版 Kidd 參考：`reference/original/usn/usn_ddg_kidd/`

## 安裝與本機測試

遊戲實際只需要 `mod/` 內的內容，不需要整個工作區。

測試方式：

1. 開啟 Sea Power 的本機模組或使用遊戲內模組工具建立本機 mod。
2. 將 `mod/` 內的檔案複製到該本機 mod 的根目錄。
3. 若直接測試目前工作副本，也可同步到：
   `Sea Power_Data/StreamingAssets/user/`
4. 進入遊戲後，在單位資料庫中尋找中華民國海軍與基隆級單位。
5. 檢查旗幟、舷號、單位資料圖、武器清單與艦名是否正確顯示。

請注意：`mod/` 這個資料夾本身是工作區中的發佈根目錄。打包或上架時通常要使用 `mod/` 的內容，而不是把外層 `ROC-Navy/` 整包丟進遊戲。

## 打包

目前建議輸出檔名：

```powershell
Compress-Archive -Path .\mod\* -DestinationPath .\dist\ROC-Navy_mod.zip -Force
```

壓縮檔內第一層應該直接看到：

```text
_info.ini
README.md
assets/
language_cn/
language_en/
ui/
vessels/
```

如果壓縮檔第一層是 `mod/`，代表包裝層級錯了。

## Steam Workshop

Sea Power 的 Workshop 發佈通常應透過遊戲內的模組/Workshop 工具處理。建議流程：

1. 先在本機 `StreamingAssets/user` 或本機 mod 目錄測試。
2. 確認沒有缺圖、缺文字、單位無法載入或變體錯誤。
3. 使用遊戲內工具建立或更新 Workshop 項目。
4. 將 `mod/` 內容作為要上傳的模組內容。
5. 上傳前確認 `_info.ini` 的名稱、描述與相容版本。

GitHub 用來管理原始檔與變更紀錄；Steam Workshop 用來發布給玩家訂閱。兩者用途不同。

## 製作規範

新增艦級時，建議採用以下命名規則：

- 艦級資料夾：使用小寫 snake_case，例如 `kee_lung`、`cheng_kung`、`kang_ding`
- 單位 ID：使用 `roc_<艦種>_<艦級>`，例如 `roc_ddg_kee_lung`
- 艦艇設定：放在 `mod/vessels/`，例如 `roc_ddg_kee_lung.ini`
- 變體設定：放在 `mod/vessels/`，例如 `roc_ddg_kee_lung_variants.ini`
- 舷號素材：放在 `mod/assets/rocn/ships/<class_id>/hullnumbers/`
- 共用 ROCN 素材：放在 `mod/assets/rocn/common/`
- 單位資料圖：放在 `mod/ui/profiles/`，檔名盡量與單位 ID 對應

目前先讓 `vessels/` 與 `ui/profiles/` 維持平放，因為尚未確認 Sea Power 對這些資料夾是否支援遞迴掃描。自製素材則可以安全地依 `assets/rocn/...` 分層。

## 原版資源引用原則

Sea Power 的 INI 中常見這類路徑：

```ini
ResourcesLiveryFolder=ships/usn_ddg_kidd/
LiveryTexture=usn_ddg_kidd_tx
ResourcesHullnumberFolder=ships/materials/hullnumbers/
HullnumberTexture=usn_dd-993
```

這些通常是 Unity Resources 或 asset bundle 內部資源路徑，不一定是磁碟上能直接看到的資料夾。製作模組時應優先引用遊戲原版資源路徑，不要把原版模型、材質或貼圖抽出後重新打包進本專案。

可以放進本專案的內容：

- 自製或自行整理的 INI 設定
- 自製舷號、旗幟、圖示、單位資料圖
- 可公開使用且有來源紀錄的參考資料
- 用於製作與考證的筆記

不應放進本專案的內容：

- 從 Sea Power 原版 asset 中抽出的模型、材質、貼圖或音效
- 來源不明、授權不清楚的圖片或資料
- 本機暫存、打包 zip、測試截圖垃圾檔

## 目前基隆級設定摘要

基隆級使用原版 Kidd class 作為遊戲內近似模型。第一版先以可玩性與資料可讀性為主，尚未建立完整 ROCN 專屬 3D 模型或武器差異。

目前主要沿用或近似：

- 船體與動畫：原版 `usn_ddg_kidd`
- 防空飛彈：使用原版 `usn_rim-66g` 作為 SM-2MR 近似
- 反艦飛彈：使用自訂 `rocn_rgm-84l` Harpoon Block II，沿用原版 `usn_rgm-84d` 外觀
- 艦載直升機：使用自訂 `roc_s-70cm` S-70C(M)，沿用原版 `usn_sh-2f` 外觀、低視度灰色 ROCN placeholder 貼皮，並掛載官方 `usn_mk46_mod5_air` Mk 46 Mod 5
- 電戰、雷達、聲納與火砲：以 Kidd class 設定為基礎逐步調整

後續若遊戲或模組工具支援更多武器、雷達或直升機，可再拆成更精準的 ROCN 時期設定。

## Git 工作流程

第一次建立或接手專案：

```powershell
git init -b main
git remote add origin https://github.com/ricetw/Sea-Power-ROC-Navy.git
git add README.md .gitignore .gitattributes mod source reference
git commit -m "Initial ROC Navy Sea Power mod workspace"
```

日常修改：

```powershell
git status
git add <changed-files>
git commit -m "描述這次修改"
git push
```

打包輸出的 `dist/*.zip` 不進 Git。需要發布時重新打包即可。

## 後續計畫

建議優先順序：

1. 穩定基隆級：舷號位置、單位資料圖、中文描述、武器與感測器資料。
2. 建立其他可由原版模型近似的 ROCN 艦艇。
3. 補足更多官方來源與考證筆記。
4. 製作更完整的 ROCN 旗幟、艦徽、舷號與資料圖模板。
5. 研究自製模型、材質與更精準武器系統的導入方式。

候選艦級：

- 成功級巡防艦
- 康定級巡防艦
- 濟陽級巡防艦
- 錦江級巡邏艦
- 沱江級巡邏艦
- 磐石級補給艦

## 素材來源與註記

基隆級單位資料圖來源：中華民國海軍官方基隆級艦艇介紹頁面，經裁切後作為遊戲內單位資料圖使用。

來源連結：
<https://navy.mnd.gov.tw/aboutus/other_info.aspx?aid=30035&id=1>

所有 Sea Power 原版資源仍屬原權利人所有。本專案只保存模組設定、自製素材與參考筆記，不重新散布原版遊戲資源。
