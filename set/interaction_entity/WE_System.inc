{on "link_weapon"			
	{if effector "stuff weapon"			
	{with_effector				
	{call "link"}			
	}		
	}		
	{if stuff "low_speed"			
		{tags add "low_speed_weapon"}		
			else			
		{tags remove "low_speed_weapon"}		
	}		
	{if stuff "radar"		
		else stuff "weapon rifle"			
		{add_view "zenit_gilz" "shell" "FXshell"}			
		{if not stuff "sd" 	
		{add_view "flash_gun_big" "flashbarrel" "foresight3"}}			
		{add_view "we_smoke" "smoke_or" "foresight3"}		
		else stuff "weapon smg"			
		{add_view "smg_gilz" "shell" "FXshell"}			
		{if not stuff "sd" 	{add_view "flash_gun_small" "flashbarrel" "foresight3"}}			
		{add_view "we_smoke" "smoke_or" "foresight3"}		
		else stuff "weapon mgun"			
		{add_view "zenit_gilz" "shell" "FXshell"}			
		{if not stuff "sd" 	{add_view "flash_gun_big" "flashbarrel" "foresight3"}}			
		{add_view "we_smoke" "smoke_or" "foresight3"}		
		else stuff "weapon gra_launch"			
			{if not stuff "sd" 	{add_view "startsm_grl" "flashbarrel" "foresight3"}}			
			{add_view "we_smoke" "smoke_or" "foresight3"}		
		else stuff "weapon rocketlauncher"			
			{add_view "flash_bazooka" "flashbarrel" "foresight3"}		
		else stuff "weapon shotgun"			
			{add_view "zenit_gilz" "shell" "FXshell"}			
			{if not stuff "sd" 	{add_view "flash_shotgun" "flashbarrel" "foresight3"}}			
			{add_view "we_smoke" "smoke_or" "foresight3"}		
		else stuff "laser_designator"			
			(mod not "mp" {add_view "laser_designator" "laser_designator" "foresight3"})			
			{view hide "laser_designator"}		
		else stuff "weapon pistol"			
			{add_view "smg_gilz" "shell" "FXshell"}			
			{if not stuff "sd" 	
			{add_view "flash_gun_small" "flashbarrel" "foresight3"}}			
			{add_view "we_smoke" "smoke_or" "foresight3"}		
		else stuff "flame_thrower_pyro"			
			{add_view "flamer_fire" "flame_pyro" "foresight3"}		
		else stuff "flame_thrower"			
			{add_view "flamer_fire" "flame" "foresight3"}			
			{add_view "flamer_fire_barrel" "fire" "foresight3"}			
			{view show	"fire"}			
			{view start	"fire"}		
		else			
			{view hide	"flashbarrel"}			
			{view hide	"laser"}			
			{view pause	"laser"}			
			{view hide	"light"}			
			{view pause	"flashbarrel"}			
			{view pause	"flame"}			
			{view pause	"flame_pyro"}			
			{view stop	"bullet"}			
			{view pause	"flash_fire"}		
	}		
	{if stuff "weapon lg"			
			{add_view "laser_day" "laser1" "foresight3"}		
		else stuff "weapon lgs"			
			{add_view "laser_day" "laser1" "foresight3"}		
	}		
	{if stuff "fn"			
		{add_view 	"weap_light"		"light"	"foresight3"}				
		{add_view 	"light_vehicle"	"light"			"foresight3"}		
		{if not sunlight					
			{view start "light"}					
			{view show "light"}				
			else					
			{view stop "light"}					
			{view hide "light"}			
		}		
	}		
	{if stuff "igla weapon" 
		{tags add "igla_in_hand"} 
			else 
		{tags remove "igla_in_hand"}}		
	{if stuff "verba weapon" 
		{tags add "verba_in_hand"} 
			else 
		{tags remove "verba_in_hand"}}
	{if stuff "stinger weapon" 
		{tags add "stinger_in_hand"} 
		else {tags remove "stinger_in_hand"}}		
		{if stuff "fn6a weapon" 
		{tags add "fn6a_in_hand"} 
		else {tags remove "fn6a_in_hand"}}		
	{if stuff "eryx weapon" 
		{tags add "eryx_in_hand"} 
		else 
		{tags remove "eryx_in_hand"}}		
	{if stuff "javelin weapon"
		{tags add "javelin_in_hand"} 
		else 
		{tags remove "javelin_in_hand"}}		
	{if stuff "hj12e_atgm weapon" 
		{tags add "hj12e_in_hand"} 
		else 
		{tags remove "hj12e_in_hand"}}		
	{if stuff "sraw weapon" 
		{tags add "sraw_in_hand"} else {tags remove "sraw_in_hand"}}		
	{if stuff "nlaw weapon" {tags add "nlaw_in_hand"} else {tags remove "nlaw_in_hand"}}		
	{if stuff "spike-sr weapon" {tags add "spike_sr_in_hand"} else {tags remove "spike_sr_in_hand"}}		
	{if stuff "rpg-30 weapon" {tags add "rpg30_in_hand"} else {tags remove "rpg30_in_hand"}}		
	{if stuff "switchblade300_w weapon" {tags add "switchblade300_in_hand"} else {tags remove "switchblade300_in_hand"}}		
	{if stuff "m47dragon_m2plus weapon" {tags add "m47dragon_in_hand"} else {tags remove "m47dragon_in_hand"}}	                                                	
	{set "reliability_low" 0}	
	{set "reliability_medium" 0}	
	{set "reliability_high" 0}	
	{if stuff "reliability_low"		{set "reliability_low" 1}	
	else stuff "reliability_medium"		{set "reliability_medium" 1}	
	else stuff "reliability_high"	{set "reliability_high" 1}	
	}	
	{if stuff "not_for_human" {weapon_work "hand_right" 0}	else {weapon_work "hand_right" 1}}	                                                	
	}	
	{on "start_update_lights"		
	{call "update_lights"}		
	{delay 30 8 "update_lights"			
	{call "start_update_lights"}		
	}	
	}	
	{on "update_lights"		
		{if not sunlight				
		{view start "light"}				
		{view show "light"}			
		else				
		{view stop "light"}				
		{view hide "light"}		
		}	
	}	
	{on fire "hand_right"	                              	                  	                  	     	    			
		("blast")	                 	                       	    		
		{if tagged "cw_check_shooting_once"			
		{tags add "cw_i_am_shooting"}			
		{kill_delay "cw_shooting"}			
		{delay 3 "cw_shooting"				
			{tags remove  "cw_i_am_shooting"}				
			{tags remove  "cw_check_shooting_once"}			
		}		
		else tagged "cw_check_shooting"			
			{tags add "cw_i_am_shooting"}			
			{kill_delay "cw_shooting"}			
			{delay 3 "cw_shooting"				
			{tags remove  "cw_i_am_shooting"}			
			}		
		}		
	{if tagged "igla_in_hand"			
		{delay 0.01 {spawn "igla_s_carrier" "Foresight3"   x}}		
		else tagged "verba_in_hand"			
		{delay 0.01 {spawn "9m336_carrier" "Foresight3"   x}}	
		else tagged "stinger_in_hand"			
		{delay 0.01 {spawn "fim-92a_carrier" "Foresight3"   x}}		
		else tagged "fn6a_in_hand"			
		{delay 0.01 {spawn "fn6a_ammo_carrier" "Foresight3"   x}}		
		else tagged "eryx_in_hand"			
		{delay 0.01 {spawn "eryx_rock_carrier" "Foresight3"   x}}			
			{spawn "eryx_tubus" "right_hand" x				
				{impulse up 2.5 0.7 dir 2.5 0.7 cz 0.2 0.1 forward -2 0.5 com}			
			}		
		else tagged "javelin_in_hand"	{spawn "proj_probe" "Foresight3"   x}			
			{spawn "jav_tubus" "right_hand" x				
				{impulse up 2.5 0.7 dir 2.5 0.7 cz 0.2 0.1 forward -2 0.5 com}			
			}		
		else tagged "m47dragon_in_hand"			{delay 0.01 {spawn "m47dragon_rock_carrier" "Foresight3"   x}}			
			{spawn "m47_tubus" "right_hand" x				
			{impulse up 2.5 0.7 dir 2.5 0.7 cz 0.2 0.1 forward -2 0.5 com}			
			}	
		else tagged "hj12e_in_hand"		{delay 0.03 {spawn "proj_actorprobe" "Foresight3"   x {spawn "red_arrow12_rock_carrier" "missile_point15"   x }}	}			
			{spawn "hj12e_gilza" "right_hand" x				
			{impulse up 2.5 0.7 dir 2.5 0.7 cz 0.2 0.1 forward -2 0.5 com}			
			}		
		else tagged "sraw_in_hand"			{delay 0.01 {spawn "sraw_rock_carrier" "Foresight3"   x}}		
		else tagged "nlaw_in_hand"			{delay 0.01 {spawn "nlaw_rocket_carrier" "Foresight3"   x}}		
		else tagged "spike_sr_in_hand"			{delay 0.01 {spawn "spike-sr_carrier" "Foresight3"   x}}		
		else tagged "rpg30_in_hand"			{delay 0.01 {spawn "pg-30_precursor" "Foresight3"   x {volumes disable all}}}		
		else tagged "switchblade300_in_hand"			{delay 0.01 {spawn "switchblade300" "Foresight3"   x {volumes disable all}}}		
	}	                      		
	{if tagged "low_speed_weapon"		
		{tags add "low_speed_bullet"}		
		{delay 0.5 {tags remove "low_speed_bullet"}}		
	}	       		
	{view show "laser_designator"}		
	{delay 0.6			
	{view hide "laser_designator"}		
	}		
	{view show	"flashbarrel"}		
	{view start	"flashbarrel"}			
	{view show	"smoke_or"}		
	{view start	"smoke_or"}		
	{view show	"shells_we"}		
	{view start	"shells_we"}		
	{view show	"shell"}		
	{view start	"shell"}			
	{view start	"flame"}		
	{view start	"flame_pyro"}		
	{view start	"bullet"}		
	{view start	"smoke_body"}			
	{kill_delay "fire"}		
	{kill_delay "shells_we"}		
	{delay 0.2			
	{view pause	"shells_we"}			
	{view pause	"shell"}		
	}		
	{delay 0.45 "fire"			
	{view hide	"flashbarrel"}			
	{view pause	"flashbarrel"}			
	{view pause	"smoke_or"}			
	{view hide	"smoke_or"}				
	{view pause	"flashbarrell"}			
	{view pause	"smoke_body"}			
	{view pause	"flame"}			
	{view pause	"bullet"}		
	}		
	{delay 2 "fire"			
		{view pause	"flame_pyro"}		
	}		
	{spawn "bazooka_shot" "fxshot" x}		                                                	
	(define "misfire_check"		
			{if terrain_fx "%terrain"		     
			{if rand %terrain_coeff 			
			{if lying			     
			{if not rain				
				{call "misfire"}			      
				else				
					{if rand %rain_coeff 					
					{call "misfire"}				
					}			     
			}			
			else rand %stand_coeff			     
				{if not rain				
				{call "misfire"}			     
			else				
				{if rand %rain_coeff 					
				{call "misfire"}				
			}			    
			}			
			}		     
		}		
		}	
	)    	                                                       			
	{if rand 0.015
	{if "reliability_low"				
	("misfire_check" terrain(road) 	terrain_coeff(0.4) rain_coeff(0.9) stand_coeff(1))				
	("misfire_check" terrain(country_road) terrain_coeff(0.66) rain_coeff(0.7) stand_coeff(0.7))				
	("misfire_check" terrain(ice) 		terrain_coeff(0.4) rain_coeff(1) stand_coeff(0.9))				
	("misfire_check" terrain(snow) 	terrain_coeff(0.4) rain_coeff(1) stand_coeff(0.9))				
	("misfire_check" terrain(sand) 	terrain_coeff(1) rain_coeff(0.9) stand_coeff(0.36))				
	("misfire_check" terrain(grass) 	terrain_coeff(0.5) rain_coeff(1) stand_coeff(0.6))				
	("misfire_check" terrain(ground) 	terrain_coeff(0.66) rain_coeff(0.9) stand_coeff(0.6))				
	("misfire_check" terrain(bridge) 	terrain_coeff(0.4) rain_coeff(0.9) stand_coeff(1))				
	("misfire_check" terrain(bridge_wood) terrain_coeff(0.33) rain_coeff(1) stand_coeff(1))				
	("misfire_check" terrain(water) 	terrain_coeff(0.9) rain_coeff(1) stand_coeff(0.3))				
	("misfire_check" terrain(swamp) 	terrain_coeff(1) rain_coeff(1) stand_coeff(0.3))			
	}			
	{if rand 0.2	                                                                                           				
	{if "reliability_medium"					
		("misfire_check" terrain(road) 	terrain_coeff(0.4) rain_coeff(0.9) stand_coeff(1))					
		("misfire_check" terrain(country_road) terrain_coeff(0.66) rain_coeff(0.7) stand_coeff(0.7))					
		("misfire_check" terrain(ice) 		terrain_coeff(0.4) rain_coeff(1) stand_coeff(0.9))					
		("misfire_check" terrain(snow) 	terrain_coeff(0.4) rain_coeff(1) stand_coeff(0.9))					
		("misfire_check" terrain(sand) 	terrain_coeff(1) rain_coeff(0.9) stand_coeff(0.36))					
		("misfire_check" terrain(grass) 	terrain_coeff(0.5) rain_coeff(1) stand_coeff(0.6))					
		("misfire_check" terrain(ground) 	terrain_coeff(0.66) rain_coeff(0.9) stand_coeff(0.6))					
		("misfire_check" terrain(bridge) 	terrain_coeff(0.4) rain_coeff(0.9) stand_coeff(1))					
		("misfire_check" terrain(bridge_wood) terrain_coeff(0.33) rain_coeff(1) stand_coeff(1))					
		("misfire_check" terrain(water) 	terrain_coeff(0.9) rain_coeff(1) stand_coeff(0.3))					
		("misfire_check" terrain(swamp) 	terrain_coeff(1) rain_coeff(1) stand_coeff(0.3))				
	}				
	{if rand 0.33	                                                                                                   					
	{if "reliability_high"						
		("misfire_check" terrain(road) 	terrain_coeff(0.4) rain_coeff(0.9) stand_coeff(1))						
		("misfire_check" terrain(country_road) terrain_coeff(0.66) rain_coeff(0.7) stand_coeff(0.7))						
		("misfire_check" terrain(ice) 		terrain_coeff(0.4) rain_coeff(1) stand_coeff(0.9))						
		("misfire_check" terrain(snow) 	terrain_coeff(0.4) rain_coeff(1) stand_coeff(0.9))						
		("misfire_check" terrain(sand) 	terrain_coeff(1) rain_coeff(0.9) stand_coeff(0.36))						
		("misfire_check" terrain(grass) 	terrain_coeff(0.5) rain_coeff(1) stand_coeff(0.6))							
		("misfire_check" terrain(ground) 	terrain_coeff(0.66) rain_coeff(0.9) stand_coeff(0.6))						
		("misfire_check" terrain(bridge) 	terrain_coeff(0.4) rain_coeff(0.9) stand_coeff(1))						
		("misfire_check" terrain(bridge_wood) terrain_coeff(0.33) rain_coeff(1) stand_coeff(1))						
		("misfire_check" terrain(water) 	terrain_coeff(0.9) rain_coeff(1) stand_coeff(0.3))						
		("misfire_check" terrain(swamp) 	terrain_coeff(1) rain_coeff(1) stand_coeff(0.3))					
	}		    		 
	}			
	}		
	}	
} 
{on "misfire"		
	{start_sound "weapon/special/ak_empty"}		
	{weapon_work "hand_right" 0}		
	{damage_report "head" "component/misfire"}				
	{if "reliability_high"			
		{delay 3 				
			{weapon_work "hand_right" 1}			
		}		
		else "reliability_medium"			
			{if rand 0.5				
				{delay 2.5 					
					{weapon_work "hand_right" 1}				
				}
				else				
					{delay 5					
						{weapon_work "hand_right" 1}				
					}			
			}		
			else  "reliability_low"			
				{if rand 0.3				
					{delay 3 				
					{weapon_work "hand_right" 1}				
					}			
			else  rand 0.6				
				{delay 6				
					{weapon_work "hand_right" 1}				
				}			
				else				
				{delay 9					
				{weapon_work "hand_right" 1}				
				}				
				}		
	}	
}	                                                