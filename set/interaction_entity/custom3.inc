
{"bayraktar_tb2"		
	{on spawn 			
		{add_view	"flash_cannon_big"		"flashbarrel00"			"hellfire_shooter_00"}			
		{add_view	"flash_cannon_big"		"flashbarrel01"			"hellfire_shooter_01"}			
		{add_view	"flash_cannon_big"		"flashbarrel02"			"hellfire_shooter_02"}			
		{add_view	"flash_cannon_big"		"flashbarrel03"			"hellfire_shooter_03"}			
		}		
	{on "link_flare_fx" overload}		
	{on "eject_all" overload}		
	{on "add_movement_sound" overload			
		{link_sound "engine_start"		"vehicle/Helicopter/en_start"	}			
		{link_sound "engine_work"		"vehicle/airborne/fw_work"	  	}			
		{link_sound "engine_stop"		"vehicle/Helicopter/en_stop"	}		
	}		
	{on "landing" 			
		{ani_stop "ols_work"}		}		
		{on "u_w_Laser_TD_damaged"			
			{weapon_work "ptur" 0}			
				{tags add "no_missile_control"}		
				}		
		{on "u_w_radarX_damaged"			
			{weapon_work "bomber" 0}		
		}		
		{on "u_w_electronics_damaged"			
			{weapon_work "ptur" 0}			
			{call "fall"}		
		}		
		{on "engine_on"			
			{if not "engine_started"				
				{set "engine_started" 1}				
					{play_sound "engine_start"}				
					{ani_play "engine_start" callback}			
			}		
		}		
		{on animation_end "engine_start"			
					{ani_play "engine_work" loop}			
					{play_sound "engine_work" 1}			
					{ani_play "ols_work" 0.3 loop}		
		}		
		{on engine off overload			
					{call "engine_stop"}			
					{play_sound "engine_stop"}		
		}		
		{on "engine_stop"			
			{kill_delay "engine_stopped"}			
			{if "engine_started"				
				{set "engine_started" 0}				
					{ani_stop "engine_start"}				
					{ani_stop "engine_work"}				
					{ani_play "engine_stop"}				
					{stop_sound "engine_start"}				
					{stop_sound "engine_work"}				
					{stop_sound "fly"}			
			}		
		}	                                                                                                               
		{on fire "ptur" 			
			("low_speed_bullet")
			(define "fire_barrel"				
				name "%0"					
			{delay 0.1 
			{spawn "startsmoke" "hellfire_shooter_%0" x}
			{spawn "hellfire_carrier" "foresight3"   x}
			{tags add "hellfire_shooter_%0"}	
			}					
			{ani_play "fire"}					
			{view start "flashbarrel%0"}					
			{delay 0.4						
				{view pause "flashbarrel%0"}					
			}
			)				
			{if    ("fire_barrel" args 00)			
					else ("fire_barrel" args 01)			
					else ("fire_barrel" args 02)			
					else ("fire_barrel" args 03)			
		}		
		}			
		{on "antifire_work" overload			
			{call "antifire_not_work"}			
				{delay 10				
					{if volume "engine" {components "engine" break}}			
				}		
		}	
}

{"5p85se"		
	("custom_multi_vertlauncher" 	
		weapon(gun) 
		tail(tail) 
		shooter(shooter) 
		missile(5v55r) 
		tailfx(proj_jet_48n6e2)
	)		
	{on "_explosion"			
		{bone cut "wires"}			
		{tear "piece_medium_steel" bone "launcher_block"				
			{impulse up 4 1 dir 5 2 cx 5 2 cy 5 2 rnd_dir 6 no_position}				
			{delay_effect 20 5 "stop"}			
		}		

	}	
}

{"30n6"
	("9k72_sound")	
	("radar_params" triplex(commander_triplex) visor(visor2) anim_rotate(radar) marker(antirad_generator_large_usa))		
}


{"51p6a"				
	("9k72_sound")
	{on spawn					
		{volumes "gun_recoil" disable blast}			
		{call "init_gun"}		
	}	
	(define "fire_barrel"			
		{delay 0.2 				
			{volumes "gun_recoil" enable blast}				
			{spawn "turret_dir_detector" "gun_recoil" {stuff_detonate}}				
			{delay 0.5 {volumes "gun_recoil" disable blast}}				
			{delay 0.1 {spawn "startsmoke_vert" "Shooter_0%shooter" x}}				
			{bone show "missile_0%shooter"}				
			{delay 0.65 					
				{add_view	 "proj_jet_sam"	"exh_0%shooter"	"tail_0%shooter"}					
				{view start "exh_0%shooter"}	                               								
			}				
			{delay 0.65 {spawn "tank_canon_fire_small" "tail_0%shooter" x}}				
			{delay 0.7				
				{bone hide "missile_0%shooter"}					
				{spawn "48n6e2_carrier" "shooter_0%shooter"   x}					
				{view pause "exh_0%shooter"}					
				{view hide "exh_0%shooter"}					
				{view stop "exh_0%shooter"}				
			}				
			{delay 1.69					
				{ani_play "fire_restore"}				
			}			
		}			
		{ani_play "fire_%shooter" 0.5}		
	)		
	{on fire "gun" 			
		{spawn "dust_shot_big_3" "basis"}	      		
 		{spawn "dust_shot_big_3" "FXtraceL4"}	      		
		{if name "00" ("fire_barrel" shooter(00))			
			else name "01" ("fire_barrel" shooter(01))			
			else name "02" ("fire_barrel" shooter(02))			
			else name "03" ("fire_barrel" shooter(03))		
		}		
	}		
	{on blast_hit		
		{if stuff "turret_dir_detector"				
			{if volume "recoil_gun_front"  {ani_play "fire_front"} {ani_play "fire_front_common"}				
				else volume "recoil_gun_left"  {ani_play "fire_left"} {ani_play "fire_left_common"}				
				else volume "recoil_gun_right"  {ani_play "fire_right"} {ani_play "fire_right_common"}				
				else volume "recoil_gun_back"  {ani_play "fire_back"} {ani_play "fire_back_common"}					
				else volume "recoil_gun_baleft"  {ani_play "fire_bl"}				
				else volume "recoil_gun_baright"  {ani_play "fire_br"}				
				else volume "recoil_gun_frright"  {ani_play "fire_fr"}				
				else volume "recoil_gun_frleft"  {ani_play "fire_fl"}				
				else volume "recoil_gun_central"				
			}			
		}		
	}		
	{on "explosion"			
		{spawn "ex_air_big2" "basis"}		
	}	
}
{"92n6e"			
	("9k72_sound")
	{on spawn {delay 5 {call "update_antiradar"}}}		
	{on "update_radar"			
		{if tagged "radar_off" {weapon_work "radar" 0}			
			else not work "commander_triplex" {weapon_work "radar" 0}			
			else not work "body" {weapon_work "radar" 0}			
			else not work "turret" {weapon_work "radar" 0}			
			else not work "radar" {weapon_work "radar" 0}			
			else tagged "no_power" {weapon_work "radar" 0}			
			else {weapon_work "radar" 1}			
		}		
	}		
	{on crew out			
		{if crew_in_place "driver" {tags add "arabel_moves"}
			{call "update_antiradar"}
		}			
		{if not crew_in_place "commander" {call "update_antiradar"}}		
	}		
	{on crew in			
		{if crew_in_place "commander" {delay 4 {call "update_antiradar"}}}		
	}		
	{on break			
		{if component "commander_triplex" {call "update_antiradar"}}		
	}		
	{on repair		
		{if component "commander_triplex" {call "update_antiradar"}}		
	}		
	{on "update_antiradar" overload				
		{if crew_in_place "commander"				  
		{if not tagged "no_power"				   
		{if not tagged "cwsh_passive"					 
		{if work "commander_triplex"					  
		{if tagged "arabel_moves"						
			{call "cwsh_radar_on"}					   
				else not tagged "radar_off"					    
			{call "cwsh_radar_on"}					  
				else {call "cwsh_radar_off"}					   
		}					
			else {call "cwsh_radar_off"}					
		}				  
		else					
			{call "cwsh_radar_off"}				   
		}				  
		else					
			{call "cwsh_radar_off"}				  
		}				
		else
			{call "cwsh_radar_off"}				
		}		
	}		
	{on "specability" overload	}		
	{on "cwsh_radar_on"			
		{tags remove "arabel_moves"}			
			{if work "commander_triplex"			  
				{if crew_in_place "commander"				
						{ani_play "radar_loop" loop}				
							{delay 0.1 {ani_play "visor1" -1}}				
								{with_linked_entity "vehicle9"					
									{call "start"}				
								}			   
				}			
			}		
	}		
	{on "cwsh_radar_off"			
		{ani_stop "radar_loop"}			
			{delay 0.1 {ani_play "visor1"}}			
				{with_linked_entity "vehicle9"				
					{call "stop"}			
				}		
	}	
}

{"su-25sm"		
	{on spawn 			
		{add_view "flash_gun_big" "flashbarrel1" "foresight1"}			
		{add_view	"flash_cannon_big"		"R60_00"			"R60_00"}			
		{add_view	"flash_cannon_big"		"R60_01"			"R60_01"}		
	}		
	{on "link_engine_effects" overload			
		{add_view	"airstream_exhaust"	"engine1_exhaust"		"engine1_exhaust"	}			
		{add_view	"airstream_exhaust"	"engine2_exhaust" 		"engine2_exhaust"	}			
		{add_view	"turbovent_overburn"		"engine1_overburn"		"engine1_exhaust"	}			
		{add_view	"turbovent_overburn"		"engine2_overburn" 		"engine2_exhaust"	}				
		("link_damage_sound_rus")		
	}		
	{on "fall"			
		{volumes "fuel_tank_internal_b_vol" disable all}			
		{volumes "fuel_tank_internal_ñ_vol" disable all}		
	}		
	{on "scripted_fillipov"			
		{spawn "tank_die_particle"}			
		{burn volume "engine2" fx "smoke_black" fake}			
		("stop_damage_sound")			
		{play_sound "engine2_damage"}			
		{view start "engine2_smoke"}			
		{delay 2				
			{add_view "smoke_dead_norm" "burn_fire2" "engine2_exhaust"}				
			{add_view "smoke_black" "burn_fire2" "engine2_exhaust"}				
			{view start "burn_fire2"}				
			{play_sound "flame" 1}			
		}			
		{delay 7				
			{play_sound "engine1_damage"}				
			{view start "engine1_smoke"}				
			{burn volume "engine1" fx "smoke_black" fake}				
			{add_view "smoke_dead_norm" "burn_fire1" "engine1_exhaust"}				
			{add_view "smoke_black" "burn_fire1" "engine1_exhaust"}				
			{view start "burn_fire1"}				
			{play_sound "flame" 1}			
		}										
	}							
}		
{"su-25sm_support_ukr"		
	{on "u_w_Laser_TD_damaged"			
		{weapon_work "ptur1" 0}			
		{tags add "no_missile_control"}		
	}		
	{on "u_w_electronics_damaged"			
		{weapon_work "ptur1" 0}			
		{weapon_work "ptur2" 0}		
	}		
	("air_multibarrel_launcher" weapon(ptur1) shooter(X-25_shooter_) missile(x_25ml_su25_ammo) flashbarrel(X-25_shooter_))		
	("air_multibarrel_launcher" weapon(ptur2) shooter(R60_) missile(r60_su25) flashbarrel(R60_))		
	("air_nar_launcher" weapon(nar1) flashbarrel(B8shooter_))		
	("air_gliding_bomber" weapon(bomber) bomb(rbk_250_impactor) bomber(RBK250_) speed(35) spread(5))	
}	
{"su-25sm_support_wagner"		
	{on "u_w_Laser_TD_damaged"			
		{weapon_work "ptur1" 0}			
		{tags add "no_missile_control"}		
	}		
	{on "u_w_electronics_damaged"			
		{weapon_work "ptur1" 0}			
		{weapon_work "ptur2" 0}		
	}		
	("air_multibarrel_launcher" weapon(ptur1) shooter(X-25_shooter_) missile(x_25ml_su25_ammo) flashbarrel(X-25_shooter_))		
	("air_multibarrel_launcher" weapon(ptur2) shooter(R60_) missile(r60_su25) flashbarrel(R60_))		
	("air_nar_launcher" weapon(nar1) flashbarrel(B8shooter_))		
	("air_gliding_bomber" weapon(bomber) bomb(rbk_250_impactor) bomber(RBK250_) speed(35) spread(5))	
}
{"su-25sm_support_light_ukr"				
	("air_multibarrel_launcher" weapon(ptur2) shooter(Shooter_r73rvvsd_) missile(r-73) flashbarrel(Shooter_r73rvvsd_))		
	("air_nar_launcher" weapon(nar1) flashbarrel(B8shooter_))		
	{on fire "nar1_s13"			("low_speed_bullet")			
	(define "fire_barrel"				name "%0"					
		{view start "tailL%0"}					
		{delay 0.42						
			{view pause "tailL%0"}					
		}			
	)			
	{spawn "startsmoke" inv_normal}				
		{if    ("fire_barrel" args 00)				  
			else ("fire_barrel" args 01)				  
			else ("fire_barrel" args 02)				
			else ("fire_barrel" args 03)				  
			else ("fire_barrel" args 04)			
		}		
	}		
	{on fire "nar2_s13"			
		("low_speed_bullet")			
		(define "fire_barrel"				name "%0"					
		{view start "tailR%0"}					
		{delay 0.42						
		{view pause "tailR%0"}					
		}			
		)			
		{spawn "startsmoke" inv_normal}				
			{if    ("fire_barrel" args 00)				 
				else ("fire_barrel" args 01)				  
				else ("fire_barrel" args 02)				
				else ("fire_barrel" args 03)				  
				else ("fire_barrel" args 04)				
			}		
		}	
		)	
}
{"su-25sm_support_light_wagner"				
	("air_multibarrel_launcher" weapon(ptur2) shooter(Shooter_r73rvvsd_) missile(r-73) flashbarrel(Shooter_r73rvvsd_))		
	("air_nar_launcher" weapon(nar1) flashbarrel(B8shooter_))		
	{on fire "nar1_s13"			("low_speed_bullet")			
	(define "fire_barrel"				name "%0"					
		{view start "tailL%0"}					
		{delay 0.42						
			{view pause "tailL%0"}					
		}			
	)			
	{spawn "startsmoke" inv_normal}				
		{if    ("fire_barrel" args 00)				  
			else ("fire_barrel" args 01)				  
			else ("fire_barrel" args 02)				
			else ("fire_barrel" args 03)				  
			else ("fire_barrel" args 04)			
		}		
	}		
	{on fire "nar2_s13"			
		("low_speed_bullet")			
		(define "fire_barrel"				name "%0"					
		{view start "tailR%0"}					
		{delay 0.42						
		{view pause "tailR%0"}					
		}			
		)			
		{spawn "startsmoke" inv_normal}				
			{if    ("fire_barrel" args 00)				 
				else ("fire_barrel" args 01)				  
				else ("fire_barrel" args 02)				
				else ("fire_barrel" args 03)				  
				else ("fire_barrel" args 04)				
			}		
		}	
		)	
}
{"su-25sm_accurate_ukr"		
	{on spawn 			
		{add_view	 	"BMP2_canon_fire"	"flashbarrel1"		"Foresight1"}			
		{add_view	"flash_cannon_big"		"X-25_shooter_00"			"X-25_shooter_00"}			
		{add_view	"flash_cannon_big"		"X-25_shooter_01"			"X-25_shooter_01"}			
		{add_view	"flash_cannon_big"		"R60_00"			"R60_00"}			
		{add_view	"flash_cannon_big"		"R60_01"			"R60_01"}		
	}		
	{on "u_w_Laser_TD_damaged"			
		{weapon_work "ptur1" 0}			
		{weapon_work "nar1" 0}			
		{tags add "no_missile_control"}		
	}		
	{on "u_w_electronics_damaged"			
		{weapon_work "ptur1" 0}			
		{weapon_work "ptur2" 0}			
		{weapon_work "nar1" 0}		
	}		
	("air_multibarrel_launcher" weapon(ptur1) shooter(X-25_shooter_) missile(x_25ml_su25_ammo) flashbarrel(X-25_shooter_))		
	("air_multibarrel_launcher" weapon(ptur2) shooter(R60_) missile(r60_su25) flashbarrel(R60_))		
	{on fire "nar1"			("low_speed_bullet")			(define "fire_barrel"				name "%0"					
	{spawn "startsmoke" "C-25_shooter_%0" x}					{spawn "startsmoke" "C-25_tail_%0" x}			)			
	{if    ("fire_barrel" args 00) else ("fire_barrel" args 01) else ("fire_barrel" args 02)				
		else ("fire_barrel" args 03) else ("fire_barrel" args 04) else ("fire_barrel" args 05)			
	}		
	}	
}	

