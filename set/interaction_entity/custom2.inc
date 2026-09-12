(define "brdm2_shield_sound"
	{on "add_movement_sound" overload
		{link_sound "move"		"vehicle/wheels/Truck_loop_3"}
		{link_sound "engine"		"vehicle/engine/Brdm_engine_1"}
		{link_sound "rotate_turret" 	"vehicle/turret/light_m1"}
		{link_sound "exhaust"		"vehicle/engine/brdm_start"}
		{link_sound "engine_end"	"vehicle/engine/brdm_shut_off"}
	}
)


(define "brdm2_ATGM_new_sound"
	{on "add_movement_sound" overload
		{link_sound "move"		"vehicle/wheels/Truck_loop_3"}
		{link_sound "engine"		"vehicle/engine/Brdm_engine_1"}
		{link_sound "rotate_turret" 	"vehicle/turret/light_m1"}
		{link_sound "exhaust"		"vehicle/engine/brdm_start"}
		{link_sound "engine_end"	"vehicle/engine/brdm_shut_off"}
	}
)

{"brdm2_ATGM_new"
	("brdm2_ATGM_new_sound")
	("atgm_multi_launcher" weapon(gun2) foresight(foresight) tail(tail))
}

{"t-64bv_flag"
	("T64_sound")
	("2a46_type_gun")	
}
{"t-64bv_wagner"
	("T64_sound")
	("2a46_type_gun")
}
{"t-64bm1_flag"
	("T64_sound")
	("2a46_type_gun")
}

(define "bmp2_brevno_sound"
	{on "add_movement_sound" overload
		{link_sound "move"		"vehicle/tracks/bmp2_Tracks"}
		{link_sound "engine"		"vehicle/engine/BMP_rus_engine"}
		{link_sound "rotate_turret"	"vehicle/turret/light_m1"}
		{link_sound "exhaust"		"vehicle/engine/BMP_rus_engine_start"}
		{link_sound "engine_end"	"vehicle/engine/bmp_end"}
	}
)

(define "bmp2_bez_ekran_sound"
	{on "add_movement_sound" overload
		{link_sound "move"		"vehicle/tracks/bmp2_Tracks"}
		{link_sound "engine"		"vehicle/engine/BMP_rus_engine"}
		{link_sound "rotate_turret"	"vehicle/turret/light_m1"}
		{link_sound "exhaust"		"vehicle/engine/BMP_rus_engine_start"}
		{link_sound "engine_end"	"vehicle/engine/bmp_end"}
	}
)

{"bmp2_bez_ekran"
	("bmp2_bez_ekran_sound")
}

{"bmp2_bez_ekran"
	{on spawn			
		{add_view "smoke_zenit" 	"zenite_smoke" "foresight1"}					
 	}
	{on fire "gun" 	      	    	 
		{spawn "BMP2_canon_fire" "Foresight1" x}								
		{view start "flashbarrel_gun"}						
		{view start "smoke_add"}			
		{delay 0.16 "shell_off"			
			{view start "zenite_smoke"}
		}		
		{view pause "smoke_add"}			
		{view pause "flashbarrel_gun"}
			
		{delay 5			
			{view pause "zenite_smoke"}		
		}	
		{spawn "gilza_30mm" "fx_invers"
	        		{add_view "smoke_zenit" "smoke_shell" "fx_invers"}
				{view start "smoke_shell"}
				{impulse up 0.1 0.1 dir 6 0  cz 0.3 0.3 com }
				{delay 5
					{view pause "smoke_shell"}
                        			}
				{delay 7
					{hide 7}
				}
			}
		}
		("atgm_single_launcher" weapon(gun2) foresight(foresight6) tail(tail))
}

(define "Ural_ufo_sound"
	{on "add_movement_sound" overload
		{link_sound "move"		"vehicle/wheels/Truck_loop_3"}
		{link_sound "engine"		"vehicle/engine/Ural_ufo_engine"}
		{link_sound "engine_end"	"vehicle/engine/Ural_ufo_shut_off"}
		{link_sound "rotate_turret"	"vehicle/turret/light1"}
		{link_sound "exhaust"		"vehicle/engine/Ural_ufo_start"}
	}
)

{"ural_4320_inf"
	("Ural_ufo_sound")
}

{"ural_ufo_ammo"
	("Ural_ufo_sound")
}

{"ural_ufo_eng"
	("Ural_ufo_sound")
}

