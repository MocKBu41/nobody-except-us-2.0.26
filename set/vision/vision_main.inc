;= HUMAN =====================================

{"tt_tankman"}

{"human"
    ("uncover" u(7))
    ("h_fov" h(70))
    ("v_fov" v(200))
    ("vision_human")
}

{"mp_soldier"
    ("uncover" u(20))
    ("h_fov" h(150))
    ("v_fov" v(200))
    ("vision_human")
}

{"mp_officer"
    ("uncover" u(50))
    ("h_fov" h(180))
    ("v_fov" v(200))
    ("vision_officer")
}
{"mp_mgunner"
    ("uncover" u(20))
    ("h_fov" h(80))
    ("v_fov" v(200))
    ("vision_mgunner")
}
{"mp_sniper"
    ("uncover" u(20))
    ("h_fov" h(100))
    ("v_fov" v(200))
    ("vision_sniper")
}

{"mp_specnaz"
    ("uncover" u(20))
    ("h_fov" h(180))
    ("v_fov" v(200))
    ("vision_stealth")
}
{"human_around"
    ("uncover" u(1))
    ("h_fov" h(200))
    ("v_fov" v(180))
    ("human_stand")
}
;========================================
;modern
;radars for 3m2 target
;vision_radar_shipSAM R=4.3*radius
;vision_radar_X_band R=4.3*radius
{"radar_sharp_p37"
    ("uncover" u(1))
    ("h_fov" h(20))
    ("v_fov" v(20))
    ("radius" r(116))
    ("vision_radar_L_band")
}
{"radar_llq305a"    ;400км
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(90))
    ("radius" r(140))
    ("vision_radar_L_band")
}
{"radarL_hq16"  ;HQ-16B СПЦ
    ("uncover" u(1))
    ("h_fov" h(90))
    ("v_fov" v(90))
    ("radius" r(109))
    ("vision_targradar_L_band")
}
{"radar_hawx_anmpq50"   ;100km
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(20))
    ("radius" r(114))
    ("vision_radar_L_band")
}
{"radar_hawx_cwar"  ;70km
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(20))
    ("radius" r(104))
    ("vision_radar_X_band")
}
{"E2c_radar"
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(30))
    ("radius" r(132))
    ("vision_radar_Hawkeye")
}
{"radarX_buk_85km"	;Бук-М1 СОУ
    ("uncover" u(1))
    ("h_fov" h(60))
    ("v_fov" v(60))
    ("radius" r(87))
    ("vision_radar_shipSAM")
}
{"radarX_buk_120km"	;Бук-М2 СОЦ
    ("uncover" u(1))
    ("h_fov" h(90))
    ("v_fov" v(90))
    ("radius" r(91))
    ("vision_radar_shipSAM")
}
{"radarX_kupol_160km"	;Купол М1-3 СОУ
    ("uncover" u(1))
    ("h_fov" h(30))
    ("v_fov" v(30))
    ("radius" r(95))
    ("vision_radar_shipSAM")
}
{"radarX_around_sampt"	;SAMPT 80 км
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(75))
    ("radius" r(85))
    ("vision_radar_shipSAM")
}
{"radarX_patriot_130km"
    ("uncover" u(1))
    ("h_fov" h(90))
    ("v_fov" v(90))
    ("radius" r(98))
    ("vision_radar_shipSAM")
}
{"Aegis_radar"	;320км
    ("uncover" u(1))
    ("h_fov" h(100))
    ("v_fov" v(100))
    ("radius" r(135))
    ("vision_radar_shipSAM")
}
{"radarX_fort_round"	;rif
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(90))
    ("radius" r(91))
    ("vision_radar_shipSAM")
}
{"radarX_fortm_round"	;320км
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(90))
    ("radius" r(135))
    ("vision_radar_shipSAM")
}
{"Fregat750_radar"	;300км
    ("uncover" u(1))
    ("h_fov" h(100))
    ("v_fov" v(100))
    ("radius" r(116))
    ("vision_radar_shipSAM")
}
{"Fregat710_radar"	;150км
    ("uncover" u(1))
    ("h_fov" h(100))
    ("v_fov" v(100))
    ("radius" r(94))
    ("vision_radar_shipSAM")
}
{"aircraft_radarX_350km"
    ("uncover" u(1))
    ("h_fov" h(120))
    ("v_fov" v(120))
    ("radius" r(96))
    ("vision_radar_X_band")
}
{"aircraft_radarX_200km"
    ("uncover" u(1))
    ("h_fov" h(120))
    ("v_fov" v(120))
    ("radius" r(75))
    ("vision_radar_X_band")
}
{"aircraft_radarX_185km"	;wide FOV - CAPTOR radar for EF2000
    ("uncover" u(1))
    ("h_fov" h(180))
    ("v_fov" v(180))
    ("radius" r(73))
    ("vision_radar_X_band")
}
{"aircraft_radarX_150km"
    ("uncover" u(1))
    ("h_fov" h(120))
    ("v_fov" v(120))
    ("radius" r(70))
    ("vision_radar_X_band")
}
{"aircraft_radarX_130km"
    ("uncover" u(1))
    ("h_fov" h(120))
    ("v_fov" v(120))
    ("radius" r(71))
    ("vision_radar_X_band")
}
{"aircraft_radarX_100km"
    ("uncover" u(1))
    ("h_fov" h(120))
    ("v_fov" v(120))
    ("radius" r(66))
    ("vision_radar_X_band")
}
{"aircraft_radarX_80km"
    ("uncover" u(1))
    ("h_fov" h(120))
    ("v_fov" v(120))
    ("radius" r(53))
    ("vision_radar_X_band")
}
{"aircraft_radarX_60km"
    ("uncover" u(1))
    ("h_fov" h(120))
    ("v_fov" v(120))
    ("radius" r(41))
    ("vision_radar_X_band")
}
{"aircraft_radarL_150km"
    ("uncover" u(1))
    ("h_fov" h(210))
    ("v_fov" v(90))
    ("radius" r(113))
    ("vision_radar_L_band")
}
{"aircraft_radar_X_side"	;better on ground targets, but small
    ("uncover" u(1))
    ("h_fov" h(90))
    ("v_fov" v(90))
    ("radius" r(41))
    ("vision_radar_X_band_small")
}
{"radar_pnsr5"
    ("uncover" u(100))
    ("h_fov" h(108))
    ("v_fov" v(90))
    ("radius" r(130))
    ("vision_radar_doppler_gr")
}
{"radar_bs903"
    ("uncover" u(100))
    ("h_fov" h(108))
    ("v_fov" v(90))
    ("radius" r(160))
    ("vision_radar_doppler_gr")
}
{"radar_pnsr5m"
    ("uncover" u(100))
    ("h_fov" h(108))
    ("v_fov" v(90))
    ("radius" r(220))
    ("vision_radar_doppler_gr")
}
{"radar_90grad"		;Mi-28, Apache, approx 15 km
    ("uncover" u(1))
    ("h_fov" h(90))
    ("v_fov" v(90))
    ("vision_radar_ground")
}
{"radar_wide"	;m163 7km
    ("uncover" u(1))
    ("h_fov" h(150))
    ("v_fov" v(150))
    ("radius" r(41))
    ("vision_radar_short")
}
{"radar_around_apache"	;Apache, approx 15 km
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(180))
    ("vision_radar_air")
}
{"radar_air_mi28n"	;Mi-28, approx 15 km
    ("uncover" u(1))
    ("h_fov" h(180))
    ("v_fov" v(60))
    ("vision_radar_air")
}
{"pelengator_strela10"	;182м по самолету
    ("uncover" u(1))
    ("h_fov" h(180))
    ("v_fov" v(60))
	("radius" r(42.3))
    ("vision_pelengator")	;видит авиацию и РЛС ПВО, не видит ракеты и наземные цели
}
{"pelengator_strela10_side"	;182м по самолету
    ("uncover" u(1))
    ("h_fov" h(180))
    ("v_fov" v(60))
	("radius" r(42.3))
    ("vision_pelengator")	;видит авиацию и РЛС ПВО, не видит ракеты и наземные цели
}
{"radar_around_shorad"  ;30km
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(180))
    ("radius" r(76))
    ("vision_radar_short")
}
{"radar_around"	;16km, Тунгуска, Шилка, т.п.
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(180))
    ("radius" r(54))
    ("vision_radar_short")
}
{"radar_around_roland"	;25km
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(180))
    ("radius" r(70))
    ("vision_radar_short")
}
{"radar_around_podkat"	; 35km
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(180))
    ("radius" r(74))
    ("vision_radar_short")
}
{"radar_pantsir_s"  ; 35km Панцирь-С (1 полотно малый 1РС1-1Е)
    ("uncover" u(1))
    ("h_fov" h(90))
    ("v_fov" v(180))
    ("radius" r(86))
    ("vision_radar_shipSAM")
}
{"radar_pantsir_s1" ; 52km Панцирь-С (1 полотно малый 1РС1-1Е)
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(180))
    ("radius" r(98))
    ("vision_radar_shipSAM")
}
{"radar_pantsir_s_front"    ; 30km Панцирь-С (станция подсвета 1РС2-1Е) малый сектор
    ("uncover" u(1))
    ("h_fov" h(25))
    ("v_fov" v(180))
    ("radius" r(81))
    ("vision_radar_short")
}
{"radar_sharp_hq7b" ; 40km малый сектор
    ("uncover" u(1))
    ("h_fov" h(25))
    ("v_fov" v(45))
    ("radius" r(93))
    ("vision_radar_short")
}
{"radar_around_long"	;310m ovod and Zubr all-around radar
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(180))
    ("radius" r(143))
    ("vision_radar")
}
;-----------------------------------------------------

