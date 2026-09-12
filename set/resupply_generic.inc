;syntaxis
;{item "bullet15" "ap" "ammo" 25 {max 400}{value 5}}
;that means that ammo of type "bullet15" "ap" "ammo" refills by 25 to maximum of 400, and this costs 5 ammo points of refiller

;{radius 			10}		;resupply radius in meter
;{resupplyPeriod 	2.5}	;resupply period in seconds
;{regenerationPeriod 25}		;regeneration period in seconds, +1 supply every x seconds (0 = no regeneration)
;{limit 			500}	;max number of resupplies (0 = unlimited)

(define "supply_decal"
	{DecalView supply_zone
		{Sprite "/texture/common/service/supply_zone.ebm"
			{Visibility 0.25}
		}
		{Layer grounddynamic}
		{Visible 0}
	}
)
;Автопополнение возможно только в том случае, если таг заряжания снаряда 
;входит в его название, а не просто прописан внутри
;====================================CW=====================
;Гранаты и бинты раздаютс в соотв. с инвентарем, 
;если у солдата по умолчанию РГН - он получит РГН, если Ф1 - то РГН ему не видать, дадут Ф1.
;Солдат без гранат получать их не будет.
;Стрелковые боеприпасы, в т. ч. подствольные, раздаются до указанного максимума, а не по инвентарю.
;Стрелок с ПГ получит все ПГ, прописанные в инвентаре.
;Разведчик с ВСС и АК-74 получит полный БК патронов под каждый ствол, а не в соотв. со своим инвентарем.
;РПГ не удается пополнять заряженными.
;Не всегда пополнется до желаемого объема. Скажем, 12.7мм пулемет или АГС - нет.
;Причина этого неясна, но единственный найденный способ обхода - правки объема и веса инвентаря так, чтобы в один стек влезал разумный боекомплект.
;Скажем, БМП и БТР можно оставить как есть, 100 снарядов не так мало
;А вот АГС надо уменьшить инвентарь и увеличить вес клетки, чтобы в нее влезало 30 гранат.
;То же и с зу-23-2.
;При этом, по каким-то несным причинам, иногда пополнение происходит до номинала, а не до объема одной ячейки
;Например, БМП-3.
;В максимальный боезапас при снабжении входят снаряды в инвентаре и заряженные, но не заряжаемые.
;Если можно пополнить БК несколькими видами однотипных снарядов, то будет выбран тот, что по умолчанию.
;т. е. от одного грузовика Т-64 получит Заколку, Оплот - Вант, а Армата - Свинец-1
;Пополнитель вовсе не должен быть обитаемым юнитом. Грузовик без экипажа тоже пополняет.
;Для отображения количества припасов юнит должен иметь топливный бак.
;Расстояние до пополнителя вычисляетс сферически, а не проекцией.
;Т. е. летящий самолет получает боеприпасы только на сверхмалых высотах.
;Если в инвентаре нет никаких снарядов для этого оружия - заряжаются все возможные (но только если это оружие не первое по порядку).
;Если есть - только имеющиеся в инвентаре, до количества, указанного в инвентаре.
;При этом, заряженное в первое по счету в дефе орудие, не учитывается.