{"ural_bm_21"
	("Ural_ufo_sound")
	
	{on ik begin "turret"
		{play_sound "rotate_turret" 1}
	}
	{on ik end "turret"
		{stop_sound "rotate_turret"}
	}
	{on fire "gun"
		{spawn "sturmtiger_fire" inv_normal}
		{if rand 0.5
			{spawn "dust_shot_big_2" "basis"}
		}
		{ani_play "fire"}	
		{view start "flashbarrel_gun"}
		{view start "smoke_add"}	
		{delay 0.16 "shell_off"
			{view pause "smoke_add"}
			{view pause "flashbarrel_gun"}
		}
	}
}

{"ura" 
	{on spawn 
		{add_view "sturmtiger_fire" "Rocket_tail00" "tail_00"} 
		{add_view "sturmtiger_fire" "Rocket_tail01" "tail_01"} 
		{add_view "sturmtiger_fire" "Rocket_tail02" "tail_02"} 
		{add_view "sturmtiger_fire" "Rocket_tail03" "tail_03"} 
		{add_view "sturmtiger_fire" "Rocket_tail04" "tail_04"} 
		{add_view "sturmtiger_fire" "Rocket_tail05" "tail_05"}
		{add_view "sturmtiger_fire" "Rocket_tail06" "tail_06"} 
		{add_view "sturmtiger_fire" "Rocket_tail07" "tail_07"} 
		{add_view "sturmtiger_fire" "Rocket_tail08" "tail_08"} 
		{add_view "sturmtiger_fire" "Rocket_tail09" "tail_09"} 
		{add_view "sturmtiger_fire" "Rocket_tail10" "tail_10"} 
		{add_view "sturmtiger_fire" "Rocket_tail11" "tail_11"}
		{add_view "sturmtiger_fire" "Rocket_tail12" "tail_12"} 
		{add_view "sturmtiger_fire" "Rocket_tail13" "tail_13"} 
		{add_view "sturmtiger_fire" "Rocket_tail14" "tail_14"} 
		{add_view "sturmtiger_fire" "Rocket_tail15" "tail_15"} 

	} 
	("9k72_sound") 
	{on fire "gun" 
		(define "fire_barrel" name "%0" 
			{view start "Rocket_tail%0"} 
			{delay 0.42 
				{view pause "Rocket_tail%0"} 
			} 
		)
		{if rand 0.5
			{spawn "dust_shot_big_2" "basis"}
		}
		{if ("fire_barrel" args 00) 
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

		} 

	}
} 

{"urag"
	{on spawn
		{add_view	"exhaust_dark_small"	"exhaust"		"FXsmoke"}
		{add_view	"exhaust_dark_small"	"exhaust"		"FXsmoke1"}

        	{add_view 	"startsmoke_big" 	"Rocket_tail00" 		"tail_00"}			
        	{add_view 	"startsmoke_big" 	"rocket_tail01" 		"tail_01"}			
        	{add_view 	"startsmoke_big" 	"rocket_tail02" 		"tail_02"}			
        	{add_view 	"startsmoke_big" 	"rocket_tail03" 		"tail_03"}			 
        	{add_view 	"startsmoke_big" 	"rocket_tail04" 		"tail_04"}			
        	{add_view 	"startsmoke_big" 	"rocket_tail05" 		"tail_05"}			
        	{add_view 	"startsmoke_big" 	"rocket_tail06" 		"tail_06"}			
        	{add_view 	"startsmoke_big" 	"rocket_tail07" 		"tail_07"}			
        	{add_view 	"startsmoke_big" 	"rocket_tail08" 		"tail_08"}			
        	{add_view 	"startsmoke_big" 	"rocket_tail09" 		"tail_09"}			
        	{add_view 	"startsmoke_big" 	"rocket_tail10" 		"tail_10"}			
        	{add_view 	"startsmoke_big" 	"rocket_tail11" 		"tail_11"}
        	{add_view 	"startsmoke_big" 	"rocket_tail12" 		"tail_12"}			
        	{add_view 	"startsmoke_big" 	"rocket_tail13" 		"tail_13"}			
        	{add_view 	"startsmoke_big" 	"rocket_tail14" 		"tail_14"}
        	{add_view 	"startsmoke_big" 	"rocket_tail14" 		"tail_14"}
	}
	("9k72_sound")

	{on ik begin "turret"
		{play_sound "rotate_turret" 1}
	}
	{on ik end "turret"
		{stop_sound "rotate_turret"}
	}
	{on fire "gun"
		{spawn "sturmtiger_fire" inv_normal}
		{if rand 0.5
			{spawn "dust_shot_big_2" "basis"}
		}
		{ani_play "fire"}	
		{view start "flashbarrel_gun"}
		{view start "smoke_add"}	
		{delay 0.16 "shell_off"
			{view pause "smoke_add"}
			{view pause "flashbarrel_gun"}
		}
	}

}

