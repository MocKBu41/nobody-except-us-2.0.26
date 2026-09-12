(include "veterancy.inc")
(define "traits_civilian"
	{perks
		{"health" "100%"}
		{"health_regeneration" "100%"}
		{"mgun" lvl_1}
		{"pistol" lvl_1}
		{"stamina" "100%"}
		{"stamina_regeneration" "100%"}
		{"rifle" lvl_1}
		{"smg" lvl_1}
		{"melee" lvl_2}
		{"vision" human}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}

	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_engineering_troops"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_3}
		{"mgun" lvl_2}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_1}
		{"pistol" lvl_2}
		{"gra_launch" lvl_2}
		{"melee" lvl_2}
		{"avoidance" lvl_2}
		{"health" "150%"}
		{"health_regeneration" "100%"}
		{"stamina" "150%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}

	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_engineer"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_3}
		{"mgun" lvl_2}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_1}
		{"pistol" lvl_2}
		{"gra_launch" lvl_2}
		{"melee" lvl_2}
		{"avoidance" lvl_2}
		{"health" "150%"}
		{"health_regeneration" "100%"}
		{"stamina" "150%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
		;{fortification}
		;{mechanic}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_vehicle_supporter"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_3}
		{"mgun" lvl_2}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_1}
		{"pistol" lvl_2}
		{"gra_launch" lvl_2}
		{"melee" lvl_2}
		{"avoidance" lvl_2}
		{"health" "150%"}
		{"health_regeneration" "100%"}
		{"stamina" "100%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.8}
		;{fortification}
		;{mechanic "-repair_lev2" factor 0.33}
		
		{"skill_tankgun" lev_4}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_crew")
	}
)
(define "traits_pilot"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_3}
		{"mgun" lvl_1}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_1}
		{"pistol" lvl_3}
		{"gra_launch" lvl_1}
		{"melee" lvl_2}
		{"avoidance" lvl_4}
		{"health" "150%"}
		{"health_regeneration" "100%"}
		{"stamina" "110%"}
		{"stamina_regeneration" "100%"}
		{"speed" 1}		
		
		{"skill_tankgun" lev_4}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_4}
		{"skill_airgm_launcher" lev_4}
	}
	{veterancy
		
		("veterancy_crew")
	}
)
(define "traits_heavy_sniper"
	{perks
		{"vision" mp_sniper}
		{"smg" lvl_3}
		{"mgun" lvl_2}
		{"rifle" lvl_4}
		{"rocketlauncher" lvl_3}
		{"pistol" lvl_4}
		{"gra_launch" lvl_2}
		{"melee" lvl_3}
		{"avoidance" lvl_3}
		{"health" "200%"}
		{"health_regeneration" "100%"}
		{"stamina" "180%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
		{"telescope"}
		{"aimedshot"}
		{"field_glass"}
		{"stealth"}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)
(define "traits_tankman"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_2}
		{"mgun" lvl_3}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_2}
		{"pistol" lvl_3}
		{"gra_launch" lvl_1}
		{"melee" lvl_2}
		{"avoidance" lvl_2}
		{"health" "100%"}
		{"health_regeneration" "100%"}

		{"stamina" "100%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.8}
		;{fortification}
		;{mechanic "-repair_lev3" factor 0.5}
		
		{"skill_tankgun" lev_4}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
		
		
	}
	{veterancy
		
		("veterancy_crew")
	}
)
(define "traits_officer"
	{perks
		{"vision" mp_officer}
		{"smg" lvl_3}
		{"mgun" lvl_3}
		{"rifle" lvl_3}
		{"rocketlauncher" lvl_3}
		{"pistol" lvl_4}
		{"gra_launch" lvl_3}
		{"melee" lvl_3}
		{"avoidance" lvl_3}
		{"health" "150%"}
		{"health_regeneration" "100%"}
		{"stamina" "150%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
		{"field_glass"}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_3}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}


	}
	{veterancy
		
		("veterancy_specnaz")
	}
)
(define "traits_scout"
	{perks
		{"vision" mp_specnaz}
		{"smg" lvl_4}
		{"mgun" lvl_2}
		{"rifle" lvl_3}
		{"rocketlauncher" lvl_4}
		{"pistol" lvl_4}
		{"gra_launch" lvl_2}
		{"melee" lvl_5}
		{"avoidance" lvl_5}
		{"health" "180%"}
		{"health_regeneration" "100%"}
		{"stamina" "300%"}
		{"stamina_regeneration" "100%"}
		{"speed" 1.1}
		{"telescope"}
		{"aimedshot"}
		{"stealth"}
		{"field_glass"}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)
;===========================================
(define "traits_militia_smg"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_1}
		{"mgun" lvl_1}
		{"rifle" lvl_1}
		{"rocketlauncher" lvl_1}
		{"pistol" lvl_2}
		{"gra_launch" lvl_1}
		{"melee" lvl_2}
		{"avoidance" lvl_1}
		{"health" "130%"}
		{"health_regeneration" "100%"}
		{"stamina" "130%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.8}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_militia_mgun"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_2}
		{"mgun" lvl_2}
		{"rifle" lvl_1}
		{"rocketlauncher" lvl_1}
		{"pistol" lvl_2}
		{"gra_launch" lvl_2}
		{"melee" lvl_2}
		{"avoidance" lvl_1}
		{"health" "130%"}
		{"health_regeneration" "100%"}
		{"stamina" "130%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.8}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_militia_bazooker"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_2}
		{"mgun" lvl_1}
		{"rifle" lvl_1}
		{"rocketlauncher" lvl_2}
		{"pistol" lvl_2}
		{"gra_launch" lvl_2}
		{"melee" lvl_2}
		{"avoidance" lvl_1}
		{"health" "130%"}
		{"health_regeneration" "100%"}
		{"stamina" "130%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.8}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_militia_sniper"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_1}
		{"mgun" lvl_1}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_1}
		{"pistol" lvl_2}
		{"gra_launch" lvl_1}
		{"melee" lvl_2}
		{"avoidance" lvl_1}
		{"health" "130%"}
		{"health_regeneration" "100%"}
		{"stamina" "130%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.8}
		{"telescope"}
		{"aimedshot"}
		{"field_glass"}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)













