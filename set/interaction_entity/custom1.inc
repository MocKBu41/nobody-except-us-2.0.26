{"2c1"
	{on spawn			
		{add_view	"smoke_zenit" 	"zenite_smoke"	"foresight1"}
		{add_view 	"smoke_ejector" "zenite_smoke" 	"foresight1"}					
 	}

	{on fire "gun"
		{spawn "canon_gaub_fire" "Foresight1" x}
		{spawn "proj_probe" "Fs1" x}
		{spawn "proj_probe" "Fs2" x}
		{spawn "dust_shot_big" "basis"}
		{view start "smoke_add"}
		{delay 0.16 "shell_off"
			{view start "zenite_smoke"}
			{view pause "smoke_add"}
			{view pause "flashbarrel_gun"}
			{delay 5	
				{view pause "zenite_smoke"}
			}
		}
  		{delay 1
   			{ani_play "lyk" 1  }
  		}
  		{delay 2.5
   			{ani_play "shell_tank" callback}
  		}
	}

	{on animation_end "shell_tank"
  		{spawn "shell_cannon" "fx_gilza" x scale 2
			{impulse up 0.1 0.1 dir 4 0  cz 0.3 0.3 com }
			{add_view "smoke_zenit" "smoke_shell" "fx_shellsmoke"}
			{view start "smoke_shell"}
			{delay_effect 3 1 "stop"}
			{delay 3 0.5
				{hide 10}
			}
		}
	}
}
{"uragan_new"
	{on spawn
		{add_view	"exhaust_dark_small"	"exhaust"		"FXsmoke"}
		{add_view	"exhaust_dark_small"	"exhaust"		"FXsmoke1"}
	}
	("9k72_sound")

	{on ik begin "turret"
		{play_sound "rotate_turret" 1}
	}
	{on ik end "turret"
		{stop_sound "rotate_turret"}
	}
	{on fire "gun"
		{spawn "startsmoke_big"}
		{spawn "startdust_big" "FXdust"}
		{if rand 0.5
			{spawn "dust_shot_big_2" "basis"}
		}
	}
} 
{"uragan_nov"
	{on spawn
		{add_view	"exhaust_dark_small"	"exhaust"		"FXsmoke"}
		{add_view	"exhaust_dark_small"	"exhaust"		"FXsmoke1"}
	}
	("9k72_sound")

	{on ik begin "turret"
		{play_sound "rotate_turret" 1}
	}
	{on ik end "turret"
		{stop_sound "rotate_turret"}
	}
	{on fire "gun"
		{spawn "startsmoke_big"}
		{spawn "startdust_big" "FXdust"}
		{if rand 0.5
			{spawn "dust_shot_big_2" "basis"}
		}
	}
}

{"c130"		
	{on "emit_desant1"		      
		{if tagged "place1_busy"			
			{delay 0.1 {with_linked_entity "seat02"	{get_off}}}	
			{delay 0.1 {with_linked_entity "seat03"	{get_off}}}			
			{delay 0.1 {with_linked_entity "seat04"	{get_off}}}			
			{delay 0.1 {with_linked_entity "seat05"	{get_off}}}			
			{delay 0.1 {with_linked_entity "seat06"	{get_off}}}			
			{delay 0.1 {with_linked_entity "seat07"	{get_off}}}			
			{delay 0.1 {with_linked_entity "seat08"	{get_off}}}			
			{delay 0.1 {with_linked_entity "seat09"	{get_off}}}			
			{delay 0.1 {with_linked_entity "seat10"	{get_off}}}			
			{delay 0.1 {with_linked_entity "seat11"	{get_off}}}			
			{delay 0.1 {with_linked_entity "seat12"	{get_off}}}			
			{delay 0.1 {with_linked_entity "seat13"	{get_off}}}		        
		}		
	}		
		{on "emit_desant2"		      
			{if tagged "place2_busy"			
			{delay 0.1 {with_linked_entity "seat14"	{get_off}	}}			
			{delay 0.1 {with_linked_entity "seat15"	{get_off}	}}			
			{delay 0.1 {with_linked_entity "seat16"	{get_off}	}}			
			{delay 0.1 {with_linked_entity "seat17"	{get_off}	}}			
			{delay 0.1 {with_linked_entity "seat18"	{get_off}	}}			
			{delay 0.1 {with_linked_entity "seat19"	{get_off}	}}			
			{delay 0.1 {with_linked_entity "seat20"	{get_off}	}}			
			{delay 0.1 {with_linked_entity "seat21"	{get_off}	}}			
			{delay 0.1 {with_linked_entity "seat22"	{get_off}	}}			
			{delay 0.1 {with_linked_entity "seat23"	{get_off}	}}			
			{delay 0.1 {with_linked_entity "seat24"	{get_off}	}}			
			{delay 0.1 {with_linked_entity "seat25"	{get_off}	}}			
			{delay 0.1 {with_linked_entity "seat26"	{get_off}	}}			
			{delay 0.1 {with_linked_entity "seat27"	{get_off}	}}	       
			}		
		}		
		{on "drop_desant1"						
			{delay 0.5 {with_linked_entity "seat02"	{get_off}	}}			
			{delay 0.7 {with_linked_entity "seat03"	{get_off}	}}			
			{delay 0.9 {with_linked_entity "seat04"	{get_off}	}}			
			{delay 1.1 {with_linked_entity "seat05"	{get_off}	}}			
			{delay 1.3 {with_linked_entity "seat06"	{get_off}	}}			
			{delay 1.5 {with_linked_entity "seat07"	{get_off}	}}			
			{delay 1.7 {with_linked_entity "seat08"	{get_off}	}}			
			{delay 1.9 {with_linked_entity "seat09"	{get_off}	}}			
			{delay 2.2 {with_linked_entity "seat10"	{get_off}	}}			
			{delay 2.4 {with_linked_entity "seat11"	{get_off}	}}		
		}		
		{on "drop_desant2"			
			{delay 0.1 {with_linked_entity "seat12"	{get_off}	}}			
			{delay 0.3 {with_linked_entity "seat13"	{get_off}	}}			
			{delay 0.5 {with_linked_entity "seat14"	{get_off}	}}			
			{delay 0.7 {with_linked_entity "seat15"	{get_off}	}}			
			{delay 0.9 {with_linked_entity "seat16"	{get_off}	}}			
			{delay 1.1 {with_linked_entity "seat17"	{get_off}	}}			
			{delay 1.3 {with_linked_entity "seat18"	{get_off}	}}			
			{delay 1.5 {with_linked_entity "seat19"	{get_off}	}}			
			{delay 1.7 {with_linked_entity "seat20"	{get_off}	}}			
			{delay 1.9 {with_linked_entity "seat21"	{get_off}	}}			
			{delay 2.1 {with_linked_entity "seat22"	{get_off}	}}			
			{delay 2.3 {with_linked_entity "seat23"	{get_off}	}}			
			{delay 2.5 {with_linked_entity "seat24"	{get_off}	}}			
			{delay 2.7 {with_linked_entity "seat25"	{get_off}	}}			
			{delay 2.9 {with_linked_entity "seat26"	{get_off}	}}			
			{delay 3.1 {with_linked_entity "seat27"	{get_off}	}}	
		}	
	{on "check_vdvstate"	      
		{if tagged "place1_busy" {ani_wind "vehicle1_in" end} {if not tagged "dont_drop" {bone show "platform1"}}}	                                                                                                                    
	}
}