{"su-25sm_strike_ukr"		
	{on spawn 			
		{add_view	 	"BMP2_canon_fire"	"flashbarrel1"		"Foresight1"}			
		{add_view	"flash_cannon_big"		"X-25_shooter_00"			"X-25_shooter_00"}			
		{add_view	"flash_cannon_big"		"X-25_shooter_01"			"X-25_shooter_01"}			
		{add_view	"flash_cannon_big"		"X-25_shooter_02"			"X-25_shooter_02"}			
		{add_view	"flash_cannon_big"		"X-25_shooter_03"			"X-25_shooter_03"}			
		{add_view	"flash_cannon_big"		"R60_00"			"R60_00"}			
		{add_view	"flash_cannon_big"		"R60_01"			"R60_01"}		
	}		
	{on "u_w_Laser_TD_damaged"			
		{weapon_work "ptur1" 0}			
		{tags add "no_missile_control"}		
	}		
	{on "u_w_electronics_damaged"			
		{weapon_work "ptur1" 0}			
		{weapon_work "ptur2" 0}		
	}		
	("air_multibarrel_launcher" weapon(ptur1) shooter(X-25_shooter_) missile(x_25ml_su25_ammo) flashbarrel(X-25_shooter_))		
	("air_multibarrel_launcher" weapon(ptur2) shooter(R60_) missile(r60_su25) flashbarrel(R60_))		
	("air_gliding_bomber" weapon(bomber) bomb(odab_500_impactor) bomber(bomber_) speed(35) spread(5))	
}		
{"su-25sm_AT_ukr"		
	{on spawn 			{add_view	 	"BMP2_canon_fire"	"flashbarrel1"		"Foresight1"}			
		{add_view	"flash_cannon_big"		"R60_00"			"R60_00"}			
		{add_view	"flash_cannon_big"		"R60_01"			"R60_01"}			
		{add_view "flash_zenit"			"sppu00"	"sppu_shooter_00"}			
		{add_view "flash_zenit"			"sppu01"	"sppu_shooter_01"}			
		{add_view "flash_zenit"			"sppu02"	"sppu_shooter_02"}			
		{add_view "flash_zenit"			"sppu03"	"sppu_shooter_03"}			
		{bone hide "Gun_sppu_break_00"}			{bone hide "Gun_sppu_break_01"}		
	}		
	{on "u_w_Laser_TD_damaged"			
		{weapon_work "nar1" 0}			
		{tags add "no_missile_control"}		
	}		
	{on "u_w_electronics_damaged"			
		{weapon_work "nar1" 0}			
		{weapon_work "ptur2" 0}			
		{weapon_work "mgun" 0}		
	}		
	{on fire "nar1"			
		("low_speed_bullet")			
		(define "fire_barrel"				name "%0"					
			{spawn "startsmoke" "C-25_shooter_%0" x}					
			{spawn "startsmoke" "C-25_tail_%0" x}			
		)			
		{if    ("fire_barrel" args 00) else ("fire_barrel" args 01) }		
	}		
	("air_gliding_bomber" weapon(bomber) bomb(rbk_500_impactor) bomber(bomber1_) speed(35) spread(5))		
	("air_multibarrel_launcher" weapon(ptur2) shooter(R60_) missile(r60_su25) flashbarrel(R60_))		
	{on fire "mgun" overload			
		{if name "00"				
		{view start "sppu00"}	
		{delay 0.42	{view pause "sppu00"}}			
			else  name "01"				
				{view start "sppu01"}	
				{delay 0.42	{view pause "sppu01"}}			
			else  name "02"				
				{view start "sppu02"}	
				{delay 0.42	{view pause "sppu02"}}			
			else  name "03"				
				{view start "sppu03"}	
				{delay 0.42	{view pause "sppu03"}}			
		}		
	}		
	{on "tear_wingl1"			
		{bone cut "Gun_sppu_00"}			
		{bone show "Gun_sppu_break_00"}		
	}		
	{on "tear_wingr1"			
		{bone cut "Gun_sppu_01"}			
		{bone show "Gun_sppu_break_01"}		
	}	
}		

{"mig29s_aa_ukr"		
	{on spawn 			
		{add_view "flash_gun_big" "flashbarrel1" "foresight1"}			
		{add_view	 	"flash_gun_big"	"flashbarrel1"		"fxshot"}			
		{add_view	"flash_cannon_big"		"Shooter_r73rvvsd_00"			"Shooter_r73rvvsd_00"}			
		{add_view	"flash_cannon_big"		"Shooter_r73rvvsd_01"			"Shooter_r73rvvsd_01"}			
		{add_view	"flash_cannon_big"		"Shooter_r73rvvsd_02"			"Shooter_r73rvvsd_02"}			
		{add_view	"flash_cannon_big"		"Shooter_r73rvvsd_03"			"Shooter_r73rvvsd_03"}			
		{add_view	"flash_cannon_big"		"Shooter_r27_00"			"Shooter_r27_00"}			
		{add_view	"flash_cannon_big"		"Shooter_r27_01"			"Shooter_r27_01"}			
		{add_view 	"rok_tail" 		"tailL00" 		"tailL00"}			
		{add_view 	"rok_tail" 		"tailL01" 		"tailL01"}			
		{add_view 	"rok_tail" 		"tailL02" 		"tailL02"}			
		{add_view 	"rok_tail" 		"tailL03" 		"tailL03"}			
		{add_view 	"rok_tail" 		"tailL04" 		"tailL04"}			
		{add_view 	"rok_tail" 		"tailL05" 		"tailL05"}			
		{add_view 	"rok_tail" 		"tailR00" 		"tailR00"}			
		{add_view 	"rok_tail" 		"tailR01" 		"tailR01"}			
		{add_view 	"rok_tail" 		"tailR02" 		"tailR02"}			
		{add_view 	"rok_tail" 		"tailR03" 		"tailR03"}			
		{add_view 	"rok_tail" 		"tailR04" 		"tailR04"}			
		{add_view 	"rok_tail" 		"tailR05" 		"tailR05"}			
		("link_damage_sound_rus")	

	}		
	{on "u_w_radarX_damaged"			
		{weapon_work "ptur1" 0}			
		{weapon_work "ptur2" 0}		
	}	                            	   		
	{on "u_w_electronics_damaged"			
		{weapon_work "ptur1" 0}			
		{weapon_work "ptur2" 0}			
		{weapon_work "ptur" 0}		
	}		
	("air_multibarrel_launcher" weapon(ptur) shooter(Shooter_r73rvvsd_) missile(r-73) flashbarrel(Shooter_r73rvvsd_))		
	("air_multibarrel_launcher" weapon(ptur2) shooter(Shooter_rvvsd_) missile(rvv-sd) flashbarrel(Shooter_rvvsd_))		
	("air_multibarrel_launcher" weapon(ptur1) shooter(Shooter_r27_) missile(r_27er) flashbarrel(Shooter_r27_))		
	("air_nar_launcher" weapon(nar3) flashbarrel(B8shooter_))		
		{on fire "nar1"			
			("low_speed_bullet")
			(define "fire_barrel" name "%0"					
				{view start "tailL%0"}					
				{delay 0.42						
					{view pause "tailL%0"}					
				}			
			)			
		{spawn "startsmoke" inv_normal}				
			{if    ("fire_barrel" args 00)				 
				else ("fire_barrel" args 01)				 
				else ("fire_barrel" args 02)				
				else ("fire_barrel" args 03)				 
				else ("fire_barrel" args 04)				
			}		
		}		
		{on fire "nar2"			
			("low_speed_bullet")			
			(define "fire_barrel" name "%0"					
				{view start "tailR%0"}					
				{delay 0.42						
					{view pause "tailR%0"}					
				}			
			)			
			{spawn "startsmoke" inv_normal}				
			{if    ("fire_barrel" args 00)				 
				else ("fire_barrel" args 01)				  
				else ("fire_barrel" args 02)				
				else ("fire_barrel" args 03)				  
				else ("fire_barrel" args 04)				
			}		
		}		
		{on "update_weaponry"			
			{if work "ecm_pod" {volumes "talisman" enable overlap}			
				else {volumes "talisman" disable overlap}			
			}		
		}		
		{on overlap begin			
			{if effector "radioproximity"			  
				{if rand 0.5				
					{with_effector {call "detonate"} {with_effector}}			 
				}			
			}		
		}		
	{on "fall" {bone cut "talisman_holder"}}		
	{on "mp_destroy" {bone cut "talisman_holder"}}

}
{"mig29s_ab_ukr"		
	{on spawn 			
		{add_view "flash_gun_big" "flashbarrel1" "foresight1"}			
		{add_view	 	"flash_gun_big"	"flashbarrel1"		"fxshot"}			
		{add_view	"flash_cannon_big"		"Shooter_r73rvvsd_00"			"Shooter_r73rvvsd_00"}			
		{add_view	"flash_cannon_big"		"Shooter_r73rvvsd_01"			"Shooter_r73rvvsd_01"}			
		{add_view	"flash_cannon_big"		"Shooter_r73rvvsd_02"			"Shooter_r73rvvsd_02"}			
		{add_view	"flash_cannon_big"		"Shooter_r73rvvsd_03"			"Shooter_r73rvvsd_03"}			
		{add_view	"flash_cannon_big"		"Shooter_r27_00"			"Shooter_r27_00"}			
		{add_view	"flash_cannon_big"		"Shooter_r27_01"			"Shooter_r27_01"}			
		{add_view 	"rok_tail" 		"tailL00" 		"tailL00"}			
		{add_view 	"rok_tail" 		"tailL01" 		"tailL01"}			
		{add_view 	"rok_tail" 		"tailL02" 		"tailL02"}			
		{add_view 	"rok_tail" 		"tailL03" 		"tailL03"}			
		{add_view 	"rok_tail" 		"tailL04" 		"tailL04"}			
		{add_view 	"rok_tail" 		"tailL05" 		"tailL05"}			
		{add_view 	"rok_tail" 		"tailR00" 		"tailR00"}			
		{add_view 	"rok_tail" 		"tailR01" 		"tailR01"}			
		{add_view 	"rok_tail" 		"tailR02" 		"tailR02"}			
		{add_view 	"rok_tail" 		"tailR03" 		"tailR03"}			
		{add_view 	"rok_tail" 		"tailR04" 		"tailR04"}			
		{add_view 	"rok_tail" 		"tailR05" 		"tailR05"}			
		("link_damage_sound_rus")		
	}		
	{on "u_w_radarX_damaged"			
		{weapon_work "ptur1" 0}			
		{weapon_work "ptur2" 0}		
	}	                            	   		
	{on "u_w_electronics_damaged"			
		{weapon_work "ptur1" 0}			
		{weapon_work "ptur2" 0}			
		{weapon_work "ptur" 0}		
	}		
	("air_multibarrel_launcher" weapon(ptur) shooter(Shooter_r73rvvsd_) missile(r-73) flashbarrel(Shooter_r73rvvsd_))		
	("air_multibarrel_launcher" weapon(ptur2) shooter(Shooter_rvvsd_) missile(rvv-sd) flashbarrel(Shooter_rvvsd_))		
	("air_multibarrel_launcher" weapon(ptur1) shooter(Shooter_r27_) missile(r_27er) flashbarrel(Shooter_r27_))		
	("air_nar_launcher" weapon(nar3) flashbarrel(B8shooter_))		
		{on fire "nar1"			
			("low_speed_bullet")
			(define "fire_barrel" name "%0"					
				{view start "tailL%0"}					
				{delay 0.42						
					{view pause "tailL%0"}					
				}			
			)			
		{spawn "startsmoke" inv_normal}				
			{if    ("fire_barrel" args 00)				 
				else ("fire_barrel" args 01)				 
				else ("fire_barrel" args 02)				
				else ("fire_barrel" args 03)				 
				else ("fire_barrel" args 04)				
			}		
		}		
		{on fire "nar2"			
			("low_speed_bullet")			
			(define "fire_barrel" name "%0"					
				{view start "tailR%0"}					
				{delay 0.42						
					{view pause "tailR%0"}					
				}			
			)			
			{spawn "startsmoke" inv_normal}				
			{if    ("fire_barrel" args 00)				 
				else ("fire_barrel" args 01)				  
				else ("fire_barrel" args 02)				
				else ("fire_barrel" args 03)				  
				else ("fire_barrel" args 04)				
			}		
		}		
		{on "update_weaponry"			
			{if work "ecm_pod" {volumes "talisman" enable overlap}			
				else {volumes "talisman" disable overlap}			
			}		
		}		
		{on overlap begin			
			{if effector "radioproximity"			  
				{if rand 0.5				
					{with_effector {call "detonate"} {with_effector}}			 
				}			
			}		
		}		
	{on "fall" {bone cut "talisman_holder"}}		
	{on "mp_destroy" {bone cut "talisman_holder"}}	
}	
{"mig29k_aa_ukr"		
	{on spawn 			
		{add_view "flash_gun_big" "flashbarrel1" "foresight1"}			
		{add_view	 	"flash_gun_big"	"flashbarrel1"		"fxshot"}			
		{add_view	"flash_cannon_big"		"Shooter_rvvsd_00"			"Shooter_rvvsd_00"}			
		{add_view	"flash_cannon_big"		"Shooter_rvvsd_01"			"Shooter_rvvsd_01"}			
		{add_view	"flash_cannon_big"		"Shooter_rvvsd_02"			"Shooter_rvvsd_02"}			
		{add_view	"flash_cannon_big"		"Shooter_rvvsd_03"			"Shooter_rvvsd_03"}			
		{add_view	"flash_cannon_big"		"Shooter_rvvsd_04"			"Shooter_rvvsd_04"}			
		{add_view	"flash_cannon_big"		"Shooter_rvvsd_05"			"Shooter_rvvsd_05"}			
		{add_view	"flash_cannon_big"		"Shooter_r73rvvsd_00"			"Shooter_r73rvvsd_00"}			
		{add_view	"flash_cannon_big"		"Shooter_r73rvvsd_01"			"Shooter_r73rvvsd_01"}			
		{add_view	"flash_cannon_big"		"Shooter_r31_00"			"Shooter_r31_00"}			
		{add_view	"flash_cannon_big"		"Shooter_r31_01"			"Shooter_r31_01"}			
		{add_view	"flash_cannon_big"		"Shooter_r31_02"			"Shooter_r31_02"}			
		{add_view	"flash_cannon_big"		"Shooter_r31_03"			"Shooter_r31_03"}			
		("link_damage_sound_rus")		
	}		
	{on "u_w_radarX_damaged"			
		{weapon_work "ptur2" 0}		
	}	                            	   		
	{on "u_w_electronics_damaged"			
		{weapon_work "ptur4" 0}			
		{weapon_work "ptur2" 0}			
		{weapon_work "ptur" 0}			
		{weapon_work "bomber" 0}		
	}		
	("air_multibarrel_launcher" weapon(ptur) shooter(Shooter_r73rvvsd_) missile(r-73) flashbarrel(Shooter_r73rvvsd_))		
	("air_multibarrel_launcher" weapon(ptur2) shooter(Shooter_rvvsd_) missile(rvv-sd) flashbarrel(Shooter_rvvsd_))		
	("air_multibarrel_launcher" weapon(ptur4) shooter(Shooter_r31_) missile(x31ad) flashbarrel(Shooter_r31_))		
	("single_alt_control")		
	{on "update_weaponry"			
		{if work "ecm_pod" {volumes "talisman" enable overlap}			
			else {volumes "talisman" disable overlap}			
		}		
	}		
	{on overlap begin			
		{if effector "radioproximity"			 
			{if rand 0.5 {with_effector {call "detonate"} {with_effector}}				
				{volumes "talisman" disable overlap}					 
				{delay 2 {volumes "talisman" enable overlap}}			 
			}			
		}		
	}		
	{on "fall" {bone cut "talisman_holder"}}		
	{on "mp_destroy" {bone cut "talisman_holder"}}	
}		
{"marder_1a3_ukr"		
	{on spawn					
		{add_view	 	"flash_gun_big"	"flashbarrel5"		"Foresight5"}			
		{add_view	"rok_tail"	"rok_tail_gun2"	"tail"}	    
	}		
	("marder_sound")		
	{on fire "mgun" overload			
		{view start "flashbarrel5"}			("cw_check_shooting" weap_id(mgun))		
	}	  
	("autocannon")	("25-50mm_gilza" fxshell(fxshell))	                                                                                             
	("atgm_single_launcher" weapon(gun2) foresight(foresight6) tail(tail))	
}
{"vbl_mistral_ukr"		
	{on spawn					
		{add_view	 	"flash_gun_big"	"gun_flash00"		"shooter00"}			
		{add_view	 	"flash_gun_big"	"gun_flash01"		"shooter01"}		
	}		
	("custom_multi_launcher"	weapon(gun2) tail(tail) shooter(shooter) missile(mistral_missile))		
	("zpu_params" gunner(gunner2) zpu_mgun(gun2) anim(into_hatch_btr90) pose(hmmwv_mgun))		
	{on "update_gun23" overload		     
		{if work "gun2" 		          
			{if tagged "cwsh_zpu_off"						
			{weapon_work "gun2" 0}					
			else {inherited}		           
			}		     
		}		
	}	
}				
{"su-25sm_support_lighti"				
	("air_multibarrel_launcher" weapon(ptur2) shooter(R60_) missile(r60_su25) flashbarrel(R60_))		
	("air_nar_launcher" weapon(nar1) flashbarrel(B8shooter_))		
	{on fire "nar1_s13"			
		("low_speed_bullet")			
		(define "fire_barrel" name "%0"	{view start "tailL%0"}					
		{delay 0.42						{view pause "tailL%0"}	}			
		)			{spawn "startsmoke" inv_normal}				
		{if    ("fire_barrel" args 00)				  
			else ("fire_barrel" args 01)				  
			else ("fire_barrel" args 02)				
			else ("fire_barrel" args 03)				 
			else ("fire_barrel" args 04)				
		}		
	}		
	{on fire "nar2_s13"			("low_speed_bullet")			(define "fire_barrel"				name "%0"					
		{view start "tailR%0"}					
			{delay 0.42			{view pause "tailR%0"}		}			)			
	{spawn "startsmoke" inv_normal}				
		{if    ("fire_barrel" args 00)				  
			else ("fire_barrel" args 01)				 
		 	else ("fire_barrel" args 02)				
		 	else ("fire_barrel" args 03)				  
		 	else ("fire_barrel" args 04)				
		}
	}	
	)	
}

