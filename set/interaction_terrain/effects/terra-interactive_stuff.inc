(define "terra-interactive_stuff"		
	{if stuff "mortar pd p ammo"			
		{spawn "vog_25p_exp"}		
		else stuff "mortar pd pm ammo"			
			{spawn "vog_25pm_exp"}		
		else stuff "nato_pg p ammo"	                   			
			{spawn "m397p_exp"}		
		else stuff "pom_2 ammo"			
			{spawn "pom_2"}		
		else stuff "grenade_xm25 ammo fg"			
			{spawn "grenade_xm25_fg_exp"}		
		else stuff "mk30abm_abm fg_abm"			
			{spawn "mk30abm_fg_exp"}		
		else stuff "bullet40_NATO abm"			
			{spawn "shell_fr_gpr-ab-t_40mm_exp"}		
		else stuff "bullet120_GER abm"			
			{spawn "shell_ger_abm_120_exp"}		
		else stuff "agm-154"			
			{spawn "proj_point_usa_other"  offset 0 0 400 {tags add "agm-154_target"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7}) {delay 15 {delete}}}		
		else stuff "pbk-500u"			
			{spawn "proj_point_rus_other"  offset 0 0 400 {tags add "pbk-500u_target"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7}) {delay 15 {delete}}}		
		else stuff "tomahawk"			{spawn "proj_point_usa_other" offset 0 0 50 {tags add "tomahawk_target"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}		
		else stuff "asroc_vla"			{spawn "proj_point_usa_other" offset 0 0 50 {tags add "asroc_vla_target"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}		
		else stuff "3m14 caliber"		{spawn "proj_point_rus_other" offset 10 0 -20 {tags add "3m14_target"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7}) {delay 120 {delete}}}				
		else stuff "3m14k"				{spawn "proj_point_rus_other" offset 10 0 -20 {tags add "3m14k_target"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}
		else stuff "malahit"			{spawn "proj_point_rus_other" offset 10 0 50 {tags add "malahit_target"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}	
		else stuff "p800"			{spawn "proj_point_rus_other" offset 10 0 50 {tags add "p800_target"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}
		else stuff "x59m"			{spawn "proj_point_rus_antiship" offset 0 0 50 {tags add "x59m_target"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}		
		else stuff "c802akg"			{spawn "proj_point_rus_antiship" offset 0 0 50 {tags add "c802akg_target"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}		
		else stuff "taurus"			{spawn "proj_point_usa_other" offset 0 0 50 {tags add "taurus_target"} {tags add "inertial_gs"} {tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}		
		else stuff "storm"			{spawn "proj_point_usa_other" offset 0 0 50 {tags add "storm_target"} {tags add "inertial_gs"} {tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}
		else stuff "kh47m2"			{spawn "proj_point_rus_other" offset 0 0 -20 {tags add "kh47m2_target"}{tags add "inertial_gs"} {tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}
		else stuff "x32"			{spawn "proj_point_rus_other" offset 10 10 50 {tags add "x32_target"} {tags add "inertial_gs"} {tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}
		else stuff "jsm"			{spawn "proj_point_usa_antiship" offset 0 0 50 {tags add "jsm_target"} {tags add "inertial_gs"} {tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7}) {if terrain_fx "deep_water" {delete}}}		
		else stuff "iskander tb"				{spawn "ex_odab"  offset 0 0 100} {spawn "ex_air_big"  offset 0 0 100}		
		else stuff "212mm_rbu"				{spawn "rgb-60_impactor"  offset 0 0 1}		
		else stuff "305mm_rbu"				{spawn "rgb-10_impactor"  offset 0 0 1}		
		else stuff "300mm_rbu"				{spawn "rgb-111szg_impactor"  offset 0 0 1}		
		else stuff "vodopad"			{spawn "proj_point_rus_other" offset 0 0 500 {tags add "vodopad_target"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}		
		else stuff "veter"				{spawn "proj_point_rus_other" offset 0 0 500 {tags add "veter_target"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}		
		else stuff "rastrub"			{spawn "proj_point_rus_other" offset 0 0 500 {tags add "rastrub_target"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})}		
		else stuff "fx_wp_small"		
		else stuff "fx_wp_med"		
		else stuff "fx_wp_large"		
		else stuff "tanksmoke"		
		else stuff "big sm"			{spawn "smoke_shell"}		
		else stuff "sm"				{spawn "smoke_shell"}		
		else stuff "gas"			{spawn "grenade_gas_alarm" {tags add "15s_timer"}} {spawn "ex_gas_small"}		
		else stuff "gas_short"			{spawn "grenade_gas_alarm"} {spawn "ex_gas_small_short"}		
		else stuff "flash"			{spawn "ex_grenade_flash"}		
	}		                                     		
	{if stuff "cm he_07to2"		
		else stuff "cm he_2to4_5"		
		else stuff "cm he_4_5to8"			{spawn "cw_fgassist_07to2" offset 0 0 44}		
		else stuff "cm he_8to30"			{spawn "cw_fgassist_2to4_5" offset 0 0 56}		
		else stuff "cm he_over30"			{spawn "cw_fgassist_4_5to8" offset 0 0 68}		
		else stuff "he_07to2"			{spawn "cw_fgassist_07to2" offset 0 0 44}		
		else stuff "he_2to4_5"			{spawn "cw_fgassist_2to4_5" offset 0 0 56}		
		else stuff "he_4_5to8"			{spawn "cw_fgassist_4_5to8" offset 0 0 68}		
		else stuff "he_8to30"			{spawn "cw_fgassist_8to30" offset 0 0 90}		
		else stuff "he_over30"			{spawn "cw_fgassist_over30" offset 0 0 110}		
	}	
)		
(define "terra-interactive_stuff_ground"			
	{if stuff "usa_laser ammo"			{spawn "proj_point_usa_laser_des_ground" offset 0 0 0 {tags add "usa_target_laser"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7} )               						{delay 5 {delete}}}		
		else stuff "rus_laser1 ammo"			{spawn "proj_point_rus_laser_des_ground" offset 0 0 0 {tags add "laser_target"}{tags add "rus_target_laser"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})			{delay 3 {delete}}}		
		else stuff "ground_antirad_usa ammo"			{spawn "proj_point_usa_antirad_ground" offset 0 0 150 {tags add "antirad_target"}{tags add "usa_target_antirad"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})			{delay 3 {delete}}}			
		else stuff "ground_antirad_rus ammo"			{spawn "proj_point_rus_antirad_ground" offset 0 0 150 {tags add "antirad_target"}{tags add "rus_target_antirad"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})			{delay 3 {delete}}}			
		else stuff "ground_laser_usa ammo"			{spawn "proj_point_usa_laser_des_ground" offset 0 0 0 {tags add "usa_target_laser"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})                           			{delay 5 {delete}}}	    
		else stuff "ground_laser_rus ammo"			{spawn "proj_point_rus_laser_des_ground" offset 0 0 0 {tags add "rus_target_laser"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})                           			{delay 10 {delete}}}	    
		else stuff "ground_ir_usa ammo"			{spawn "proj_point_usa_ir_ground" offset 0 0 0 {tags add "ir_target"}{tags add "usa_target_ir"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})			{delay 10 {delete}}}		    
		else stuff "ground_ir_rus ammo"			{spawn "proj_point_rus_ir_ground" offset 0 0 0 {tags add "ir_target"}{tags add "rus_target_ir"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})			{delay 10 {delete}}}		   
		else stuff "ground_active_usa ammo"			{spawn "proj_point_usa_active_ground" offset 0 0 0 {tags add "active_target"}{tags add "usa_target_active"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})			{delay 10 {delete}}}		
		else stuff "ground_active_rus ammo"			{spawn "proj_point_rus_active_ground" offset 0 0 0 {tags add "active_target"}{tags add "rus_target_active"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})			{delay 10 {delete}}}	   
		else stuff "ground_other_usa ammo"			{spawn "proj_point_usa_other_ground" offset 0 0 0 {tags add "other_target"}{tags add "usa_target_other"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})			{delay 10 {delete}}}		 
		else stuff "ground_other_usa_far ammo"			{spawn "proj_point_usa_other_ground" offset 0 0 0 {tags add "ground_far"}{tags add "other_target"}{tags add "usa_target_other"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})			{delay 25 {delete}}}	 	   
		else stuff "ground_other_rus ammo"			{spawn "proj_point_rus_other_ground" offset 0 0 0 {tags add "other_target"}{tags add "rus_target_other"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})			{delay 7 {delete}}}			    
		else stuff "ground_other_rus ammo"			{spawn "proj_point_rus_other_ground" offset 0 0 0 {tags add "other_target"}{tags add "rus_target_other"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})			{delay 10 {delete}}}		    
		else stuff "ground_other_rus ammo"			{spawn "proj_point_rus_other_ground" offset 0 0 0 {tags add "other_target"}{tags add "rus_target_other"}{tags add "cwps_ground_attack"}(mod "mp"{player 1}) (mod not "mp"{player 7})			{delay 10 {delete}}}				                             		                                                                                                                                                                             		                      	                             		                                                                                                                                                                             		                       					
	}		
)					