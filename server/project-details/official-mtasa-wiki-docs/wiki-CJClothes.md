# CJ Clothes (MTA)

Clothing types for CJ's character model, including textures, models, and indexes.

## Clothing Types

| Type ID | Name                     |
| ------- | ------------------------ |
| 0       | Shirt                    |
| 1       | Head                     |
| 2       | Trousers                 |
| 3       | Shoes                    |
| 4       | Tattoos: Left Upper Arm  |
| 5       | Tattoos: Left Lower Arm  |
| 6       | Tattoos: Right Upper Arm |
| 7       | Tattoos: Right Lower Arm |
| 8       | Tattoos: Back            |
| 9       | Tattoos: Left Chest      |
| 10      | Tattoos: Right Chest     |
| 11      | Tattoos: Stomach         |
| 12      | Tattoos: Lower Back      |
| 13      | Necklace                 |
| 14      | Watches                  |
| 15      | Glasses                  |
| 16      | Hats                     |
| 17      | Extra                    |

---

## Useful Functions

- `getBodyPartName(partID)` – Get clothing part name
- `getClothesByTypeIndex(type, index)` – Get a specific clothing item
- `getClothesTypeName(typeID)` – Get type name
- `getTypeIndexFromClothes(model)` – Get index for a clothing model
- **BETA:** `addClothingModel(model, texture)` – Add custom clothing (1.6.0 r23124)

---

## Type 0 – Shirts

| Index | Texture        | Model      |
| ----- | -------------- | ---------- |
| 0     | player_torso   | torso      |
| 1     | vestblack      | vest       |
| 2     | vest           | vest       |
| 3     | tshirt2horiz   | tshirt2    |
| 4     | tshirtwhite    | tshirt     |
| 5     | tshirtilovels  | tshirt     |
| 6     | tshirtblunts   | tshirt     |
| 7     | shirtbplaid    | shirtb     |
| 8     | shirtbcheck    | shirtb     |
| 9     | field          | field      |
| 10    | tshirterisyell | tshirt     |
| 11    | tshirterisorn  | tshirt     |
| 12    | trackytop2eris | trackytop1 |
| 13    | bbjackrim      | bbjack     |
| 14    | bballjackrstar | bbjack     |
| 15    | baskballdrib   | baskball   |
| 16    | baskballrim    | baskball   |
| 17    | sixtyniners    | tshirt     |
| 18    | bandits        | baseball   |
| 19    | tshirtprored   | tshirt     |
| 20    | tshirtproblk   | tshirt     |
| 21    | trackytop1pro  | trackytop1 |
| 22    | hockeytop      | sweat      |
| 23    | bbjersey       | sleevt     |
| 24    | shellsuit      | trackytop1 |
| 25    | tshirtheatwht  | tshirt     |
| 26    | tshirtbobomonk | tshirt     |
| 27    | tshirtbobored  | tshirt     |
| 28    | tshirtbase5    | tshirt     |
| 29    | tshirtsuburb   | tshirt     |
| 30    | hoodyamerc     | hoodya     |
| 31    | hoodyabase5    | hoodya     |
| 32    | hoodyarockstar | hoodya     |
| 33    | wcoatblue      | wcoat      |
| 34    | coach          | coach      |
| 35    | coachsemi      | coach      |
| 36    | sweatrstar     | sweat      |
| 37    | hoodyAblue     | hoodyA     |
| 38    | hoodyAblack    | hoodyA     |
| 39    | hoodyAgreen    | hoodyA     |
| 40    | sleevtbrown    | sleevt     |
| 41    | shirtablue     | shirta     |
| 42    | shirtayellow   | shirta     |
| 43    | shirtagrey     | shirta     |
| 44    | shirtbgang     | shirtb     |
| 45    | tshirtzipcrm   | tshirt     |
| 46    | tshirtzipgry   | tshirt     |
| 47    | denimfade      | denim      |
| 48    | bowling        | hawaii     |
| 49    | hoodjackbeige  | hoodjack   |
| 50    | baskballloc    | baskball   |
| 51    | tshirtlocgrey  | tshirt     |
| 52    | tshirtmaddgrey | tshirt     |
| 53    | tshirtmaddgrn  | tshirt     |
| 54    | suit1grey      | suit1      |
| 55    | suit1blk       | suit1      |
| 56    | leather        | leather    |
| 57    | painter        | painter    |
| 58    | hawaiiwht      | hawaii     |
| 59    | hawaiired      | hawaii     |
| 60    | sportjack      | trackytop1 |
| 61    | suit1red       | suit1      |
| 62    | suit1blue      | suit1      |
| 63    | suit1yellow    | suit1      |
| 64    | suit2grn       | suit2      |
| 65    | tuxedo         | suit2      |
| 66    | suit1gang      | suit1      |
| 67    | letter         | sleevt     |

---

## Type 1 – Head