{"mi28ubi"		
	{on spawn			
		{add_view	"flash_zenit"		"flashbarrel1"			"Foresight1"}			
		{add_view	"exhaust_dark"	"engine_steam1" "FXsmoke1"}						
		{add_view	"exhaust_dark"	"engine_steam2" "FXsmoke2"}	                                                                                         			
		{add_view 	"rok_tail" 		"rok_tail00" 		"shooter_l00"}			
		{add_view 	"rok_tail" 		"rok_tail01" 		"shooter_l01"}			
		{add_view 	"rok_tail" 		"rok_tail02" 		"shooter_l02"}			
		{add_view 	"rok_tail" 		"rok_tail03" 		"shooter_l03"}			
		{add_view 	"rok_tail" 		"rok_tail04" 		"shooter_l04"}			
		{add_view 	"rok_tail" 		"rok_tail05" 		"shooter_l05"}			
		{add_view 	"rok_tail" 		"rok_tail06" 		"shooter_l06"}			
		{add_view 	"rok_tail" 		"rok_tail07" 		"shooter_l07"}			
		{add_view 	"rok_tail" 		"rok_tail08" 		"shooter_l08"}			
		{add_view 	"rok_tail" 		"rok_tail09" 		"shooter_l09"}			
		{add_view 	"rok_tail" 		"rok_tail10" 		"shooter_l10"}			
		{add_view 	"rok_tail" 		"rok_tail11" 		"shooter_l11"}			
		{add_view 	"rok_tail" 		"rok_tail12" 		"shooter_l12"}			
		{add_view 	"rok_tail" 		"rok_tail13" 		"shooter_l13"}			
		{add_view 	"rok_tail" 		"rok_tail14" 		"shooter_l14"}			
		{add_view 	"rok_tail" 		"rok_tail15" 		"shooter_l15"}			
		{add_view 	"rok_tail" 		"rok_tail16" 		"shooter_l16"}			
		{add_view 	"rok_tail" 		"rok_tail17" 		"shooter_l17"}			
		{add_view 	"rok_tail" 		"rok_tail18" 		"shooter_l18"}			
		{add_view 	"rok_tail" 		"rok_tail19" 		"shooter_l19"}	                                                                                             			
		{add_view 	"rok_tail" 		"rok_tail_00" 		"shooter_r00"}			
		{add_view 	"rok_tail" 		"rok_tail_01" 		"shooter_r01"}			
		{add_view 	"rok_tail" 		"rok_tail_02" 		"shooter_r02"}			
		{add_view 	"rok_tail" 		"rok_tail_03" 		"shooter_r03"}			
		{add_view 	"rok_tail" 		"rok_tail_04" 		"shooter_r04"}			
		{add_view 	"rok_tail" 		"rok_tail_05" 		"shooter_r05"}			
		{add_view 	"rok_tail" 		"rok_tail_06" 		"shooter_r06"}			
		{add_view 	"rok_tail" 		"rok_tail_07" 		"shooter_r07"}			
		{add_view 	"rok_tail" 		"rok_tail_08" 		"shooter_r08"}			
		{add_view 	"rok_tail" 		"rok_tail_09" 		"shooter_r09"}			
		{add_view 	"rok_tail" 		"rok_tail_10" 		"shooter_r10"}			
		{add_view 	"rok_tail" 		"rok_tail_11" 		"shooter_r11"}			
		{add_view 	"rok_tail" 		"rok_tail_12" 		"shooter_r12"}			
		{add_view 	"rok_tail" 		"rok_tail_13" 		"shooter_r13"}			
		{add_view 	"rok_tail" 		"rok_tail_14" 		"shooter_r14"}			
		{add_view 	"rok_tail" 		"rok_tail_15" 		"shooter_r15"}			
		{add_view 	"rok_tail" 		"rok_tail_16" 		"shooter_r16"}			
		{add_view 	"rok_tail" 		"rok_tail_17" 		"shooter_r17"}			
		{add_view 	"rok_tail" 		"rok_tail_18" 		"shooter_r18"}			
		{add_view 	"rok_tail" 		"rok_tail_19" 		"shooter_r19"}	                                                                                             			
		{add_view 	"rok_tail" 		"ptur1tail_00" 		"ptur1tail_00"}			
		{add_view 	"rok_tail" 		"ptur1tail_01" 		"ptur1tail_01"}			
		{add_view 	"rok_tail" 		"ptur1tail_02" 		"ptur1tail_02"}			
		{add_view 	"rok_tail" 		"ptur1tail_03" 		"ptur1tail_03"}			
		{add_view 	"rok_tail" 		"ptur1tail_04" 		"ptur1tail_04"}			
		{add_view 	"rok_tail" 		"ptur1tail_05" 		"ptur1tail_05"}			
		{add_view 	"rok_tail" 		"ptur1tail_06" 		"ptur1tail_06"}			
		{add_view 	"rok_tail" 		"ptur1tail_07" 		"ptur1tail_07"}			
		{add_view 	"rok_tail" 		"ptur2tail_00" 		"ptur2tail_00"}			
		{add_view 	"rok_tail" 		"ptur2tail_01" 		"ptur2tail_01"}			
		{add_view 	"rok_tail" 		"ptur2tail_02" 		"ptur2tail_02"}			
		{add_view 	"rok_tail" 		"ptur2tail_03" 		"ptur2tail_03"}			
		{add_view 	"rok_tail" 		"ptur2tail_04" 		"ptur2tail_04"}			
		{add_view 	"rok_tail" 		"ptur2tail_05" 		"ptur2tail_05"}			
		{add_view 	"rok_tail" 		"ptur2tail_06" 		"ptur2tail_06"}			
		{add_view 	"rok_tail" 		"ptur2tail_07" 		"ptur2tail_07"}				
		{add_view 	"flash_cannon_big" 		"ptur1tail_00" 		"ptur1shooter_00"}			
		{add_view 	"flash_cannon_big" 		"ptur1tail_01" 		"ptur1shooter_01"}			
		{add_view 	"flash_cannon_big" 		"ptur1tail_02" 		"ptur1shooter_02"}			
		{add_view 	"flash_cannon_big" 		"ptur1tail_03" 		"ptur1shooter_03"}			
		{add_view 	"flash_cannon_big" 		"ptur1tail_04" 		"ptur1shooter_04"}			
		{add_view 	"flash_cannon_big" 		"ptur1tail_05" 		"ptur1shooter_05"}			
		{add_view 	"flash_cannon_big" 		"ptur1tail_06" 		"ptur1shooter_06"}			
		{add_view 	"flash_cannon_big" 		"ptur1tail_07" 		"ptur1shooter_07"}			
		{add_view 	"flash_cannon_big" 		"ptur2tail_00" 		"ptur2shooter_00"}			
		{add_view 	"flash_cannon_big" 		"ptur2tail_01" 		"ptur2shooter_01"}			
		{add_view 	"flash_cannon_big" 		"ptur2tail_02" 		"ptur2shooter_02"}			
		{add_view 	"flash_cannon_big" 		"ptur2tail_03" 		"ptur2shooter_03"}			
		{add_view 	"flash_cannon_big" 		"ptur2tail_04" 		"ptur2shooter_04"}			
		{add_view 	"flash_cannon_big" 		"ptur2tail_05" 		"ptur2shooter_05"}			
		{add_view 	"flash_cannon_big" 		"ptur2tail_06" 		"ptur2shooter_06"}			
		{add_view 	"flash_cannon_big" 		"ptur2tail_07" 		"ptur2shooter_07"}			
		("link_damage_sound_rus")	    	
	}		
	{on "add_movement_sound" overload				
		{link_sound "fly"			"vehicle/helicopter/MI-28engine"}				
		{link_sound "engine_start"		"vehicle/helicopter/MI-8en_start"}				
		{link_sound "engine_work"		"vehicle/helicopter/en_work"}				
		{link_sound "engine_stop"		"vehicle/helicopter/MI-8en_stop"}		
	}		
	{on fire "ptur1" overload			
		("low_speed_bullet")			
		{spawn "proj_probe" "Foresight3" x  {tags add "Foresight3"}}			
		(define "fire_barrel"				name "%0"					
		{view start "ptur1tail_%0"}					
			{delay 0.42						
				{view pause "ptur1tail_%0"}					
			}			
		)				
		{spawn "startsmoke" inv_normal}				
			{if    ("fire_barrel" args 00)				  
			else ("fire_barrel" args 01)				  
				else ("fire_barrel" args 02)				  
				else ("fire_barrel" args 03)				  
				else ("fire_barrel" args 04)				  
				else ("fire_barrel" args 05)				  
				else ("fire_barrel" args 06)				  
				else ("fire_barrel" args 07)				
			}		
	}		
	{on fire "ptur2" overload			
	("low_speed_bullet")			{spawn "proj_probe" "Foresight4" x  {tags add "Foresight4"}}			(define "fire_barrel"				name "%0"					{view start "ptur2tail_%0"}					{delay 0.42						{view pause "ptur2tail_%0"}					}			)				
	{spawn "startsmoke" inv_normal}				
		{if   
			("fire_barrel" args 00)				  
				else ("fire_barrel" args 01)				  
				else ("fire_barrel" args 02)				  
				else ("fire_barrel" args 03)				  
				else ("fire_barrel" args 04)				  
				else ("fire_barrel" args 05)				  
				else ("fire_barrel" args 06)				  
				else ("fire_barrel" args 07)				
		}		
	}		
	{on fire "nar1" overload			
	("low_speed_bullet")			
		(define "fire_barrel" name "%0"					                  					
		{view start "rok_tail%0"}					
			{delay 0.42		{view pause "rok_tail%0"}	}			
		)			
		{spawn "startsmoke" inv_normal}				
			{if    ("fire_barrel" args 00)				  
				else ("fire_barrel" args 01)				  
				else ("fire_barrel" args 02)				
				else ("fire_barrel" args 03)				  
				else ("fire_barrel" args 04)				 
				else ("fire_barrel" args 05)				
				else ("fire_barrel" args 06)				
				else ("fire_barrel" args 07)			
				else ("fire_barrel" args 08)				
				else ("fire_barrel" args 09)				
				else ("fire_barrel" args 10)				
				else ("fire_barrel" args 11)					 
				else ("fire_barrel" args 12)				
				else ("fire_barrel" args 13)				  
				else ("fire_barrel" args 14)				 
				else ("fire_barrel" args 15)				
				else ("fire_barrel" args 16)				
				else ("fire_barrel" args 17)				
				else ("fire_barrel" args 18)				
				else ("fire_barrel" args 19)								 
				else ("fire_barrel" args 20)				  
				else ("fire_barrel" args 21)				
				else ("fire_barrel" args 22)				  
				else ("fire_barrel" args 23)				 
				else ("fire_barrel" args 24)				
				else ("fire_barrel" args 25)				
				else ("fire_barrel" args 26)				
				else ("fire_barrel" args 27)				
				else ("fire_barrel" args 28)				
				else ("fire_barrel" args 29)				
				else ("fire_barrel" args 30)					 
				else ("fire_barrel" args 31)				
				else ("fire_barrel" args 32)				 
			 	else ("fire_barrel" args 33)				 
			 	else ("fire_barrel" args 34)				
			 	else ("fire_barrel" args 35)			
			 	else ("fire_barrel" args 36)				
			 	else ("fire_barrel" args 37)				
			 	else ("fire_barrel" args 38)				
			 	else ("fire_barrel" args 39)				
			}					
		}			
		{on "update_lights"			
			{if rain {ani_play "rain" loop} else {ani_stop "rain"}}			
			{if not sunlight {ani_play "lights"} else {ani_wind "lights" begin}}		
		}		("autocannon")		
		("25-50mm_gilza" fxshell(fxshell))		
			{on "_explosion" 			
				{delay 0.1				
					("cut_part" args "radar"	1.0)				
					("cut_part" args "ols2"	0.5)				
					("cut_part" args "gun_rot2"	0.5)			
				}		
			}		
		{on break overload			
			{if component "ammo_storage_autocannon"				
				{if not tagged "destroyed"				
					{spawn "ex_air_big"}				
						{blastwave c4 2 r0 1 r1 3 position}				
						{delay 0.2 0.5	{spawn "ex_air_norm"}	
						{blastwave c4 2 r0 1 r1 3 position}}				
						{delay  0.6 1	{spawn "ex_air_norm"}	
						{blastwave c4 2 r0 1 r1 3 position}}				
						{delay 1 1.2	{spawn "ex_air_norm"}	
						{blastwave c4 2 r0 1 r1 3 position}}				
						{delay 1.3 1.5	{spawn "ex_air_norm"}	
						{blastwave c4 2 r0 1 r1 3 position}}				
				}			
				else {inherited}			
			}		
		}		
		{on "tear_propeller_up" overload			
			{spawn "propeller_hit2" "propeller" x}			
			{spawn "propeller_hit2" "propeller" x}			
			{inherited}		
		}		
		{on "check_pilot_existance" overload		                               			
			{if not tagged "destroyed"			 
				{if chassis "airborne"				
					{if crew_in_place "driver"				   
						{delay 0.2					
							{if not crew_in_place "driver"						
								{call "fall"}					
							}				  
						}					
					}			 
				}			
			}		
		}		
		{on crew out			
			{if not tagged "destroyed"			  
				{if chassis "airborne"				 
					{delay 0.2					
						{if not crew_in_place "driver"					 
							{call "fall"}					
						}				
					}				  
				}
			}		
		}	
}
{"kornet_stan_nov"		
	{on fire "gun" 			
	{spawn "proj_probe" "Foresight1" x {tags add "Foresight1"}}	
	}		
	{on "cut_parts" overload			
		{add_view "smoke_dead_norm" "deathfx" "FXfire1"}			
		{view start "deathfx"}			
		(define "cut_part"				
			{tear "piece_medium_steel" bone %0					
				{impulse up 1 1 dir 5 2 cx 5 2 cy 5 2 rnd_dir 5 no_position}					
				{call "check_delete_part"}				
			}			
		)			
		("cut_part" args "part1")			
		("cut_part" args "part2")			
		("cut_part" args "part3")			
		("cut_part" args "part5")			
		("cut_part" args "gun")			
		("cut_part" args "turret")			
		{delay 14 {view stop "deathfx"}}		
	}	
}	