;===========================================
(define "traits_army_smg"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_3}
		{"mgun" lvl_2}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_2}
		{"pistol" lvl_2}
		{"gra_launch" lvl_3}
		{"melee" lvl_3}
		{"avoidance" lvl_2}
		{"health" "180%"}
		{"health_regeneration" "100%"}
		{"stamina" "150%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.8}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_army_bazooker"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_3}
		{"mgun" lvl_2}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_3}
		{"pistol" lvl_2}
		{"gra_launch" lvl_2}
		{"melee" lvl_3}
		{"avoidance" lvl_2}
		{"health" "150%"}
		{"health_regeneration" "100%"}
		{"stamina" "150%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.8}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_army_sniper"
	{perks
		{"vision" mp_sniper}
		{"smg" lvl_2}
		{"mgun" lvl_2}
		{"rifle" lvl_3}
		{"rocketlauncher" lvl_2}
		{"pistol" lvl_3}
		{"gra_launch" lvl_2}
		{"melee" lvl_2}
		{"avoidance" lvl_2}
		{"health" "180%"}
		{"health_regeneration" "100%"}
		{"stamina" "100%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.8}
		{"telescope"}
		{"aimedshot"}
		{"field_glass"}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_army_mgun"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_3}
		{"mgun" lvl_3}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_2}
		{"pistol" lvl_2}
		{"gra_launch" lvl_3}
		{"melee" lvl_2}
		{"avoidance" lvl_2}
		{"health" "180%"}
		{"health_regeneration" "100%"}
		{"stamina" "150%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.8}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_army_com"
	{perks
		{"vision" mp_officer}
		{"smg" lvl_3}
		{"mgun" lvl_2}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_2}
		{"pistol" lvl_2}
		{"gra_launch" lvl_2}
		{"melee" lvl_3}
		{"avoidance" lvl_2}
		{"health" "180%"}
		{"health_regeneration" "100%"}
		{"stamina" "100%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.8}
		{"field_glass"}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_army_spotter"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_3}
		{"mgun" lvl_2}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_2}
		{"pistol" lvl_2}
		{"gra_launch" lvl_3}
		{"melee" lvl_3}
		{"avoidance" lvl_2}
		{"health" "180%"}
		{"health_regeneration" "100%"}
		{"stamina" "150%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.8}
		{"stealth"}
		{"telescope"}
		{"aimedshot"}
		{"field_glass"}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
;===========================================
(define "traits_advanced_com"
	{perks
		{"vision" mp_officer}
		{"smg" lvl_4}
		{"mgun" lvl_3}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_3}
		{"pistol" lvl_3}
		{"gra_launch" lvl_4}
		{"melee" lvl_4}
		{"avoidance" lvl_2}
		{"health" "200%"}
		{"health_regeneration" "100%"}
		{"stamina" "200%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
		{"field_glass"}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_advanced_mgun"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_3}
		{"mgun" lvl_4}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_4}
		{"pistol" lvl_2}
		{"gra_launch" lvl_3}
		{"melee" lvl_4}
		{"avoidance" lvl_2}
		{"health" "200%"}
		{"health_regeneration" "100%"}
		{"stamina" "200%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_advanced_bazooker"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_3}
		{"mgun" lvl_3}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_4}
		{"pistol" lvl_3}
		{"gra_launch" lvl_4}
		{"melee" lvl_4}
		{"avoidance" lvl_2}
		{"health" "200%"}
		{"health_regeneration" "100%"}
		{"stamina" "200%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_advanced_smg"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_4}
		{"mgun" lvl_3}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_3}
		{"pistol" lvl_3}
		{"gra_launch" lvl_4}
		{"melee" lvl_4}
		{"avoidance" lvl_2}
		{"health" "200%"}
		{"health_regeneration" "100%"}
		{"stamina" "200%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_advanced_medic"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_4}
		{"mgun" lvl_3}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_3}
		{"pistol" lvl_3}
		{"gra_launch" lvl_4}
		{"melee" lvl_4}
		{"avoidance" lvl_2}
		{"health" "200%"}
		{"health_regeneration" "100%"}
		{"stamina" "200%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_advanced_sniper"
	{perks
		{"vision" mp_sniper}
		{"smg" lvl_3}
		{"mgun" lvl_2}
		{"rifle" lvl_4}
		{"rocketlauncher" lvl_3}
		{"pistol" lvl_3}
		{"gra_launch" lvl_3}
		{"melee" lvl_4}
		{"avoidance" lvl_3}
		{"health" "200%"}
		{"health_regeneration" "100%"}
		{"stamina" "200%"}
		{"stamina_regeneration" "100%"}
		{"speed" 1}
;		{"stealth"}
		{"telescope"}
		{"aimedshot"}
		{"field_glass"}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
(define "traits_advanced_spotter"
	{perks
		{"vision" mp_sniper}
		{"smg" lvl_4}
		{"mgun" lvl_2}
		{"rifle" lvl_3}
		{"rocketlauncher" lvl_2}
		{"pistol" lvl_2}
		{"gra_launch" lvl_4}
		{"melee" lvl_4}
		{"avoidance" lvl_3}
		{"health" "200%"}
		{"health_regeneration" "100%"}
		{"stamina" "200%"}
		{"stamina_regeneration" "100%"}
		{"speed" 1}
		{"stealth"}
		{"telescope"}
		{"aimedshot"}
		{"field_glass"}
		
		{"skill_tankgun" lev_1}
		{"skill_atgm_launcher" lev_1}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_1")
	}
)
;===========================================
(define "traits_specnaz_smg"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_4}
		{"mgun" lvl_3}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_3}
		{"pistol" lvl_3}
		{"gra_launch" lvl_4}
		{"melee" lvl_4}
		{"avoidance" lvl_3}
		{"health" "250%"}
		{"stamina" "180%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_3}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)
(define "traits_specnaz_com"
	{perks
		{"vision" mp_officer}
		{"smg" lvl_4}
		{"mgun" lvl_3}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_3}
		{"pistol" lvl_3}
		{"gra_launch" lvl_4}
		{"melee" lvl_4}
		{"avoidance" lvl_3}
		{"health" "250%"}
		{"stamina" "180%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
		{"field_glass"}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_3}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)
(define "traits_specnaz_bazooker"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_3}
		{"mgun" lvl_3}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_4}
		{"pistol" lvl_3}
		{"gra_launch" lvl_4}
		{"melee" lvl_4}
		{"avoidance" lvl_3}
		{"health" "250%"}
		{"stamina" "180%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_3}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)
(define "traits_specnaz_mgun"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_3}
		{"mgun" lvl_4}
		{"rifle" lvl_2}
		{"rocketlauncher" lvl_3}
		{"pistol" lvl_3}
		{"gra_launch" lvl_4}
		{"melee" lvl_4}
		{"avoidance" lvl_3}
		{"health" "250%"}
		{"stamina" "180%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_3}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)
(define "traits_specnaz_grenadier"
	{perks
		{"vision" mp_soldier}
		{"smg" lvl_4}
		{"mgun" lvl_2}
		{"rifle" lvl_4}
		{"rocketlauncher" lvl_2}
		{"pistol" lvl_2}
		{"gra_launch" lvl_4}
		{"melee" lvl_3}
		{"avoidance" lvl_3}
		{"health" "250%"}
		{"stamina" "180%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_3}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)
(define "traits_specnaz_spotter"
	{perks
		{"vision" mp_specnaz}
		{"smg" lvl_3}
		{"mgun" lvl_2}
		{"rifle" lvl_3}
		{"rocketlauncher" lvl_3}
		{"pistol" lvl_3}
		{"gra_launch" lvl_2}
		{"melee" lvl_3}
		{"avoidance" lvl_3}
		{"health" "250%"}
		{"stamina" "180%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
		{"telescope"}
		{"aimedshot"}
		{"stealth"}
		{"field_glass"}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_3}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)
(define "traits_specnaz_sniper"
	{perks
		{"vision" mp_sniper}
		{"smg" lvl_3}
		{"mgun" lvl_2}
		{"rifle" lvl_4}
		{"rocketlauncher" lvl_3}
		{"pistol" lvl_4}
		{"gra_launch" lvl_2}
		{"melee" lvl_3}
		{"avoidance" lvl_2}
		{"health" "250%"}
		{"stamina" "180%"}
		{"stamina_regeneration" "100%"}
		{"speed" 0.9}
		{"telescope"}
		{"aimedshot"}
;		{"stealth"}
		{"field_glass"}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_3}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)





















;===========================================
(define "traits_elite_smg"
	{perks
		{"vision" mp_specnaz}
		{"smg" lvl_4}
		{"mgun" lvl_4}
		{"rifle" lvl_4}
		{"rocketlauncher" lvl_4}
		{"pistol" lvl_4}
		{"gra_launch" lvl_4}
		{"melee" lvl_5}
		{"avoidance" lvl_3}
		{"health" "250%"}
		{"stamina" "250%"}
		{"stamina_regeneration" "100%"}
		{"speed" 1.1}
		{"stealth"}
		{"field_glass"}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_3}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)
(define "traits_elite_mgun"
	{perks
		{"vision" mp_specnaz}
		{"smg" lvl_4}
		{"mgun" lvl_4}
		{"rifle" lvl_4}
		{"rocketlauncher" lvl_4}
		{"pistol" lvl_4}
		{"gra_launch" lvl_4}
		{"melee" lvl_5}
		{"avoidance" lvl_3}
		{"health" "250%"}
		{"stamina" "250%"}
		{"stamina_regeneration" "100%"}
		{"speed" 1.1}
		{"stealth"}
		{"field_glass"}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_3}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)
(define "traits_elite_bazooker"
	{perks
		{"vision" mp_specnaz}
		{"smg" lvl_4}
		{"mgun" lvl_4}
		{"rifle" lvl_4}
		{"rocketlauncher" lvl_4}
		{"pistol" lvl_4}
		{"gra_launch" lvl_4}
		{"melee" lvl_5}
		{"avoidance" lvl_3}
		{"health" "250%"}
		{"stamina" "250%"}
		{"stamina_regeneration" "100%"}
		{"speed" 1.1}
		{"stealth"}
		{"field_glass"}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_3}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)
(define "traits_elite_com"
	{perks
		{"vision" mp_elite_officer}
		{"smg" lvl_4}
		{"mgun" lvl_4}
		{"rifle" lvl_4}
		{"rocketlauncher" lvl_4}
		{"pistol" lvl_4}
		{"gra_launch" lvl_4}
		{"melee" lvl_5}
		{"avoidance" lvl_3}
		{"health" "250%"}
		{"stamina" "250%"}
		{"stamina_regeneration" "100%"}
		{"speed" 1.1}
		{"stealth"}
		{"field_glass"}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_3}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)
(define "traits_elite_sniper"
	{perks
		{"vision" mp_sniper}
		{"smg" lvl_4}
		{"mgun" lvl_4}
		{"rifle" lvl_4}
		{"rocketlauncher" lvl_4}
		{"pistol" lvl_4}
		{"gra_launch" lvl_4}
		{"melee" lvl_5}
		{"avoidance" lvl_3}
		{"health" "250%"}
		{"stamina" "250%"}
		{"stamina_regeneration" "100%"}
		{"speed" 1.1}
		{"stealth"}
		{"telescope"}
		{"aimedshot"}
		{"field_glass"}
;		{"medic" 10.0}
		
		{"skill_tankgun" lev_3}
		{"skill_atgm_launcher" lev_4}
		{"skill_airgun" lev_1}
		{"skill_airgm_launcher" lev_1}
	}
	{veterancy
		
		("veterancy_specnaz")
	}
)

(define "perk_t1")
(define "perk_t2")
(define "perk_t3")
(define "perk_t4")
(define "perk_t5")