{"shtora_visor"
    ("uncover" u(10))
    ("h_fov" h(360))
    ("v_fov" v(90))
    ("radius" r(140))
    ("vision_shtora")
}
{"shtora90_visor"
    ("uncover" u(10))
    ("h_fov" h(100))
    ("v_fov" v(120))
    ("radius" r(140))
    ("vision_shtora")
}
{"trophy_visor"
    ("uncover" u(20))
    ("h_fov" h(110))
    ("v_fov" v(60))
    ("radius" r(140))
    ("vision_shtora")
}
;-----------------------------------------------------
{"tank_gunner_optic_1g"
    ("uncover" u(5))
    ("h_fov" h(30))
    ("v_fov" v(140))
    ("vision_optic_modern_1gen")
}
{"tank_gunner_optic_2g"
    ("uncover" u(5))
    ("h_fov" h(25))
    ("v_fov" v(140))
    ("vision_optic_modern_2gen")
}
{"tank_gunner_optic_3g"
    ("uncover" u(5))
    ("h_fov" h(25))
    ("v_fov" v(140))
    ("vision_optic_modern_3gen")
}
{"tank_gunner_optic_IR_1g"
    ("uncover" u(25))
    ("h_fov" h(30))
    ("v_fov" v(140))
    ("vision_optic_modern_and_IR_1gen")
}
{"tank_gunner_optic_IR_2g"
    ("uncover" u(35))
    ("h_fov" h(25))
    ("v_fov" v(140))
    ("vision_optic_modern_and_IR_2gen")
}
{"tank_gunner_optic_IR_3g"
    ("uncover" u(35))
    ("h_fov" h(25))
    ("v_fov" v(140))
    ("vision_optic_modern_and_IR_3gen")
}
{"tank_gunner_optic_IR_4g"
    ("uncover" u(35))
    ("h_fov" h(20))
    ("v_fov" v(140))
    ("vision_optic_modern_and_IR_4gen")
}
{"aircraft_optic_2g"
    ("uncover" u(35))
    ("h_fov" h(35))
    ("v_fov" v(140))
    ("vision_optic_modern_2gen")
}
{"aircraft_optic_3g"
    ("uncover" u(35))
    ("h_fov" h(35))
    ("v_fov" v(140))
    ("vision_optic_modern_3gen")
}
{"aircraft_optic_3g_wide"
    ("uncover" u(35))
    ("h_fov" h(120))
    ("v_fov" v(140))
    ("vision_optic_modern_3gen")
}
{"aircraft_optic_IR_1g"
    ("uncover" u(35))
    ("h_fov" h(35))
    ("v_fov" v(140))
    ("vision_optic_modern_and_IR_1gen")
}
{"aircraft_optic_IR_2g"
    ("uncover" u(35))
    ("h_fov" h(35))
    ("v_fov" v(140))
    ("vision_optic_modern_and_IR_2gen")
}
{"aircraft_optic_IR_2g_wide"
    ("uncover" u(35))
    ("h_fov" h(120))
    ("v_fov" v(140))
    ("vision_optic_modern_and_IR_2gen")
}
{"aircraft_optic_IR_3g"
    ("uncover" u(35))
    ("h_fov" h(35))
    ("v_fov" v(140))
    ("vision_optic_modern_and_IR_3gen")
}
{"aircraft_optic_IR_3g_wide"
    ("uncover" u(35))
    ("h_fov" h(120))
    ("v_fov" v(140))
    ("vision_optic_modern_and_IR_3gen")
}
{"aircraft_optic_IR_4g"
    ("uncover" u(35))
    ("h_fov" h(180))
    ("v_fov" v(140))
    ("vision_optic_modern_and_IR_4gen")
}
{"aircraft_optic_IR_4g_platan"
    ("uncover" u(35))
    ("h_fov" h(70))
    ("v_fov" v(180))
    ("vision_optic_modern_and_IR_4gen")
}
{"uav_optic_optic_IR_1g"
    ("uncover" u(5))
    ("h_fov" h(1))
    ("v_fov" v(45))
    ("vision_optic_modern_and_IR_1gen")
}
;-------------------------------------------
{"missile"
;    ("radius" r(315))
    ("radius" r(415))
    ("uncover" u(350))
    ("h_fov" h(90))
    ("v_fov" v(90))
    ("vision_missile")
}
{"antimissile"
;    ("radius" r(315))
    ("radius" r(415))
    ("uncover" u(350))
    ("h_fov" h(90))
    ("v_fov" v(90))
    ("vision_antimissile")
}
{"semiLR_missile"
    ("radius" r(550))
    ("uncover" u(350))
    ("h_fov" h(70))
    ("v_fov" v(70))
    ("vision_missile")
}
{"vertical_missile"
    ("radius" r(315))
    ("uncover" u(350))
    ("h_fov" h(360))
    ("v_fov" v(180))
    ("vision_missile")
}
{"LRmissile"	;perhaps dont work
    ("radius" r(690))
    ("uncover" u(420))
;    ("radius" r(520))
;    ("uncover" u(120))
    ("h_fov" h(90))
    ("v_fov" v(90))
    ("vision_missile")
}
{"vertical_LRmissile"
    ("radius" r(690))
    ("uncover" u(420))
    ("h_fov" h(360))
    ("v_fov" v(180))
    ("vision_missile")
}
{"vertical_antimissile"
    ("radius" r(690))
    ("uncover" u(350))
    ("h_fov" h(90))
    ("v_fov" v(90))
    ("vision_antimissile")
}
{"vertical_antimissile_side"
    ("radius" r(690))
;    ("radius" r(420))
;    ("uncover" u(350))
    ("uncover" u(10))
    ("h_fov" h(360))
;    ("v_fov" v(360))
    ("v_fov" v(60))
   ("vision_antimissile")
}
{"torpedo_small"
;    ("radius" r(113))
    ("radius" r(150))
    ("uncover" u(180))
    ("h_fov" h(360))
    ("v_fov" v(180))
    ("vision_missile")
}
{"missile_sam"
;    ("radius" r(113))
    ("radius" r(250))
    ("uncover" u(350))
    ("h_fov" h(180))
    ("v_fov" v(180))
    ("vision_missile")
}
{"antimissile_sam"
;    ("radius" r(113))
    ("radius" r(250))
    ("uncover" u(350))
    ("h_fov" h(180))
    ("v_fov" v(180))
    ("vision_antimissile")
}
{"missile_close"
    ("radius" r(38))
    ("uncover" u(350))
    ("h_fov" h(240))
    ("v_fov" v(240))
    ("vision_missile")
}
{"antimissile_close"
    ("radius" r(38))
    ("uncover" u(350))
    ("h_fov" h(240))
    ("v_fov" v(240))
    ("vision_antimissile")
}
{"harm_passive_radar"
    ("radius" r(240))
    ("uncover" u(350))
    ("h_fov" h(60))
    ("v_fov" v(90))
    ("vision_antirad")
}
{"antiship_missile"
    ("radius" r(250))
    ("uncover" u(10))
    ("h_fov" h(90))
    ("v_fov" v(120))
    ("vision_antiship_missile")
}
{"antiship_missile_close"
    ("radius" r(20))
    ("uncover" u(10))
    ("h_fov" h(180))
    ("v_fov" v(60))
    ("vision_antiship_missile")
}
{"largeantiship_missile"
    ("radius" r(750))
    ("uncover" u(10))
    ("h_fov" h(60))
    ("v_fov" v(120))
    ("vision_largeantiship_missile")
}
{"largeantiship_missile_close"
    ("radius" r(70))
    ("uncover" u(10))
    ("h_fov" h(80))
    ("v_fov" v(30))
    ("vision_largeantiship_missile")
}
{"none"}