{"ka52_nov"	                                                              		
	{on spawn			
		{add_view	"shtora_work"	"vitebsk1"	"vitebsk1"}			
		{add_view	"shtora_work"	"vitebsk2"	"vitebsk2"}			
		{add_view	"flash_zenit"		"flashbarrel1"			"Foresight1"}			
		{add_view	"exhaust_dark"	"engine_steam1" "FXsmoke1"}						
		{add_view	"exhaust_dark"	"engine_steam2" "FXsmoke2"}			
		{add_view       "autocannon_gilz"		"shell"	"fx_shell"}					
		{add_view 	"smoke_zenit" 	"zenite_smoke" 		"foresight1"}	                                                                                         			
		{add_view 	"rok_tail" 		"rok_tail00" 		"shooter_l00"}			
		{add_view 	"rok_tail" 		"rok_tail01" 		"shooter_l01"}			
		{add_view 	"rok_tail" 		"rok_tail02" 		"shooter_l02"}			
		{add_view 	"rok_tail" 		"rok_tail03" 		"shooter_l03"}			
		{add_view 	"rok_tail" 		"rok_tail04" 		"shooter_l04"}			
		{add_view 	"rok_tail" 		"rok_tail05" 		"shooter_l05"}			
		{add_view 	"rok_tail" 		"rok_tail06" 		"shooter_l06"}			
		{add_view 	"rok_tail" 		"rok_tail07" 		"shooter_l07"}			
		{add_view 	"rok_tail" 		"rok_tail08" 		"shooter_l08"}			
		{add_view 	"rok_tail" 		"rok_tail09" 		"shooter_l09"}			
		{add_view 	"rok_tail" 		"rok_tail10" 		"shooter_l10"}			
		{add_view 	"rok_tail" 		"rok_tail11" 		"shooter_l11"}			
		{add_view 	"rok_tail" 		"rok_tail12" 		"shooter_l12"}			
		{add_view 	"rok_tail" 		"rok_tail13" 		"shooter_l13"}			
		{add_view 	"rok_tail" 		"rok_tail14" 		"shooter_l14"}			
		{add_view 	"rok_tail" 		"rok_tail15" 		"shooter_l15"}			
		{add_view 	"rok_tail" 		"rok_tail16" 		"shooter_l16"}			
		{add_view 	"rok_tail" 		"rok_tail17" 		"shooter_l17"}			
		{add_view 	"rok_tail" 		"rok_tail18" 		"shooter_l18"}			
		{add_view 	"rok_tail" 		"rok_tail19" 		"shooter_l19"}	                                                                                             			
		{add_view 	"rok_tail" 		"rok_tail_00" 		"shooter_r00"}			
		{add_view 	"rok_tail" 		"rok_tail_01" 		"shooter_r01"}			
		{add_view 	"rok_tail" 		"rok_tail_02" 		"shooter_r02"}			
		{add_view 	"rok_tail" 		"rok_tail_03" 		"shooter_r03"}			
		{add_view 	"rok_tail" 		"rok_tail_04" 		"shooter_r04"}			
		{add_view 	"rok_tail" 		"rok_tail_05" 		"shooter_r05"}			
		{add_view 	"rok_tail" 		"rok_tail_06" 		"shooter_r06"}			
		{add_view 	"rok_tail" 		"rok_tail_07" 		"shooter_r07"}			
		{add_view 	"rok_tail" 		"rok_tail_08" 		"shooter_r08"}			
		{add_view 	"rok_tail" 		"rok_tail_09" 		"shooter_r09"}			
		{add_view 	"rok_tail" 		"rok_tail_10" 		"shooter_r10"}			
		{add_view 	"rok_tail" 		"rok_tail_11" 		"shooter_r11"}			
		{add_view 	"rok_tail" 		"rok_tail_12" 		"shooter_r12"}			
		{add_view 	"rok_tail" 		"rok_tail_13" 		"shooter_r13"}			
		{add_view 	"rok_tail" 		"rok_tail_14" 		"shooter_r14"}			
		{add_view 	"rok_tail" 		"rok_tail_15" 		"shooter_r15"}			
		{add_view 	"rok_tail" 		"rok_tail_16" 		"shooter_r16"}			
		{add_view 	"rok_tail" 		"rok_tail_17" 		"shooter_r17"}			
		{add_view 	"rok_tail" 		"rok_tail_18" 		"shooter_r18"}			
		{add_view 	"rok_tail" 		"rok_tail_19" 		"shooter_r19"}	                                                                                             			
		{add_view 	"rok_tail" 		"ShooterH_l00" 		"ShooterH_l00"}			
		{add_view 	"rok_tail" 		"ShooterH_l01" 		"ShooterH_l01"}			
		{add_view 	"rok_tail" 		"ShooterH_l02" 		"ShooterH_l02"}			
		{add_view 	"rok_tail" 		"ShooterH_l03" 		"ShooterH_l03"}			
		{add_view 	"rok_tail" 		"ShooterH_l04" 		"ShooterH_l04"}			
		{add_view 	"rok_tail" 		"ShooterH_r00" 		"ShooterH_r00"}			
		{add_view 	"rok_tail" 		"ShooterH_r01" 		"ShooterH_r01"}			
		{add_view 	"rok_tail" 		"ShooterH_r02" 		"ShooterH_r02"}			
		{add_view 	"rok_tail" 		"ShooterH_r03" 		"ShooterH_r03"}			
		{add_view 	"rok_tail" 		"ShooterH_r04" 		"ShooterH_r04"}		                                                                                             			
		{add_view 	"rok_tail" 		"tailL00" 		"tailL00"}			
		{add_view 	"rok_tail" 		"tailL01" 		"tailL01"}			
		{add_view 	"rok_tail" 		"tailL02" 		"tailL02"}			
		{add_view 	"rok_tail" 		"tailL03" 		"tailL03"}			
		{add_view 	"rok_tail" 		"tailL04" 		"tailL04"}			
		{add_view 	"rok_tail" 		"tailL05" 		"tailL05"}			
		{add_view 	"rok_tail" 		"tailR00" 		"tailR00"}			
		{add_view 	"rok_tail" 		"tailR01" 		"tailR01"}			
		{add_view 	"rok_tail" 		"tailR02" 		"tailR02"}			
		{add_view 	"rok_tail" 		"tailR03" 		"tailR03"}			
		{add_view 	"rok_tail" 		"tailR04" 		"tailR04"}			
		{add_view 	"rok_tail" 		"tailR05" 		"tailR05"}						
		{add_view 	"rok_tail" 		"TAil_iglaL00" 		"TAil_iglaL00"}			
		{add_view 	"rok_tail" 		"TAil_iglaL01" 		"TAil_iglaL01"}			
		{add_view 	"rok_tail" 		"TAil_iglaR00" 		"TAil_iglaR00"}			
		{add_view 	"rok_tail" 		"TAil_iglaR01" 		"TAil_iglaR01"}	                                                                                             			
		{add_view	"flash_cannon_big"		"flashbarrel2"			"Foresight2"}			
		{add_view	"flash_cannon_big"		"flashbarrel3"			"Foresight3"}				
		("link_damage_sound_rus")		    	
	}		
	{on "add_movement_sound" overload				
		{link_sound "fly"			"vehicle/helicopter/ka52_rotor"			}				
		{link_sound "engine_start"		"vehicle/helicopter/MI-8en_start"	}				
		{link_sound "engine_work"		"vehicle/helicopter/ka52_engine"	}				
		{link_sound "engine_stop"		"vehicle/helicopter/MI-8en_stop"	}		
	}		
	{on fire "nar1" overload			("low_speed_bullet")			
	(define "fire_barrel" name "%0"	{view start "tailL%0"}					
	{delay 0.42						{view pause "tailL%0"} }			
	)			
	{spawn "startsmoke" inv_normal}				
		{if    ("fire_barrel" args 00)				 
			else ("fire_barrel" args 01)				  
			else ("fire_barrel" args 02)				
			else ("fire_barrel" args 03)				  
			else ("fire_barrel" args 04)				
			else ("fire_barrel" args 05)				
			else ("fire_barrel" args 06)				
			else ("fire_barrel" args 07)				
			else ("fire_barrel" args 08)				
			else ("fire_barrel" args 09)				
			else ("fire_barrel" args 10)				
			else ("fire_barrel" args 11)					
			else ("fire_barrel" args 12)				
			else ("fire_barrel" args 13)				  
			else ("fire_barrel" args 14)				 
			else ("fire_barrel" args 15)				
			else ("fire_barrel" args 16)				
			else ("fire_barrel" args 17)				
			else ("fire_barrel" args 18)				
			else ("fire_barrel" args 19)				
		}			
		{if name "00" {call "fire_gun_common"}			}		
	}		
	{on fire "nar2" overload			
	 ("low_speed_bullet")			
	 	(define "fire_barrel" name "%0"					                  					
	 	{view start "tailR_%0"}					
	 	{delay 0.42	 {view pause "tailR_%0"}}			
	 	)			
	 	{spawn "startsmoke" inv_normal}				
	 		{if    ("fire_barrel" args 00)				 
	 			else ("fire_barrel" args 01)				  
	 			else ("fire_barrel" args 02)				
	 			else ("fire_barrel" args 03)				  
	 			else ("fire_barrel" args 04)				 
	 			else ("fire_barrel" args 05)				
	 			else ("fire_barrel" args 06)				
	 			else ("fire_barrel" args 07)				
	 			else ("fire_barrel" args 08)				
	 			else ("fire_barrel" args 09)				
	 			else ("fire_barrel" args 10)				
	 			else ("fire_barrel" args 11)					 
	 			else ("fire_barrel" args 12)				
	 			else ("fire_barrel" args 13)				  
	 			else ("fire_barrel" args 14)				
	 			else ("fire_barrel" args 15)				
	 			else ("fire_barrel" args 16)				
	 			else ("fire_barrel" args 17)				
	 			else ("fire_barrel" args 18)				
	 			else ("fire_barrel" args 19)											
	 		}			
	 	{if name "00"				
	 		{call "fire_gun_common"}			
	 	}		
	 }		
	{on fire "nar3" overload			
	 	("low_speed_bullet")			
	 		(define "fire_barrel" name "%0"					                  					
	 		{view start "shooter_%0"}					
	 		{delay 0.42						
	 		{view pause "shooter_%0"}}			
	 		)			
	 	{spawn "startsmoke" inv_normal}				
	 		{if    ("fire_barrel" args 00)				  
	 			else ("fire_barrel" args 01)				  
	 			else ("fire_barrel" args 02)				
	 			else ("fire_barrel" args 03)				  
	 			else ("fire_barrel" args 04)				 
	 			else ("fire_barrel" args 05)				
	 			else ("fire_barrel" args 06)				
	 			else ("fire_barrel" args 07)				
	 			else ("fire_barrel" args 08)				
	 			else ("fire_barrel" args 09)				
	 			else ("fire_barrel" args 10)				
	 			else ("fire_barrel" args 11)					 
	 			else ("fire_barrel" args 12)				
	 			else ("fire_barrel" args 13)				  
	 			else ("fire_barrel" args 14)				 
	 			else ("fire_barrel" args 15)				
	 			else ("fire_barrel" args 16)				
	 			else ("fire_barrel" args 17)				
	 			else ("fire_barrel" args 18)				
	 			else ("fire_barrel" args 19)				
	 		}			
	 	{if name "00"				
	 	{call "fire_gun_common"}			
	 	}		
	 }		                                                  		{on fire "ptur3" overload			("low_speed_bullet")			{spawn "proj_probe" "Foresight3" x  {tags add "Foresight3"}}			(define "fire_barrel"				name "%0"					{view start "tailL%0"}					{delay 0.42						{view pause "tailL%0"}					}			)				{spawn "startsmoke" inv_normal}				{if    ("fire_barrel" args 00)				  else ("fire_barrel" args 01)				  else ("fire_barrel" args 02)				  else ("fire_barrel" args 03)				  else ("fire_barrel" args 04)				  else ("fire_barrel" args 05)				}		}		{on fire "ptur4" overload			("low_speed_bullet")			{spawn "proj_probe" "Foresight2" x  {tags add "Foresight2"}}			(define "fire_barrel"				name "%0"					{view start "tailR%0"}					{delay 0.42						{view pause "tailR%0"}					}			)				{spawn "startsmoke" inv_normal}				{if    ("fire_barrel" args 00)				  else ("fire_barrel" args 01)				  else ("fire_barrel" args 02)				  else ("fire_barrel" args 03)				  else ("fire_barrel" args 04)				  else ("fire_barrel" args 05)				}		}		{on fire "ptur1" overload			("low_speed_bullet")			{delay 0.5 {spawn "vixr_carrier" "Foresight3"   x}}			(define "fire_barrel"				name "%0"					{view start "tailL%0"}					{delay 0.42						{view pause "tailL%0"}					}			)				{spawn "startsmoke" inv_normal}				{if    ("fire_barrel" args 00)				  else ("fire_barrel" args 01)				  else ("fire_barrel" args 02)				  else ("fire_barrel" args 03)				  else ("fire_barrel" args 04)				  else ("fire_barrel" args 05)				}		}		{on fire "ptur2" overload			("low_speed_bullet")			{delay 0.5 {spawn "vixr_carrier" "Foresight2"  x}}			(define "fire_barrel"				name "%0"					{view start "tailR%0"}					{delay 0.42						{view pause "tailR%0"}					}			)				{spawn "startsmoke" inv_normal}				{if    ("fire_barrel" args 00)				  else ("fire_barrel" args 01)				  else ("fire_barrel" args 02)				  else ("fire_barrel" args 03)				  else ("fire_barrel" args 04)				  else ("fire_barrel" args 05)				}		}		{on fire "ptur5" overload			{delay 0.1 {spawn "igla_s_carrier" "Foresight7"  x}}			(define "fire_barrel"				name "%0"					{view start "TAil_iglaL%0"}					{delay 0.42						{view pause "TAil_iglaL%0"}					}			)				{spawn "startsmoke" inv_normal}				{if    ("fire_barrel" args 00)				  else ("fire_barrel" args 01)				}		}		{on fire "ptur6" overload			{delay 0.1 {spawn "igla_s_carrier" "Foresight8"  x}}			(define "fire_barrel"				name "%0"					{view start "TAil_iglaR%0"}					{delay 0.42						{view pause "TAil_iglaR%0"}					}			)				{spawn "startsmoke" inv_normal}				{if    ("fire_barrel" args 00)				  else ("fire_barrel" args 01)				}		}		{on "tear_propeller_up1"			{spawn "propeller_hit2" "propeller1" x}			{spawn "propeller_hit2" "propeller1" x}			{spawn "propeller_hit2" "propeller1" x}			{bone cut "propeller1"}		}		{on "tear_propeller_down1"			{spawn "propeller_hit2" "propeller" x}			{spawn "propeller_hit2" "propeller" x}			{spawn "propeller_hit2" "propeller" x}			{bone cut "propeller"}		}		(define "vitebsk_work"		{if rand 1			                                         			                                         		    {delay 0.5				{spawn "proj_point_usa_ir"  "basis" x					{impulse up 0 10 rnd_dir 20 com}					{gravity 0.5}					{tags add "proj_vitebsk"}					 {kill_delay "normal_hide" }						 {delay 1.5 {delete}}				}							{spawn "proj_point_rus_ir"  "basis" x					{impulse up 0 10 rnd_dir 20 com}					{gravity 0.5}					 {kill_delay "normal_hide" }					    {delay 1.5 {delete}}				}			}		}		)		{on fire "soep1"			("vitebsk_work")			{view show "vitebsk1"}			{view start "vitebsk1"}			{delay 0.3				{view hide "vitebsk1"}			}		}		{on fire "soep2"			("vitebsk_work")			{view show "vitebsk2"}			{view start "vitebsk2"}			{delay 0.3				{view hide "vitebsk2"}			}		}		{on break			{if component "ir_active_def_2gen"				{weapon_work "soep1" 0}	{weapon_work "soep2" 0}			}		}		{on repair			{if component "ir_active_def_2gen"				{weapon_work "soep1" 1}	{weapon_work "soep2" 1}			}		}			{on "fall"			{call "eject_all"}		}		{on "eject_all"			(define "paradrop_crew_member_with_alt"	                                                                				{if rand 0.5 					{if rand 0.5 						{if rand 0.5 ("paradrop_crew_member_with_alt_r" args %0 0)						else ("paradrop_crew_member_with_alt_r" args %0 1)						}					else						{if rand 0.5 ("paradrop_crew_member_with_alt_r" args %0 2)						else ("paradrop_crew_member_with_alt_r" args %0 3)						}					}				else					{if rand 0.5 						{if rand 0.5 ("paradrop_crew_member_with_alt_r" args %0 4)						else ("paradrop_crew_member_with_alt_r" args %0 5)						}					else						{if rand 0.5 ("paradrop_crew_member_with_alt_r" args %0 6)						else ("paradrop_crew_member_with_alt_r" args %0 7)						}					}				}			)				(define "paradrop_crew_member_with_alt_r" 				{tags add "heli_paradrop%1"} 				{spawn "parachute_new"  "basis" x no_position					{tags add "heli_parashute%1"} 					{call "start_alt_%0"}				}			)			(define "eject_crewman"			{delay 0.3				{if not tagged "destroyed"					{link_sound "eject" "vehicle/airborne/eject/eject"}					{play_sound "eject"}					{ani_play "%fx_bone_name" callback}					{add_view	"eject"		"fx_%fx_bone_name" 		"fx_%fx_bone_name"}					{add_view	"proj_smoke"		"fx_%fx_bone_name"		"fx_%fx_bone_name"}					{view start "fx_%fx_bone_name"}					{delay 0.3 {view pause "fx_%fx_bone_name"}}				}			}			)			{volumes "fonar" disable contact} {delay 0.5 {volumes "fonar" enable contact}}			{delay 0.1 {tear "piece_big_airborne_wing" bone "fonar"	{impulse up 2 1 forward -5 1}}}			{delay 0.6 {tear "piece_big_airborne_wing" bone "fonar1"	{impulse up 2 1 forward -5 1}}}			("eject_crewman" fx_bone_name(eject))			{delay 0.6 ("eject_crewman" fx_bone_name(eject1))}			                                                                 			                                                 			                            			{add_view	"eject"		"fx_eject" 		"fx_ejecta"}			{add_view	"eject"		"fx_eject1" 		"fx_eject1a"}			{add_view	"proj_smoke"		"fx_eject" 		"fx_ejecta"}			{add_view	"proj_smoke"		"fx_eject1" 		"fx_eject1a"}			{tear "piece_big_airborne_wing" bone "blade1"	{impulse up 0 0.1 forward 10 1}}			{tear "piece_big_airborne_wing" bone "blade2"	{impulse up 0 0.1 forward 10 1}}			{tear "piece_big_airborne_wing" bone "blade3"	{impulse up 0 0.1 forward 10 1}}			{tear "piece_big_airborne_wing" bone "blade4"	{impulse up 0 0.1 forward 10 1}}			{tear "piece_big_airborne_wing" bone "blade5"	{impulse up 0 0.1 forward 10 1}}			{tear "piece_big_airborne_wing" bone "blade6"	{impulse up 0 0.1 forward 10 1}}			{delay 0.1 {spawn "glass_hit" "glass"}{spawn "glass_hit" "glass1"}{bone cut "glass"}{bone cut "glass1"}}											}		(define "eject_end"			{on animation_end "%fx_bone_name"			     {view pause "fx_%fx_bone_name"}	 		     {tear "piece_big_airborne_wing" bone "%eject_bone_name"	{impulse up 2 1 forward -1 1}}			     {if altitude 26			          {with_linked_entity "%crewman"				{delay 0.2 ("paradrop_crew_member_with_alt" args 5)}			          }			      else altitude 21			          {with_linked_entity "%crewman"				{delay 0.2 ("paradrop_crew_member_with_alt" args 4)}			          }			      else altitude 16			          {with_linked_entity "%crewman"				{delay 0.2 ("paradrop_crew_member_with_alt" args 3)}			          }			      else altitude 8			          {with_linked_entity "%crewman"				{delay 0.2 ("paradrop_crew_member_with_alt" args 2)}			          }			      else altitude 4			          {with_linked_entity "%crewman"				{delay 0.2 ("paradrop_crew_member_with_alt" args 1)}			          }			      else			      }			}		)			("eject_end" crewman(driver) fx_bone_name(eject) eject_bone_name(catapult))			("eject_end" crewman(driver1) fx_bone_name(eject1) eject_bone_name(catapult1))	}
{"metis_m_nov"		
	{on fire "gun2" 			
		{spawn "proj_probe" "Foresight1" x {tags add "Foresight1"}}		
	}		
	{on "cut_parts" overload			
		{add_view "smoke_dead_norm" "deathfx" "FXfire1"}			
		{view start "deathfx"}			(define "cut_part"				
		{tear "piece_medium_steel" bone %0					
			{impulse up 1 1 dir 5 2 cx 5 2 cy 5 2 rnd_dir 5 no_position}					
			{call "check_delete_part"}				
		}			)			
	("cut_part" args "part1")			
	("cut_part" args "part2")			
	("cut_part" args "part3")			
	{delay 14 {view stop "deathfx"}}		
	}	
}
{"metis_m_ukr"		
	{on fire "gun2" 			
		{spawn "proj_probe" "Foresight1" x {tags add "Foresight1"}}		
	}		
	{on "cut_parts" overload			
		{add_view "smoke_dead_norm" "deathfx" "FXfire1"}			
		{view start "deathfx"}			(define "cut_part"				
		{tear "piece_medium_steel" bone %0					
			{impulse up 1 1 dir 5 2 cx 5 2 cy 5 2 rnd_dir 5 no_position}					
			{call "check_delete_part"}				
		}			)			
	("cut_part" args "part1")			
	("cut_part" args "part2")			
	("cut_part" args "part3")			
	{delay 14 {view stop "deathfx"}}		
	}	
}