{"desatn_heli"		
	{on "check_vdvstate"	      
		{if tagged "place1_busy" {ani_wind "vehicle1_in" end} {if not tagged "dont_drop" {bone show "platform1"}}}	                                                                                                                    
	}		
}


{"helfaer_x4"			                                                                                                               
	{on fire "ptur" overload			
		("low_speed_bullet")			
		{view start "flashbarrel3"}			
		{spawn "proj_probe" "Foresight3" x  
		{tags add "Foresight3"}}			
		{delay 0.42				
			{view pause "flashbarrel3"}			
		}		
	}				
}

{"dagr"			                                                                                                               				
	("air_multibarrel_launcher" weapon(ptur1) shooter(hydra_dagr_) missile(hydra_dagr) flashbarrel(hydra_dagr_))	
}

{"cerna"	
	{on "load_light_vehicle"			   
			{tags add "cargo_inside"}			        
			{if not tagged "place1_busy"				
				{delay 0.1 {ani_play "vehicle1_in" callback}}				
				{tags add "vdv_link_place1"} {delay 3 {tags remove "vdv_link_place1"}}				
				{tags add "place1_busy"} {tags add "place7_busy"}				
				{with_effector {tags add "vdv_link_to_place1"} {call "emit_desant"} {delay 3 {tags remove "vdv_link_to_place1"}}}			        
					else not tagged "place2_busy"				
						{delay 0.1 {ani_play "vehicle2_in" callback}}				
						{tags add "vdv_link_place2"} {delay 3 {tags remove "vdv_link_place2"}}				
						{tags add "place2_busy"} {tags add "place7_busy"}				
						{with_effector {tags add "vdv_link_to_place2"} {call "emit_desant"} {delay 3 {tags remove "vdv_link_to_place2"}}}			        
					else not tagged "place3_busy"				
						{delay 0.1 {ani_play "vehicle3_in" callback}}				
						{tags add "vdv_link_place3"} {delay 3 {tags remove "vdv_link_place3"}}				
						{tags add "place3_busy"} {tags add "place7_busy"}				
						{with_effector {tags add "vdv_link_to_place3"} {call "emit_desant"} {delay 3 {tags remove "vdv_link_to_place3"}}}			       
					else not tagged "place4_busy"				
						{delay 0.1 {ani_play "vehicle4_in" callback}}				
						{tags add "vdv_link_place4"} {delay 3 {tags remove "vdv_link_place4"}}				
						{tags add "place4_busy"} {tags add "place7_busy"}				
						{with_effector {tags add "vdv_link_to_place4"} {call "emit_desant"} {delay 3 {tags remove "vdv_link_to_place4"}}}				
				}		
	}		
	{on "load_heavy_vehicle"			       
			{tags add "cargo_inside"}			       
			{if not tagged "place7_busy"				
				{delay 0.1 {ani_play "vehicle7_in" callback}}				
				{tags add "vdv_link_place7"} {delay 3 {tags remove "vdv_link_place7"}}				
				{tags add "place7_busy"} {tags add "place1_busy"} {tags add "place2_busy"}{tags add "place3_busy"} {tags add "place4_busy"}				
				{with_effector {tags add "vdv_link_to_place7"} {call "emit_desant"} {delay 3 {tags remove "vdv_link_to_place7"}}}			        
			}		
		}		
		{on overlap begin		      
			{if tagged "rampa_open"				
				{if effector "heavy_M"					
					{call "load_heavy_vehicle"}				
				else  effector "medium_M"					
					{call "load_heavy_vehicle"}				
				else  effector "armored_car_M"					
					{call "load_light_vehicle"}				
				else  effector "light_M"					
					{call "load_heavy_vehicle"}				
				else  effector "car"					
					{call "load_light_vehicle"}				
				}		       
			}		
		}		
		{on "script_update_cargo_anim"			
			{if tagged "place1_busy" {ani_wind "vehicle1_in" end} else {ani_wind "vehicle1_in" begin}}			
			{if tagged "place2_busy" {ani_wind "vehicle2_in" end} else {ani_wind "vehicle2_in" begin}}			
			{if tagged "place3_busy" {ani_wind "vehicle3_in" end} else {ani_wind "vehicle3_in" begin}}			
			{if tagged "place4_busy" {ani_wind "vehicle4_in" end} else {ani_wind "vehicle4_in" begin}}			
			{if tagged "place7_busy" {ani_wind "vehicle7_in" end} else {ani_wind "vehicle7_in" begin}}		
		}		
		{on "open_cargo"			
			{if not tagged "cargo_open"				
				{volumes "vehicle" enable overlap}			
			}			
			{if "engine_started" {call "engine_stop_load"}}		
		}		
		(define "scripted_unload"			
			{on animation_end "vehicle%0_unload" overload				
				{with_linked_entity "vehicle%0"					
					{tags add "unlink_me"}					
					{able "sinking" 0}				
				}			
			}	    
		)		
		("scripted_unload" args 1)		
		("scripted_unload" args 2)		
		("scripted_unload" args 3)		
		("scripted_unload" args 4)		
		("scripted_unload" args 7)	
		(define "zubr_unload"			
			{if tagged "place%place_busy"				
				{delay %delay {volumes disable overlap} {ani_play "cargo_unload"} {ani_play "vehicle%place_unload" callback}}			
			}		
		)		
		{on animation_end "cargo_open"	overload		          
			{if tagged "cargo_inside"					
				{tags remove "cargo_inside"}					
				{chassis_work 0}					
				{if tagged "place3_busy"						
					{delay 10 {call "zubr_unload_step2"}}					
				else tagged "place4_busy"						
					{delay 10 {call "zubr_unload_step2"}}					
				else {call "zubr_unload_step2"}					
				}					
				("zubr_unload" place(3) delay(0))					
				("zubr_unload" place(4) delay(5))					
				("zubr_unload" place(7) delay(0))					
				{tags remove "place3_busy"}{tags remove "place4_busy"}{tags remove "place7_busy"}				 
					else {volumes "vehicle" enable overlap}		          
			}		
		}
		{on "zubr_unload_step2"			
			("zubr_unload" place(1) delay(0))			
			("zubr_unload" place(2) delay(5))			
			{tags remove "place1_busy"}{tags remove "place2_busy"}			
			{delay 5 {chassis_work 1}}		
		}
}
{"ptsm"	
	{on "load_light_vehicle"			   
			{tags add "cargo_inside"}			        
			{if not tagged "place1_busy"				
				{delay 0.1 {ani_play "vehicle1_in" callback}}				
				{tags add "vdv_link_place1"} {delay 3 {tags remove "vdv_link_place1"}}				
				{tags add "place1_busy"} {tags add "place7_busy"}				
				{with_effector {tags add "vdv_link_to_place1"} {call "emit_desant"} {delay 3 {tags remove "vdv_link_to_place1"}}}			        
					else not tagged "place2_busy"				
						{delay 0.1 {ani_play "vehicle2_in" callback}}				
						{tags add "vdv_link_place2"} {delay 3 {tags remove "vdv_link_place2"}}				
						{tags add "place2_busy"} {tags add "place7_busy"}				
						{with_effector {tags add "vdv_link_to_place2"} {call "emit_desant"} {delay 3 {tags remove "vdv_link_to_place2"}}}			        
					else not tagged "place3_busy"				
						{delay 0.1 {ani_play "vehicle3_in" callback}}				
						{tags add "vdv_link_place3"} {delay 3 {tags remove "vdv_link_place3"}}				
						{tags add "place3_busy"} {tags add "place7_busy"}				
						{with_effector {tags add "vdv_link_to_place3"} {call "emit_desant"} {delay 3 {tags remove "vdv_link_to_place3"}}}			       
					else not tagged "place4_busy"				
						{delay 0.1 {ani_play "vehicle4_in" callback}}				
						{tags add "vdv_link_place4"} {delay 3 {tags remove "vdv_link_place4"}}				
						{tags add "place4_busy"} {tags add "place7_busy"}				
						{with_effector {tags add "vdv_link_to_place4"} {call "emit_desant"} {delay 3 {tags remove "vdv_link_to_place4"}}}				
				}		
	}		
	{on "load_heavy_vehicle"			       
			{tags add "cargo_inside"}			       
			{if not tagged "place7_busy"				
				{delay 0.1 {ani_play "vehicle7_in" callback}}				
				{tags add "vdv_link_place7"} {delay 3 {tags remove "vdv_link_place7"}}				
				{tags add "place7_busy"} {tags add "place1_busy"} {tags add "place2_busy"}{tags add "place3_busy"} {tags add "place4_busy"}				
				{with_effector {tags add "vdv_link_to_place7"} {call "emit_desant"} {delay 3 {tags remove "vdv_link_to_place7"}}}			        
			}		
	}		
		{on overlap begin		      
			{if tagged "rampa_open"				
				{if effector "heavy_M"					
					{call "load_heavy_vehicle"}				
				else  effector "medium_M"					
					{call "load_heavy_vehicle"}				
				else  effector "armored_car_M"					
					{call "load_heavy_vehicle"}				
				else  effector "light_M"					
					{call "load_heavy_vehicle"}				
				else  effector "car"					
					{call "load_light_vehicle"}				
				}		       
			}		
		}		
		{on "script_update_cargo_anim"			
			{if tagged "place1_busy" {ani_wind "vehicle1_in" end} else {ani_wind "vehicle1_in" begin}}			
			{if tagged "place2_busy" {ani_wind "vehicle2_in" end} else {ani_wind "vehicle2_in" begin}}			
			{if tagged "place3_busy" {ani_wind "vehicle3_in" end} else {ani_wind "vehicle3_in" begin}}			
			{if tagged "place4_busy" {ani_wind "vehicle4_in" end} else {ani_wind "vehicle4_in" begin}}			
			{if tagged "place7_busy" {ani_wind "vehicle7_in" end} else {ani_wind "vehicle7_in" begin}}		
		}		
		{on "open_cargo"			
			{if not tagged "cargo_open"				
				{volumes "vehicle" enable overlap}			
			}			
			{if "engine_started" {call "engine_stop_load"}}		
		}		
		(define "scripted_unload"			
			{on animation_end "vehicle%0_unload" overload				
				{with_linked_entity "vehicle%0"					
					{tags add "unlink_me"}					
					{able "sinking" 0}				
				}			
			}	    
		)		
		("scripted_unload" args 1)		
		("scripted_unload" args 2)		
		("scripted_unload" args 3)		
		("scripted_unload" args 4)		
		("scripted_unload" args 7)	
		(define "zubr_unload"			
			{if tagged "place%place_busy"				
				{delay %delay {volumes disable overlap} {ani_play "cargo_unload"} {ani_play "vehicle%place_unload" callback}}			
			}		
		)		
		{on animation_end "cargo_open"	overload		          
			{if tagged "cargo_inside"					
				{tags remove "cargo_inside"}					
				{chassis_work 0}					
				{if tagged "place3_busy"						
					{delay 10 {call "zubr_unload_step2"}}					
				else tagged "place4_busy"						
					{delay 10 {call "zubr_unload_step2"}}					
				else {call "zubr_unload_step2"}					
				}					
				("zubr_unload" place(3) delay(0))					
				("zubr_unload" place(4) delay(5))					
				("zubr_unload" place(7) delay(0))					
				{tags remove "place3_busy"}{tags remove "place4_busy"}{tags remove "place7_busy"}				 
					else {volumes "vehicle" enable overlap}		          
			}		
		}
		{on "zubr_unload_step2"			
			("zubr_unload" place(1) delay(0))			
			("zubr_unload" place(2) delay(5))			
			{tags remove "place1_busy"}{tags remove "place2_busy"}			
			{delay 5 {chassis_work 1}}		
		}
}
{"pac3"		
	{on spawn			
		{add_view	 "flash_gun_big"	"shooter00"	"shooter00"}			
		{add_view	 "flash_gun_big"	"shooter01"	"shooter01"}			
		{add_view	 "flash_gun_big"	"shooter02"	"shooter02"}			
		{add_view	 "flash_gun_big"	"shooter03"	"shooter03"}		
		{add_view	 "flash_gun_big"	"shooter04"	"shooter04"}
		{add_view	 "flash_gun_big"	"shooter05"	"shooter05"}
		{add_view	 "flash_gun_big"	"shooter06"	"shooter06"}
		{add_view	 "flash_gun_big"	"shooter07"	"shooter07"}
		{add_view	 "flash_gun_big"	"shooter08"	"shooter08"}
		{add_view	 "flash_gun_big"	"shooter09"	"shooter09"}
		{add_view	 "flash_gun_big"	"shooter10"	"shooter10"}
		{add_view	 "flash_gun_big"	"shooter11"	"shooter11"}
		{add_view	 "flash_gun_big"	"shooter12"	"shooter12"}
		{add_view	 "flash_gun_big"	"shooter13"	"shooter13"}
		{add_view	 "flash_gun_big"	"shooter14"	"shooter14"}
		{add_view	 "flash_gun_big"	"shooter15"	"shooter15"}
		{add_view	 "startsmoke_big"	"shooter00"	"tail00"}			
		{add_view	 "startsmoke_big"	"shooter01"	"tail01"}			
		{add_view	 "startsmoke_big"	"shooter02"	"tail02"}			
		{add_view	 "startsmoke_big"	"shooter03"	"tail03"}		
		{add_view	 "startsmoke_big"	"shooter04"	"tail04"}
		{add_view	 "startsmoke_big"	"shooter05"	"tail05"}
		{add_view	 "startsmoke_big"	"shooter06"	"tail06"}
		{add_view	 "startsmoke_big"	"shooter07"	"tail07"}
		{add_view	 "startsmoke_big"	"shooter08"	"tail08"}
		{add_view	 "startsmoke_big"	"shooter09"	"tail09"}
		{add_view	 "startsmoke_big"	"shooter10"	"tail10"}
		{add_view	 "startsmoke_big"	"shooter11"	"tail11"}
		{add_view	 "startsmoke_big"	"shooter12"	"tail12"}
		{add_view	 "startsmoke_big"	"shooter13"	"tail13"}
		{add_view	 "startsmoke_big"	"shooter14"	"tail14"}
		{add_view	 "startsmoke_big"	"shooter15"	"tail15"}
	}		
	{on fire "gun2" 			
		{weapon_work "gun" 0}
			{Delay 0.8
		{weapon_work "gun" 1}
		}
		(define "fire_barrel"				
			name "%0"					
			{spawn "startsmoke" "shooter%0"   x}					
			{delay 0.1 {spawn "pac3_mse_carrier" "shooter%0"   x}}	                                                           					
			{view start "shooter%0"}					
			{spawn "dust_shot_big_2" "basis"}					
			{delay 0.42						
			{view pause "shooter%0"}					
			}			
		)				
		{if    
			("fire_barrel" args 00)				 
			else ("fire_barrel" args 01)				  
			else ("fire_barrel" args 02)				
			else ("fire_barrel" args 03)				
			else ("fire_barrel" args 03)
			else ("fire_barrel" args 04)
			else ("fire_barrel" args 05)
			else ("fire_barrel" args 06)
			else ("fire_barrel" args 07)
		}				
		("cw_check_shooting" weap_id(gun2))		
	}	
	{on fire "gun" 			
		{weapon_work "gun2" 0}
			{Delay 0.8
		{weapon_work "gun2" 1}
		}
		(define "fire_barrel"				
			name "%0"					
			{spawn "startsmoke" "shootere%0"   x}					
			{delay 0.1 {spawn "pac3_mse_carrier" "shootere%0"   x}}	                                                           					
			{view start "shootere%0"}					
			{spawn "dust_shot_big_2" "basis"}					
			{delay 0.42						
			{view pause "shootere%0"}					
			}			
		)				
		{if    
			("fire_barrel" args 00)				 
			else ("fire_barrel" args 01)				  
			else ("fire_barrel" args 02)				
			else ("fire_barrel" args 03)				
			else ("fire_barrel" args 03)
			else ("fire_barrel" args 04)
			else ("fire_barrel" args 05)
			else ("fire_barrel" args 06)
			else ("fire_barrel" args 07)
		}				
		("cw_check_shooting" weap_id(gun2))		
	}

}
{"buk_launcher_ukr"		
	("Shilka_sound")		
	{on move on	
		{delay 0.1 {call "update_radar"}{call "update_gun23"}}}		
		{on move off	{delay 0.1 {call "update_radar"}{call "update_gun23"}}}		
		{on "update_gun23" overload			
			{if work "gun2"			     
			{if work "stabilizer"				    
			{if work "gunner_panel"				  	  
			{if not tagged "no_power"						
			{if not "specability"						  
			{if not velocity 0							 
			{weapon_work "gun2" 1}						  
				else {weapon_work "gun2" 0}}						
				else {weapon_work "gun2" 0}}					  
				else {weapon_work "gun2" 0}}					
				else {weapon_work "gun2" 0}}			      
				else {weapon_work "gun2" 0}}			
				else {weapon_work "gun2" 0}}		
		}		
		{on "update_radar"			
			{if tagged "radar_off" {weapon_work "radar" 0}			
			else not work "commander_triplex" {weapon_work "radar" 0}			
			else not work "body" {weapon_work "radar" 0}			
			else not work "turret" {weapon_work "radar" 0}			
			else not work "radar" {weapon_work "radar" 0}			
			else tagged "no_power" {weapon_work "radar" 0}			
			else velocity 0 {weapon_work "radar" 0}			
			else {weapon_work "radar" 1}			
			}		
		}		
		("custom_sh_multi_launcher" weapon(gun2) foresight(foresight1) tail(tail) shooter(shooter))		                                                                                 		
		("radar_params" triplex(commander_triplex) visor(visor1) anim_rotate(none) marker(antirad_generator_large_usa))	
}
{"iskander_k"		
	{on spawn			
		{add_view	 "flash_gun_big"	"shootera1"	"Missile1"}			
		{add_view	 "flash_gun_big"	"shootera2"	"Missile2"}					
		{add_view	 "startsmoke_big"	"shooter1"	"tail1"}			
		{add_view	 "startsmoke_big"	"shooter2"	"tail2"}		
		
	}
	{on fire "ptur1" 			
		(define "fire_barrel"	

			{ani_play "fire%0"}				
			{delay 0.2 						
				{spawn "3m14k_carrier" "missile%0"   x}						
				{bone hide "Missile%0"}					
				{bone hide "close%0"}
				{volumes "ammo_storage_main%0" disable contact bullet blast}					
			}		
			{ani_play "cover%0"}					
			{view start "shooter%0"}					
			{delay 0.3						
				{view pause "shooter%0"}						
				{view start "shootera%0"}						
				{delay 0.3							
					{view pause "shootera%0"}						
				}					
			}		
		)				
		{if name "00" ("fire_barrel" args 1)				 
		else name "01" ("fire_barrel" args 2)					
		}		
	}		
}

