# Hsiung Feng III Modeling Notes

This note documents the public references and exterior assumptions used for the Sea Power visual OBJ model.

## Public reference points

- Common public dimensions: overall length about 6.1 m and main body diameter about 0.46 m.
- Public exterior descriptions identify four inlet ducts and four clipped-delta control surfaces.
- Public propulsion descriptions identify a solid rocket booster phase, liquid-fuel ramjet sustainment, and two diagonally mounted solid-propellant strap-on boosters.
- Wikimedia Commons public display imagery provides the baseline missile silhouette and side profile.
- User-provided launch and exhibition photos were used for color blocking, strap-on booster placement, nose color, dark body, red fins, and side markings.

## Modeling decisions

- Coordinate system: nose points toward +X, Y is starboard, Z is up.
- Scale: total model bounds are -3.05 m to +3.05 m on X, matching a 6.1 m overall length.
- Main missile body: 0.46 m diameter basis, dark graphite finish, white ogive nose.
- Ramjet/intake layout: four conformal external duct fairings at the top, starboard, bottom, and port positions, not four separate round tubes.
- Intake details: long black recessed slots and forward black scoop mouths are modeled as separate geometry and material groups.
- Boosters: two diagonal strap-on boosters sit in the gaps between the ramjet ducts, at the upper-starboard and lower-port diagonal positions; each uses a gold-brown cylinder, white pointed nose cap, black rear nozzle, mounting saddles, and aft fins.
- Control surfaces: four red clipped-delta tail fins are placed between the duct/booster geometry.
- Markings: side text and S001 are texture planes referenced by the MTL; blue/white roundels are modeled as small geometry discs.

## Limits

The model is a high-poly game-art approximation based on public imagery and dimensions. It is not CAD-accurate and should not be treated as a manufacturing or engineering model.

## Source links

- https://en.wikipedia.org/wiki/Hsiung_Feng_III
- https://zh.wikipedia.org/zh-tw/%E9%9B%84%E9%A2%A8%E4%B8%89%E5%9E%8B%E5%8F%8D%E8%89%A6%E9%A3%9B%E5%BD%88
- https://commons.wikimedia.org/wiki/Category:Hsiung_Feng_III
- https://commons.wikimedia.org/wiki/File:%E9%9B%84%E9%A2%A8%E4%B8%89%E5%9E%8B%E5%8F%8D%E8%89%A6%E9%A3%9B%E5%BD%88.jpg
- https://www.ncsist.org.tw/csistdup/products/product.aspx?catalog=30&product_id=10
- https://www.ncsist.org.tw/csistdup/products/productRelated.aspx?id=144

## Gameplay integration

- Game ammunition ID: `rocn_hf-3`.
- The HF-3 is added as an independent Sea Power ammunition entry and does not overwrite `rocn_rgm-84l` or vanilla Harpoon data.
- Standard-model public data is used for core gameplay values: 150 km range (`81 nmi`), Mach 2.5-class speed (`1650 kt` in-game), and approximately 1.4 t mass.
- Warhead power, seeker range, ECCM, and defensive modifiers are game-scale approximations derived from Sea Power's Harpoon and SS-N-22/HY-3 balance ranges because detailed official seeker/warhead parameters are not public.
- NCSIST explicitly describes HF-3 as a supersonic low-altitude sea-skimming missile. A public report hosted by NCSIST gives an approximate 20-200 m flight band, but no official boost-transition altitude or complete trajectory is disclosed.
- The Sea Power profile therefore uses a short 25-degree boost climb capped at 656 ft (200 m), followed by a 65 ft (20 m) low-altitude cruise. The previous 30,000 ft setting was copied from the vanilla SS-N-22 high-low profile and is not supported for HF-3.
- The source OBJ remains in meter scale with +X forward. `rocn_hf-3_game.obj` is generated at 1:100 scale with +Z forward and split into material-named objects for Sea Power's OBJ loader.
- Kee Lung-class vessels keep their RGM-84L Harpoon loadout. HF-3 is currently assigned to the modern Cheng Kung-class fit and can be reused by future Tuo Chiang, Kuang Hua VI, and shore-launcher entries.