{"su24_x59"
("air_multibarrel_launcher" weapon(ptur4) shooter(Shooter_x59_) missile(x59m) flashbarrel(Shooter_x59_))				
}	
{"su24_x31"
("air_multibarrel_launcher" weapon(ptur4) shooter(Shooter_r31_) missile(x31p) flashbarrel(Shooter_r31_))			
}	
{"su24_x25"
("air_multibarrel_launcher" weapon(ptur) shooter(shooter_) missile(x_25ml_su25_ammo) flashbarrel(shooter_))				
}
{"su24_agm88"
("air_multibarrel_launcher" weapon(ptur4) shooter(AGM-86-88_shooter_) missile(agm88) flashbarrel(AGM-86-88_shooter_))			
}
{"mig29_agm88"
("air_multibarrel_launcher" weapon(ptur4) shooter(AGM-86-88_shooter_) missile(agm88) flashbarrel(AGM-86-88_shooter_))			
}


{"su24_storm"
("air_multibarrel_launcher" weapon(ptur4) shooter(storm_shooter_) missile(storm) flashbarrel(storm_shooter_))			
}

{"tu22m3"
("air_multibarrel_launcher" weapon(ptur4) shooter(x32_shooter_) missile(x32) flashbarrel(x32_shooter_))			
}