;= SPECIAL ===================================

{"soldier_focused"
    ("uncover" u(10))
    ("h_fov" h(20))
    ("v_fov" v(50))
;    ("vision_human")
    ("vision_binocular")
}

{"rifle_telescope"
    ("uncover" u(7))
    ("h_fov" h(360))
    ("v_fov" v(120))
    ("glass" args 7)
}

{"field_glass"
    ("uncover" u(7))
    ("h_fov" h(45))
    ("v_fov" v(120))
    ("glass" args 50)
}

;= CANNON ========================================

{"cannon_main"
    ("uncover" u(5))
    ("h_fov" h(60))
    ("v_fov" v(140))
    ("vision_optic")
}

{"cannon_mgun"
    ("uncover" u(5))
    ("h_fov" h(50))
    ("v_fov" v(140))
    ("vision_human")
;    {wide 2}
}

{"cannon_main-far"
    ("uncover" u(5))
    ("h_fov" h(60))
    ("v_fov" v(140))
    ("vision_optic")
}

{"cannon_crew"
    ("uncover" u(5))
    ("h_fov" h(360))
    ("v_fov" v(140))
    ("human_stand")
}

;= VEHICLE & MOTO ============================

{"vehicle_main"
    ("uncover" u(5))
    ("h_fov" h(50))
    ("v_fov" v(140))
    ("vision_human")
}