| Index | Texture     | Model     |
| ----- | ----------- | --------- |
| 0     | player_face | head      |
| 1     | hairblond   | head      |
| 2     | hairred     | head      |
| 3     | hairblue    | head      |
| 4     | hairgreen   | head      |
| 5     | hairpink    | head      |
| 6     | bald        | head      |
| 7     | baldbeard   | head      |
| 8     | baldtash    | head      |
| 9     | baldgoatee  | head      |
| 10    | highfade    | head      |
| 11    | highafro    | highafro  |
| 12    | wedge       | wedge     |
| 13    | slope       | slope     |
| 14    | jhericurl   | jheri     |
| 15    | cornrows    | cornrows  |
| 16    | cornrowsb   | cornrows  |
| 17    | tramline    | tramline  |
| 18    | groovecut   | groovecut |
| 19    | mohawk      | mohawk    |
| 20    | mohawkblond | mohawk    |
| 21    | mohawkpink  | mohawk    |
| 22    | mohawkbeard | mohawk    |
| 23    | afro        | afro      |
| 24    | afrotash    | afro      |
| 25    | afrobeard   | afro      |
| 26    | afroblond   | afro      |
| 27    | flattop     | flattop   |
| 28    | elvishair   | elvishair |
| 29    | beard       | head      |
| 30    | tash        | head      |
| 31    | goatee      | head      |
| 32    | afrogoatee  | afro      |

---

## Type 3 – Shoes

| Index | Texture         | Model    |
| ----- | --------------- | -------- |
| 0     | foot            | feet     |
| 1     | cowboyboot2     | biker    |
| 2     | bask2semi       | bask1    |
| 3     | bask1eris       | bask1    |
| 4     | sneakerbincgang | sneaker  |
| 5     | sneakerbincblu  | sneaker  |
| 6     | sneakerbincblk  | sneaker  |
| 7     | sandal          | flipflop |
| 8     | sandalsock      | flipflop |
| 9     | flipflop        | flipflop |
| 10    | hitop           | bask1    |
| 11    | convproblk      | conv     |
| 12    | convproblu      | conv     |
| 13    | convprogrn      | conv     |
| 14    | sneakerprored   | sneaker  |
| 15    | sneakerproblu   | sneaker  |
| 16    | sneakerprowht   | sneaker  |

## Type 16 – Hats

| Index | Texture      | Model       |
| ----- | ------------ | ----------- |
| 0     | bandred      | bandana     |
| 1     | bandblue     | bandana     |
| 2     | bandgang     | bandana     |
| 3     | bandblack    | bandana     |
| 4     | bandred2     | bandknots   |
| 5     | bandblue2    | bandknots   |
| 6     | bandblack2   | bandknots   |
| 7     | bandgang2    | bandknots   |
| 8     | capknitgrn   | capknit     |
| 9     | captruck     | captruck    |
| 10    | cowboy       | cowboy      |
| 11    | hattiger     | cowboy      |
| 12    | helmet       | helmet      |
| 13    | moto         | moto        |
| 14    | boxingcap    | boxingcap   |
| 15    | hockey       | hockeymask  |
| 16    | capgang      | cap         |
| 17    | capgangback  | capback     |
| 18    | capgangside  | capside     |
| 19    | capgangover  | capovereye  |
| 20    | capgangup    | caprimup    |
| 21    | bikerhelmet  | bikerhelmet |
| 22    | capred       | cap         |
| 23    | capredback   | capback     |
| 24    | capredside   | capside     |
| 25    | capredover   | capovereye  |
| 26    | capredup     | caprimup    |
| 27    | capblue      | cap         |
| 28    | capblueback  | capback     |
| 29    | capblueside  | capside     |
| 30    | capblueover  | capovereye  |
| 31    | capblueup    | caprimup    |
| 32    | skullyblk    | skullycap   |
| 33    | skullygrn    | skullycap   |
| 34    | hatmancblk   | hatmanc     |
| 35    | hatmancplaid | hatmanc     |
| 36    | capzip       | cap         |
| 37    | capzipback   | capback     |
| 38    | capzipside   | capside     |
| 39    | capzipover   | capovereye  |
| 40    | capzipup     | caprimup    |
| 41    | beretred     | beret       |
| 42    | beretblk     | beret       |
| 43    | capblk       | cap         |
| 44    | capblkback   | capback     |
| 45    | capblkside   | capside     |
| 46    | capblkover   | capovereye  |
| 47    | capblkup     | caprimup    |
| 48    | trilbydrk    | trilby      |
| 49    | trilbylght   | trilby      |
| 50    | bowler       | bowler      |
| 51    | bowlerred    | bowler      |
| 52    | bowlerblue   | bowler      |
| 53    | bowleryellow | bowler      |
| 54    | boater       | boater      |
| 55    | bowlergang   | bowler      |
| 56    | boaterblk    | boater      |

## Type 17 – Extra Clothing

| Index | Texture   | Model     |
| ----: | --------- | --------- |
|     0 | gimpleg   | gimpleg   |
|     1 | valet     | valet     |
|     2 | countrytr | countrytr |
|     3 | croupier  | valet     |
|     4 | policetr  | policetr  |
|     5 | balaclava | balaclava |
|     6 | pimptr    | pimptr    |
|     7 | garageleg | garagetr  |
|     8 | medictr   | medictr   |