{"mig31_kh47m2"        
  {on fire "ptur4"               
	{delay 0.1 
 	 	{spawn "kh47m2_carrier" "shooter_00"   x}
  	}                     
  }      
 }


{"osa_akm"
  	
	{on spawn			
	{add_view	 "flash_gun_big"	"shooter00"	"shooter00"}			
	{add_view	 "flash_gun_big"	"shooter01"	"shooter01"}
	{add_view	 "flash_gun_big"	"shooter02"	"shooter02"}			
	{add_view	 "flash_gun_big"	"shooter03"	"shooter03"}
	{add_view	 "flash_gun_big"	"shooter04"	"shooter04"}	{add_view	 "flash_gun_big"	"shooter05"	"shooter05"}	
	{add_view	 "startsmoke_big"	"shooter00"	"shooter00"}			
	{add_view	 "startsmoke_big"	"shooter01"	"shooter01"}
	{add_view	 "startsmoke_big"	"shooter02"	"shooter02"}			
	{add_view	 "startsmoke_big"	"shooter03"	"shooter03"}	
	{add_view	 "startsmoke_big"	"shooter04"	"shooter04"}
	{add_view	 "startsmoke_big"	"shooter05"	"shooter05"}
	}		
	{on fire "gun" 			
	(define "fire_barrel"				name "%0"					
	{delay 0.1 
	{spawn "osa_missile_carrier" "shooter%0"   x}
	}					
	{ani_play "fire"}					
	{view start "shooter%0"}					
	{delay 0.42						{view pause "shooter%0"}					
	}			
	)				
	{if    ("fire_barrel" args 00)				  else ("fire_barrel" args 01)				  else ("fire_barrel" args 02)				  else ("fire_barrel" args 03)				  else ("fire_barrel" args 04)				  else ("fire_barrel" args 05)				
	}		
	}	
}



{"stugna-p"		
	{on fire "gun2" 			
		{spawn "proj_probe" "Foresight1" x {tags add "Foresight1"}}		
	}		
	{on "cut_parts" overload			
		{add_view "smoke_dead_norm" "deathfx" "FXfire1"}			
		{view start "deathfx"}			
			(define "cut_part"				
				{tear "piece_medium_steel" bone %0					
					{impulse up 1 1 dir 5 2 cx 5 2 cy 5 2 rnd_dir 5 no_position}					
					{call "check_delete_part"}				
				}			
			)			
		("cut_part" args "part1")			
		("cut_part" args "part2")			
		("cut_part" args "part3")			
		("cut_part" args "part5")			
		("cut_part" args "gun")			
		("cut_part" args "turret")			
		{delay 14 {view stop "deathfx"}}		
	}		
}
{"bmd1_ukr"		
	("bmd")		
	("73mm_2a28_grom")		
	("atgm_single_launcher" weapon(gun2) foresight(foresight6) tail(tail))	
}
{"bmd2_ukr"		
	("bmd")		
	("30mm_2a42")		
	("atgm_single_launcher" weapon(gun2) foresight(foresight6) tail(tail))	
}




{"fp5_trailer"		
	{on fire "gun" 
		(define "fire_barrel"				name "%0"					
		{delay 0.1 
			{spawn "fp5_carrier" "shooter%0"   x}
		}					
	{ani_play "fire"}					
	{view start "shooter%0"}					
	{delay 0.42					
	{view pause "shooter%0"}					
	}			
	)				
	{if    ("fire_barrel" args 00)			
	  else ("fire_barrel" args 01)			
	  else ("fire_barrel" args 02)				 			
	}		
	}			
}	



{"mi-24p"		
	{on fire "ptur1" overload	("low_speed_bullet")	{spawn "proj_probe" "Foresight3" x  {tags add "Foresight3"}}			
		(define "fire_barrel"	name "%0"				
		{view start "ptur1tail_%0"}					
		{delay 0.42						
		{view pause "ptur1tail_%0"}					
		}			
		)				
		{spawn "startsmoke" inv_normal}				
			{if    ("fire_barrel" args 00)				  
				else ("fire_barrel" args 01)				
			}		
	}		
	{on fire "ptur2" overload			
		("low_speed_bullet")			
		{spawn "proj_probe" "Foresight4" x  {tags add "Foresight4"}}			
		(define "fire_barrel" name "%0"					
		{view start "ptur2tail_%0"}					
		{delay 0.42						
		{view pause "ptur2tail_%0"}					
		}			
		)				
		{spawn "startsmoke" inv_normal}				
		{if    ("fire_barrel" args 00)				  
			else ("fire_barrel" args 01)				
		}		
	}	
}

{"brdm2_strela_ukr"		
	("brdm_sound")			
	{on ik begin "turret" {play_sound "rotate_turret" 1}}		
	{on ik end "turret" {stop_sound "rotate_turret"}}		
	{on fire "gun2" 			("low_speed_bullet")			
		{if name "00"	{delay 0.1 {spawn "9k31_carrier" "shooter00"   x}
		{spawn "startsmoke" "shooter00" x}}			
		else name "01"
		{delay 0.1 {spawn "9k31_carrier" "shooter01"   x}
		{spawn "startsmoke" "shooter01" x}}			
			else name "02"	{delay 0.1 {spawn "9k31_carrier" "shooter02"   x}{spawn "startsmoke" "shooter02" x}}			
			else name "03"	{delay 0.1 {spawn "9k31_carrier" "shooter03"   x}{spawn "startsmoke" "shooter03" x}}			
		}			
		{ani_play "fire"}		
	}		
	{on bullet_hit			
	{if volume "glass" {call "break_glass"}}		
	}		
	{on "break_glass"			
		{volumes "glass" disable bullet contact}		 	
		{spawn "glass_hit2" "glass" x}		 	
		{delay 0.1 {bone cut "glass"}}		
	}	
}



{"stugna_neu"
	
	("atgm_multi_launcher"
 		weapon(ptur)
 		foresight(foresight4)
 		tail(foresight4)
	)
}

{"dagr"
	("atgm_multi_launcher"
 		weapon(nar1)
 		foresight(foresight5)
 		tail(foresight5)
	)
}


{"tochka"
	{on fire "rock"
		{spawn "startsmoke_big"}
		{spawn "dust_shot_big_2" "basis"}
		{ani_play "fire"}
		{view start "flashbarrel_gun"}
		{view start "smoke_add"}
		{delay 0.16 "shell_off"
			{view pause "smoke_add"}
			{view pause "flashbarrel_gun"}
		}
		{spawn "startsmoke_otrk"}
		(define "fire_barrel" name "%0"
			{view start "rok_tail%0"}
			{delay 0.42
				{view pause "rok_tail%0"}
			}
		)
		{if
			("fire_barrel" args 00)
			else ("fire_barrel" args 01)
			else ("fire_barrel" args 02)
			else ("fire_barrel" args 03)
			else ("fire_barrel" args 04)
			else ("fire_barrel" args 05)
			else ("fire_barrel" args 06)
			else ("fire_barrel" args 07)
			else ("fire_barrel" args 08)
			else ("fire_barrel" args 09)
			else ("fire_barrel" args 10)
			else ("fire_barrel" args 11)
			else ("fire_barrel" args 12)
			else ("fire_barrel" args 13)
			else ("fire_barrel" args 14)
			else ("fire_barrel" args 15)
			else ("fire_barrel" args 16)
			else ("fire_barrel" args 17)
			else ("fire_barrel" args 18)
			else ("fire_barrel" args 19)
		}
	}
}



{"gyurza-m"	                                             		
	{on "break_and_sink"			
		{if not work "body1"			   
			{if rand 0.5				
				{ani_play "break_nose" 0.03 callback}				
				{delay 2 {call "break_nose"}}			   
			}			
		}						
		{if work "body1"				
			{delay 10 2 {call "sink_ballast"}}				
		}			
			{components break}		
	}		
	{on "break_nose"						
		("break_delete_linked" name(gun1) delay(0))	
		("sink_effect" effsize(big) bone(02) delay(0))			
		{delay 4 2 {volumes "ballast1" disable float} {impulse up 0.1}}			
		{delay 4 2 {volumes "ballast2" disable float} {impulse up 0.1}}			
		{delay 0.5				
			{if not tagged "no_hull_cut"					
					{tear "ship_part" bone "body1"						
						{impulse up -1 dir 1 1 cx 1 1 cy 1 1 rnd_dir 2 no_position}						
						{volumes disable float}					
					}				
			}			
		}		
	}			
	{on animation_end "sink"			
		{view pause "on_stead"}			
		{view pause "on_move"}			
		{call "stop_sink_sound"}		
	}		
	{on "sink_sequence"			
		{delay 15 ("cut_part_big" args machta)}						
		("break_linked" name(gun) delay(20 15))			
		("break_linked" name(gun1) delay(20 15))	
	}		
	{on break			
		{if component "body1"							
			("break_effect" effsize(big) bone(01) delay(0))		
			("break_linked" name(gun) delay(15 7))	
			else component "body"				
				("break_effect" effsize(norm) bone(01) delay(0))				
				("break_effect" effsize(norm) bone(02) delay(0))			
				("break_linked" name(gun) delay(15 7))	
		}		
	}
}	

{"2s7_pion"	  
	("Shilka_sound")	

	{on fire "gun" 
	     		{spawn "dust_shot_big_2" "basis"}
			{ani_play "fire"}
			{view start "flashbarrel_gun"}
			{view start "spawn_shell"}
	{delay 1
			{ani_play "reload"}}

	}	
}
{"i_hawk"	  
	
	{on spawn			
	{add_view	 "flash_gun_big"	"shooter00"	"shooter00"}	{add_view	 "flash_gun_big"	"shooter01"	"shooter01"}
	{add_view	 "flash_gun_big"	"shooter02"	"shooter02"}

	{add_view	 "startsmoke_big"	"shooter00"	"shooter00"}			
	{add_view	 "startsmoke_big"	"shooter01"	"shooter01"}
	{add_view	 "startsmoke_big"	"shooter02"	"shooter02"}			 	
	}		
	{on fire "ptur" 
			
	(define "fire_barrel"				name "%0"					
	{delay 0.1 
	{spawn "mim23k_carrier" "shooter%0"   x}
	}					
	{ani_play "fire"}					
	{view start "shooter%0"}					
	{delay 0.42					
	{view pause "shooter%0"}					
	}			
	)				
	{if    ("fire_barrel" args 00)			
	  else ("fire_barrel" args 01)			
	  else ("fire_barrel" args 02)				 			
	}		
	}	
	}

	