{"mi26"
	{on "load_light_vehicle"			   
			{tags add "cargo_inside"}			        
			{if not tagged "place1_busy"				
				{delay 0.1 {ani_play "vehicle1_in" callback}}				
				{tags add "vdv_link_place1"} {delay 3 {tags remove "vdv_link_place1"}}				
				{tags add "place1_busy"} {tags add "place7_busy"}				
				{with_effector {tags add "vdv_link_to_place1"} {call "emit_desant"} {delay 3 {tags remove "vdv_link_to_place1"}}}			        
			
			}		
			{spawn "fj"}
			
	}		
	{on overlap begin		      
			{if tagged "rampa_open"				
				{if effector "heavy_M"					
					{call "load_light_vehicle"}				
				else  effector "medium_M"					
					{call "load_light_vehicle"}				
				else  effector "armored_car_M"					
					{call "load_light_vehicle"}				
				else  effector "light_M"					
					{call "load_light_vehicle"}				
				else  effector "car"					
					{call "load_light_vehicle"}				
				}		       
			}		


		}		
		{on "script_update_cargo_anim"			
			{if tagged "place1_busy" {ani_wind "vehicle1_in" end} else {ani_wind "vehicle1_in" begin}}	
		}		
		{on "open_cargo"			
			{if not tagged "cargo_open"				
				{volumes "vehicle" enable overlap}			
			}			
			{if "engine_started" {call "engine_stop_load"}}		
		}		
		(define "scripted_unload"			
			{on animation_end "vehicle%0_unload" overload				
				{with_linked_entity "vehicle%0"					
					{tags add "unlink_me"}					
					{able "sinking" 0}				
				}			
			}	    
		)		
		("scripted_unload" args 1)
		(define "zubr_unload"			
			{if tagged "place%place_busy"				
				{delay %delay {volumes disable overlap} {ani_play "cargo_unload"} {ani_play "vehicle%place_unload" callback}}			
			}		
		)		
		{on animation_end "cargo_open"	overload		          
			{if tagged "cargo_inside"					
				{tags remove "cargo_inside"}					
				{chassis_work 0}					
				{if tagged "place3_busy"						
					{delay 10 {call "zubr_unload_step2"}}					
				else tagged "place4_busy"						
					{delay 10 {call "zubr_unload_step2"}}					
				else {call "zubr_unload_step2"}					
				}					
				("zubr_unload" place(3) delay(0))					
				("zubr_unload" place(4) delay(5))					
				("zubr_unload" place(7) delay(0))					
				{tags remove "place3_busy"}{tags remove "place4_busy"}{tags remove "place7_busy"}				 
					else {volumes "vehicle" enable overlap}		          
			}		
		}
		{on "zubr_unload_step2"			
			("zubr_unload" place(1) delay(0))			
			("zubr_unload" place(2) delay(5))			
			{tags remove "place1_busy"}
			{tags remove "place2_busy"}
			{delay 5 {chassis_work 1}}		
		}
}