(define "H2_DShKM_sound"
	{on "add_movement_sound" overload
			{link_sound "move"		"vehicle/wheels/hmmwv"}
			{link_sound "engine"		"vehicle/engine/Humvee"}
			{link_sound "engine_end"	"vehicle/engine/Humvee"}
			{link_sound "rotate_turret" 	"vehicle/turret/light1"}
			{link_sound "exhaust"		"vehicle/engine/car_up"}
	}
)

{"H2_DShKM"
	("H2_DShKM_sound")
	("commonzpu_params" gunner(gunner) zpu_mgun(mgun) anim(into_hatch_common) pose(seat_m7_mgunner))
}
{"H2_DShKM_turret"
	("commonzpu_params" gunner(gunner) zpu_mgun(mgun) anim(into_hatch_car) pose(seat_gunner_stand))
}


{"H2_DShKM"
	("H2_DShKM_sound")

}

(define "bmp-2_ukr"	
	{on "add_movement_sound" overload		
		{link_sound "move"		"vehicle/bmp-2_ukr/b_trak"}
		{link_sound "rotate_turret" 	"vehicle/bmp-2_ukr/turret_b1"}
		{link_sound "engine"		"vehicle/bmp-2_ukr/engine"}
		{link_sound "exhaust"		"vehicle/bmp-2_ukr/engine_up"}
		{link_sound "engine_end"	"vehicle/bmp-2_ukr/engine_end"}
	}
)

{"bmp-2_ukr"
	{on spawn			
		{add_view "smoke_zenit" 	"zenite_smoke" "foresight1"}					
 	}
	{on fire "gun" 	      	    	 
		{spawn "BMP2_canon_fire" "Foresight1" x}								
		{view start "flashbarrel_gun"}						
		{view start "smoke_add"}			
		{delay 0.16 "shell_off"			
			{view start "zenite_smoke"}
		}		
		{view pause "smoke_add"}			
		{view pause "flashbarrel_gun"}
			
		{delay 5			
			{view pause "zenite_smoke"}		
		}	
		{spawn "gilza_30mm" "fx_invers"
	        	{add_view "smoke_zenit" "smoke_shell" "fx_invers"}
			{view start "smoke_shell"}
			{impulse up 0.1 0.1 dir 6 0  cz 0.3 0.3 com }
			{delay 5
				{view pause "smoke_shell"}
                        }
			{delay 7
				{hide 7}
			}
		}
	}
}

{"bmp-2_ukr"
	("bmp-2_ukr")
}

(define "bmp-1_ukr"	
	{on "add_movement_sound" overload		
		{link_sound "move"		"vehicle/bmp-1_ukr/b_trak"}
		{link_sound "rotate_turret" 	"vehicle/bmp-1_ukr/turret_b1"}
		{link_sound "engine"		"vehicle/bmp-1_ukr/engine"}
		{link_sound "exhaust"		"vehicle/bmp-1_ukr/engine_up"}
		{link_sound "engine_end"	"vehicle/bmp-1_ukr/engine_end"}
	}
)

{"bmp-1_ukr"
	("atgm_single_launcher" weapon(gun2) foresight(foresight6) tail(tail))
}

{"bmp-1_ukr"
	("bmp-1_ukr")
}
{"cannon zu_23_new"
	{on "add_movement_sound"  overload
		{link_sound "rotate_turret" "vehicle/turret/light_m1"}
	}
	("handle_ik")
	{on "init_gun"	
		{add_view "light_flash_zenit"	"flashbarrel"	"foresight1"}
		{add_view "flash_zenit"		"flashbarrel00"	"shooter00"}
		{add_view "flash_zenit"		"flashbarrel01"	"shooter01"}
		{add_view "smoke_zenit"		"smoke00"	"shooter00"}
		{add_view "smoke_zenit"		"smoke01"	"shooter01"}
		{add_view "zenit_gilz"		"shell"		"FXshell"}
		{add_view "zenit_gilz"		"shell"		"FXshell1"}
		{add_view "circledust_norm2"	"dust"		"basis"}
		{call "update_gun"}
	}
	{on "fire_gun_common"
		{view start "flashbarrel"}
		{ani_play "recoil"}
		{kill_delay "shell_off"}
		{view start "shell"}
		{view start "dust"}
		{delay 0.12 "shell_off"
			{view pause "shell"}
			{view pause "dust"}
		}
	}
}