{"vehicle_main_IR"
    ("uncover" u(25))
    ("h_fov" h(50))
    ("v_fov" v(140))
    ("vision_human_IR")
}

{"vehicle_main_180"
    ("uncover" u(25))
    ("h_fov" h(180))
    ("v_fov" v(140))
    ("vision_human")
}

{"vehicle_main_IR_360"
    ("uncover" u(25))
    ("h_fov" h(360))
    ("v_fov" v(140))
    ("vision_human_IR")
}

{"vehicle_top_mgun"
    ("h_fov" h(90))
    ("v_fov" v(140))
    ("vision_human")
}
{"vehicle_top_turret2"
    ("uncover" u(3))
    ("h_fov" h(100))
    ("v_fov" v(20))
    ("vision_turret")
}
{"vehicle_top_turret"
    ("uncover" u(1))
    ("h_fov" h(360))
    ("v_fov" v(20))
    ("vision_turret")
}
{"moto"
    ("uncover" u(5))
    ("h_fov" h(30))
    ("v_fov" v(140))
    ("vision_human")
}
{"moto_crew"
    ("uncover" u(5))
    ("h_fov" h(90))
    ("v_fov" v(60))
    ("vision_human")
}

{"moto_around"
    ("uncover" u(3))
    ("h_fov" h(360))
    ("v_fov" v(60))
    ("human_stand")
}