;=========================constr============================================================
{"dom"
	{on spawn
		{delay 5
			{call "update_volume_touch"}
		}
	}
	{on "update_volume_touch"
		{volumes "attach" enable touch}
	}
}
{"smoke"
	{on spawn			
		{add_view	 "smoke_sm"	"fx_smoke_sm"	"fx_smoke_sm"}
		{view start "fx_smoke_sm"}
		{view show "fx_smoke_sm"}
	}
	
}



{"iron_dome"		
	{on spawn			
		{add_view	 "flash_gun_big"	"shooter00"	"shooter00"}			
		{add_view	 "flash_gun_big"	"shooter01"	"shooter01"}			
		{add_view	 "flash_gun_big"	"shooter02"	"shooter02"}			
		{add_view	 "flash_gun_big"	"shooter03"	"shooter03"}		
		{add_view	 "flash_gun_big"	"shooter04"	"shooter04"}
		{add_view	 "flash_gun_big"	"shooter05"	"shooter05"}
		{add_view	 "flash_gun_big"	"shooter06"	"shooter06"}
		{add_view	 "flash_gun_big"	"shooter07"	"shooter07"}
		{add_view	 "flash_gun_big"	"shooter08"	"shooter08"}
		{add_view	 "flash_gun_big"	"shooter09"	"shooter09"}
		{add_view	 "flash_gun_big"	"shootere09"	"shootere09"}
		{add_view	 "flash_gun_big"	"shootere08"	"shootere08"}
		{add_view	 "flash_gun_big"	"shootere07"	"shootere07"}
		{add_view	 "flash_gun_big"	"shootere06"	"shootere06"}
		{add_view	 "flash_gun_big"	"shootere05"	"shootere05"}
		{add_view	 "flash_gun_big"	"shootere04"	"shootere04"}
		{add_view	 "flash_gun_big"	"shootere03"	"shootere03"}
		{add_view	 "flash_gun_big"	"shootere02"	"shootere02"}
		{add_view	 "flash_gun_big"	"shootere01"	"shootere01"}
		{add_view	 "flash_gun_big"	"shootere00"	"shootere00"}
		{add_view	 "startsmoke_big"	"shooter00"	"tail00"}			
		{add_view	 "startsmoke_big"	"shooter01"	"tail01"}			
		{add_view	 "startsmoke_big"	"shooter02"	"tail02"}			
		{add_view	 "startsmoke_big"	"shooter03"	"tail03"}		
		{add_view	 "startsmoke_big"	"shooter04"	"tail04"}
		{add_view	 "startsmoke_big"	"shooter05"	"tail05"}
		{add_view	 "startsmoke_big"	"shooter06"	"tail06"}
		{add_view	 "startsmoke_big"	"shooter07"	"tail07"}
		{add_view	 "startsmoke_big"	"shooter08"	"tail08"}
		{add_view	 "startsmoke_big"	"shooter09"	"tail09"}
		{add_view	 "startsmoke_big"	"shootere09"	"tail10"}
		{add_view	 "startsmoke_big"	"shootere08"	"tail11"}
		{add_view	 "startsmoke_big"	"shootere07"	"tail12"}
		{add_view	 "startsmoke_big"	"shootere06"	"tail13"}
		{add_view	 "startsmoke_big"	"shootere05"	"tail14"}
		{add_view	 "startsmoke_big"	"shootere04"	"tail15"}
		{add_view	 "startsmoke_big"	"shootere03"	"tail16"}
		{add_view	 "startsmoke_big"	"shootere02"	"tail17"}
		{add_view	 "startsmoke_big"	"shootere01"	"tail18"}
		{add_view	 "startsmoke_big"	"shootere00"	"tail19"}
	}		

	{on fire "gun2" 			
		{weapon_work "gun" 0}
			{Delay 1.7
		{weapon_work "gun" 1}
		}
		(define "fire_barrel"				
			name "%0"					
			{spawn "startsmoke" "shooter%0"   x}					
			{delay 0.1 {spawn "tamir_carrier" "shooter%0"   x}}	                                                           					
			{view start "shooter%0"}					
			{spawn "dust_shot_big_2" "basis"}					
			{delay 0.42						
			{view pause "shooter%0"}					
			}			
		)				
		{if    
			("fire_barrel" args 00)				 
			else ("fire_barrel" args 01)				  
			else ("fire_barrel" args 02)				
			else ("fire_barrel" args 03)				
			else ("fire_barrel" args 03)
			else ("fire_barrel" args 04)
			else ("fire_barrel" args 05)
			else ("fire_barrel" args 06)
			else ("fire_barrel" args 07)
			else ("fire_barrel" args 08)
			else ("fire_barrel" args 09)
		}				
		("cw_check_shooting" weap_id(gun2))		
	}	
	{on fire "gun" 			
		{weapon_work "gun2" 0}
			{Delay 1.7
		{weapon_work "gun2" 1}
		}
		(define "fire_barrel"				
			name "%0"					
			{spawn "startsmoke" "shootere%0"   x}					
			{delay 0.1 {spawn "tamir_carrier" "shootere%0"   x}}	                                                           					
			{view start "shootere%0"}					
			{spawn "dust_shot_big_2" "basis"}					
			{delay 0.42						
			{view pause "shootere%0"}					
			}			
		)				
		{if    
			("fire_barrel" args 00)				 
			else ("fire_barrel" args 01)				  
			else ("fire_barrel" args 02)				
			else ("fire_barrel" args 03)				
			else ("fire_barrel" args 03)
			else ("fire_barrel" args 04)
			else ("fire_barrel" args 05)
			else ("fire_barrel" args 06)
			else ("fire_barrel" args 07)
			else ("fire_barrel" args 08)
			else ("fire_barrel" args 09)
		}				
		("cw_check_shooting" weap_id(gun))		
	}
}