{"gaz-66_new-ZU"
	{on "add_movement_sound" overload
		{link_sound "move"		"vehicle/wheels/Truck_loop_3"}
		{link_sound "engine"		"vehicle/engine/Ural_engine"}
		{link_sound "engine_end"	"vehicle/engine/Ural_4320_shut_off"}
		{link_sound "rotate_turret" 	"vehicle/turret/light_m1"}
		{link_sound "exhaust"		"vehicle/engine/Ural_4320_start"}
	}
	{on ik begin "turret"
		{play_sound "rotate_turret" 1}
	}
	{on ik end "turret"
		{stop_sound "rotate_turret"}
	}
	{on "init_gun"
		{add_view "light_flash_zenit"	"flashbarrel"	"foresight1"}
		{add_view "flash_zenit"		"flashbarrel00"	"shooter00"}
		{add_view "flash_zenit"		"flashbarrel01"	"shooter01"}
		{add_view "smoke_zenit"		"smoke00"	"shooter00"}
		{add_view "smoke_zenit"		"smoke01"	"shooter01"}
		{add_view "zenit_gilz"		"shell"	"FXshell"}
		{add_view "zenit_gilz"		"shell"	"FXshell1"}
		{add_view "circledust_norm2"	"dust"	"basis"}
		{call "update_gun"}
	}
	{on "fire_gun_common"
		{view start "flashbarrel"}
		{ani_play "recoil"}
		{kill_delay "shell_off"}
		{view start "shell"}
		{view start "dust"}
		{delay 0.12 "shell_off"
			{view pause "shell"}
			{view pause "dust"}
		}
	}
}

