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
;====================================CW=====================
(define "test"
{item "bandage"	1 {max 3}}
{item "rgo grenade"  {max 3}}
{item "knife_rus"  {max 3}}
{item "repair_kit"  {max 3}}


			{item "ammo pkm_ammo" 100 {max 6000}}		
			{item "ammo bullet100a_RUS rok"  {max 8}}	
			{item "ammo bullet30_RUS ap"  10 {max 210}}
			{item "ammo bullet30_RUS fg" 10 {max 250}}
			
			{item "ammo bullet100a_RUS fg" 10 {max 39}}
			{item "bullet100a_RUS fg" {max 39}}
			{item "bullet100a_RUS fg" "2a70ammo" {max 39}}
			{item "bullet100a_RUS 2a70ammo" {max 39}}
			{item "2a70ammo fg" {max 39}}
			{item "2a70ammo" {max 39}}
			
			{item "f1 grenade" 5 {max 15}}
			{item "lahat rok ammo" {max 15}}
			{item "762 ammo" 30 {max 300}{value 5}}		


)
(define "smallarms_rus"
	{item "545 ammo" 30 {max 300}{value 5}}				
	{item "762 ammo" 30 {max 300}{value 5}}				
	{item "762x41pss ammo" 10 {max 30}{value 5}}				
	{item "pkm_ammo ammo" 100 {max 600}{value 10}}				
	{item "osv_ap ammo" 10 {max 60}{value 7}}				
	{item "osv_fg ammo" 10 {max 60}{value 7}}				
	{item "osv_fl ammo" 10 {max 60}{value 7}}				
	{item "762x51_x20 ammo" 10 {max 60}{value 7}}				
	{item "SVD_ammo ammo" 10 {max 120}{value 4}}				
	{item "svdk_ammo ammo" 10 {max 60}{value 7}}				
	{item "Vin_ammo ammo" 10 {max 120}{value 7}}
)
(define "smallarms_usa"
	{item "556Nato ammo" 30 {max 300}{value 5}}				
	{item "556NatoMB ammo" 30 {max 300}{value 5}}				
	{item "9mm ammo" 30 {max 300}{value 5}}				
	{item "762Nato ammo" 100 {max 600}{value 10}}				
	{item "12mm_shotgun ammo" 10 {max 60}{value 2}}				
	{item "nato_ptr ap ammo" 10 {max 60}{value 7}}				
	{item "nato_ptr sn ammo" 10 {max 60}{value 7}}				
	{item "8_6x70_x10 ammo" 10 {max 60}{value 7}}				
	{item "103x77_x5 ammo" 10 {max 60}{value 7}}				
)

(define "hmgun_rus"
	{item "Hcb_ammo ammo" 50 {max 300}{value 10}}				
	{item "dshkm_ammo ammo" 50 {max 300}{value 10}}				
	{item "Kpvt_ammo ammo" 25 {max 300}{value 10}}				
	{item "Kpvt_bst ammo" 25 {max 300}{value 15}}				
	{item "Kpvt_mdz ammo" 25 {max 300}{value 15}}				
)
(define "hmgun_rus"
	{item "50Nato ammo" 50 {max 300}{value 10}}				
	{item "50NatoAP ammo" 50 {max 100}{value 20}}				
)

(define "20mm"
	{item "bullet20_139 ap ammo" 10 {max 300}{value 8}}				
	{item "bullet20_139 fg ammo" 10 {max 300}{value 8}}	
	{item "vulcan20mm fg ammo" 10 {max 300}{value 8}}	
	{item "vulcan20mmA fg ammo" 10 {max 300}{value 8}}	
	{item "vulcan20mmB fg ammo" 10 {max 300}{value 8}}	
)
(define "23mm"
	{item "bullet23" "bzt" "zenite" "ammo" 10 {max 300}{value 10}}				
	{item "bullet23" "ofzt" "zenite" "ammo" 10 {max 300}{value 10}}
)
(define "23mm_avia"
	{item "bullet23_115 bzt zenite" 10 {max 100}{value 10}}				
	{item "bullet23_115 ofzt zenite" 10 {max 150}{value 10}}				
)
(define "25mm"
	{item "bullet25_FR ap ammo" 10 {max 200}{value 12}}				
	{item "bullet25_FR fg ammo" 10 {max 300}{value 12}}				
	{item "bullet25_USA ap ammo" 10 {max 200}{value 12}}				
	{item "bullet25_USA fg ammo" 10 {max 300}{value 12}}				
	{item "bullet25_USA_a ap ammo" 10 {max 200}{value 12}}				
)
(define "30mm"
	{item "bullet30_RUS ap ammo" 10 {max 200}{value 15}}				
	{item "bullet30_RUS fg ammo" 10 {max 300}{value 15}}				
	{item "bullet30_RUS_apg ap ammo" 10 {max 200}{value 25}}				
	{item "bullet30_RUS_aph ap ammo" 10 {max 200}{value 12}}
)
(define "30mm_usa"
	{item "bullet30_USA cm ammo" 10 {max 400}{value 15}}				
)
(define "35mm"
	{item "bullet35 ap ammo" 10 {max 300}{value 20}}				
	{item "bullet35 apcr ammo" 10 {max 80}{value 30}}				
	{item "bullet35 fg ammo" 10 {max 300}{value 20}}				
)
(define "100mm_bmp3"
	{item "bullet100a_RUS" "fg" "ammo" 1 {max 30}{value 20}}				
	{item "bullet100a_RUS" "rok" "ammo" 1 {max 8}{value 30}}				
)
(define "hydra"
	{item "Bullet70_Hydra ammo" 1 {max 300}{value 15}}				
)
(define "125mm"
	{item "bullet125_h_rus rok ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS apcr ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS apcr_h ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS cm ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS cm_e ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS fg ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS fgh ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS rok ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS_a cm ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS_b cm ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS_m apcr ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS_s1 apcr ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS_s2 apcr ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS_v apcr ammo" 1 {max 15}{value 40}}				
	{item "bullet125_RUS_z apcr ammo" 1 {max 15}{value 40}}				
)

(define "mortar_usa"
	{item "81mm of ammo" 1 {max 10}{value 15}}				
)
(define "mortar_rus"
	{item "82mm of ammo" 1 {max 10}{value 15}}				
)

(define "ags30"
	{item "mortar pdb ammo" 10 {max 90}{value 30}}				
)

(define "mk19"
	{item "40x53_usapg ammo cm" 10 {max 90}{value 30}}	
	{item "ammo mk19_ammo fg"	 10 {max 90}{value 30}}	
)











;resupply works only if in gun {filling uses the same tag as in shell filename.
;not working with tags in shell
(define "rus_heavy_ammo"
	{extender "supply_zone"
		{resupply
;			("smallarms_rus")
;			("30mm")
;			("100mm_bmp3")
;			("125mm")
;			("mortar_usa")
;			("mortar_rus")
;			("ags30")
;			("mk19")
			("test")
		}
		{radius 			10}		;resupply radius in meter
		{resupplyPeriod 	0.1}	;resupply period in seconds
		{regenerationPeriod 0}		;regeneration period in seconds, +1 supply every x seconds (0 = no regeneration)
		{limit 				10000}	;max number of resupplies (0 = unlimited)
	}
	("supply_decal")
)