;Параметр max - максимальный объем пополнения. При коэффициенте max(1) - полный БК. 
;Можно увеличить лимит пополнения, если надо, но не уменьшить.
;Параметр value - цена за 1 обойму, {item "545 ammo" 30 означает, что обойма 30 патронов
;При нижеуказанных объемах БК получилась такая схема: цену БП ставить по весу, 
;но легкому управляемому оружию (до 200 кг весом) ее удваивать.
;При этом полный БК снарядов одного типа не должен превышать 3000 (напр. Искандер весит 3800, но мы ему даем 1500)
;Авиационное вооружение наоборот, режется по массе вдвое.

;Ящик несет 1000 единиц
;Урал - 3 ящика по 1000 - 3000
;Самолеты - 3000
;Мста, Град, Искандер - 3000
;Танк - 1500 14 БПС 17 ОС 4 КС 6 ТУР=360
;БМП-2 - 700 (600 ПКМ =24 500 30мм=500 4 ПТУР=200)
;Миномет - 300
;АГС - 30 единиц на улитку
;1 рожок - 1 единица 

;====================================Пополнители ящиков снабжения=====================
(define "smallarms_rus"
	{item "standart ammo" 10 		{max 20}	{value 1}}				
	{item "pistol ammo" 10 			{max 20}	{value 1}}				
	{item "9mm ammo" 10 			{max 20}	{value 1}}				
	{item "545 ammo" 30 			{max 180}	{value 1}}				
	{item "RPK_ammo ammo" 45 		{max 180}	{value 1}}				
	{item "762 ammo" 30 			{max 180}	{value 1}}				
	{item "762x41pss ammo" 10 		{max 30}	{value 1}}				
	{item "pkm_ammo ammo" 100 		{max 600}	{value 4}}				
	{item "osv_ap ammo" 5 			{max 15}	{value 1}}				
	{item "osv_fg ammo" 5 			{max 15}	{value 1}}				
	{item "osv_fl ammo" 5 			{max 15}	{value 1}}				
	{item "762x51_x20 ammo" 10 		{max 100}	{value 1}}
    {item "8_6x70_x10 ammo" 10      {max 120}   {value 1}}		
	{item "SVD_ammo ammo" 10 		{max 120}	{value 1}}				
	{item "svdk_ammo ammo" 10 		{max 70}	{value 1}}				
	{item "Vin_ammo ammo" 10 		{max 80}	{value 1}}
	{item "mortar pd a ammo" 1 		{max 5}	{value 1}}
;	{item "mortar pd p ammo" 1 		{max 4}	{value 1}}
;	{item "mortar pd pm ammo" 1 	{max 4}	{value 1}}
	{item "mortar pd m ammo" 1 		{max 3}	{value 1}}
	{item "f1 grenade" 1 			{max 4}	{value 1}}
	{item "rgd grenade" 1 			{max 4}	{value 1}}
	{item "rgn grenade" 1 			{max 4}	{value 1}}
	{item "rgo grenade" 1 			{max 4}	{value 1}}
	{item "smoke grenade" 1 		{max 2}	{value 1}}
	{item "bandage" 1 				{max 5}	{value 1}}
	{item "ur_83p_ammo ammo" 1 		{max 2}	{value 25}}
)
(define "UAV_rus"
	{item "eleron3sv ammo" 1 {max 1}{value 150}}				
)
(define "smallarms_west"	;common for USA and NATO
	{item "standart ammo" 10 {max 30}{value 1}}				
	{item "pistol ammo" 10 {max 30}{value 1}}				
	{item "9mm ammo" 10 {max 30}{value 1}}				
	{item "556Nato ammo" 30 {max 180}{value 1}}				
	{item "556NatoS ammo" 30 {max 180}{value 1}}	
	{item "556natomb ammo" 100 {max 800}{value 2}}						
	{item "762Nato ammo" 100 {max 600}{value 4}}	
	{item "762x51_x20 ammo" 10 {max 120}{value 1}}	
    {item "762 ammo" 30 			{max 180}	{value 1}}	
	{item "12mm_shotgun ammo" 10 {max 50}{value 1}}				
	{item "nato_ptr ap ammo" 10 {max 40}{value 1}}				
	{item "nato_ptr sn ammo" 10 {max 40}{value 1}}				
	{item "8_6x70_x10 ammo" 10 {max 120}{value 1}}				
	{item "103x77_x5 ammo" 10 {max 120}{value 1}}	
	{item "bandage" 1 {max 5}{value 1}}
	
	{item "pkm_ammo ammo" 100 		{max 600}	{value 4}}
)
(define "fpv"
	{item "fpv_drone" 1 {max 2}{value 20}}
	{item "fpv_drone120" 1 {max 2}{value 20}}

)
(define "smallarms_usa"
	{item "nato_pg cm ammo" 1 {max 8}{value 1}}
;	{item "40x46_natopg fg ammo" 1 {max 4}{value 1}}
	{item "grenade_xm25 ammo cm" 1 {max 6}{value 1}}
	{item "grenade_xm25 ammo fg" 1 {max 6}{value 1}}
	{item "m61 grenade" 1 {max 4}{value 1}}
	{item "m67 grenade" 1 {max 4}{value 1}} 
	{item "rq11raven" 1 {max 1}{value 115}}
	{item "switchblade300 ammo" 1 {max 2}{value 25}}
	{item "switchblade600 ammo" 1 {max 2}{value 50}}
)
(define "smallarms_nato"
	{item "40x46ammo 40x46_natopg ammo cm" 1 {max 4}{value 1}}
	{item "40x46ammo 40x46_gerpg ammo fg" 1 {max 4}{value 1}}
	{item "grenade_famas fg ammo" 1 {max 3}{value 3}}
	{item "grenade_famas cm ammo" 1 {max 3}{value 3}}
	{item "grenade_famas sm ammo" 1 {max 1}{value 3}}
	{item "dm51gr grenade" 1 {max 4}{value 1}}
	{item "of37_grenade grenade" 1 {max 4}{value 1}}
	{item "m61 grenade" 1 {max 4}{value 1}}
	{item "m67 grenade" 1 {max 4}{value 1}}
	{item "aladin" 1 {max 1}{value 125}}
)
(define "smallarms_cn"
	{item "standart ammo" 10 				{max 20}	{value 1}}				
	{item "pistol ammo" 10 					{max 20}	{value 1}}				
	{item "58ammo 58ammo_basic ammo" 30 	{max 180}	{value 1}}				
	{item "58ammo 58ammo_drum ammo" 70 	{max 280}	{value 1}}				
	{item "58ammo 58ammo_sn ammo" 10 	{max 120}	{value 1}}				
	{item "cn_pg fg ammo" 1 		{max 5}	{value 1}}
	{item "type86p grenade" 1 			{max 4}	{value 1}}
	{item "smoke grenade" 1 		{max 2}	{value 1}}
	{item "bandage" 1 				{max 5}	{value 1}}
	{item "ch802" 1 {max 1}{value 125}}
)
(define "hmgun_rus"
	{item "Hcb_ammo ammo" 50 {max 300}{value 1}}				
	{item "dshkm_ammo ammo" 50 {max 300}{value 1}}				
	{item "Kpvt_ammo ammo" 25 {max 300}{value 1}}				
	{item "Kpvt_bst ammo" 25 {max 80}{value 1}}				
	{item "Kpvt_mdz ammo" 25 {max 80}{value 1}}				
)
(define "hmgun_cn"
	{item "Hcb_ammo ammo" 50 {max 300}{value 1}}				
)
(define "hmgun_usa"
	{item "50Nato ammo" 50 {max 1000}{value 1}}
	{item "50NatoAP ammo" 50 {max 200}{value 1}}					
)
(define "hmgun_nato"
	{item "50Nato ammo" 50 {max 1000}{value 1}}	
    {item "Hcb_ammo ammo" 50 {max 300}{value 1}}				
	{item "dshkm_ammo ammo" 50 {max 300}{value 1}}		
)

;---------------Grenades----------------

(define "ags30"
	{item "agsammo ammo" 30 {max 180}{value 3}}				
)
(define "mk19_usa"
	{item "40x53ammo 40x53_usapg ammo cm" 30 {max 180}{value 3}}	
	{item "mk19_ammo ammo fg" 30 {max 90}{value 3}}	
	{item "40x53_usapg ammo cm" 30 {max 180}{value 3}}	
)
(define "mk19_nato"
	{item "40x53_natopg ammo cm" 30 {max 180}{value 3}}	
	{item "40x53_natopg ammo fg" 30 {max 180}{value 3}}	
	{item "40x53_gerpg ammo cm" 30 {max 180}{value 3}}	
	{item "40x53_gerpg ammo fg" 30 {max 180}{value 3}}	
)
(define "ags_cn"
	{item "35x32ammo cm ammo" 30 {max 180}{value 3}}				
	{item "35x32ammo cm ammo" 30 {max 180}{value 3}}				
)
(define "mortar_usa"
	{item "81mm of ammo" 3 {max 30}{value 3}}				
	{item "mortar 60mm of ammo" 1 {max 20}{value 1}}				
)
(define "mortar_rus"
	{item "82mm of ammo" 3 {max 30}{value 3}}
)
(define "mortar_cn"
	{item "82mm er ammo" 3 {max 30}{value 3}}
)
(define "type63_cn"
	{item "type63_rocket fg ammo" 2 {max 24}{value 8}}
)
;---------------RPGs----------------

(define "rpg_rus"
	{item "PG-7VL RPG7 ammo" 1 {max 3}{value 1}}				
;	{item "TBG-7V RPG7 ammo" 1 {max 1}{value 2}}				
;	{item "RPG7_og-7V RPG7 ammo" 1 {max 1}{value 2}}				
	{item "PG-7VR RPG7 ammo" 1 {max 2}{value 3}}				
	{item "PG-29V RPG29 ammo" 1 {max 3}{value 3}}				
	{item "TBG-29 RPG29 ammo" 1 {max 1}{value 3}}				
)

(define "rpg_usa"
	{item "SMAW cm ammo" 1 {max 4}{value 2}}				
	{item "SMAW fg ammo" 1 {max 1}{value 2}}
    {item "gustaf3 heat551 ammo" 1 {max 1}{value 2}}				
	{item "gustaf3 heat751 ammo" 1 {max 3}{value 2}}	
)

(define "rpg_nato"
;	{item "pzf3 dm12a1 ammo" 1 {max 2}{value 2}}				
	{item "pzf3 dm22 ammo" 1 {max 1}{value 2}}				
	{item "pzf3 dm22i ammo" 1 {max 1}{value 2}}				
;	{item "pzf3 dm32 ammo" 1 {max 1}{value 2}}				
	{item "gustaf3 heat551 ammo" 1 {max 1}{value 2}}				
	{item "gustaf3 heat751 ammo" 1 {max 3}{value 2}}				
)

(define "rpg_cn"
	{item "PG-7VL RPG7 ammo" 1 {max 3}{value 1}}				
	{item "PG-29V RPG29 ammo" 1 {max 3}{value 3}}				
	{item "heat_pf98 cm ammo" 1 {max 2}{value 3}}				
	{item "heat_pf98 fg ammo" 1 {max 1}{value 3}}				
)
;---------------Autocannons----------------
(define "autocannons_rus"
	{item "bullet23" "bzt" "zenite" "ammo" 10 {max 400}{value 2}}				
	{item "bullet23" "ofzt" "zenite" "ammo" 10 {max 400}{value 2}}
	{item "bullet23_115 bzt zenite" 10 {max 200}{value 3}}				
	{item "bullet23_115 ofzt zenite" 10 {max 300}{value 3}}				
	{item "bullet30_RUS ap ammo" 30 {max 160}{value 2}}				
	{item "bullet30_RUS fg ammo" 30 {max 350}{value 2}}	
    {item "bullet57_RUS ap ammo" 25 {max 120}{value 2}}				
	{item "bullet57_RUS fg ammo" 25 {max 120}{value 2}}	
	{item "GSH-30_ammo fg ammo" 10 {max 150}{value 2}}				
	{item "GSH-30_ammo ap ammo" 10 {max 150}{value 2}}				
)
(define "autocannons_usa"
	{item "M61ammo vulcan20mm ammo" 20 {max 800}{value 2}}	
	{item "M61ammo vulcan20mmA ammo" 20 {max 800}{value 2}}	
	{item "M61ammo vulcan20mmB ammo" 20 {max 800}{value 2}}	
	{item "bullet25_USA ap ammo" 10 {max 225}{value 2}}				
	{item "bullet25_USA fg ammo" 10 {max 675}{value 2}}				
	{item "bullet30_USA cm ammo" 10 {max 400}{value 2}}				
	{item "gau-8 ap ammo" 10 {max 300}{value 2}}				
	{item "gau-8 fg ammo" 10 {max 600}{value 2}}				
)
(define "autocannons_nato"
	{item "bullet20_139 ap ammo" 10 {max 200}{value 2}}				
	{item "bullet20_139 fg ammo" 10 {max 400}{value 2}}	
	{item "M61ammo vulcan20mm ammo" 10 {max 400}{value 2}}	
	{item "M61ammo vulcan20mmA ammo" 10 {max 200}{value 2}}	
	{item "M61ammo vulcan20mmB ammo" 10 {max 200}{value 2}}	
	{item "bullet25_FR ap ammo" 10 {max 111}{value 2}}				
	{item "bullet25_FR fg ammo" 10 {max 111}{value 2}}				
	{item "bullet27_ger ap ammo" 10 {max 180}{value 2}}				
	{item "bullet27_ger fg ammo" 10 {max 180}{value 2}}				
	{item "mk30abm apcr ammo" 10 {max 200}{value 10}}				
	{item "mk30abm_abm mk30abm fg ammo" 10 {max 200}{value 10}}				
	{item "bullet30_gb ap ammo" 10 {max 114}{value 2}}				
	{item "bullet30_gb fg ammo" 10 {max 114}{value 2}}				
	{item "bullet35 ap ammo" 10 {max 200}{value 2}}				
	{item "bullet35 apcr ammo" 10 {max 40}{value 2}}				
	{item "bullet35 fg ammo" 10 {max 400}{value 2}}				
	{item "bullet40_NATO abm ammo" 10 {max 200}{value 12}}				
	{item "bullet40_NATO apcr ammo" 10 {max 100}{value 12}}				
;	{item "bullet40_NATO fg ammo" 10 {max 200}{value 3}}				
)
(define "autocannons_cn"
	{item "bullet23_115 bzt zenite" 10 {max 200}{value 3}}				
	{item "bullet23_115 ofzt zenite" 10 {max 300}{value 3}}				
;	{item "bullet30_rus ap_cn ap ammo" 30 {max 160}{value 2}}				
	{item "bullet30_rus apcr_cn ap ammo" 30 {max 100}{value 3}}				
	{item "bullet30_RUS fg fg_cn ammo" 30 {max 350}{value 2}}	
	{item "bullet35_cn ap ammo" 10 {max 200}{value 2}}				
	{item "bullet35_cn fg ammo" 10 {max 400}{value 2}}				
	{item "bullet25_cn ap ammo" 10 {max 120}{value 2}}				
	{item "bullet25_cn fg ammo" 10 {max 160}{value 2}}				
)

;---------------Shells----------------

(define "telson"
	{item "bullet68_FR cm ammo" 6 {max 24}{value 4}}
	{item "bullet68_FR fg ammo" 6 {max 24}{value 4}}				
)
(define "hydra"
	{item "Bullet70_Hydra ammo" 9 {max 38}{value 3}}				
)
(define "73mm"
	{item "bullet73_RUS" "fg" "ammo" 1 {max 24}{value 2}}				
	{item "bullet73_RUS" "cm" "ammo" 1 {max 15}{value 2}}				
	{item "grenade_spg9" "fg" "ammo" 1 {max 9}{value 2}}				
	{item "grenade_spg9" "cm" "ammo" 1 {max 9}{value 2}}				
)
(define "c13"
	{item "bullet122s13" "fg" "ammo" 1 {max 20}{value 3}}			
)
(define "c8"
;	{item "bullet80_DM" "fg" "ammo" 10 {max 40}{value 5}}				
;	{item "bullet80_DM" "fgh" "ammo" 10 {max 40}{value 50}}				
	{item "bullet80_DM" "cm" "ammo" 10 {max 40}{value 10}}				
)
(define "c5"
	{item "c5" "fg" "ammo" 10 {max 64}{value 6}}				
	{item "c5" "cm" "ammo" 10 {max 64}{value 6}}				
)
(define "brmi90"
	{item "brmi-90" "ammo" 2 {max 14}{value 20}}				
)
(define "100mm"
	{item "bullet100_RUS" "fg" "ammo" 1 {max 17}{value 3}}				
	{item "bullet100_RUS" "cm" "ammo" 1 {max 10}{value 2}}				
	{item "bullet100_RUS" "apcr" "ammo" 1 {max 15}{value 2}}				
	{item "bullet100_RUS" "ap" "ammo" 1 {max 15}{value 3}}				
)
(define "100mm_bmp3"
	{item "bullet100a_RUS" "fg" "2a70ammo" "ammo" 1 {max 40}{value 2}}				
	{item "bullet100a_RUS" "rok" "2a70ammo" "ammo" 1 {max 8}{value 3}}				
)
(define "100mm_rapira"
	{item "bullet100_rus_rapira" "fg" "ammo" 1 {max 14}{value 3}}				
	{item "bullet100_rus_rapira" "cm" "ammo" 1 {max 16}{value 2}}				
	{item "bullet100_rus_rapira" "apcr" "ammo" 1 {max 19}{value 2}}				
)
(define "105mm_usa"
	{item "bullet105_USA fg bullet105_NATO ammo" 1 {max 20}{value 2}}				
	{item "bullet105_USA cm bullet105_NATO ammo" 1 {max 20}{value 2}}				
;	{item "bullet105_USA apcr bullet105_NATO ammo" 1 {max 20}{value 2}}				
	{item "bullet105_USA apcr_h bullet105_NATO ammo" 1 {max 20}{value 2}}				
	{item "bullet105_USA ap bullet105_NATO ammo" 1 {max 8}{value 2}}				
;	{item "bullet105_USA" "sm" "ammo" 1 {max 2}{value 2}}
    {item "bullet105how_usa fg ammo" 5 {max 40}{value 15}}
	{item "bullet105how_usa sm ammo" 1 {max 30}{value 5}}				
)
(define "105mm_NATO"
	{item "bullet105how_uk fg ammo" 5 {max 40}{value 15}}
    {item "bullet105how_uk sm ammo" 1 {max 30}{value 5}}				
)
(define "105mm_idf"
	{item "bullet105_IDF" "fg" "ammo" 1 {max 20}{value 2}}				
	{item "bullet105_IDF" "cm" "ammo" 1 {max 20}{value 2}}				
	{item "bullet105_IDF" "apcr" "ammo" 1 {max 20}{value 3}}				
	{item "bullet105_IDF" "ap" "ammo" 1 {max 8}{value 2}}				
	{item "bullet105_IDF" "sm" "ammo" 1 {max 2}{value 2}}				
)
(define "105mm_ger"
	{item "bullet105_GER" "ap" "ammo" 1 {max 15}{value 2}}				
)
(define "105mm_fr_short"
	{item "bullet105a_fr" "apcr" "ammo" 1 {max 13}{value 1}}				
	{item "bullet105a_fr" "cm" "ammo" 1 {max 5}{value 1}}				
	{item "bullet105a_fr" "fg" "ammo" 1 {max 19}{value 1}}				
)
(define "115mm"
	{item "bullet115_RUS" "apcr" "ammo" 1 {max 16}{value 2}}				
	{item "bullet115_RUS" "apcr_h" "ammo" 1 {max 16}{value 2}}				
	{item "bullet115_RUS" "cm" "ammo" 1 {max 8}{value 3}}				
	{item "bullet115_RUS" "fg" "ammo" 1 {max 15}{value 3}}				
	{item "bullet115_RUS" "rok" "ammo" 1 {max 2}{value 5}}				
)
(define "120mm_UK"
	{item "bullet120_UK" "apcr" "ammo" 1 {max 31}{value 2}}				
	{item "bullet120_UK" "apcr_h" "ammo" 1 {max 31}{value 2}}				
	{item "bullet120_UK" "sm" "ammo" 1 {max 8}{value 2}}				
	{item "bullet120_UK" "hesh" "ammo" 1 {max 12}{value 2}}				
)
(define "120mm_USA"
	{item "bullet120_USA apcr bullet120_NATO bullet120_israel ammo" 1 {max 20}{value 2}}		
	{item "bullet120_USA apcr_h bullet120_NATO bullet120_israel ammo" 1 {max 20}{value 2}}		
;	{item "bullet120_USA_s" "apcr" "ammo" 1 {max 20}{value 2}}				
	{item "bullet120_USA cm bullet120_NATO bullet120_israel ammo" 1 {max 20}{value 2}}		
	{item "bullet120_USA ap bullet120_NATO bullet120_israel ammo" 1 {max 10}{value 2}}		
	{item "bullet120_USA fg bullet120_NATO bullet120_israel ammo" 1 {max 25}{value 2}}
	{item "bullet120_GER abm bullet120_NATO ammo" 1 {max 25}{value 3}}	
	;{item "bullet120_GER fg bullet120_NATO bullet120_israel ammo" 1 {max 25}{value 3}}
    {item "bullet120_IDF" "cm" "ammo" 1 {max 20}{value 3}}				
	{item "bullet120_IDF" "fg" "ammo" 1 {max 20}{value 3}}				
	{item "lahat" "rok" "ammo" 1 {max 3}{value 25}}		
;	{item "bullet120_USA" "sm" "ammo" 1 {max 2}{value 2}}				
)
(define "120mm_GER"
	{item "bullet120_GER apcr bullet120_NATO bullet120_israel ammo" 1 {max 25}{value 2}}		
	{item "bullet120_GER cm bullet120_NATO bullet120_israel ammo" 1 {max 25}{value 2}}	
	{item "bullet120_GER abm bullet120_NATO ammo" 1 {max 25}{value 3}}	
   ; {item "bullet120_GER fg bullet120_NATO bullet120_israel ammo" 1 {max 25}{value 3}}	
)
(define "120mm_FR"
	{item "bullet120_FR apcr bullet120_NATO bullet120_israel ammo" 1 {max 20}{value 2}}		
	{item "bullet120_FR cm bullet120_NATO bullet120_israel ammo" 1 {max 9}{value 2}}		
	{item "bullet120_FR fg bullet120_NATO bullet120_israel ammo" 1 {max 10}{value 3}}				
)
(define "120mm_IDF"
	{item "bullet120_IDF" "cm" "ammo" 1 {max 20}{value 3}}				
	{item "bullet120_IDF" "fg" "ammo" 1 {max 20}{value 3}}				
	{item "lahat" "rok" "ammo" 1 {max 3}{value 25}}				
)
(define "120mm_NATO_mine"
	{item "bullet120_USA_mine" "fg" "ammo" 2 {max 60}{value 3}}	
	{item "bullet120_FR_mine" "ammo" 2 {max 60}{value 3}}
)
(define "120mm_RUS_mine"
;	{item "bullet120_RUS" "fg" "ammo" 1 {max 15}{value 6}}				
;	{item "bullet120_RUS" "cm" "ammo" 1 {max 5}{value 2}}				
	{item "bullet120_RUS" "rok" "ammo" 1 {max 5}{value 8}}
    {item "bullet120_2b11_mine" "fg" "ammo" 2 {max 30}{value 5}}		
)
(define "122mm"
;	{item "bullet122_RUS" "fg" "d30ammo" "ammo" 1 {max 24}{value 10}}				
;	{item "bullet122_RUS" "cm" "d30ammo" "ammo" 1 {max 5}{value 3}}				
	{item "bullet122_RUS" "rok" "d30ammo" "ammo" 1 {max 24}{value 3}}				
;	{item "bullet122_RUS" "sm" "d30ammo" "ammo" 1 {max 5}{value 3}}				
)
(define "125mm"
	{item "bullet125_h_rus rok ammo" 1 {max 6}{value 10}}				
	{item "tur_kobra ammo" 1 {max 6}{value 10}}				
	{item "tur_kombat ammo" 1 {max 6}{value 10}}				
	{item "bullet125_RUS rok ammo" 1 {max 6}{value 10}}	
	{item "bullet125_m_RUS rok" 1 {max 6}{value 10}}	
	
	{item "bullet125_RUS_z apcr ammo" 1 {max 20}{value 2}}				
	{item "bullet125_RUS_m apcr ammo" 1 {max 20}{value 2}}				
	{item "bullet125_RUS_v apcr ammo" 1 {max 20}{value 2}}				
	{item "bullet125_RUS apcr ammo" 1 {max 20}{value 2}}				
	{item "bullet125_RUS_s2 apcr ammo" 1 {max 20}{value 2}}				
	{item "bullet125_RUS apcr_h ammo" 1 {max 20}{value 2}}	
	{item "bullet125_RUS_s1 apcr ammo" 1 {max 20}{value 2}}				
	
	{item "bullet125_RUS_a cm ammo" 1 {max 20}{value 3}}				
	{item "bullet125_RUS_b cm ammo" 1 {max 20}{value 3}}				
	{item "bullet125_RUS cm ammo" 1 {max 20}{value 3}}				
	{item "bullet125_RUS cm_e ammo" 1 {max 10}{value 3}}	
	
	{item "bullet125_RUS fg ammo" 1 {max 25}{value 3}}				
	{item "bullet125_RUS fgh ammo" 1 {max 25}{value 3}}	
    {item "bullet152_RUS fg ammo" 1 {max 20}{value 20}} ;для общего грузовика	
)
(define "125mm_cn"
		
	{item "bullet125_RUS rok ammo" 1 {max 3}{value 10}}	
	
	{item "bullet125_cn apcr ammo" 1 {max 20}{value 2}}				
	{item "bullet125_cn_h apcr ammo" 1 {max 20}{value 2}}				
	
	{item "bullet125_cn_b cm ammo" 1 {max 20}{value 3}}				
	
	{item "bullet125_cn fg ammo" 1 {max 25}{value 3}}				
)
(define "125mm_nato"
	{item "bullet125_RUS_z apcr ammo" 1 {max 20}{value 2}}	
	{item "bullet125_RUS_e apcr ammo" 1 {max 20}{value 2}}				
	{item "bullet125_RUS_p apcr ammo" 1 {max 20}{value 2}}	
    {item "bullet125_RUS_a cm ammo" 1 {max 20}{value 3}}				
	{item "bullet125_RUS_b cm ammo" 1 {max 20}{value 3}}	
    {item "bullet125_RUS fgh ammo" 1 {max 25}{value 3}}
    {item "bullet125_RUS fg ammo" 1 {max 25}{value 3}}	
	{item "bullet125_RUS_o fg ammo" 1 {max 25}{value 3}}
)
(define "152mm"
	{item "bullet152_RUS rok ammo" 1 {max 20}{value 20}}				
	{item "bullet152_RUS fg ammo" 1 {max 40}{value 20}}				
;	{item "bullet152_RUS sm ammo" 1 {max 2}{value 20}}				
	{item "bullet152_RUS_a fg bullet152_RUS ammo" 1 {max 40}{value 20}}				
	{item "bullet152_RUS_korr2 fg bullet152_RUS ammo" 1 {max 30}{value 30}}				
	{item "bullet152_RUS_h fg ammo" 1 {max 20}{value 20}}				
	{item "bullet152_RUS_h korr ammo" 1 {max 3}{value 80}}
)
(define "155mm_USA"
	{item "bullet155_USA cl ammo" 1 {max 30}{value 20}}				
	{item "bullet155_USA fg ammo" 1 {max 30}{value 20}}				
	{item "bullet155_USA satt ammo" 1 {max 2}{value 80}}				
	{item "bullet155_USA_ar fg ammo" 1 {max 30}{value 20}}				
	{item "bullet155_USA_h fg ammo" 1 {max 30}{value 20}}	
)
(define "155mm_NATO"
	{item "bullet155_GER fg ammo" 1 {max 40}{value 20}}				
	{item "bullet155_GER_ar fg ammo" 1 {max 20}{value 20}}				
	{item "bullet155_NATO fg ammo" 1 {max 30}{value 20}}				
	{item "bullet155_USA spbe ammo" 1 {max 20}{value 25}}				
	{item "bullet155_USA cl ammo" 1 {max 30}{value 20}}
	{item "bullet152_RUS_a fg bullet152_RUS ammo" 1 {max 40}{value 20}}		
)
(define "203mm_pion"
	{item "bullet203_RUS fg ammo" 1 {max 10}{value 30}}	
)

(define "203mm_pion"
	{item "bullet203_RUS fg ammo" 1 {max 10}{value 30}}	
)

(define "155mm_cn"
	{item "bullet155_cn 155_cn cl ammo" 1 {max 20}{value 20}}				
	{item "bullet155_cn 155_cn fg ammo" 1 {max 40}{value 20}}
    {item "bullet155_cn_rok 155_cn fg ammo" 1 {max 40}{value 20}}	
	{item "bullet155_cn 155_cn satt ammo" 1 {max 3}{value 40}}
)
(define "152mm_d1" 
{item "ammo bullet152_fg_d1_152" 1 {max 8}{value 10}}	
)
;-1--------------Missiles----------------

(define "atacms"
	{item "ATACMS fg ammo" 1 {max 2}{value 130}}
;    {item "ATACMS ammo" 1 {max 2}{value 130}}		
)
(define "iskander"
	{item "iskander tb ammo" 1 {max 2}{value 200}}			;лимит 3000		
	{item "iskander cl ammo" 1 {max 2}{value 200}}
)
(define "grom"
	{item "grom fg ammo" 1 {max 2}{value 200}}			;лимит 3000		
	{item "grom cl ammo" 1 {max 2}{value 200}}
)
(define "iskander-k"
	{item "3m14k ammo" 1 {max 2}{value 200}}			;лимит 3000		
)
(define "df15"
	{item "df15b fg ammo" 1 {max 1}{value 400}}
;	{item "df15b tb ammo" 1 {max 1}{value 250}}
)
(define "grad"
	{item "grad rok ammo" 10 {max 40}{value 100}}
	{item "grad oa ammo" 10 {max 40}{value 100}}
    {item "tos1a fg ammo" 2 {max 24}{value 30}}	
;	{item "grad cl ammo" 10 {max 40}{value 50}}				
;	{item "grad fg ammo" 10 {max 40}{value 50}}				
;	{item "grad spbe ammo" 10 {max 40}{value 50}}				
;	{item "grad mine ammo" 10 {max 40}{value 50}}				
)
(define "grad_cn"
	{item "grad fgh ammo" 10 {max 40}{value 100}}
    {item "grad clcn ammo" 10 {max 40}{value 50}}	
)
(define "smerch"
    {item "smerch tornado_s 9m528 fg ammo" 4 {max 12}{value 130}}
    
	{item "tornado_s 9m546 cl ammo" 4 {max 12}{value 150}}
)
(define "lars2"
	{item "lars2 fg ammo" 9 {max 36}{value 80}}				
	;{item "lars2 mine ammo" 9 {max 18}{value 10}}		;мин нет в инвентаре, вот и не заряжаются		
)
(define "m270"
	{item "m270 fg ammo" 1 {max 12}{value 40}}		;лимит 3000			
	;{item "m270 cl ammo" 1 {max 12}{value 20}}		;лимит 3000			
)
(define "m270_nato"
	;{item "m270 fg ammo" 1 {max 12}{value 40}}		;лимит 3000			
	{item "m270 cl ammo" 1 {max 12}{value 20}}		;лимит 3000			
)
(define "m142"
	{item "gmrlser" 1 {max 6}{value 40}}		;лимит 3000					
)

(define "uragan"
	{item "9M27 F  ammo" 2 {max 16}{value 20}}
	{item "9M27 K  ammo" 2 {max 16}{value 20}}	
)
(define "tochka"
	{item "tochka f ammo" 1 {max 1}{value 200}}
)



;---------------ATGMs----------------

(define "atgm_rus"
	{item "9k14m ammo" 1 {max 4}{value 4}}				
	{item "9k115-2 cm ammo" 1 {max 4}{value 6}}				
;	{item "9k115-2 cm_e ammo" 1 {max 3}{value 6}}				
	{item "9m114m shturm cm ammo" 1 {max 4}{value 20}}				
;	{item "9m114m shturm fg ammo" 1 {max 4}{value 20}}				
	{item "9m120 shturm cm ammo" 1 {max 8}{value 10}}				
	{item "9m120 shturm fg ammo" 1 {max 4}{value 20}}				
	{item "9m133 fg ammo" 1 {max 4}{value 20}}				
	{item "9m133 cm ammo" 1 {max 4}{value 10}}				
;	{item "9m133 tb ammo" 1 {max 4}{value 20}}				
;	{item "fagot_concurs 9m111 ammo" 1 {max 5}{value 6}}				
	{item "fagot_concurs 9m111m ammo" 1 {max 3}{value 6}}				
;	{item "fagot_concurs 9m113 ammo" 1 {max 5}{value 10}}				
	{item "fagot_concurs 9m113m ammo" 1 {max 3}{value 10}}				
	{item "fagot_concurs 9m113m1 ammo" 1 {max 5}{value 10}}				
	{item "strela10 9m333 ammo" 1 {max 8}{value 9}}	
	
)
(define "atgm_usa"
;	gm{item "tow_missile tow_rock ammo" 1 {max 6}{value 8}}	
	{item "tow_missile tow2e ammo" 1 {max 4}{value 10}}		
	{item "tow_missile tow2b ammo" 1 {max 2}{value 10}}	
	{item "tow_missile tow2_fg ammo" 1 {max 2}{value 15}}						
	;{item "tow_missile tow2d ammo" 1 {max 2}{value 10}}					
    {item "jav_rock ammo" 1 {max 2}{value 30}}		
	{item "agm-114 k ammo" 1 {max 4}{value 10}}
;	{item "agm-114 l ammo" 1 {max 2}{value 10}}
	;{item "agm-114 n ammo" 1 {max 2}{value 10}}
	{item "aim-9l_ammo ammo" 1 {max 2}{value 5}}
	{item "mistral_missile ammo" 1 {max 4}{value 30}}	
    {item "spike-er2 spike-er ammo" 1 {max 4}{value 51}}			
)
(define "atgm_nato"
	{item "tow_missile tow2e ammo" 1 {max 7}{value 10}}
    {item "tow_missile tow2_fg ammo" 1 {max 2}{value 15}}
    {item "tow_missile tow2b ammo" 1 {max 2}{value 10}}	
	{item "hot_rock hot3 ammo" 1 {max 8}{value 10}}				
;	{item "milan_rock cm ammo" 1 {max 4}{value 4}}				
	{item "milan_rock milan-er ammo" 1 {max 4}{value 6}}				
	{item "spike-er spike-er ammo" 1 {max 6}{value 25}}				
	{item "spike-lr ammo" 1 {max 6}{value 25}}
    {item "spike_nlos cm ammo" 1 {max 4}{value 40}}                                             	
	{item "eryx_rock ammo" 1 {max 2}{value 3}}				
	{item "mmp_missile ammo" 1 {max 6}{value 15}}
	{item "jav_rock ammo" 1 {max 2}{value 30}}	
	{item "agm-114 k ammo" 1 {max 4}{value 10}}
	{item "aim-9l_ammo ammo" 1 {max 2}{value 5}}
)
(define "atgm_cn"
	{item "hj73 hj73c" 1 {max 4}{value 4}}				
	{item "hj9_missile ammo" 1 {max 4}{value 10}}				
	{item "hj-10 ammo" 1 {max 8}{value 51}}				
;	{item "hj8e hj8 ammo" 3 {max 3}{value 10}}
	{item "hj8h hj8 ammo" 3 {max 3}{value 10}}
	{item "hq7b ammo" 1 {max 8}{value 9}}				
	{item "red_arrow12_rock ammo" 1 {max 2}{value 20}}				
)
(define "atgm_ukr"			
	{item "p2c h ammo" 1 {max 3}{value 20}}		
	{item "p2c cm ammo" 1 {max 2}{value 20}}
)


(define "sam_rus"
	;{item "strela10 9m37 ammo" 1 {max 8}{value 9}}				
	{item "strela10 9m333 ammo" 1 {max 8}{value 9}}				
	{item "9m31 ammo" 1 {max 4}{value 9}}				
	;{item "9m38 buk ammo" 1 {max 4}{value 50}}				
	{item "9m317 buk ammo" 1 {max 4}{value 60}}				
	{item "9m311 ammo" 1 {max 8}{value 40}}
    {item "pantsir 57e6e ammo" 2 {max 12}{value 40}}
    {item "9m330 ammo" 2 {max 8}{value 13}}
    {item "ammo 48n6e2 s-300" 1 {max 4}{value 100}}
    	
    
)

(define "sam_ukr"
	 {item "ammo 5v55r s-300" 1 {max 4}{value 100}}		;лимит 3000						
)


(define "sam_usa"
	{item "patriot ammo" 1 {max 4}{value 50}}		;лимит 3000		
	{item "pac3 ammo" 1 {max 16}{value 20}}
	{item "adats ammo" 1 {max 8}{value 10}}				
)
(define "sam_nato"
	{item "xmim-115avt1 ammo" 1 {max 10}{value 13}}
	{item "sampt ammo" 1 {max 8}{value 35}}				
)
(define "sam_cn"
	{item "hq7b ammo" 1 {max 4}{value 13}}
	{item "hq16 hq16b ammo" 1 {max 6}{value 60}}				
)

(define "manpads_rus"
	{item "igla_S ammo" 1 {max 8}{value 2}}				
	{item "9m336 ammo" 1 {max 8}{value 2}}
)
(define "manpads_usa"
	{item "fim-92a_ammo ammo" 1 {max 8}{value 2}}				
)
(define "manpads_nato"
	{item "fim-92a_ammo ammo" 1 {max 8}{value 2}}	
	{item "mistral_missile ammo" 1 {max 6}{value 15}}			
)
(define "manpads_cn"
	{item "fn6a_ammo ammo" 1 {max 4}{value 2}}	
)
;Особо тяжелые бомбы и ракеты имеют половинную цену

(define "air_stuff_rus"	
    {item "vixr_ammo ammo" 2 {max 12}{value 12}}
	{item "germes ammo" 2 {max 8}{value 40}}				
	{item "fab_250 ammo" 1 {max 4}{value 9}}				
	{item "fab_250_270 ammo" 1 {max 12}{value 9}}				
	{item "fab_500 ammo" 1 {max 8}{value 12}}				
	{item "kab-250 ammo" 1 {max 9}{value 25}}				
	{item "kab-500s ammo" 1 {max 4}{value 50}}
    {item "kab-500kr ammo" 1 {max 4}{value 50}}
    {item "kab-500l ammo" 1 {max 6}{value 50}}	
	{item "odab_500 ammo" 1 {max 2}{value 25}}				
	{item "pbk-500u ammo" 1 {max 2}{value 25}}				
	{item "RBK_250 ammo" 1 {max 2}{value 12}}				
	{item "RBK_500 ammo" 1 {max 2}{value 12}}
    {item "kmgu2 ammo" 4 {max 8}{value 5}}		
	{item "s25ld ammo" 1 {max 6}{value 20}}				
	{item "x_25ml_su25_ammo ammo" 1 {max 4}{value 80}}				
	{item "x31p ammo" 1 {max 6}{value 60}}				
	{item "x-38mte ammo" 1 {max 2}{value 75}}			
	{item "x59m ammo" 1 {max 2}{value 125}}				
	{item "x32 ammo" 1 {max 2}{value 100}}	
	{item "r_27er ammo" 1 {max 6}{value 5}}				
	{item "r-3c ammo" 1 {max 2}{value 5}}				
	{item "r60_su25 ammo" 1 {max 2}{value 5}}				
	{item "r-73 ammo" 1 {max 2}{value 5}}				
	{item "rvv-ae ammo" 1 {max 4}{value 5}}				
	{item "rvv-md ammo" 1 {max 2}{value 5}}				
	{item "rvv-sd ammo" 1 {max 10}{value 5}}				
)
(define "air_stuff_usa"
	{item "aim-9l_ammo ammo" 1 {max 2}{value 5}}				
	{item "AIM-120C7 ammo" 1 {max 6}{value 5}}				
;	{item "agm-114 k ammo" 1 {max 4}{value 10}}				
;	{item "agm-114 k2 ammo" 1 {max 4}{value 10}}				
	{item "agm-114 l ammo" 1 {max 4}{value 10}}	
;    {item "agm-114 r ammo" 1 {max 4}{value 10}}	
;	{item "agm-114 n ammo" 1 {max 8}{value 10}}				
	{item "agm-65D ammo" 1 {max 3}{value 22}}				
	{item "agm-65G ammo" 1 {max 3}{value 30}}				
	{item "agm88 ammo" 1 {max 2}{value 60}}
    {item "agm-84D ammo" 1 {max 2}{value 20}}	
	{item "agm-154 ammo" 1 {max 2}{value 40}}				
	{item "cbu-97 ammo" 1 {max 6}{value 21}}				
	{item "gbu-31 ammo" 1 {max 2}{value 45}}				
	{item "gbu-38 ammo" 1 {max 4}{value 23}}				
	{item "jsm ammo" 1 {max 6}{value 80}}			
	{item "storm ammo" 1 {max 2}{value 80}}
	{item "mk_82 ammo" 1 {max 22}{value 12}}				
)
(define "air_stuff_nato"
    {item "agm-65D ammo" 1 {max 3}{value 22}}
	{item "aim-9l_ammo ammo" 1 {max 2}{value 5}}
	{item "mistral_missile ammo" 1 {max 4}{value 15}}				
	{item "agm-114 k ammo" 1 {max 8}{value 10}}
	{item "trigat ammo" 1 {max 8}{value 10}}				
	{item "AIM-120C7 ammo" 1 {max 8}{value 5}}				
	{item "brimstone ammo" 1 {max 12}{value 60}}				
	{item "alarm_missile ammo" 1 {max 4}{value 20}}				
	{item "gbu10 ammo" 1 {max 4}{value 40}}				
	{item "gbu16 ammo" 1 {max 4}{value 25}}				
	{item "kleinbombe-44 ammo" 56 {max 112}{value 20}}		;Они легкие, но в их цену входит сбраываемая ПУ		
	{item "taurus ammo" 1 {max 2}{value 50}}				
	{item "mk_82 ammo" 1 {max 18}{value 12}}				
)
(define "air_stuff_cn"	
    {item "akd-10 ammo" 2 {max 8}{value 12}}
	{item "bomb250_3 fg ammo" 1 {max 24}{value 9}}				
	;{item "bomb250_3 ic ammo" 1 {max 24}{value 9}}		
	{item "ls6 ammo" 1 {max 4}{value 70}}
	{item "rbk_cn cl ammo" 1 {max 12}{value 12}}				
	;{item "rbk_cn tb ammo" 1 {max 12}{value 12}}				
	{item "ld10 ammo" 1 {max 2}{value 20}}				
	{item "c802akg ammo" 1 {max 2}{value 125}}				
	{item "pl5e2 ammo" 1 {max 2}{value 5}}				
	{item "pl8b ammo" 1 {max 2}{value 5}}				
	{item "r-73 ammo" 1 {max 2}{value 5}}				
	{item "rvv-sd ammo" 1 {max 10}{value 5}}				
)

;---------------Misc----------------

(define "smokes"
	{item "smoke ammo" 1 {max 8}{value 1}}				
	;{item "smoke_shtora ammo" 1 {max 12}{value 1}}				
)
(define "kaz"
;	{item "afganit ammo" 1 {max 10}{value 1}}			;Пока не работает	
;	{item "arena ammo" 1 {max 10}{value 1}}				
;	{item "drozd ammo" 1 {max 10}{value 1}}				
	{item "smoke_kzvp ammo" 1 {max 20}{value 1}}				
	{item "trophy ammo" 1 {max 8}{value 5}}				
)
(define "mines"
	{item "antipersonnel mine" 1 {max 20}{value 1}}				
	{item "antitank mine" 1 {max 12}{value 1}}				
	{item "ksf_cassette kpom2 ammo" 1 {max 60}{value 1}}				
	{item "ksf_cassette kptm ammo" 1 {max 60}{value 1}}				
	{item "ksf_cassette ksf ammo" 1 {max 60}{value 1}}				
)

;------------------------------Ammobox

(define "ammobox_rus"
	{item "mp_cwr_rus_common" 1 {max 1}{value 100}}				
	{item "mp_cwr_rus_common1" 1 {max 1}{value 100}}				
	{item "mp_cwr_rus_common2" 1 {max 1}{value 100}}
    {item "mp_smallbox_rus" 1 {max 3}{value 100}}	
)
(define "ammobox_usa"
	{item "mp_cwr_usa_common" 1 {max 1}{value 100}}				
	{item "mp_cwr_usa_common1" 1 {max 1}{value 100}}				
	{item "mp_cwr_usa_common2" 1 {max 1}{value 100}}
    {item "mp_smallbox_usa" 1 {max 3}{value 100}}	
)
(define "ammobox_nato"
	{item "mp_cwr_nato_common" 1 {max 1}{value 100}}				
	{item "mp_cwr_nato_common1" 1 {max 1}{value 100}}				
	{item "mp_cwr_nato_common2" 1 {max 1}{value 100}}	
    {item "mp_smallbox_nato" 1 {max 3}{value 100}}	
)
(define "ammobox_cn"
	{item "mp_cwr_cn_common" 1 {max 1}{value 100}}				
	{item "mp_cwr_cn_common1" 1 {max 1}{value 100}}				
	{item "mp_cwr_cn_common2" 1 {max 1}{value 100}}	
    {item "mp_smallbox_cn" 1 {max 3}{value 100}}	
)
;====================================Другие пополнители=====================

;resupply works only if in gun {filling uses the same tag as in shell filename.
;not working with tags in shell
(define "test_all"
	{extender "supply_zone"
		{resupply
			("smallarms_rus")
			("smallarms_west")
			("smallarms_usa")
			("smallarms_nato")
			("fpv")
		
			("hmgun_rus")
			("hmgun_usa")
			("hmgun_nato")
			("ags30")
			("mk19_usa")
			("mk19_nato")
			("mortar_usa")
			("mortar_rus")
			
            ("UAV_rus")
			("autocannons_rus")
			("autocannons_usa")
			("autocannons_nato")
			("hydra")
			("73mm")
			("c5")
			("c8")
			("c13")
			("100mm")
			("100mm_bmp3")
			("100mm_rapira")
			("105mm_usa")
			("105mm_NATO")
			("105mm_idf")
			("105mm_ger")
			("105mm_fr_short")
			("115mm")
			("120mm_UK")
			("120mm_USA")
			("120mm_GER")
			("125mm_nato")
			("120mm_FR")
			("120mm_IDF")
			("120mm_NATO_mine")
			("120mm_RUS_mine")
			("122mm")
			("125mm")
			("152mm")
			("152mm_d1")
			
			("105mm_idf")
			("105mm_USA")
			("105mm_NATO")
			("155mm_USA")
			("155mm_NATO")
			("203mm_pion")
			("m270")
			("m270_nato")
			("atacms")
			("m142")
			("grom")
			("iskander")
			("iskander-k")
			("grad")
			("lars2")
			("smerch")
			("uragan")
			("tochka")
			


			("smokes")
			("kaz")
			("mines")
			
			("rpg_rus")
			("rpg_usa")
			("rpg_nato")
			
			("atgm_ukr")
			("atgm_rus")
			("atgm_usa")
			("atgm_nato")
			
			("sam_rus")
			
			("sam_ukr")
			("sam_usa")
			("sam_nato")
			("manpads_rus")
			("manpads_usa")
			("manpads_nato")

			("air_stuff_rus")
			("air_stuff_usa")
			("air_stuff_nato")
			
			("ammobox_rus")
			("ammobox_usa")
			("ammobox_nato")
			
			{item "mp_cwr_nato_artpvo" 1 {max 1}{value 300}}	
			{item "mp_cwr_rus_artpvo" 1 {max 1}{value 300}}	
			{item "mp_cwr_usa_artpvo" 1 {max 1}{value 300}}	

			{item "mp_cwr_nato_avia" 1 {max 1}{value 300}}	
			{item "mp_cwr_rus_avia" 1 {max 1}{value 300}}	
			{item "mp_cwr_usa_avia" 1 {max 1}{value 300}}	
			
		}
		{radius 			20}		;resupply radius in meter
		{resupplyPeriod 	0.1}	;resupply period in seconds
		{regenerationPeriod 0}		;regeneration period in seconds, +1 supply every x seconds (0 = no regeneration)
		{limit 				10000}	;max number of resupplies (0 = unlimited)
	}
	("supply_decal")
)

;-------------------------CW resupply units----------------
;----------------------------------------------------------
(define "refueller"
	{props "cwfs_refueller"}
	{extender "supply_zone"
		{resupply}
		{radius 			20}
		{resupplyPeriod 	5}
		{regenerationPeriod 0}
		{limit 				1}
	}
	("supply_decal")
)
;===========flags
(define "land_troops_flag_rus"
	{extender "supply_zone"
		{resupply
			("ammobox_rus")
		}
		{radius 			10}
		{resupplyPeriod 	5}
		{regenerationPeriod 1.2}	;1000 очков за 2 минуты
		{limit 				300}
	}
	("supply_decal")
)
(define "land_troops_flag_usa"
	{extender "supply_zone"
		{resupply
			("ammobox_usa")
		}
		{radius 			10}
		{resupplyPeriod 	5}
		{regenerationPeriod 1.2}	;1000 очков за 2 минуты
		{limit 				300}
	}
	("supply_decal")
)
(define "land_troops_flag_nato"
	{extender "supply_zone"
		{resupply
			("ammobox_nato")
		}
		{radius 			10}
		{resupplyPeriod 	5}
		{regenerationPeriod 1.2}	;1000 очков за 2 минуты
		{limit 				300}
	}
	("supply_decal")
)
(define "land_troops_flag_cn"
	{extender "supply_zone"
		{resupply
			("ammobox_cn")
		}
		{radius 			10}
		{resupplyPeriod 	5}
		{regenerationPeriod 1.2}	;1000 очков за 2 минуты
		{limit 				300}
	}
	("supply_decal")
)
(define "art_flag_rus"
	{extender "supply_zone"
		{resupply
			{item "mp_cwr_rus_artpvo" 1 {max 1}{value 300}}	
		}
		{radius 			10}
		{resupplyPeriod 	5}
		{regenerationPeriod 0.6}	;1000 очков за 1 минуту
		{limit 				600}
	}
	("supply_decal")
)
(define "art_flag_usa"
	{extender "supply_zone"
		{resupply
			{item "mp_cwr_usa_artpvo" 1 {max 1}{value 300}}	
		}
		{radius 			10}
		{resupplyPeriod 	5}
		{regenerationPeriod 0.6}	;1000 очков за 1 минуту
		{limit 				600}
	}
	("supply_decal")
)
(define "art_flag_nato"
	{extender "supply_zone"
		{resupply
			{item "mp_cwr_nato_artpvo" 1 {max 1}{value 300}}	
		}
		{radius 			10}
		{resupplyPeriod 	5}
		{regenerationPeriod 0.6}	;1000 очков за 1 минуту
		{limit 				600}
	}
	("supply_decal")
)
(define "art_flag_cn"
	{extender "supply_zone"
		{resupply
			("ammobox_cn")
		}
		{radius 			10}
		{resupplyPeriod 	5}
		{regenerationPeriod 0.6}	;1000 очков за 1 минуту
		{limit 				600}
	}
	("supply_decal")
)
(define "avia_flag_rus"
	{extender "supply_zone"
		{resupply
			{item "mp_cwr_rus_avia" 1 {max 1}{value 300}}	
		}
		{radius 			15}
		{resupplyPeriod 	5}
		{regenerationPeriod 0.6}	;1000 очков за 1 минуту
		{limit 				600}
	}
	("supply_decal")
)
(define "avia_flag_usa"
	{extender "supply_zone"
		{resupply
			{item "mp_cwr_usa_avia" 1 {max 1}{value 300}}	
		}
		{radius 			15}
		{resupplyPeriod 	5}
		{regenerationPeriod 0.6}	;1000 очков за 1 минуту
		{limit 				600}
	}
	("supply_decal")
)
(define "avia_flag_nato"
	{extender "supply_zone"
		{resupply
			{item "mp_cwr_nato_avia" 1 {max 1}{value 300}}	
		}
		{radius 			15}
		{resupplyPeriod 	5}
		{regenerationPeriod 0.6}	;1000 очков за 1 минуту
		{limit 				600}
	}
	("supply_decal")
)
(define "avia_flag_cn"
	{extender "supply_zone"
		{resupply
			("ammobox_cn")
		}
		{radius 			15}
		{resupplyPeriod 	5}
		{regenerationPeriod 0.6}	;1000 очков за 1 минуту
		{limit 				600}
	}
	("supply_decal")
)
;===========smallammobox
(define "mp_smallbox_rus_konkurs"
	{extender "supply_zone"
		{resupply
;			{item "fagot_concurs 9m113m1 ammo" 1 {max 4}{value 50}}
	                {item "fagot_concurs 9m113 ammo" 1 {max 4}{value 50}}	
		}
		{radius 			5}
		{resupplyPeriod 	15}
		{regenerationPeriod 0}
		{limit 				200}
	}
	("supply_decal")
)
(define "mp_smallbox_rus1"
	{extender "supply_zone"
		{resupply
;			("smallarms_rus")
			("hmgun_rus")
			("ags30")
			("mortar_rus")
			("UAV_rus")
			("autocannons_rus")
			("73mm")
			("c8")
			("c13")
			("100mm")
			("100mm_bmp3")
			("100mm_rapira")
			("115mm")
			("120mm_RUS_mine")
			("122mm")
			("125mm")
			("smokes")
			("kaz")
			("rpg_rus")
			("atgm_rus")
			("manpads_rus")
		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 0}
		{limit 				50}
	}
	;("supply_decal")
)
(define "mp_smallbox_usa1"
	{extender "supply_zone"
		{resupply
;			("smallarms_west")
			("smallarms_usa")
			("hmgun_nato")
			("mk19_usa")
			("mortar_usa")

			("autocannons_usa")
			("hydra")
            ("105mm_idf")
			("105mm_usa")
			("120mm_USA")
			("120mm_NATO_mine")
			
			("rpg_usa")
			("atgm_nato")
			("atgm_usa")
			("manpads_usa")
			
			("smokes")
			("kaz")
		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 0}
		{limit 				50}
	}
	;("supply_decal")
)
(define "mp_smallbox_nato1"
	{extender "supply_zone"
		{resupply
;			("smallarms_west")
			("smallarms_nato")
			("hmgun_nato")
			("mk19_nato")
			("mortar_usa")

			("autocannons_nato")
			("hydra")
            
			("105mm_NATO")
			("105mm_idf")
			("105mm_ger")
			("105mm_fr_short")
			("120mm_UK")
			("120mm_GER")
			("125mm_nato")
			("120mm_FR")
			("120mm_IDF")
			("120mm_NATO_mine")
			
			("rpg_nato")
			
			("atgm_nato")
			("manpads_nato")
			("smokes")
		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 0}
		{limit 				50}
	}
	;("supply_decal")
)
(define "mp_smallbox_cn1"
	{extender "supply_zone"
		{resupply
			("smallarms_cn")
			("hmgun_cn")
			("ags_cn")
			("mortar_cn")
			("type63_cn")
			("autocannons_cn")
			("100mm_bmp3")
			("122mm")
			("125mm_cn")
			("125mm")
			("smokes")
			("rpg_cn")
			("atgm_cn")
			("manpads_cn")
		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 0}
		{limit 				50}
	}
	;("supply_decal")
)
;===========crates
(define "mp_cwr_ukr_common"
	{extender "supply_zone"
		{resupply
			("fpv")
			("smallarms_usa")
			("smallarms_rus")
			("mk19_nato")
			("105mm_ger")
			("120mm_UK")
			("120mm_GER")
			("atgm_nato")
			("hmgun_rus")
			("ags30")
			("mortar_rus")
			("UAV_rus")
			("autocannons_usa")
			("autocannons_rus")
			("73mm")
			("c8")
			("c13")
			("100mm")
			("100mm_bmp3")
			("100mm_rapira")
			("115mm")
			("120mm_RUS_mine")
			("122mm")
			("125mm")
			("smokes")
			("kaz")
			("rpg_rus")
			("atgm_rus")
			("atgm_ukr")
			("atgm_usa")
			("manpads_rus")
		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 4.4}
		{limit 				200}
	}
	("supply_decal")
)
(define "mp_cwr_ukr_artpvo"
	{extender "supply_zone"
		{resupply
			("grom")
			("155mm_USA")
			("105mm_NATO")
			("155mm_NATO")
			("203mm_pion")
			("m142")
			("atacms")
			("smerch")
			("uragan")
			("tochka")
			("122mm")
			("152mm")
			("152mm_d1")		
			("grad")
			("mines")
			("sam_rus")
			("UAV_rus")
			("autocannons_rus")
			("sam_rus")
			("smerch")
			("air_stuff_usa")
			("sam_usa")
			("sam_ukr")
		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 2.4}
		{limit 				450}
	}
	("supply_decal")
)
(define "mp_cwr_ukr_avia"
	{extender "supply_zone"
		{resupply
			 ("UAV_rus")
			("autocannons_rus")
			("c5")
			("c8")
			("c13")
			("air_stuff_rus")
			("air_stuff_usa")
			("manpads_rus")
			("atgm_rus")
			
		}
		{radius 			20}
		{resupplyPeriod 	5}
		{regenerationPeriod 2.4}
		{limit 				900}
	}
	("supply_decal")
)
(define "mp_cwr_rus_common"
	{extender "supply_zone"
		{resupply
			("smallarms_rus")
			("hmgun_rus")
			("ags30")
			("mortar_rus")
			("UAV_rus")
			("autocannons_rus")
			("73mm")
			("c8")
			("c13")
			("100mm")
			("100mm_bmp3")
			("100mm_rapira")
			("115mm")
			("120mm_RUS_mine")
			("122mm")
			("125mm")
			("smokes")
			("kaz")
			("rpg_rus")
			("atgm_rus")
			("manpads_rus")
		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 4.4}
		{limit 				200}
	}
	("supply_decal")
)
(define "mp_cwr_rus_artpvo"
	{extender "supply_zone"
		{resupply
			("uragan")
			("122mm")
			("152mm")
			("152mm_d1")
			("iskander")
			("iskander-k")
			("grad")
			("smerch")
			("mines")
			("sam_rus")
			("UAV_rus")
			("autocannons_rus")
		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 2.4}
		{limit 				450}
	}
	("supply_decal")
)
(define "mp_cwr_rus_avia"
	{extender "supply_zone"
		{resupply
		    ("UAV_rus")
			("autocannons_rus")
			("c5")
			("c8")
			("c13")
			("air_stuff_rus")
			("manpads_rus")
			("atgm_rus")
		}
		{radius 			20}
		{resupplyPeriod 	5}
		{regenerationPeriod 2.4}
		{limit 				900}
	}
	("supply_decal")
)

(define "mp_cwr_usa_common"
	{extender "supply_zone"
		{resupply
			("smallarms_west")
			("smallarms_usa")
			("hmgun_nato")
			("mk19_usa")
			("mortar_usa")

			("autocannons_usa")
			("hydra")
            ("105mm_idf")
			("105mm_usa")
			("120mm_USA")
			("120mm_NATO_mine")
			
			("rpg_usa")
			("atgm_nato")
			("atgm_usa")
			("manpads_usa")
			
			("smokes")
			("kaz")

		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 4.4}
		{limit 				200}
	}
	("supply_decal")
)
(define "mp_cwr_usa_artpvo"
	{extender "supply_zone"
		{resupply
			("155mm_USA")
            ("105mm_usa")

			("atacms")
			("m270")
			("m142")
			("kaz")
			("mines")
			("sam_ukr")
			("sam_usa")
		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 2.4}
		{limit 				450}
	}
	("supply_decal")
)
(define "mp_cwr_usa_avia"
	{extender "supply_zone"
		{resupply
			("autocannons_usa")
			("hydra")
			("air_stuff_usa")
			;("atgm_usa")
		}
		{radius 			20}
		{resupplyPeriod 	5}
		{regenerationPeriod 2.4}
		{limit 				900}
	}
	("supply_decal")
)

(define "mp_cwr_nato_common"
	{extender "supply_zone"
		{resupply
			("smallarms_west")
			("smallarms_nato")
			("hmgun_nato")
			("mk19_nato")
			("mortar_usa")

			("autocannons_nato")
			("hydra")
            
			("105mm_NATO")			
			("105mm_idf")
			("105mm_ger")
			("105mm_fr_short")
			("120mm_UK")
			("120mm_GER")
			("125mm_nato")
			("120mm_FR")
			("120mm_IDF")
			("120mm_NATO_mine")
			
			("rpg_nato")
			
			("atgm_nato")
			("manpads_nato")
			("smokes")
		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 4.4}
		{limit 				200}
	}
	("supply_decal")
)
(define "mp_cwr_nato_artpvo"
	{extender "supply_zone"
		{resupply
			("kaz")
			("mines")
			("autocannons_nato")
			("105mm_NATO")
			("155mm_NATO")
			("lars2")
			("m270_nato")
			("sam_nato")
			("atacms")
		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 2.4}
		{limit 				450}
	}
	("supply_decal")
)
(define "mp_cwr_nato_avia"
	{extender "supply_zone"
		{resupply
			("air_stuff_nato")
			("autocannons_nato")
			("hydra")
			("telson")
			("atgm_nato")
		}
		{radius 			20}
		{resupplyPeriod 	5}
		{regenerationPeriod 2.4}
		{limit 				900}
	}
	("supply_decal")
)
(define "mp_cwr_cn_common"
	{extender "supply_zone"
		{resupply
			("smallarms_cn")
			("hmgun_cn")
			("ags_cn")
			("mortar_cn")
			("type63_cn")
			("autocannons_cn")
			("100mm_bmp3")
			("122mm")
			("125mm_cn")
			("125mm")
			("smokes")
			("rpg_cn")
			("atgm_cn")
			("manpads_cn")
		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 4.4}
		{limit 				200}
	}
	("supply_decal")
)
(define "mp_cwr_cn_artpvo"
	{extender "supply_zone"
		{resupply
			("mines")
			("autocannons_cn")
			("122mm")
			("155mm_cn")
			("grad_cn")
			("sam_cn")
			("df15")
		}
		{radius 			10}
		{resupplyPeriod 	15}
		{regenerationPeriod 2.4}
		{limit 				450}
	}
	("supply_decal")
)
(define "mp_cwr_cn_avia"
	{extender "supply_zone"
		{resupply
			("autocannons_cn")
			("brmi90")
			("air_stuff_cn")
			("manpads_cn")
		}
		{radius 			20}
		{resupplyPeriod 	5}
		{regenerationPeriod 2.4}
		{limit 				900}
	}
	("supply_decal")
)