{"btr4e"
	{on spawn			
		{add_view "smoke_zenit" 	"zenite_smoke" "foresight1"}					
 	}
	{on fire "gun" 	      	    	 
		{spawn "tank_canon_fire_verysmall" "Foresight1"   x}							
		{view start "flashbarrel_gun"}						
		{view start "smoke_add"}			
		{delay 0.16 "shell_off"			
			{view start "zenite_smoke"}
		}		
		{view pause "smoke_add"}			
		{view pause "flashbarrel_gun"}
			
		{delay 5			
			{view pause "zenite_smoke"}		
		}	
		{spawn "gilza_30mm" "fx_invers"
	        	{add_view "smoke_zenit" "smoke_shell" "fx_invers"}
			{view start "smoke_shell"}
			{impulse up 0.1 0.1 dir 4 0  cz 0.3 0.3 com }
			{delay 5
				{view pause "smoke_shell"}
                        		}
			{delay 7
				{hide 7}
			}
		}
	}
}
(define "btr-4e_sound"
	{on "add_movement_sound" overload
		{link_sound "move"		"vehicle/wheels/Truck_loop_3"}
		{link_sound "engine"		"vehicle/engine/Brdm_engine_1"}
		{link_sound "rotate_turret" 	"vehicle/bmp-1_ukr/turret_b1"}
		{link_sound "exhaust"		"vehicle/engine/brdm_start"}
		{link_sound "engine_end"	"vehicle/engine/brdm_shut_off"}
	}
)
{"btr-4e"
	("atgm_single_launcher" weapon(gun2) foresight(foresight6) tail(tailR_))




}
{"btr4e1"
	{on spawn			
		{add_view "smoke_zenit" 	"zenite_smoke" "foresight1"}					
 	}
	{on fire "gun" 	      	    	 							
		{spawn "tank_canon_fire_verysmall" "Foresight1"   x}
		{view start "flashbarrel_gun"}						
		{view start "smoke_add"}			
		{delay 0.16 "shell_off"			
			{view start "zenite_smoke"}
		}		
		{view pause "smoke_add"}			
		{view pause "flashbarrel_gun"}
			
		{delay 5			
			{view pause "zenite_smoke"}		
		}	
		{spawn "gilza_30mm" "fx_invers"
	        	{add_view "smoke_zenit" "smoke_shell" "fx_invers"}
			{view start "smoke_shell"}
			{impulse up 0.1 0.1 dir 4 0  cz 0.3 0.3 com }
			{delay 5
				{view pause "smoke_shell"}
                        		}
			{delay 7
				{hide 7}
			}
		}
	}
}
(define "btr-4e_sound"
	{on "add_movement_sound" overload
		{link_sound "move"		"vehicle/wheels/Truck_loop_3"}
		{link_sound "engine"		"vehicle/engine/Brdm_engine_1"}
		{link_sound "rotate_turret" 	"vehicle/bmp-1_ukr/turret_b1"}
		{link_sound "exhaust"		"vehicle/engine/brdm_start"}
		{link_sound "engine_end"	"vehicle/engine/brdm_shut_off"}
	}
)
{"btr_3e"
	("atgm_single_launcher" weapon(stugna) foresight(foresight5) tail(tailR_))
}
{"btr4e1_ptur"
	{on spawn			
		{add_view "smoke_zenit" 	"zenite_smoke" "foresight1"}					
 	}
	{on fire "gun" 	      	    	 
		{spawn "tank_canon_fire_verysmall" "Foresight1"   x}							
		{view start "flashbarrel_gun"}						
		{view start "smoke_add"}			
		{delay 0.16 "shell_off"			
			{view start "zenite_smoke"}
		}		
		{view pause "smoke_add"}			
		{view pause "flashbarrel_gun"}
			
		{delay 5			
			{view pause "zenite_smoke"}		
		}	
		{spawn "gilza_30mm" "fx_invers"
	        	{add_view "smoke_zenit" "smoke_shell" "fx_invers"}
			{view start "smoke_shell"}
			{impulse up 0.1 0.1 dir 4 0  cz 0.3 0.3 com }
			{delay 5
				{view pause "smoke_shell"}
                        		}
			{delay 7
				{hide 7}
			}
		}
	}
}
(define "btr4e_sound"
	{on "add_movement_sound" overload
		{link_sound "move"		"vehicle/wheels/Truck_loop_3"}
		{link_sound "engine"		"vehicle/engine/Brdm_engine_1"}
		{link_sound "rotate_turret" 	"vehicle/bmp-1_ukr/turret_b1"}
		{link_sound "exhaust"		"vehicle/engine/brdm_start"}
		{link_sound "engine_end"	"vehicle/engine/brdm_shut_off"}
	}
)
{"btr-4e1_ptur"
	("atgm_single_launcher" weapon(gun2) foresight(foresight6) tail(tailR_))




}
{"btr3e"
   ("atgm_single_launcher" weapon(gun2) foresight(foresight6) tail(tail_))
}
{"btr-4e1_wtht_pt"
	{on spawn			
		{add_view "smoke_zenit" 	"zenite_smoke" "foresight1"}					
 	}
	{on fire "gun" 	      	    	 
		{spawn "tank_canon_fire_verysmall" "Foresight1"   x}							
		{view start "flashbarrel_gun"}						
		{view start "smoke_add"}			
		{delay 0.16 "shell_off"			
			{view start "zenite_smoke"}
		}		
		{view pause "smoke_add"}			
		{view pause "flashbarrel_gun"}
			
		{delay 5			
			{view pause "zenite_smoke"}		
		}	
		{spawn "gilza_30mm" "fx_invers"
	        	{add_view "smoke_zenit" "smoke_shell" "fx_invers"}
			{view start "smoke_shell"}
			{impulse up 0.1 0.1 dir 4 0  cz 0.3 0.3 com }
			{delay 5
				{view pause "smoke_shell"}
                        		}
			{delay 7
				{hide 7}
			}
		}
	}
}
(define "btr-4e_sound"
	{on "add_movement_sound" overload
		{link_sound "move"		"vehicle/wheels/Truck_loop_3"}
		{link_sound "engine"		"vehicle/engine/Brdm_engine_1"}
		{link_sound "rotate_turret" 	"vehicle/bmp-1_ukr/turret_b1"}
		{link_sound "exhaust"		"vehicle/engine/brdm_start"}
		{link_sound "engine_end"	"vehicle/engine/brdm_shut_off"}
	}
)


(define "2c3_sound"
	{on "add_movement_sound" overload
		{link_sound "move"		"vehicle/tracks/bmp2_Tracks"}
		{link_sound "engine"		"vehicle/engine/BMP_rus_engine"}
		{link_sound "rotate_turret" 	"vehicle/turret/T-72-Turret"}
		{link_sound "exhaust"		"vehicle/engine/BMP_rus_engine_start"}
		{link_sound "engine_end"	"vehicle/engine/bmp_end"}
	}
)