{"fh70_new"		
	{on spawn					
		{add_view 	"smoke_zenit" 	"zenite_smoke" 		"foresight1"}		    	
	}	   
	{on fire "gun" 	    	 	
		{spawn "canon_gaub_fire" "Foresight1" x}	      		
		{spawn "dust_shot_big_2" "basis"}			
		{view start "smoke_add"}			
		{delay 0.16 "shell_off"				
		{view start "zenite_smoke"}				
		{view pause "smoke_add"}				
		{view pause "flashbarrel_gun"}					
		{delay 5						
		{view pause "zenite_smoke"}					
		}			
		}		
	}			
	{on "cut_parts"			
		("cut_part" args "wheelleft")			
		("cut_part" args "wheelright")			
		("cut_part" args "turret")			
		("cut_part" args "standr")			
		("cut_part" args "standl")			
		("cut_part" args "standl1")		
	}		
}




;=============================================new_fx==========================================


 {"tunguska"		
 	{on spawn					
 		{add_view "autocannon_gilz"	"gun_flash00" "fxshell00"}			
 		{add_view "autocannon_gilz"	"gun_flash01" "fxshell01"}			
 		{add_view	 	"flash_gun_big"	"gun_flash00"		"shooter00"}			
 		{add_view	 	"flash_gun_big"	"gun_flash01"		"shooter01"}		
 	}		
 	("Shilka_sound")		
 	("radar_lifting90_params" triplex(additional_triplex) visor(visor3) anim_rotate(radar_loop) anim_lift(radar_lift) marker(antirad_generator_rus))		
 	{on "init_gun" overload	}		
 	{on fire "gun" overload			
 		(define "fire_barrel"				
 			name "%0"					
 			{ani_play "fire%0"}					
 			{view start	"gun_flash%0"}					
 			{spawn "autocannon_fire" "fxshell%0"   x}					
 			{spawn "startsmoke_grl" "fxshell%0"   x}					
 			{spawn "tank_canon_fire_verysmall" "shooter%0"   x}					
 			{delay 0.2 {view pause	"gun_flash%0"}}			
 		)			
 		{if   
 			("fire_barrel" args 00)					
 			{spawn "tank_canon_fire_verysmall" "smoke_gunr1"   x}					
 			{spawn "tank_canon_fire_verysmall" "smoke_gunr2"   x}					  
 			else ("fire_barrel" args 01)					
 			{spawn "tank_canon_fire_verysmall" "smoke_gunl1"   x}					
 			{spawn "tank_canon_fire_verysmall" "smoke_gunl2"   x}				
 		}			
 	("cw_check_shooting" weap_id(gun))		
 	}		
 	{on ik begin "turret"	                                                                                 		       
 		{delay 0.1 "turret_rot"			
 			{if rand 0.5 {ani_play "hit" 1}			
 				else	{ani_play "hit" -1}			
 			}		       
 		}		
 	}		
 	{on ik end "turret"			
 		{kill_delay "turret_rot"}		
 	}		
 	{on "init_gun2"			
 		{add_view 	"rok_tail"		"tail00"			"tail00"}			
 		{add_view 	"rok_tail"		"tail01"			"tail01"}			
 		{add_view 	"rok_tail"		"tail02"			"tail02"}			
 		{add_view 	"rok_tail"		"tail03"			"tail03"}			
 		{add_view 	"rok_tail"		"tail04"			"tail04"}			
 		{add_view 	"rok_tail"		"tail05"			"tail05"}			
 		{add_view 	"rok_tail"		"tail06"			"tail06"}			
 		{add_view 	"rok_tail"		"tail07"			"tail07"}		
 	}		
 	{on fire "gun2" overload			
 		(define "fire_barrel"				
 			name "%0"					
 			{delay 0.1 						
 				{if not tagged "radar_off"							
 					{spawn "9m311_carrier" "R_shooter%0"   x}						
 				else				                                                      							
 					{spawn "9m311_carrier" "R_shooter%0"   x								
 						{delay 1.05 									
 							{volumes "proximity" disable all}								
 						}							
 					}						
 				}					
 			}					
 			{view start "tail%0"}					
 			{spawn "startsmoke" "R_shooter%0" x}					
 			{spawn "startsmoke" "tail%0" x}					
 			{delay 0.4						
 				{view pause "tail%0"}					
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
 		}			
 	("cw_check_shooting" weap_id(gun2))		
 	}		
 	{on "cut_parts"			
 		{if rand 0.5			     
 			{tear "piece_large_steel" bone "Gun_l1" id "Gun_rot"				
 				{impulse dir 0.5 1}				
 				{if rand 0.2 {add_view "smoke_dead_norm" "smoke" "basis"}				
 			else {add_view "smoke_black" "smoke" "basis"}}				
 				{view start "smoke"}				
 				{delay_effect 30 5 "pause"}				
 				{delay 0.1 {volumes "gun" disable obstacle}}			     
 			}			
 		}			
 		{if rand 0.5			     
 			{tear "piece_large_steel" bone "Gun_r1" id "Gun_rot"				
 				{impulse dir 0.5 1}				
 				{if rand 0.2 {add_view "smoke_dead_norm" "smoke" "basis"}				
 			else {add_view "smoke_black" "smoke" "basis"}}				
 				{view start "smoke"}				
 				{delay_effect 30 5 "pause"}				
 				{delay 0.1 {volumes "gun" disable obstacle}}			    
 			}			
 		}			
 		{if rand 0.5			     
 			{tear "piece_large_steel" bone "Radar_Kron"				
 				{impulse dir 0.5 1}				
 				{if rand 0.2 {add_view "smoke_dead_norm" "smoke" "basis"}				
 			else {add_view "smoke_black" "smoke" "basis"}}				
 				{view start "smoke"}				
 				{delay_effect 30 5 "pause"}			    
 			}			
 		}			
 		{if rand 0.5			     
 			{tear "piece_large_steel" bone "Radar_r"				
 				{impulse dir 0.5 1}				
 				{if rand 0.2 {add_view "smoke_dead_norm" "smoke" "basis"}				
 			else {add_view "smoke_black" "smoke" "basis"}}				
 				{view start "smoke"}				
 				{delay_effect 30 5 "pause"}			    
 			}			
 		}		
 	}	
 }

 {"fp1_base"		
	{on "add_movement_sound" overload			
		{link_sound "engine_start"		"vehicle/airborne/small_uav/shahed136_start"			}			
		{link_sound "engine_work"		"vehicle/airborne/small_uav/shahed136_engine"			}			
		{link_sound "engine_stop"		"vehicle/airborne/small_uav/shahed136_engine_end"			}		
	}		
	{on "link_flare_fx" overload}		
	{on "engine_on"			
	{if not "engine_started"				
		{set "engine_started" 1}				
		{play_sound "engine_start"}				
		{ani_play "engine_start" callback}			
	}			
	{if not altitude 15				
	{link_sound "rocket"		"vehicle/airborne/small_uav/shahed136_rocket"			}				
	{play_sound "rocket"}				
	{add_view	"proj_jet_atgm"			"proj_jet"			"fx_starter"}				
	{view start "proj_jet"}				
	{view show "proj_jet"}				
	{delay 2 					
		{view stop "proj_jet"}					
		{view hide "proj_jet"}					
		{tear "piece_medium_steel" bone "part4" {impulse forward 5 up -0.1}}				
	}			
	else				
		{bone cut "part4"}			
	}		
	}		
	{on animation_end "engine_start"			
	{ani_play "engine_work" loop}			
	{play_sound "engine_work" 1}		
}		                                            		
	("loitering_munition" missilename(fp1_base))		
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
		{inherited}			{stuff_detonate}		
	}		
	{on "underground_detonate" overload			
		{if rand 0.3 ("cut_part" args "part1")}			
		{if rand 0.3 ("cut_part" args "tail1")}			
		{if rand 0.3 ("cut_part" args "tail2")}		    
		{inherited}			
		{stuff_detonate}		
	}	
}

 {"fp5_base"		
 	{on "link_engine_effects" overload			
		{add_view	"exhaust_dark_big"	"engine1_exhaust"		"engine1_exhaust"	}						
		{add_view	"exhaust_dark_big"		"engine1_overburn"		"engine1_exhaust"	}			
	}
	{on "add_movement_sound" overload			
		{link_sound "engine_start"		"vehicle/airborne/jet_engine_start"				}			
		{link_sound "engine_work"		"vehicle/airborne/jet_engine_work"			}			
		{link_sound "engine_stop"		"vehicle/airborne/jet_engine_stop"			}		
	}		
	{on "link_flare_fx" overload}		
	{on "engine_on"			
	{if not "engine_started"				
		{set "engine_started" 1}				
		{play_sound "engine_start"}				
		{ani_play "engine_start" callback}			
	}			
	{if not altitude 15				
	{link_sound "rocket"		"vehicle/airborne/jet_engine_work"		}				
	{play_sound "rocket"}				
	{add_view	"proj_jet_atgm"			"proj_jet"			"fx_starter"}				
	{view start "proj_jet"}				
	{view show "proj_jet"}				
	{delay 2 					
		{view stop "proj_jet"}					
		{view hide "proj_jet"}					
		{tear "piece_medium_steel" bone "part4" {impulse forward 5 up -0.1}}				
	}			
	else				
		{bone cut "part4"}			
	}		
	}		
	{on animation_end "engine_start"			
	{ani_play "engine_work" loop}			
	{play_sound "engine_work" 1}		
}		                                            		
	("loitering_munition" missilename(fp5_base))		
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
		{inherited}			{stuff_detonate}		
	}		
	{on "underground_detonate" overload			
		{if rand 0.3 ("cut_part" args "part1")}			
		{if rand 0.3 ("cut_part" args "tail1")}			
		{if rand 0.3 ("cut_part" args "tail2")}		    
		{inherited}			
		{stuff_detonate}		
	}	
}