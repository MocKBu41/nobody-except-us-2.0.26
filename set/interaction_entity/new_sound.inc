
{"kraz_6322_grad"		
       ("Ural_sound")		
          {on ik begin "turret"		
                   {play_sound "rotate_turret" 1}	
          }		
          {on ik end "turret"			
                  {stop_sound "rotate_turret"}	
          }		
          {on fire "gun" 			
                  {spawn "startsmoke_big" inv_normal}			 
                   {if rand 0.5	      			
                          {spawn "dust_shot_big_2" "basis"}			
                  }			
                  {ani_play "fire"}			
                  {view start "flashbarrel_gun"}			                                                 	  {view start "smoke_add"}			
                  {delay 0.16 "shell_off"			
                  {view pause "smoke_add"}			
                  {view pause "flashbarrel_gun"}			
                  }		
          } 		
          {on "explosion"			
                  {set "big_explosion" 0}			
                  {if not "big_explosion"			       
                         {if explosive_amount 50		
  			          {blastwave c4 25 r0 15 r1 35}					
                                  {spawn "train_die" "basis"}					
                                  {set "big_explosion" 1}	                          				                 }			
                  }		
          }		
          {on "spawn_shellhole"		
     	          {if "big_explosion"                                         		                                    {spawn "crater_extra_big" "basis" terrain_texmod}	                        			          {spawn "shellhole_big_dead" "basis"}			
                  }		
          }	
}
{"kraz_6322"
	("Ural_sound")
}
{"kraz_6322_art"
	("Ural_sound")
}
{"kraz_6322_eng"
	("Ural_sound")
}
{"kraz_6322_fuel"
	("Ural_sound")
}
{"kraz_6322_flag"
	("Ural_sound")
}	
{"dozor-b_1"
	("hmmwv_sound")
}
{"hmmwv_ukr"
	("hmmwv_sound")

}	
{"UKR_car_police"
	("uaz_sound")

}	
{"UKR_car_police_black"
	("uaz_sound")

}	
{"UKR_car_—¡”"
	("hmmwv_sound")

}
{"UKR_car_—¡”1"
	("hmmwv_sound")

}
{"hummer_h2"
	("hmmwv_sound")

}
{"Ford Crown Police"
	("hmmwv_sound")

}


{"mw2_civil_truck_1"
	("uaz_sound")

}	
{"mw2_civilian_1"
	("uaz_sound")

}	
{"mw2_civilian_2"
	("uaz_sound")

}	
{"mw2_civilian_3"
	("uaz_sound")

}	
{"mw2_civilian_4"
	("uaz_sound")

}	
{"mw2_civilian_5"
	("uaz_sound")

}	
{"mw2_civilian_6"
	("uaz_sound")

}	
{"mw2_civilian_7"
	("uaz_sound")

}
{"mw2_civilian_8"
	("uaz_sound")

}
{"mw2_civilian_9"
	("uaz_sound")

}	
{"mw2_civilian_10"
	("uaz_sound")

}	
{"mw2_civilian_11"
	("uaz_sound")

}	
{"mw2_civilian_12"
	("uaz_sound")

}	
{"mw2_civilian_13"
	("uaz_sound")

}	
{"mw2_civilian_14"
	("uaz_sound")

}	
{"mw2_civilian_15"
	("uaz_sound")

}	
{"mw2_civilian_16"
	("uaz_sound")

}	
	
	

{"mw2_pikup_1"
	("hmmwv_sound")

}
{"mw2_pikup_2"
	("hmmwv_sound")

}
{"bistruck_1"
	("hmmwv_sound")

}
{"bistruck_2"
	("hmmwv_sound")

}
{"mw3_uaz_1"
	("uaz_sound")

}
{"mw3_uaz_2"
	("uaz_sound")

}	
{"mw3_uaz_3"
	("uaz_sound")

}	
{"mw3_uaz_4"
	("uaz_sound")

}	
{"mw3_uaz_5"
	("uaz_sound")

}	
{"mw3_uaz_6"
	("uaz_sound")

}	
{"mw3_uaz_7"
	("uaz_sound")

}	
{"mw3_uaz_8"
	("uaz_sound")

}
{"mw3_vanlondon_1"
	("uaz_sound")

}
{"mw3_vansas_1"
	("uaz_sound")

}
{"mw2_taxi_1"
	("uaz_sound")

}
{"mw2_policeru_1"
	("uaz_sound")

}
{"mw2_police_1"
	("uaz_sound")
}
{"mw2_vehteh_1"
	("uaz_sound")
}
{"mw2_vehteh_1"
	("uaz_sound")
}
{"uragan"
	("Ural_sound")
}



	
	
	


	
					


	
					