;= TANK ======================================
{"mg_hull"
    ("uncover" u(3))
    ("h_fov" h(5))
    ("v_fov" v(90))
    ("vision_tgunner")
}
{"tank_main-l"
    ("uncover" u(5))
    ("h_fov" h(30))
    ("v_fov" v(140))
    ("vision_optic")
}

{"tank_main-m"
    ("uncover" u(5))
    ("h_fov" h(25))
    ("v_fov" v(140))
    ("vision_optic")
}

{"tank_main-h"
    ("uncover" u(5))
    ("h_fov" h(25))
    ("v_fov" v(140))
    ("vision_optic")
}

{"tank_driver"
    ("uncover" u(3))
    ("h_fov" h(50))
    ("v_fov" v(20))
    ("vision_tgunner")
}

{"tank_back"
    ("uncover" u(3))
    ("h_fov" h(50))
    ("v_fov" v(120))
    ("vision_tgunner")
}
{"l_tank_unc"
    ("uncover" u(70))
    ("h_fov" h(25))
    ("v_fov" v(180))
    ("vision_optic_unc")
}
{"tank_around-l"

}

{"tank_around-m"

}

{"tank_around-h"

}

;===================
{"Visor_Artil"
    ("uncover" u(3))
    ("h_fov" h(15))
    ("v_fov" v(100))
    ("vision_optic")
}