{"proba"
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
  		{spawn "msta_shell" "fx_gilza" x scale 2
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



{"2c3"
	("2c3_sound")
}	                                       		               	                	                    	   	           	                     	                     	    	   	  	
{"tunguska_nov"		
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
 		(define "fire_barrel"				name "%0"					
 			{ani_play "fire%0"}					
 			{view start	"gun_flash%0"}					
 			{spawn "autocannon_fire" "fxshell%0"   x}					
 			{spawn "startsmoke_grl" "fxshell%0"   x}					
 			{spawn "tank_canon_fire_small" "shooter%0"   x}					
 			{delay 0.2 {view pause	"gun_flash%0"}}			
 		)			
 			{if    
 				("fire_barrel" args 00)					
 				{spawn "tank_canon_fire_small" "smoke_gunr1"   x}					
 				{spawn "tank_canon_fire_small" "smoke_gunr2"   x}					  
 					else ("fire_barrel" args 01)					
 					{spawn "tank_canon_fire_small" "smoke_gunl1"   x}					
 					{spawn "tank_canon_fire_small" "smoke_gunl2"   x}				
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
 		(define "fire_barrel"				name "%0"					
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
 		{if    ("fire_barrel" args 00)				  
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
 		 		{view start "smoke"}				{delay_effect 30 5 "pause"}				
 		 		{delay 0.1 {volumes "gun" disable obstacle}}			    
 		 	}			
 		 }			{if rand 0.5			     {tear "piece_large_steel" bone "Radar_Kron"				{impulse dir 0.5 1}				{if rand 0.2 {add_view "smoke_dead_norm" "smoke" "basis"}				else {add_view "smoke_black" "smoke" "basis"}}				{view start "smoke"}				{delay_effect 30 5 "pause"}			     }			}			{if rand 0.5			     {tear "piece_large_steel" bone "Radar_r"				{impulse dir 0.5 1}				{if rand 0.2 {add_view "smoke_dead_norm" "smoke" "basis"}				else {add_view "smoke_black" "smoke" "basis"}}				{view start "smoke"}				{delay_effect 30 5 "pause"}			     }			}		}	}	

{"tunguska_ukr"		
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
 		(define "fire_barrel"				name "%0"					
 			{ani_play "fire%0"}					
 			{view start	"gun_flash%0"}					
 			{spawn "autocannon_fire" "fxshell%0"   x}					
 			{spawn "startsmoke_grl" "fxshell%0"   x}					
 			{spawn "tank_canon_fire_small" "shooter%0"   x}					
 			{delay 0.2 {view pause	"gun_flash%0"}}			
 		)			
 			{if    
 				("fire_barrel" args 00)					
 				{spawn "tank_canon_fire_small" "smoke_gunr1"   x}					
 				{spawn "tank_canon_fire_small" "smoke_gunr2"   x}					  
 					else ("fire_barrel" args 01)					
 					{spawn "tank_canon_fire_small" "smoke_gunl1"   x}					
 					{spawn "tank_canon_fire_small" "smoke_gunl2"   x}				
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
 		(define "fire_barrel"				name "%0"					
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
 		{if    ("fire_barrel" args 00)				  
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
 		 		{view start "smoke"}				{delay_effect 30 5 "pause"}				
 		 		{delay 0.1 {volumes "gun" disable obstacle}}			    
 		 	}			
 		 }			{if rand 0.5			     {tear "piece_large_steel" bone "Radar_Kron"				{impulse dir 0.5 1}				{if rand 0.2 {add_view "smoke_dead_norm" "smoke" "basis"}				else {add_view "smoke_black" "smoke" "basis"}}				{view start "smoke"}				{delay_effect 30 5 "pause"}			     }			}			{if rand 0.5			     {tear "piece_large_steel" bone "Radar_r"				{impulse dir 0.5 1}				{if rand 0.2 {add_view "smoke_dead_norm" "smoke" "basis"}				else {add_view "smoke_black" "smoke" "basis"}}				{view start "smoke"}				{delay_effect 30 5 "pause"}			     }			}		}	}	


{"ptur_konkurs_ukr"		
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
			("cut_part" args "ptur_rot")			
			("cut_part" args "turret")			
			("cut_part" args "ptur")			
			{delay 14 {view stop "deathfx"}}		
	}	
}
{"ptur_konkurs_nov"		
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
			("cut_part" args "ptur_rot")			
			("cut_part" args "turret")			
			("cut_part" args "ptur")			
			{delay 14 {view stop "deathfx"}}		
	}	
}