{"mpq64_radar"

	("radar_params" triplex(additional_triplex) visor(visor_radar) anim_rotate(radar) marker(antirad_generator_large_usa))

	{on spawn {delay 0.1 {call "check_unlink"}}}			
	{on "check_unlink"			
	{delay 1				       
	{if linked  
	{call "cwsh_radar_off"}				   
	
	else 
	{if not tagged "cwsh_passive" 
	{if tagged "radar_off"{call "cwsh_radar_on"}}}}			{call "check_unlink"}			}		}		
	{on "_explosion"			{impulse up 0.1}	
	}
	}	


	
{"harpoon_launcher"	
	{on spawn			
	{add_view	 "flash_gun_big"	"shooter00"	"shooter00"}			
	{add_view	 "flash_gun_big"	"shooter01"	"shooter01"}
	{add_view	 "flash_gun_big"	"shooter02"	"shooter02"}			
	{add_view	 "flash_gun_big"	"shooter03"	"shooter03"}
	
	{add_view	 "startsmoke_big"	"shooter00"	"shooter00"}			
	{add_view	 "startsmoke_big"	"shooter01"	"shooter01"}
	{add_view	 "startsmoke_big"	"shooter02"	"shooter02"}			
	{add_view	 "startsmoke_big"	"shooter03"	"shooter03"}	
	}		
	{on fire "ptur" 			
	(define "fire_barrel"				name "%0"					
	{delay 0.1 
	{spawn "agm-84d_carrier" "shooter%0"   x}
	}					
	{ani_play "fire"}					
	{view start "shooter%0"}					
	{delay 0.42						{view pause "shooter%0"}					
	}			
	)				
	{if    ("fire_barrel" args 00)				  else ("fire_barrel" args 01)				  else ("fire_barrel" args 02)				  else ("fire_barrel" args 03)				 			
	}		
	}	
}
{"9k33_osa_akm"		
	("btr80_sound")	  

	("radar_lifting90_params" triplex(additional_triplex) visor(visor_radar) anim_rotate(radar_loop) anim_lift(radar_lift) marker(antirad_generator_rus))	

	{on spawn	
		{add_view	 "startsmoke_big"	"shooter00"	"tail00"}			
		{add_view	 "startsmoke_big"	"shooter01"	"tail01"}			
		{add_view	 "startsmoke_big"	"shooter02"	"tail02"}		
		{add_view	 "startsmoke_big"	"shooter03"	"tail03"}		
		{add_view	 "startsmoke_big"	"shooter04"	"tail04"}		
		{add_view	 "startsmoke_big"	"shooter05"	"tail05"}			
	}
		
	{on fire "gun2" 			
	(define "fire_barrel"				name "%0"					
	{delay 0.1 
	{spawn "9m33_missile_carrier" "shooter%0"   x}
	}					
	{ani_play "fire"}					
	{view start "shooter%0"}					
	{delay 0.42						{view pause "shooter%0"}					
	}			
	)				
	{if    ("fire_barrel" args 00)				  else ("fire_barrel" args 01)				  else ("fire_barrel" args 02)				  else ("fire_barrel" args 03)				  else ("fire_barrel" args 04)				  else ("fire_barrel" args 05)		
		}		
	}			
}
{"bastion_p"
			
	(define "fire_barrel"	
			
	{delay 0.1 				
	{delay 0.15 
	{spawn "startsmoke_cali" "tail_0%shooter" x}
	}				
	{delay 0.50 
	{spawn "startsmoke_cali" "tail_0%shooter" x}
	}
	{delay 0.60 
	{add_view	 "proj_jet_sam"	"exh_0%shooter" "tail_0%shooter"}
	{view start "exh_0%shooter"}
	}				
	{delay 1.05 

	{view pause "exh_0%shooter"}
	{view hide"exh_0%shooter"}	
					
	{bone hide "missile_0%shooter"}					
	{spawn "p800_carrier" "shooter_0%shooter"   x 
	{spawn "startsmoke" "medium_tail" x}
	}				
	}				
	{delay 1.1					
	{ani_play "fire_restore"}				
	}			
	}			
	{bone show "missile_0%shooter"}			
	{ani_play "fire"}		
	)	
	{on fire "ptur" 				
				
	{if name "00" ("fire_barrel" shooter(00))			else name "01" ("fire_barrel" shooter(01))				
	}
	}			
}


{"club_m"
			
	(define "fire_barrel"	
			
	{delay 0.1 				
	{delay 0.15 
	{spawn "startsmoke_cali" "tail_0%shooter" x}
	}				
	{delay 0.50 
	{spawn "startsmoke_cali" "tail_0%shooter" x}
	}
	{delay 0.55
	{add_view	 "proj_jet_sam"	"exh_0%shooter" "tail_0%shooter"}
	{view start "exh_0%shooter"}
	}		
	{delay 2.05 

	{view pause "exh_0%shooter"}
	{view hide"exh_0%shooter"}	
					
	{bone hide "missile_0%shooter"}					
	{spawn "3m14_carrier" "shooter_0%shooter"   x 
	{spawn "startsmoke" "medium_tail" x}
	}				
	}				
	{delay 2.1					
	{ani_play "fire_restore"}				
	}			
	}			
	{bone show "missile_0%shooter"}			
	{ani_play "fire"}		
	)	
	{on fire "ptur1" 				
				
	{if name "00" ("fire_barrel" shooter(00))			else name "01" ("fire_barrel" shooter(01))			else name "02" ("fire_barrel" shooter(02))			else name "03" ("fire_barrel" shooter(03))				
	}
	}			
}

{"pu_singl"
	("atgm_single_launcher" weapon(gun) foresight(foresight1) tail(tail))			
}



	

{"3m14"					
	{on "add_movement_sound" overload
	{link_sound "engine_work"		"vehicle/airborne/jet_fly"}											
	}
}

{"kamaz_hj400"
	{on spawn			
 		{Volumes "ammo_storage_main" enable contact bullet blast}			
 		{Volumes "ammo_storage_main1" enable contact bullet blast}			
 		{set "radar_up" 0}		
 	}		
 	("9k72_sound")	   
 	{on fire "gun2" 	      		
 		{spawn "dust_shot_big_3" "basis"}	      		
 		{spawn "dust_shot_big_3" "FXtraceL4"}	      		
 		{spawn "dust_shot_big_3" "FXtraceR4"}			
 		{if not "radar_up"				
 			{Volumes "ammo_storage_main" disable contact bullet blast}				
 			{set "radar_up" 1}	      		
 			{spawn "startsmoke_otrk" "rocket000"}			
 				else				
 				{Volumes "ammo_storage_main1" disable contact bullet blast}				
 				{set "radar_up" 0}	      		
 				{spawn "startsmoke_otrk" "rocket001"}				
 				{delay 300 					
 					{Volumes "ammo_storage_main" enable contact bullet blast}					
 					{Volumes "ammo_storage_main1" enable contact bullet blast}				
 				}			
 			}
 		{if rand 0.005
			{Spawn "cw_explosion_1000kg"}
		}				
 	}		
 		{on break_armor			
 			{if volume "cabin" {components "cabin" break} 			
 				else volume "cabin_back" {components "cabin_back" break} 			
 			}		
 		}		
 		{on pierce			
 			{if component "ammo_storage_main"				
 			{spawn "ex_anti_size5" "Gun_rot"}				
 			{spawn "hj400_ammo" "basis" x {stuff_detonate}}				
 			{call "_explosion"}			
 			}		
 		}		
 		{on bullet_hit			
 			(define "check_break_glass"			     
 				else volume "glass%0"				
 				{volumes "glass%0" disable bullet contact blast}		 		
 				{spawn "glass_hit2" "glass%0" x}		 		
 				{delay 0.1				 	
 				{bone cut "glass%0"}		 		
 				}			
 			)			
 			{if stuff "radar_ammo"	                                         			
 				else stuff "laser_ammo"			
 				else stuff "rus_IR_ff_beam ammo"			
 				else stuff "usa_IR_ff_beam ammo"			
 				else stuff "IR_ff_ammo"			
 				("check_break_glass" args 1)			
 				("check_break_glass" args 2)			
 				("check_break_glass" args 3)			
 				("check_break_glass" args 4)			
 				("check_break_glass" args 5)			
 				("check_break_glass" args 6)			
 				("check_break_glass" args 7)			
 			}		
 		}		
 		{on break 			
	 		{if component "cabin"  
	 			{spawn "tank_die_particle" "cabin"}			
	 				else component "cabin_back" {spawn "tank_die_particle" "Engine"}			
	 		}		
 		}		
 		{on repair 			
 			{if component "cabin"			else component "cabin_back"			}		
 		}		
 		{on "update_lights"			
 			{if rain {ani_play "rain" loop} else {ani_stop "rain"}}		
 		}		
 		{on "explosion"			
 			{set "big_explosion" 0}			
 			{if explosive_amount 50				
	 			{blastwave c4 25 r0 15 r1 35}				
	 			{spawn "train_die" "basis"}				
	 			{set "big_explosion" 1}				
	 			{con "big explosive"}			
 			}		
 		}
}
{"grom2"
	{on spawn			
 		{Volumes "ammo_storage_main" enable contact bullet blast}			
 		{Volumes "ammo_storage_main1" enable contact bullet blast}			
 		{set "radar_up" 0}		
 	}		
 	("9k72_sound")	   
 	{on fire "gun2" 	      		
 		{spawn "dust_shot_big_3" "basis"}	      		
 		{spawn "dust_shot_big_3" "FXtraceL4"}	      		
 		{spawn "dust_shot_big_3" "FXtraceR4"}			
 		{if not "radar_up"				
 			{Volumes "ammo_storage_main" disable contact bullet blast}				
 			{set "radar_up" 1}	      		
 			{spawn "startsmoke_otrk" "rocket000"}			
 				else				
 				{Volumes "ammo_storage_main1" disable contact bullet blast}				
 				{set "radar_up" 0}	      		
 				{spawn "startsmoke_otrk" "rocket001"}				
 				{delay 300 					
 					{Volumes "ammo_storage_main" enable contact bullet blast}					
 					{Volumes "ammo_storage_main1" enable contact bullet blast}				
 				}			
 			}
 		{if rand 0.005
			{Spawn "cw_explosion_1000kg"}
		}				
 	}		
 		{on break_armor			
 			{if volume "cabin" {components "cabin" break} 			
 				else volume "cabin_back" {components "cabin_back" break} 			
 			}		
 		}		
 		{on pierce			
 			{if component "ammo_storage_main"				
 			{spawn "ex_anti_size5" "Gun_rot"}				
 			{spawn "hj400_ammo" "basis" x {stuff_detonate}}				
 			{call "_explosion"}			
 			}		
 		}		
 		{on bullet_hit			
 			(define "check_break_glass"			     
 				else volume "glass%0"				
 				{volumes "glass%0" disable bullet contact blast}		 		
 				{spawn "glass_hit2" "glass%0" x}		 		
 				{delay 0.1				 	
 				{bone cut "glass%0"}		 		
 				}			
 			)			
 			{if stuff "radar_ammo"	                                         			
 				else stuff "laser_ammo"			
 				else stuff "rus_IR_ff_beam ammo"			
 				else stuff "usa_IR_ff_beam ammo"			
 				else stuff "IR_ff_ammo"			
 				("check_break_glass" args 1)			
 				("check_break_glass" args 2)			
 				("check_break_glass" args 3)			
 				("check_break_glass" args 4)			
 				("check_break_glass" args 5)			
 				("check_break_glass" args 6)			
 				("check_break_glass" args 7)			
 			}		
 		}		
 		{on break 			
	 		{if component "cabin"  
	 			{spawn "tank_die_particle" "cabin"}			
	 				else component "cabin_back" {spawn "tank_die_particle" "Engine"}			
	 		}		
 		}		
 		{on repair 			
 			{if component "cabin"			else component "cabin_back"			}		
 		}		
 		{on "update_lights"			
 			{if rain {ani_play "rain" loop} else {ani_stop "rain"}}		
 		}		
 		{on "explosion"			
 			{set "big_explosion" 0}			
 			{if explosive_amount 50				
	 			{blastwave c4 25 r0 15 r1 35}				
	 			{spawn "train_die" "basis"}				
	 			{set "big_explosion" 1}				
	 			{con "big explosive"}			
 			}		
 		}
}
;==============================kamikadze=========
{"kamikadze_1000"
	{on fire "charge" 	      		
 		{delay 2.5				 	
 			{Spawn "cw_explosion_1000kg"}		 		
 		}				
 	}
}

{"kamikadze_250"
	{on fire "charge" 	      		
 		{delay 2.5				 	
 			{Spawn "cw_explosion_200kg"}		 		
 		}				
 	}
}

{"nokia3310 weapon"
	{on fire	      		
 		{delay 0.1				 	
 			{spawn "cw_explosion_200kg"}
 		
 		}				
 	}
}