{"Visor_BTR"
    ("uncover" u(10))
    ("h_fov" h(30))
    ("v_fov" v(100))
    ("vision_optic")
}


{"Visor_CAY"
    ("uncover" u(5))
    ("h_fov" h(25))
    ("v_fov" v(180))
    ("vision_optic")
}

{"sau_unc" 
    ("uncover" u(70))
    ("h_fov" h(25))
    ("v_fov" v(180))
    ("vision_optic_unc")
}

{"Visor_Tank_Long"
    ("uncover" u(5))
    ("h_fov" h(25))
    ("v_fov" v(180))
    ("vision_optic")
}

{"Visor_Tank"
    ("uncover" u(5))
    ("h_fov" h(25))
    ("v_fov" v(180))
    ("vision_optic")
}

{"tank_unc"
    ("uncover" u(70))
    ("h_fov" h(25))
    ("v_fov" v(180))
    ("vision_optic_unc")
}

{"Visor_cannon"
    ("uncover" u(5))
    ("h_fov" h(25))
    ("v_fov" v(180))
    ("vision_optic")
}
{"cann_unc"
    ("uncover" u(70))
    ("vision_optic_unc")
}

{"gunfire_detector"	;detects shooting targets - 2km for smallarms
					;does not detect movement sound, only supersonic shockwaves
	{radius 100}
	{h_fov 360}
   	{v_fov 180}
	{uncover 100}
    ("sensor_acoustic")
}

{"sonar_ship_50km"	;detects submarines and ships only
	{radius 300}	;50km moving sub, 25km static sub, 220 ship
	{h_fov 360}
   	{v_fov 45}
	{uncover 10}
    ("sensor_ship_sonar")
}
{"sonar_ship_15km"	;detects submarines and ships only
	{radius 220}	
	{h_fov 360}
   	{v_fov 45}
	{uncover 10}
    ("sensor_ship_sonar")
}
{"sonar_torpedo"	;detects submarines and ships only
	{radius 200}	
	{h_fov 60}
   	{v_fov 45}
	{uncover 10}
    ("sensor_ship_sonar")
}