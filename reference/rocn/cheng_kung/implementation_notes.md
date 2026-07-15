# 成功級第一版實作筆記

## 建模基準

成功級為美國海軍 Oliver Hazard Perry 級的修改型，本模組以 Sea Power 原版長船體派里級作為船體、機庫、飛行甲板、感測器掛點與動畫基礎。官方公開尺寸為滿載排水量 4,104 噸、長 138.1 公尺、寬 13.7 公尺、最大速率 28 節，已套用至 `roc_ffg_cheng_kung.ini`。

## 第一版武裝

- Mk 13 單臂發射器：40 枚 `usn_rim-66e`，作為成功級 SM-1MR 配裝。
- 1993 至 2006：兩組四聯裝 `rocn_hf-2`，合計 8 枚雄風二型。
- 2007 起：一組四聯裝 `rocn_hf-2` 與一組四聯裝 `rocn_hf-3`，合計雄二、雄三各 4 枚。
- OTO 76 mm、Mk 32 魚雷管、Mk 15 方陣與誘餌系統沿用原版派里級基礎。
- 前七艘增加左右舷各一門 40 mm 快砲；田單艦取消這兩門砲，因此拆成獨立的 `roc_ffg_tien_tan` 單位定義。
- 艦載航空隊改為兩架 `roc_s-70cm`。

## 已知外觀近似

- 原版沒有成功級專用雄風發射箱；目前使用原版 Mk 141 四聯裝箱體作為可替換掛點。
- 原版沒有成功級 Bofors 350PX 40 mm L/70 單裝砲；目前使用最接近的單裝 Bofors 幾何與 `Bofors_L60` 系統近似。
- `rocn_hf-2` 是獨立彈藥資料，但第一版暫用原版 Harpoon 飛彈外觀；完成 HF-2 自製模型後可直接替換，不需修改艦艇武器邏輯。
- 成功級與原版長船體派里級的上層結構、電子裝備與局部甲板配置仍有差異，第一版以可玩與可測試為優先。
- 2007 是全艦級統一的遊戲化換裝分界；實艦改裝並非八艘在同一天完成。

## 來源

- 中華民國海軍，成功級飛彈巡防艦：<https://navy.mnd.gov.tw/AboutUs/Other_Info.aspx?AID=30033&ID=1>
- 國家中山科學研究院，雄風二型反艦飛彈：<https://www.ncsist.org.tw/csistdup/products/product.aspx?catalog=30&product_Id=238>
- 國家中山科學研究院，雄風三型超音速反艦飛彈：<https://www.ncsist.org.tw/eng/csistdup/products/product.aspx?catalog=8&product_Id=10>
- 成功級詳細配裝交叉參考：<https://www.mdc.idv.tw/mdc/navy/rocnavy/FFG1101.htm>