;===============DRONE===========================
{"switchblade600"		
	{on "add_movement_sound" overload			
		{link_sound "engine_start"		"vehicle/airborne/small_UAV/small_UAV_start"			}			
		{link_sound "engine_work"		"vehicle/airborne/small_UAV/small_UAV_work"			}			
		{link_sound "engine_stop"		"vehicle/airborne/small_UAV/small_UAV_stop"			}		
	}		
		{on "link_flare_fx" overload}		
		{on "landing"			
			{ani_stop "ols_work"}			
			{bone show "parashute"}			
			{bone hide "cover"}			
			{call "engine_stop"}			
			{drop_orders}			
			{reset_manual_control}			
			{able select 0}			
			{able repaired 0}			
			{if not work "wheel_front"			    
				{call "fall"}			
			}			
			{delay 15				
				{if chassis "airborne"					 
				{call "fall"}				
				}			
			}		
		}		
		{on "engine_on"			
			{if not "engine_started"				
				{set "engine_started" 1}				
				{play_sound "engine_start"}				
				{ani_play "engine_start" callback}			
			}		
		}		
		{on animation_end "engine_start"			
			{ani_play "engine_work" loop}			
			{play_sound "engine_work" 1}			
			{ani_play "ols_work" 0.3 loop}		
		}		
		{on engine off			
			{call "engine_stop"}			
			{play_sound "engine_stop"}			
			{if not chassis "airborne"				
			{spawn "switchblade600_ammo" "basis" x {impulse forward 3}}				
			{delete}			
			}		
		}		
	{on "engine_stop"			
		{kill_delay "engine_stopped"}			
			{if "engine_started"				
				{set "engine_started" 0}				
				{ani_stop "engine_start"}				
				{ani_stop "engine_work"}				
				{ani_play "engine_stop"}				
				{stop_sound "engine_start"}				
				{stop_sound "engine_work"}				
				{stop_sound "fly"}			
		}		
	}		                                                                           		                        	
	("loitering_munition" missilename(switchblade600))	
}	
{"switchblade600_catapult" 		
	{on spawn 		{tags add "cannon_proj"}		}		
	{on fire "gun" overload			
	{ani_play "fire" callback}			
	("cw_check_shooting" weap_id(gun))		}		
	{on animation_end "fire"			
	{spawn "switchblade600" "foresight1" x}		
	}	
}
{"fpv_drone"		
	{on "add_movement_sound" overload			
		{link_sound "engine_start"		"vehicle/airborne/small_UAV/small_UAV_start"		}			
		{link_sound "engine_work"		"vehicle/airborne/small_UAV/small_UAV_work"			}			
		{link_sound "engine_stop"		"vehicle/airborne/small_UAV/small_UAV_stop"			}		
	}		
	{on "link_flare_fx" overload}		
	{on "engine_on"			
		{if not "engine_started"				
			{set "engine_started" 1}				
			{play_sound "engine_start"}				
			{ani_play "engine_start" callback}			
		}		
	}		
	{on animation_end "engine_start"			
		{ani_play "engine_work" loop}			
		{play_sound "engine_work" 1}		
	}		                                                                           		                        		
	("loitering_munition" missilename(fpv_drone))	
}
{"fpv_drone"

	{on "specability"
		{if chassis "wheel"		
			{spawn "fpv_drone_ammo" "basis" x}
			{delete}
		}
	}
	{on "add_movement_sound" overload			
	{link_sound "engine_start"		"vehicle/airborne/small_UAV/small_UAV_start"}			
	{link_sound "engine_work"		"vehicle/airborne/small_UAV/small_UAV_work"}			
	{link_sound "engine_stop"		"vehicle/airborne/small_UAV/small_UAV_stop"	}	
				
	}				
}
{"fpv_drone120"		
	{on "add_movement_sound" overload			
		{link_sound "engine_start"		"vehicle/airborne/small_UAV/small_UAV_start"		}			
		{link_sound "engine_work"		"vehicle/airborne/small_UAV/small_UAV_work"			}			
		{link_sound "engine_stop"		"vehicle/airborne/small_UAV/small_UAV_stop"			}		
	}		
	{on "link_flare_fx" overload}		
	{on "engine_on"			
		{if not "engine_started"				
			{set "engine_started" 1}				
			{play_sound "engine_start"}				
			{ani_play "engine_start" callback}			
		}		
	}		
	{on animation_end "engine_start"			
		{ani_play "engine_work" loop}			
		{play_sound "engine_work" 1}		
	}		                                                                           		                        		
	("loitering_munition" missilename(fpv_drone120))	
}

{"cvadropoter"

{on "specability"
	{if chassis "wheel"		
		{spawn "cvadropoter_ammo" "basis" x}
		{delete}
	}
}

{on "add_movement_sound" overload			
{link_sound "engine_start"		"vehicle/airborne/small_UAV/small_UAV_start"	
}			
{link_sound "engine_work"		"vehicle/airborne/small_UAV/small_UAV_work"			
}			
{link_sound "engine_stop"		"vehicle/airborne/small_UAV/small_UAV_stop"			
}	
			
}					
}

{"fpv_drone_b_ammo"			{on "change"			{spawn "fpv_drone_ammo" "root" x}										{delete}		}	}	
{"fpv_drone_ammo"			{on "onThrow"	        {spawn "fpv_drone" 		"root" dir_velocity no_normal}					{delete}	    }	}	
{"fpv_drone120_b_ammo"		{on "change"			{spawn "fpv_drone120_ammo" "root" x}									{delete}		}	}	
{"fpv_drone120_ammo"		{on "onThrow"	        {spawn "fpv_drone120" "root" dir_velocity no_normal}					{delete}	    }	}	
{"cvadropoter_b_ammo"		{on "change"			{spawn "cvadropoter_ammo" "root" x}										{delete}		}	}	
{"cvadropoter_ammo"			{on "onThrow"	        {spawn "cvadropoter" "root" dir_velocity no_normal} 					{delete}	    }	}
{"magura"
{on fire "charge"
	{call "explosion"}
}
}

{"x101"			                                            		
	
	{on "add_movement_sound" overload			
	{link_sound "engine_start"		"vehicle/engine/testx101"	
	}			
	{link_sound "engine_work"		"vehicle/engine/testx101"		
	}			
	{link_sound "engine_stop"		"vehicle/engine/testx101"		
	}	
				
	}
			
	
	("loitering_munition" missilename(x101))		
	(define "cut_part"			
	{tear "piece_medium_steel" bone %0				
		{impulse up 8 1 dir 5 2 cx 5 2 cy 5 2 rnd_dir 10 no_position}				
		{call "check_delete_part"}			
	}	
	)		
	{on "detonate" overload			
	{if rand 0.3 ("cut_part" args "part1")}			
	{if rand 0.3 ("cut_part" args "tail1")}			
	{if rand 0.3 ("cut_part" args "tail2")}		   
	{inherited}			
	{stuff_detonate}		
	}		
	{on "underground_detonate" overload			
	{if rand 0.3 ("cut_part" args "part1")}			
	{if rand 0.3 ("cut_part" args "tail1")}			
	{if rand 0.3 ("cut_part" args "tail2")}		   
	{inherited}			
	{stuff_detonate}		
	}	
}




;===================================texmod==================

{"wagner_mp_flag"
	{On spawn
		{Delay 0.2
			{tex_mod "wagner"}
		}
	}
}
{"naem_mp_flag"
	{On spawn
		{Delay 0.2
			{tex_mod "wagner"}
		}
	}
}

{"artbrw_mp_flag"
	{On spawn
		{Delay 0.2
			{tex_mod "wagner"}
		}
	}
}

{"pvow_mp_flag"
	{On spawn
		{Delay 0.2
			{tex_mod "wagner"}
		}
	}
}

{"vvsw_mp_flag"
	{On spawn
		{Delay 0.2
			{tex_mod "wagner"}
		}
	}
}

{"su24m"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr_pix"}
		}
	}
}
{"su24_agm88"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr_pix"}
		}
	}
}
{"su24m_kab"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr_pix"}
		}
	}
}
{"su24m_jdam"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr_pix"}
		}
	}
}
{"su24m_strike"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr_pix"}
		}
	}
}
{"su24m_storm"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr_pix"}
		}
	}
}
{"mig-29s_aa_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "ukraine"}
		}
	}
}
{"mig-29s_harm"
	{On spawn
		{Delay 0.2
			{tex_mod "ukraine"}
		}
	}
}

{"mig-29s_bb_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "ukraine"}
		}
	}
}

{"bayraktar_tb2"
	{On spawn
		{Delay 0.2
			{tex_mod "vsu2"}
		}
	}
}
{"bayraktar_tb2_mamc"
	{On spawn
		{Delay 0.2
			{tex_mod "vsu2"}
		}
	}
}
{"bayraktar_tb2_maml"
	{On spawn
		{Delay 0.2
			{tex_mod "vsu2"}
		}
	}
}
{"mi17_unarmed_urk"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr"}
		}
	}
}
{"2s7_pion_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr_pix"}
		}
	}
}
{"msta_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr_2"}
		}
	}
}
{"2c3"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr6"}
		}
	}
}
{"ural_grad_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr_pix"}
		}
	}
}
{"su-25sm_accurate_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr_pics"}
		}
	}
}
{"su-25sm_strike_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr_pics"}
		}
	}
}
{"su-25sm_support_lighti_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr_pics"}
		}
	}
}
{"su-25sm_miner_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr_pics"}
		}
	}
}
{"su27"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr1"}
		}
	}
}

{"vvc_ukr_mp_flag"
	{On spawn
		{Delay 0.2
			{tex_mod "vvc"}
		}
	}
}

{"ukr_aa_aa_mp_flag"
	{On spawn
		{Delay 0.2
			{tex_mod "specb_ukr"}
		}
	}
}

{"mi-24p_2"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr1"}
		}
	}
}
{"mi-24p_3"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr1"}
		}
	}
}
{"mi-24v_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr1"}
		}
	}
}

{"il-76td_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr"}
		}
	}
}
{"ahs_krab"
	{On spawn
		{Delay 0.2
			{tex_mod "pix"}
		}
	}
}
{"m2a3_brat"
	{On spawn
		{Delay 0.2
			{tex_mod "ua_dirt"}
		}
	}
}
{"marder_1a3_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "MarderUA"}
		}
	}
}
{"m142_himars_atacams"
	{On spawn
		{Delay 0.2
			{tex_mod "wood"}
		}
	}
}
{"m142_himarser"
	{On spawn
		{Delay 0.2
			{tex_mod "wood"}
		}
	}
}
{"btr4e1i"
	{On spawn
		{Delay 0.2
			{tex_mod "pix"}
		}
	}
}
{"btr4e1_ptur"
	{On spawn
		{Delay 0.2
			{tex_mod "pix"}
		}
	}
}
{"btr3e"
	{On spawn
		{Delay 0.2
			{tex_mod "pix"}
		}
	}
}
{"btr3e_whth_pt"
	{On spawn
		{Delay 0.2
			{tex_mod "pix"}
		}
	}
}

{"amx10rcr"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}
{"challenger_2_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}
{"m142_himars_atacams"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}
{"m142_himarser"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}
{"pzh2000_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}

{"bm_oplot"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}

{"bmp2_new_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}

{"bmp3_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "green"}
		}
	}
}
{"buk_m1_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}

{"leopard_2a6"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}
{"leopard_2a6"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}

{"pt-91_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}
{"bm-30_smerch"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}

{"t80bv_ukri"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}
{"t80bvm_2_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "ukr"}
		}
	}
}
{"t-64bv_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}
{"t-64bm1"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}
{"t-64bv"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}
{"tor_m1_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}
{"tunguska_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}
{"2c9_ukr"
	{On spawn
		{Delay 0.2
			{tex_mod "nbd"}
		}
	}
}
{"30n6"
	{On spawn
		{Delay 0.2
			{tex_mod "pix_ua"}
		}
	}
}
{"5p85se"
	{On spawn
		{Delay 0.2
			{tex_mod "pix_ua"}
		}
	}
}

;===================================air_speed======================thx Fedor Chizh====================

(define "air_speed"
	{"air_speed_%air_name"
		{on spawn
			{tags add "force_down_%air_name"}
		}
		{on "force_speed"
			{if operatable
				{if tagged "force_down_%air_name"
					{tags remove "force_down_%air_name"}
					{tags add "force_up_%air_name"}
					{view show "engine_overburn"}
					{view show "engine1_overburn"}
					{view show "engine2_overburn"}
					{view start "engine_overburn"}
					{view start "engine1_overburn"}
					{view start "engine2_overburn"}

					else tagged "force_up_%air_name"
					{tags add "force_down_%air_name"}
					{tags remove "force up_%air_name"}
					{view pause "engine_overburn"}
					{view pause "engine1_overburn"}
					{view pause "engine2_overburn"}
				}
			}
		}
	}
)

("air_speed" air_name(mig31)) ; пример тэга force_down_mig21
("air_speed" air_name(f16)) ;пример имени пропса air_speed_f16
("air_speed" air_name(il2))
("air_speed" air_name(mig29))

{"air_support"		
	{on "air_1"		
		{tags add "air_1"}
		{link_sound "air_1"		"weapon/shot/reactive/radio1"		}
		{play_sound "air_1"}
		{delay 4 {tags remove "air_1"}}

	}
	{on "air_2"		
		{tags add "air_2"}
		{link_sound "air_2"		"weapon/shot/reactive/radio1"		}
		{play_sound "air_2"}
		{delay 4 {tags remove "air_2"}}

	}
	{on "air_3"		
		{tags add "air_3"}
		{link_sound "air_3"		"weapon/shot/reactive/radio1"		}
		{play_sound "air_3"}
		{delay 4 {tags remove "air_3"}}

	}
	{on "air_4"		
		{tags add "air_4"}
		{link_sound "air_4"		"weapon/shot/reactive/radio1"		}
		{play_sound "air_4"}
		{delay 4 {tags remove "air_4"}}

	}
	{on "air_5"		
		{tags add "air_5"}
		{link_sound "air_5"		"weapon/shot/reactive/radio1"		}
		{play_sound "air_5"}
		{delay 4 {tags remove "air_5"}}

	}
	{on "air_6"		
		{tags add "air_6"}
		{link_sound "air_6"		"weapon/shot/reactive/radio1"		}
		{play_sound "air_6"}
		{delay 4 {tags remove "air_6"}}

	}
	{on "air_7"		
		{tags add "air_7"}
		{link_sound "air_7"		"weapon/shot/reactive/radio1"		}
		{play_sound "air_7"}
		{delay 4 {tags remove "air_7"}}

	}
}

{"novator"		
	{on "air2_1"		
		{tags add "air2_1"}
		{link_sound "air2_1"		"weapon/shot/reactive/radio2"		}
		{play_sound "air2_1"}
		{delay 4 {tags remove "air2_1"}}

	}
	{on "air2_2"		
		{tags add "air2_2"}
		{link_sound "air2_2"		"weapon/shot/reactive/radio2"		}
		{play_sound "air2_2"}
		{delay 4 {tags remove "air2_2"}}

	}
	{on "air2_3"		
		{tags add "air2_3"}
		{link_sound "air2_3"		"weapon/shot/reactive/radio2"		}
		{play_sound "air2_3"}
		{delay 4 {tags remove "air2_3"}}

	}
	{on "air2_4"		
		{tags add "air2_4"}
		{link_sound "air2_4"		"weapon/shot/reactive/radio2"		}
		{play_sound "air2_4"}
		{delay 4 {tags remove "air2_4"}}

	}
	{on "air2_5"		
		{tags add "air2_5"}
		{link_sound "air2_5"		"weapon/shot/reactive/radio2"		}
		{play_sound "air2_5"}
		{delay 4 {tags remove "air2_5"}}

	}
	{on "air2_6"		
		{tags add "air2_6"}
		{link_sound "air2_6"		"weapon/shot/reactive/radio2"		}
		{play_sound "air2_6"}
		{delay 4 {tags remove "air2_6"}}

	}
	{on "air2_7"		
		{tags add "air2_7"}
		{link_sound "air2_7"		"weapon/shot/reactive/radio2"		}
		{play_sound "air2_7"}
		{delay 4 {tags remove "air2_7"}}

	}
}

;=====================================================WE_system===============

