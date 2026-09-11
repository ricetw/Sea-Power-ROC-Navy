# 基隆級飛彈公開規格校正（2026-09-11）

本次以公開規格校正遊戲資料，不宣稱重建真實飛彈性能。模型與材質維持原版。

## 來源與適用範圍

- 美國海軍 Standard Missile Fact File：https://www.navy.mil/Resources/Fact-Files/Display-FactFiles/Article/2169011/standard-missile/ 。Block III/IIIA/IIIB 中程系列共用規格：708 kg、最大 90 nmi、雙推力固態火箭、半主動雷達導引。這是系列規格，不是臺灣 K-2 個別批次的測試結果；1558 lb 換算約 706.7 kg，官方同頁的 708 kg 存在四捨五入差異，本模組採其公制欄位。
- 澳洲海軍 Harpoon Block II：https://www.navy.gov.au/capabilities/weapons/rgm-84-harpoon-block-ii 。艦射重量 690.8 kg、射程 124 km、高次音速、227 kg 彈頭、GPS 輔助 INS、反艦及固定地面目標攻擊。此為同型公開資料，不保證基隆級每批彈或射控系統均開放全部模式。
- 波音 Block II 公開搜尋索引列射程「In excess of 67 NM」：https://www.boeing.com/content/dam/boeing/boeingdotcom/defense/weapons-weapons/images/harpoon_product_card.pdf 。本次直接開啟回傳 404，故以可直接讀取的澳洲海軍頁面為主要依據。67 nmi = 124.084 km，僅為公開射程的遊戲近似，不是真實極限。

## 變更

| 參數 | 原設定 | 新設定 | 理由 |
|---|---:|---:|---|
| K-2 Mass | 707 | 708 | 採美國海軍公制欄位；僅四捨五入層級差異 |
| K-2 Power | 26 | 24 | 回歸原版 G 傷害基準；公開彈頭總重量不能直接當作遊戲傷害 |
| K-2 KillProbability | 0.88 | 0.9 | 原版 G 基準，不宣稱真實命中率為 90% |
| K-2 InterceptOutOfAltitudePenalty | 0.28 | 0.40 | 移除沒有數據支持的額外加成 |
| K-2 InterceptSizePenaltyMultiplier | 0.70 | 0.8 | 同上 |
| K-2 MinAttackAltitude | 25 | 35 | 回歸原版 G 近似；不宣稱真實最低攔截高度 |
| L Mass | 690 | 690.8 | 艦射 Block II 公開重量 |
| L RCS | 0.15 | 0.2 | 回歸原版 D；沒有證據支持較小 RCS |
| L SeekerGain | 55 | 50 | 回歸原版 D |
| L RangeGate / SizeGate | 1 / 8 | 2 / 10 | 回歸原版 D，移除未證實加成 |
| L AntiJammerBonus | 0.30 | 0.35 | 回歸原版 D，沒有量化真實抗干擾資料 |

## 保留值與限制

- 標二射程 90 nmi、半主動雷達導引及中途指令修正維持；魚叉射程 67 nmi、主動雷達導引及 Installation 固定設施攻擊維持。
- 魚叉 MidCourseCorrection=0、Retargetable=False 維持。GPS/INS 自主導航與發射後指令更新不同，不加入 Block II+ 資料鏈能力。
- 速度、轉向、推力/燃燒時間、壽命、飛行高度、雷達頻率/功率、導引頭範圍、引信距離、可靠度與補給成本等，維持既有遊戲近似；未取得可靠的型號專屬公開值，不將它們包裝為實測數據。
- 標二 MaxAttackAltitude=120000 ft 與 MaxVelocity=2800 kn 等尤其仍需遊戲內驗證及進一步可靠資料；此次不以未核實的網路數字代替。
- 魚叉 CircularErrorRadiusInstallation=35 保留為遊戲近似，不能視為公開確認的 35 m CEP。此鍵是否完整代表 GPS/INS 導航改善，亦不能由設定文字證明。
- IIIA 真實引信/彈頭改良，不應在缺乏遊戲傷害換算規則時直接換成額外傷害或命中倍率。本次採原版基準的保守校正。
- 外觀引用、發射器位置與特效維持。檢查範圍為 INI 語法、引用、差異及部署一致性，未完成遊戲內發射/攔截測試。
