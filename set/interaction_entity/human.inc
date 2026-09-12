{"human"		
	{inflammation_time 0.25}		
	{on spawn			
		{add_view	"cigarettesmoke"		"smoke"		"head"}			
		{add_view	"drops_water_small2"	"on_water"	"foot3r"}			
		{add_view	"drops_water_small2"	"on_water"	"foot3l"}			
		{add_view	"drops_water_small3"	"swim"		"foot3r"}			
		{add_view	"drops_water_small3"	"swim"		"foot3l"}			
		{add_view	"drops_water_small3"	"swim"		"hand2r"}			
		{add_view	"drops_water_small3"	"swim"		"hand2l"}			
		{add_view	"wash_human_small"		"swim_move"	"head"}			
		{add_view	"drops_puddle_small"	"on_puddle"	"foot3r"}			
		{add_view	"drops_puddle_small"	"on_puddle"	"foot3l"}			
		{add_view	"drops_puddle_small"	"die_in_swamp"	"foot3r"}			
		{add_view	"drops_puddle_small"	"die_in_swamp"	"foot3l"}						                    			
		{add_view	"healing" 				"healing" "head"}			                  			
		{add_view	"marker_healing" 		"marker_healing" "head"}			
		{add_view	"marker_repair" 		"marker_repair" "head"}			
		{add_view	"marker_ammo_out" 		"marker_ammo_out" "head"}			
		{add_view	"marker_ammo_refill" 	"marker_ammo_refill" "head"}			
		{add_view	"marker_personage" 		"marker_personage" "head"}			
		{add_view	"marker_personage_acute""marker_personage_acute" "head"}			
		{add_view	"marker_veterancy" 		"marker_veterancy" "head"}						
		{add_view	"shield" 		"shield" "head"}			
		{add_view	"broken_shield" 		"broken_shield" "head"}						
		{link_sound "move_ground" "human/move/ground"}			
		{link_sound "move_road"   "human/move/road"}			
		{link_sound "move_sand"   "human/move/sand"}			
		{link_sound "move_snow"   "human/move/snow"}			
		{link_sound "move_grass"  "human/move/grass"}			
		{link_sound "door_in"			"vehicle/other/door_in"}		
		{link_sound "door_out"			"vehicle/other/door_out"}			
		{link_sound "hatch_in"			"vehicle/other/hatch_in"}			
		{link_sound "hatch_out"			"vehicle/other/hatch_out"}				
		{link_sound "swim" "human/move/swim"}						
		{if able "burning"				
			{call "add_burn_fx"}				
			{view start "burn_fire"}			
		}						
		{if tagged "cw_face1"	             				
			{bone show "head1"} {bone cut "head2"} {bone cut "head3"} {bone cut "head4"}				
			{bone cut "head5"} {bone cut "head6"} {bone cut "head7"} {bone cut "head8"} 			
		else  tagged "cw_face2"				
			{bone cut "head1"} {bone show "head2"} {bone cut "head3"} {bone cut "head4"}				
			{bone cut "head5"} {bone cut "head6"} {bone cut "head7"} {bone cut "head8"} 			
		else  tagged "cw_face3"				
			{bone cut "head1"} {bone cut "head2"} {bone show "head3"} {bone cut "head4"}				
			{bone cut "head5"} {bone cut "head6"} {bone cut "head7"} {bone cut "head8"} 			
		else  tagged "cw_face4"				
			{bone cut "head1"} {bone cut "head2"} {bone cut "head3"} {bone show "head4"}				
			{bone cut "head5"} {bone cut "head6"} {bone cut "head7"} {bone cut "head8"} 			
		else  tagged "cw_face5"				
			{bone cut "head1"} {bone cut "head2"} {bone cut "head3"} {bone cut "head4"}				
			{bone show "head5"} {bone cut "head6"} {bone cut "head7"} {bone cut "head8"} 			
		else  tagged "cw_face6"				
			{bone cut "head1"} {bone cut "head2"} {bone cut "head3"} {bone cut "head4"}				
			{bone cut "head5"} {bone show "head6"} {bone cut "head7"} {bone cut "head8"} 			
		else  tagged "cw_face7"				
			{bone cut "head1"} {bone cut "head2"} {bone cut "head3"} {bone cut "head4"}				
			{bone cut "head5"} {bone cut "head6"} {bone show "head7"} {bone cut "head8"} 			
		else  tagged "cw_face8"				
			{bone cut "head1"} {bone cut "head2"} {bone cut "head3"} {bone cut "head4"}				
			{bone cut "head5"} {bone cut "head6"} {bone cut "head7"} {bone show "head8"} 			
		else	                   				
			{if rand 0.125					
				{bone show "head1"} {bone cut "head2"} {bone cut "head3"} {bone cut "head4"}					
				{bone cut "head5"} {bone cut "head6"} {bone cut "head7"} {bone cut "head8"} 					
				{tags add "cw_face1"}				
			else  rand 0.143					
				{bone cut "head1"} {bone show "head2"} {bone cut "head3"} {bone cut "head4"}					
				{bone cut "head5"} {bone cut "head6"} {bone cut "head7"} {bone cut "head8"} 					
				{tags add "cw_face2"}				
			else  rand 0.167					
				{bone cut "head1"} {bone cut "head2"} {bone show "head3"} {bone cut "head4"}					
				{bone cut "head5"} {bone cut "head6"} {bone cut "head7"} {bone cut "head8"} 					
				{tags add "cw_face3"}				
			else  rand 0.2					
				{bone cut "head1"} {bone cut "head2"} {bone cut "head3"} {bone show "head4"}					
				{bone cut "head5"} {bone cut "head6"} {bone cut "head7"} {bone cut "head8"} 					
				{tags add "cw_face4"}				
			else  rand 0.25					
				{bone cut "head1"} {bone cut "head2"} {bone cut "head3"} {bone cut "head4"}					
				{bone show "head5"} {bone cut "head6"} {bone cut "head7"} {bone cut "head8"} 					
				{tags add "cw_face5"}				
			else  rand 0.33					
				{bone cut "head1"} {bone cut "head2"} {bone cut "head3"} {bone cut "head4"}					
				{bone cut "head5"} {bone show "head6"} {bone cut "head7"} {bone cut "head8"} 					
				{tags add "cw_face6"}				
			else  rand 0.5					
				{bone cut "head1"} {bone cut "head2"} {bone cut "head3"} {bone cut "head4"}					
				{bone cut "head5"} {bone cut "head6"} {bone show "head7"} {bone cut "head8"} 					
				{tags add "cw_face7"}				
			else					
				{bone cut "head1"} {bone cut "head2"} {bone cut "head3"} {bone cut "head4"}					
				{bone cut "head5"} {bone cut "head6"} {bone cut "head7"} {bone show "head8"} 					
				{tags add "cw_face8"}				
			}			
		}		  
		{set "overheating" 0}			
		{volumes "body_c" enable bullet}		
	}		
	{on "phone_act"		

		{link_sound "c4"		"weapon/shot/reactive/kamokadze"		}
		{play_sound "c4"}
		{delay 2
		{tags add "phone_bum"}
		}
		{delay 4 {tags remove "phone_bum"}}

	}

(define "health_damage"			
	{health_damage_count %c				
		{effects "" "hit" "damage" "die" "die"}			
	}		
)		
(define "bleed_damage"		  
	{if not dead		   
		{if "overheating"			
			{health_damage_count %c				
				{effects "" "hit" "damage" "die" "die"}			
			}	  		  
		}		   
	else 
		{set "overheating" 0}
		{view pause  "marker_personage_acute"}		  
	}			
)		
(define "bleed"		  
	{if not stuff "nobleed"		  
		{if not impregnable			
			{if rand (* 0.5 %bleed_big)				
			{call "bleed_big"}			
			else rand %bleed_med				
			{call "bleed_med"}			
			else rand %bleed_small				
			{call "bleed_small"}			
			}		   
		}		  
	}		
)		
{on "bleed_big"			
	{set "overheating" 1}			
		{delay 5 
			{if "overheating" 
				{if not dead 
					{view start  "marker_personage_acute"} 
					("bleed_damage" c(16))				
					{delay 10 
						{if "overheating" 
							("bleed_damage" c(16))					
							{if not linked 
								{delay 5 
									{if "overheating" 
										("bleed_damage" c(16))						
											{delay 5 
												{if "overheating" 
													("bleed_damage" c(16))							
													{delay 5 
													{if "overheating"
													("bleed_damage" c(16))								
													{delay 5 
													{if "overheating" 
													("bleed_damage" c(0))									
													{delay 1 
													{if "overheating"										
													{set "overheating" 0} 
													{view pause  "marker_personage_acute"}									
												}}								
											}}							
										}}						
									}}					
								}}}				
							}}			
						}}}		
}		
{on "bleed_med"			
	{set "overheating" 1}			
	{delay 5 
		{if "overheating" 
			{if not dead {view start  "marker_personage_acute"} ("bleed_damage" c(8))				
			{delay 5 {if "overheating" ("bleed_damage" c(8))					
			{delay 5 {if "overheating" ("bleed_damage" c(8))						
			{delay 5 {if "overheating" ("bleed_damage" c(8))							
			{delay 5 {if "overheating" ("bleed_damage" c(8))								
			{delay 5 {if "overheating" ("bleed_damage" c(0))									
			{delay 1 {if "overheating"										
			{set "overheating" 0} 
			{view pause  "marker_personage_acute"}									
		}}								
	}}							
	}}						
	}}					
	}}				
	}}			
	}}}		
}		
{on "bleed_small"			
	{set "overheating" 1}			
	{delay 5 {if "overheating" 
	{if not dead {view start  "marker_personage_acute"} ("bleed_damage" c(4))				
		{delay 5 {if "overheating" ("bleed_damage" c(4))					
		{delay 5 {if "overheating" ("bleed_damage" c(4))						
		{delay 5 {if "overheating" ("bleed_damage" c(4))							
		{delay 5 {if "overheating" ("bleed_damage" c(4))								
		{delay 5 {if "overheating" ("bleed_damage" c(0))									
		{delay 1 {if "overheating"										
		{set "overheating" 0} {view pause  "marker_personage_acute"}									
	}}								
	}}							
	}}						
	}}					
	}}				
	}}			
	}}}		
}		
{on contact			
	{if not impregnable				
	{kill_flags reset}				
	{volumes disable contact}				
		{delay 2					
		{volumes enable contact}				
		}				
		{if effector "tank"					
			{if not user_control						
			{health_damage_crush "die" "crush"}					
				else							
				{health_damage_crush "die" "crush"}					
				else						
				{call "knock_down"}					
			}				
			else effector "vehicle"					
				{if not dead						
				{if not user_control							
				{call "die"}						
				(mod "mp"						
					else						        
					{call "die"}						
				)						
				}					
				else						
				{spawn "bloodsparks_small"}					
				}				
				else effector "knife"					
					{if volume "body"					  
					{if not volume_armored						
					{if contact_velocity 5							
						{health_damage_count 500								
							{effects "" "hit" "damage" "die_from_knife" "die_from_knife"}							
						}						
						}					  
					}					 
					else volume "head"					  
						{if not volume_armored						
							{if contact_velocity 5							
								{health_damage_count 500								
									{effects "" "hit" "damage" "die_from_knife" "die_from_knife"}							
								}						
							}					   
							else					     
								{if rand 0.5							
									{if contact_velocity 5								
										{health_damage_count 500									
											{effects "" "hit" "damage" "die_from_knife" "die_from_knife"}								
										}							
									}						 
								}					  
						}					
						else					 	
							{if contact_velocity 5							
								{health_damage_count 100								
									{effects "" "hit" "damage" "die_from_knife" "die_from_knife"}							
								}						
							}					
						}				
(define "contact_part"				
	else effector %e					
	{if contact_velocity %v							
		("health_damage" c(%d))					
	}		  	        
)				
("contact_part" e("building_part")	v(3)	ud(20)	d(120))				
("contact_part" e("big part")		v(3)	ud(20)	d(120))				
("contact_part" e("medium part")	v(6)	ud(10)	d(100))				
("contact_part" e("small part")		v(10)	ud(3)	d(40))				
("contact_part" e("part")			v(10)	ud(3)	d(100))				
else effector "chicken"					
	{health_damage_count 0						
	{effects "" "hit" "hit" "hit" "hit"}					
	}				
	else effector "wire"					
	{health_damage_count 20						
	{effects "" "hit" "damage" "die" "die"}					
	}				
	else effector "flame_piece"					
	{health_damage_count 15						
	{effects "" "hit" "hit" "die" "die"}					
	}				
}			
}		
}	
(define "bullet_damage"						
	{health_damage_pierce							
		{effects	"hit-scream"									
		"hit-light" "hit-heavy"									
		"die" "hit-explosion"									
		"throw-off" "throw-off-and-die"							
		}							
		{explosive_treshold 70}							
		{table {30 1} {200 2.5} {500 3} {5000 5}}						
	}	
)	
(define "kill_flags"			
	{if hit_side front	
		{kill_flags front}			
			else hit_side back	{kill_flags back}			
			else				{kill_flags front back}			
	}			
	{if velocity 7		
	{kill_flags run}			
	else velocity 0.1	{kill_flags go}			
	}			
	{kill_flags piercing}			
	{if	stuff "rifle"	{kill_flags rifle}}			
	{if	stuff "mgun"	{kill_flags mgun}}			
	{if	stuff "smg"	{kill_flags smg}}			
	{if	stuff "pistol"	
	{kill_flags pistol}}	
)				
{on bullet_hit			
	{if stuff "laser_ammo"			
		else stuff "radar_ammo"			
		else stuff "IR_ff_ammo"			
		else stuff "proj_pointer"			
		else				
		{kill_flags reset}				
		{spawn "bloodsparks_small"}		                        			
	}			
	{if stuff "hesh_type_dmg" 
		{spawn "cw_cumulative_frestrict" inv_normal}			
			else stuff "cm_type_dmg cm" {spawn "rpg_restrictor" inv_normal}}			
			{if stuff "laser_ammo"			
			else stuff "radar_ammo"			
			else stuff "proj_pointer"			
			else stuff "shell"				
			{if stuff "shell fg"					
				{bullet_detonate}					
				{kill_flags reset}					
				{call "process_bullet_hit"}					
				{spawn "bloodsparks_big"}				
					else stuff "autocannon_small"					
					{kill_flags reset}					
					{call "process_bullet_hit"}					
					{call "die_with_blood"}					
					{spawn "bloodsparks_big"}				
					else stuff "shell apcr"					
					{kill_flags reset}					
					{call "process_bullet_hit"}					
					{call "die_with_blood"}					
					{spawn "bloodsparks_big"}				
					else stuff "shell apcr_h"					
					{kill_flags reset}					
					{call "process_bullet_hit"}					
					{call "die_with_blood"}					
					{spawn "bloodsparks_big"}				
					else stuff "shell ap"					
					{kill_flags reset}					
					{call "process_bullet_hit"}					
					{call "hit-explosion"}					
					{spawn "bloodsparks_big"}				
				}			
				else stuff "mgun"				
					{kill_flags reset}				
					{call "process_bullet_hit"}			
				else stuff "20mm"				
					{kill_flags reset}				
					{call "process_bullet_hit"}				
					{spawn "bloodsparks_big"}			
				else stuff "bazooka"				
					{bullet_detonate}				
					{call "process_bullet_hit"}			
					else stuff "full_shock"				
					{if stuff "tazzer" {die}}				
					{if dead					
						{tags add "melee_hit"}				
						else					
						{tags add "melee_hit_temp"}					
						{delay 5 {tags remove "melee_hit_temp"}}				
					}				
					{bullet_detonate}				
					("kill_flags")				
					("bullet_damage")	                               			
					else stuff "bullet"				
						{if volume_armored					
						{bullet_detonate}				
						}	                       				
						{call "process_bullet_hit"}			
						else				
						{call "process_bullet_hit"}			
					}		
				}		
				{on blow			
					{if not name "knife"				
					{start_sound "human/blow"}			
				}		
			}		
			{on blow opponent			
			{if name "knife"				
			{health_damage_blow					
			{effects "" "hit" "hit" "die_from_knife" "die_from_knife"}				
			}			
			else				
				{if name "head"					
				{spawn "bloodsparks_small" "head"}				
			}				
			{health_damage_blow					
			{effects "" "hit" "hit" "die" "die"}				
			}				
			{if dead					
			{tags add "melee_hit"}				
			else					
			{tags add "melee_hit_temp"}					
			{delay 5 {tags remove "melee_hit_temp"}}				
			}			
			}		
			}			
			{on "hit_in_leg"			
			{if stuff "shell" {die} 			
			else stuff "mgun" 				
			("health_damage" c(0)) 				
			("bullet_damage")			
			else stuff "hmgun" {die}{spawn "bloodsparks_big"}			
			else stuff "zenite" {die} 			
			else stuff "bullet" 				
			("health_damage" c(0))				
			("bullet_damage")			
			}		
		}		
		{on pierce			                                       			
		{if volume "crit"				                  				
		("bleed" bleed_big(0.33) bleed_med(0.2) bleed_small(0.2))			
		}		
		}						
		{on "process_bullet_hit"			
		{tags remove "melee_hit"}			
		("kill_flags")	                                                                                                			
		{if volume "foot1r" {call "hit_in_leg"} ("bleed" bleed_big(0.66) bleed_med(0.10) bleed_small(0.13))			
			else volume "foot2r" {call "hit_in_leg"} ("bleed" bleed_big(0.05) bleed_med(0.66) bleed_small(0.2))			
			else volume "foot1l" {call "hit_in_leg"} ("bleed" bleed_big(0.66) bleed_med(0.10) bleed_small(0.13))			
			else volume "foot2l" {call "hit_in_leg"} ("bleed" bleed_big(0.05) bleed_med(0.66) bleed_small(0.2))			
			else volume "body"				
			{if stuff "hmgun" {die}{spawn "bloodsparks_big"}				
			else					
			("bullet_damage")					
			("bullet_damage")					
			("bleed" bleed_big(0.10) bleed_med(0.13) bleed_small(0.2))				
		}			
		else  volume "head"			  
		  {if not impregnable								
		  	{if stuff "hmgun" {die}{spawn "bloodsparks_big" "head"}					
		  	else stuff "sniper" 						{die}{spawn "bloodsparks_big" "head"}					
		  	else stuff "mgun" {if not volume_armored {die}{spawn "bloodsparks_big" "head"}}					
		  	else stuff "smg" {if not volume_armored {die}{spawn "bloodsparks_big" "head"}}					
		  	}				
		  }				                                                            				
		  ("bullet_damage")				
		  ("bullet_damage")				
		  ("bullet_damage")								
		}					
	}		
	{on blast_hit overload	       	
		{if min_energy 2.5	            		
		{health_damage_crush "die" "crush"}	      	 
		}			  
		{if not volume_armored			  
			{if min_energy 0.5	            		
			("bleed" bleed_big(0.0) bleed_med(0.0) bleed_small(0.66))	      	 
			}			  
			{if min_energy 1.0	            		
			("bleed" bleed_big(0.0) bleed_med(0.66) bleed_small(0.0))	      	  
			}			  
		}			
		{kill_flags reset}			
		{if hit_side front	
		{kill_flags front}				
		else hit_side back	{kill_flags back}				
		else				{kill_flags front back}		   
		}			
		{kill_flags blast}				
		{if volume "head"				
		{if volume_armored					
		{if min_energy 0.1						
		{health_damage_blast							
		{effects	
			"hit-scream"										
			"hit-light" "hit-heavy"										
			"die" "hit-explosion"										
			"throw-off" "throw-off-and-die"							
		}							
		{table {0.5 0.5} {2 2.6} {10 4} {50 6}}						
		}					
		else						
		{health_damage_blast							
			{effects	"hit-scream"										
				"hit-light" "hit-heavy"										
				"die" "hit-explosion"										
				"throw-off" "throw-off-and-die"							
			}							
			{table {0.5 0.5} {2 2.6} {10 4} {50 6}}						
		}						
		("bleed" bleed_big(0.10) bleed_med(0.10) bleed_small(0.10))						
		else						
		("health_damage" c(50)) 						
		("bleed" bleed_big(0.10) bleed_med(0.10) bleed_small(0.10))											
		}				
		else					
			{health_damage_blast						
			{effects	
				"hit-scream"									
				"hit-light" "hit-heavy"									
				"die" "hit-explosion"									
				"throw-off" "throw-off-and-die"						
			}						
			{table {0.5 0.5} {2 2.6} {10 4} {50 6}}					
			}					
			("bleed" bleed_big(0.10) bleed_med(0.10) bleed_small(0.10))				
			}						
			else volume_armored				
				{if min_energy 0.1					
				{health_damage_blast						
				{effects	
				"hit-scream"									
				"hit-light" "hit-heavy"									
				"die" "hit-explosion"									
				"throw-off" "throw-off-and-die"						
				}						
				{table {0.5 0.5} {2 2.6} {10 4} {50 6}}					
				}					
				("bleed" bleed_big(0.10) bleed_med(0.10) bleed_small(0.10))				
				}			
				else				
				{health_damage_blast					
					{effects	
						"hit-scream"								
						"hit-light" "hit-heavy"								
						"die" "hit-explosion"								
						"throw-off" "throw-off-and-die"					
					}					
					{table {0.5 0.5} {2 2.6} {10 4} {50 6}}				
				}				
				("bleed" bleed_big(0.10) bleed_med(0.10) bleed_small(0.10))			
			}	                                                                                       		
		}						
		{on "die_throw_high"			
			{set "die_after_throw" 1}			
			{spawn "bloodsparks_small"}			
			{call "die_scream"}			
			{call "throw_high"}		
		}				
		{on "hit-scream"			
		{if not "talk"				
		{set "talk" 1}				
		{talk "injuring"}				
		{delay 10 2					
		{set "talk" 0}				
		}			
		}		
		}			
		{on "hit-light"			
		{spawn "bloodsparks_small"}		
		}				
		{on "hit-heavy"			
			{spawn "bloodsparks_big"}		
		}		
		{on "hit-explosion"			
		{if tagged "no_explosion"				
		{call "die"}			
		else				
			{call "die_scream"}				
			{if stuff "bullet"					                     				
				else 					
				{call "explosion"}					
		}			
		}		
		}		
		{on "throw-off"			
		{set "die_after_throw" 0}			
		{call "throw_high"}		
		}		
		{on "throw-off-and-die"			
			{set "die_after_throw" 1}			
			{call "die_scream"}			
			{call "throw_high"}		
		}				
		{on "hit"			
		{call "hit-scream"}		
		}		
		{on "damage"			
			{spawn "bloodsparks_small"}			
			{call "hit"}		
		}			
		{on "throw_high"			
			{if senseless				
			{if not dead					
			{if not user_control						
			{call "die"}					
			else "die_after_throw"						
			{call "die"}					
			}				
			}			
			else				
				{if not dead					
					{if linked "vehicle"						
						{if "die_after_throw"							
							{throw_off up 1.3 0.5 dir 5.5 2 forward 4 turn 0 360 die force}						
							else							
							{throw_off up 1.3 0.5 dir 5.5 2 forward 4 turn 0 360 force}						
						}					
						else						
						{if "die_after_throw"							
						{throw_off up 4 0.8 dir 3.5 0.5 forward 0 0 die}						
						else							
						{throw_off up 4 0.8 dir 3.5 0.5 forward 0 0}						
						}					
					}				
					else					
					{if stuff "bullet"						                     					
						else 						
						{call "explosion"}					
					}				
				}			
			}		
		}		
		{on "throw_off_end"			
		{if not user_control				
			{health_damage_count 50 					
			{effects "" "hit" "damage" "die" "die"}				
			}			
		}			
		{call "knock_down"}		
		}		{on "throw_off_end_die"			{call "die"}		}		{on "throw_off_from_tower"			{throw_off up 1 forward 2 die force}		}		{on "throw_off_from_ladder"			{throw_off up 1 forward -2 die force}		}		{on "throw_off_from_ship"			{throw_off up 4 dir 3 1 die force}		}		{on "throw_off_from_vehicle"			{if user_control				{throw_off up 1.3 0.5 dir 5.5 2 forward 4 turn 0 360 force}			else				{throw_off up 1.3 0.5 dir 5 1 forward 4 turn 0 360 rnd_die 0.7 force}			}		}		{on "linker_simulation"			{if effector "airborne"			 else effector "cannon"	                                                               			 else altitude 3				{throw_off up 1 forward 2 die force}			}		}			{on "knock_down"			{if not water_level -0.1				{knockdown 8 3}			}		}			{on "die"			{if not dead				{view pause  "marker_personage_acute"}				{spawn "bloodsparks_small"}				{if linked					{if linked "shipflak"						{call "throw_off_from_ship"}					else linked "doublecolt"						{call "throw_off_from_ship"}					else linked "car"						{if place "driver"							{throw_off up 1.6 forward 2 turn -90 die force rotate_to_dir}						else place "commander"							{throw_off up 1.6 forward 2 turn +90 die force rotate_to_dir}						else							{call "die_with_blood"}						}					else altitude 2						{if boarding							{call "throw_off_from_ladder"}						else							{call "throw_off_from_tower"}						}					else linked "cannon"						{call "die_with_blood"}					else linked "airborne"						{call "throw_off_from_ship"}					else linked "vehicle"						{call "throw_off_from_vehicle"}					else						{call "die_with_blood"}					}				else					{call "die_with_blood"}				}			}		}		{on "die_with_blood"			{if not senseless				{spawn "blood"}			}	                                         	                                          	                                          	                                                  	                                                  	                                                    	                                                        	                            	    			{tex_morph "dead" 3}			{call "die_without_blood"}		}		{on "die_without_blood"	              			{view pause "swim"}			{call "die_scream"}			{if not kill_flags blast				{kill_flags piercing}			}			{die}	                   			{delay 3				{volumes enable contact}			}	                      		}		{on "die_scream"			{if not "die_sound"				{set "die_sound" 1}				{talk "death_cry"}				{signal mandie 5}	                        	                                         	        	                              	     			}		}		{on "die_from_knife"			{set "die_from_knife" 1}			{call "die"}		}		                    	                  	                              	                	                          	        	                 	     	    	   			{on ground_hit			{spawn "blood"}		}			(define "piece_explosion"			{spawn %0 %1				{impulse	up 1 0.5 dir 8 4							cx 0 12 cy 0 12							fx 0 60 fy 0 60 fz 80 40				}			}		)		(define "piece_crush"			{spawn %0 %1				{impulse	up 0.1 0.1							fx 0 7 fy 0 7 fz 0 7				}			}		)		(define "spawn_pieces"			          			{if rand 0.2				(%0 args "#hand00" "hand1l")			else rand 0.2				(%0 args "#hand01" "hand1l")			else 				(%0 args "#hand02" "hand1l")			}			           			{if rand 0.2				(%0 args "#hand00" "hand1r")			else rand 0.2				(%0 args "#hand01" "hand1r")			else 				(%0 args "#hand02" "hand1r")			}				          		              				(%0 args "#leg00" "foot1l")		   			           			             				(%0 args "#leg00" "foot1r")			  				     			{if rand 0.3				(%0 args "#head00" "head")			else 				(%0 args "#head01" "head")			}		)			{on "explosion"			{if personage				{call "die"}			else				{spawn "bloodsparks_big"}	                                           				{call "delete"}			}		}		{on "crush"			{if personage				{call "die"}			else				{spawn "bloodsparks_big"}	                                       				{call "delete"}			}		}		{on "delete"			{if not dead				{stat_notify die}			}			{delete}		}		{on "burn_volume"			{if volume "body"				{call "_burn"}			}		}		{on "get_off"			{get_off}		}		{on "_burn"			{if not burned				{able "burning" 1}				(mod "mp"					{able select 0}				)				(define "try_get_off"					{delay %0 0.5						{get_off}					}				)				("try_get_off" args 1.0)				("try_get_off" args 2.0)				("try_get_off" args 3.0)				("try_get_off" args 4.0)				("try_get_off" args 5.0)				{tex_morph "burned" 10}				{call "add_burn_fx"}				{view start "burn_fire"}				{delay_effect 0.5 0.2 "burn_scream"}				{delay 6 2 "burn_die"					{able "burning" 0}					{kill_flags reset}					{kill_flags piercing}					("health_damage" c(150))					{if not dead						{call "die"}					}					{view stop "burn_fire"}					{if terrain_fx "puddle"						{call "stop_burn"}					else						{add_view "smoke_dead_small1" "burn_fire_b" 	"body"}						{add_view "smoke_dead_small1" "burn_fire_hl"	"hand1l"}						{add_view "smoke_dead_small1" "burn_fire_hr"	"hand1r"}						{add_view "smoke_dead_small1" "burn_fire_fl"	"foot2l"}						{add_view "smoke_dead_small1" "burn_fire_fr"	"foot2r"}						{view start "burn_fire_b"}						{view start "burn_fire_hl"}						{view start "burn_fire_hr"}						{view start "burn_fire_fl"}						{view start "burn_fire_fr"}						{delay 7.5 1.5	{view stop "burn_fire_b"}}						{delay 3.5 2.0	{view stop "burn_fire_hl"}}						{delay 3.8 1.5	{view stop "burn_fire_hr"}}						{delay 4.3 1.5	{view stop "burn_fire_fl"}}						{delay 4.5 1.5	{view stop "burn_fire_fr"}}					}				}				{burn time 17}                  			}		}		{on "add_burn_fx"			{add_view "smoke_dead_small" "burn_fire"	"body"}			{add_view "smoke_dead_small" "burn_fire"	"hand1l"}			{add_view "smoke_dead_small" "burn_fire"	"hand1r"}	                                                     	                                                     			{add_view "smoke_dead_small" "burn_fire"	"foot2l"}			{add_view "smoke_dead_small" "burn_fire"	"foot2r"}		}		{on "burn_scream"			{if not dead				{if not senseless					{if not "quench"						{talk "death_cry"}	                               						{delay_effect 1.2 0.5 "burn_scream"}					else						{kill_delay "burn_die"}						{view stop "burn_fire"}						{set "quench" 0}						{able "burning" 0}					}				}			}		}		{on "smoke"			{smoke}		}		{on "smoking"	                      			{view start "smoke"}			{delay 0.3 0.1				{view pause "smoke"}	                     			}		}		{on "reset_manual_control"			{reset_manual_control}		}	                    	                     	(include "WE_System.inc")	                    			(define "terrain_fx_human"			{on terrain_fx %0 enter				{if not swimming					{view start "on_%1"}					{view start "on_%1_time_short"}					{delay 0.1						{view pause "on_%1_time_short"}					}				}			}			{on terrain_fx %0 leave				{view pause "on_%1"}			}		)		("terrain_fx_human" args "water" 			water)		("terrain_fx_human" args "puddle"			puddle)		("terrain_fx_human" args "shallow_water"	puddle)		("terrain_fx_human" args "mud" 				mud)			{on terrain_pp "swamp" enter			{delay 0							                                   				{call "die_without_blood"}				{view start "die_in_swamp"}				{delay 10					{view stop "die_in_swamp"}					{delete}				}			}		}			{on "diving"			{delay 0.3				{spawn "spherewater_big"}			}		}		{on swim on			{view pause "on_water"}			{view start "swim"}			{call "stop_burn"}			{kill_delay "after_swim"}		}		{on swim off			{delay 1.5 "after_swim"				{view pause "swim"}			}		}		{on move on			{if swimming				{view start "swim_move"}			}		}	                           	                        	                                         	                                 	                                         	                        	                                         	                         	                                         	                         	                                         	                          	                                          	       	                                           	    	   								{on "stop_move_sounds"	                                 	                                   	                                 	                                 	                                  			{stop_sound "move_road"}			{stop_sound "move_ground"}			{stop_sound "move_snow"}			{stop_sound "move_sand"}			{stop_sound "move_grass"}				{stop_sound "swim"}	                                                		}		{on movement_mode_changed			{call "stop_move_sounds"}			{if name "fast"				{if swimming					{play_sound "swim" 1}				else not lying	                                        	                       						{if terrain_fx "road"	                                    						{play_sound "move_road" 1}					else terrain_fx "country_road"	                                    						{play_sound "move_road" 1}					else terrain_fx "ice"	                                    						{play_sound "move_snow" 1}					else terrain_fx "snow"	                                    						{play_sound "move_snow" 1}					else terrain_fx "sand"	                                    						{play_sound "move_sand" 1}					else terrain_fx "grass"	                                     						{play_sound "move_grass" 1}					else	                                      						{play_sound "move_ground" 1}					}				}			}		}	                          	                       	                                    	             	                                     	       	                                      	    	   	 	                                	                               	   	                                 	                                	   		{on move off			{view pause "swim_move"}			{call "stop_move_sounds"}		}		{on "stop_burn"			{if burned				{burn stop_retry}				{set "quench" 1}			}		}		{on "falldown"			{if altitude 3				{throw_off up 1 forward 0.01 die force}			else altitude 1				{throw_off up 1 forward 0.01 force}			else       				{throw_on_ground}			}		}		(define "sink_on_emit"			{if effector "sink_on_%0"				{if name "%0"					{with_effector						{if chassis "water"							{components "hull_integrity" break}						}						{with_effector}					}				}			}			)		{on board in			{view pause "swim"}			{if effector "no_hatch_sound"			else effector "car"				{play_sound "door_in"}			else effector "tank"				{play_sound "hatch_in"}			}			("sink_on_emit" args emit0)			 ("sink_on_emit" args emit1)			 ("sink_on_emit" args emit2)			 ("sink_on_emit" args emit3)			 ("sink_on_emit" args emit4)			 ("sink_on_emit" args emit5)			 ("sink_on_emit" args emit6)			 ("sink_on_emit" args emit7)			 ("sink_on_emit" args emit8)			{if effector "sink_on_allemit"				{with_effector					{if chassis "water"						{components "hull_integrity" break}					}					{with_effector}				}			}	                 	                                           	    		}		{on board out			{if effector "mtb_d3"				{if name "emit1" "emit2" "emit3" "emit4"					{delay 0.7						{spawn "spherewater_big"}					}				}			}			{if effector "no_hatch_sound"			else effector  "car truck"				{if name "emit1" "emit2" {play_sound "door_out"}}	                                                                    			else effector "car"				{play_sound "door_out"}			else effector "tank"				{play_sound "hatch_out"}			}			("sink_on_emit" args emit0)			 ("sink_on_emit" args emit1)			 ("sink_on_emit" args emit2)			 ("sink_on_emit" args emit3)			 ("sink_on_emit" args emit4)			 ("sink_on_emit" args emit5)			 ("sink_on_emit" args emit6)			 ("sink_on_emit" args emit7)			 ("sink_on_emit" args emit8)			{if effector "sink_on_allemit"				{with_effector					{if chassis "water"						{components "hull_integrity" break}					}					{with_effector}				}			}	                 	                                            	    							                                     	                          			(define "paradrop_crew_member_with_alt_" 			   {if linked "mi17"				{if name "emit1" "emit2"					{delay  1.2 ("paradrop_crew_member_with_alt" args %0)}				else name "ropel_node5" "roper_node5"					{delay  0.1 ("paradrop_crew_member_with_alt" args %0)}				}			   else linked "mi8amtsh"			    {if name "emit1" "emit2"					{delay  1.2 ("paradrop_crew_member_with_alt" args %0)}				else name "ropel_node5" "roper_node5"					{delay  0.1 ("paradrop_crew_member_with_alt" args %0)}				}			   else linked "apache"				{delay 2.8 ("paradrop_crew_member_with_alt" args %0)}			   else linked "ka50"				{delay 2.8 ("paradrop_crew_member_with_alt" args %0)}			   else linked "ka50sh"				{delay 2.8 ("paradrop_crew_member_with_alt" args %0)}			   else linked "uh60"				{if name "emit1" "emit2"					{delay  2.5 ("paradrop_crew_member_with_alt" args %0)}				else name "emit3" "emit4"					{delay  1.2 ("paradrop_crew_member_with_alt" args %0)}				else name "ropel_node5" "roper_node5"					{delay  0.1 ("paradrop_crew_member_with_alt" args %0)}				}			   else linked "an-12"				{delay 0.5 ("paradrop_crew_member_with_alt" args %0)}			   else linked "il-76td"				{delay 0.5 ("paradrop_crew_member_with_alt" args %0)}			   else linked "mi-24"				{if name "emit0"					{delay  2.8 ("paradrop_crew_member_with_alt" args %0)}				else name "emit1"					{delay  2.8 ("paradrop_crew_member_with_alt" args %0)}				else name "emit2" "emit3"					{delay  1.2 ("paradrop_crew_member_with_alt" args %0)}				}			   else linked "mh-6"				{if name "emit1" "emit2"					{delay  2.0 ("paradrop_crew_member_with_alt" args %0)}				else name  "emit3" "emit4" "emit5" "emit6" "emit7" "emit8"					{delay  2.0 ("paradrop_crew_member_with_alt" args %0)}				}			   else linked "uh1y"				{if name "emit1" "emit2"					{delay  2.8 ("paradrop_crew_member_with_alt" args %0)}				else name  "emit3" "emit4"					{delay  1.2 ("paradrop_crew_member_with_alt" args %0)}				else name "ropel_node5" "roper_node5"					{delay  0.1 ("paradrop_crew_member_with_alt" args %0)}				}			   else linked "su-34"				{delay 1 ("paradrop_crew_member_with_alt" args %0)}			   else linked "nh90"				{delay 0.5 ("paradrop_crew_member_with_alt" args %0)}			   else			    {delay  2.8 ("paradrop_crew_member_with_alt" args %0)}			   }			)			(define "paradrop_crew_member_with_alt"	                                                                				{if rand 0.5 					{if rand 0.5 						{if rand 0.5 ("paradrop_crew_member_with_alt_r" args %0 0)						else ("paradrop_crew_member_with_alt_r" args %0 1)						}					else						{if rand 0.5 ("paradrop_crew_member_with_alt_r" args %0 2)						else ("paradrop_crew_member_with_alt_r" args %0 3)						}					}				else					{if rand 0.5 						{if rand 0.5 ("paradrop_crew_member_with_alt_r" args %0 4)						else ("paradrop_crew_member_with_alt_r" args %0 5)						}					else						{if rand 0.5 ("paradrop_crew_member_with_alt_r" args %0 6)						else ("paradrop_crew_member_with_alt_r" args %0 7)						}					}				}			)			(define "paradrop_crew_member_with_alt_r" 				{if not altitude 2					{tags add "heli_paradrop%1"} {delay 5 {tags remove "heli_paradrop%1"}}					{spawn "parachute_new"  "basis" x no_position						{tags add "heli_parashute%1"} 						{call "start_alt_%0"}					}				}			)			{if linked "able_paradrop"				     {if altitude 40	("paradrop_crew_member_with_alt_" args 7)				      else altitude 35	("paradrop_crew_member_with_alt_" args 6)				      else altitude 30	("paradrop_crew_member_with_alt_" args 5)				      else altitude 25	("paradrop_crew_member_with_alt_" args 4)				      else altitude 20	("paradrop_crew_member_with_alt_" args 3)				      else altitude 12	("paradrop_crew_member_with_alt_" args 2)				      else altitude 8	("paradrop_crew_member_with_alt_" args 1)				      else altitude 3					   {if linked "mi17"							{delay 2.0 {throw_off up 1 forward 2}}					    else linked "apache"							{delay 2.5 {throw_off up 1 forward 2}}					    else linked "ka50"							{delay 2.5 {throw_off up 1 forward 2}}					    else linked "ka50sh"							{delay 2.5 {throw_off up 1 forward 2}}					    else linked "uh60"							{if name "emit1" "emit2"								{delay  2.0 {throw_off up 1 forward 2}}							else name "emit3" "emit4"								{delay  1.0 {throw_off up 1 forward 2}}							}						else linked "nh90"							{delay  0.2 {if linked "airborne" {throw_off up 1 forward 2}}}						else linked "an-12"							{delay 3.0 {if linked "airborne" {throw_off up 1 forward 2}}}						else linked "il-76td"							{delay 3.0 {if linked "airborne"{throw_off up 1 forward 2}}}						else						 {delay 2.5 {throw_off up 1 forward 2}}					   }				      else				      }			}	                                 		}		                   		{on "start_heal"			{view start "healing"}		}		{on "stop_heal"			{view pause "healing"}		}		                                                                                       		{on "start_healing"			{set "overheating" 0}			{view start  "marker_healing"}			{view pause  "marker_personage_acute"}		}		{on "stop_healing"			{view pause "marker_healing"}		}		{on "start_repair"			{view start  "marker_repair"}		}		{on "stop_repair"			{view pause "marker_repair"}		}		{on "start_ammo_out"			{view start  "marker_ammo_out"}		}		{on "stop_ammo_out"			{view pause "marker_ammo_out"}		}		{on "start_ammo_refill"			{view start  "marker_ammo_refill"}			{delay 2.5				{view pause "marker_ammo_refill"}			}		}		{on "start_personage"			{view pause "marker_personage_acute"}			{view start  "marker_personage"}		}		{on "stop_personage"			{view pause "marker_personage"}			{view pause "marker_personage_acute"}		}		{on "start_personage_acute"			{view pause "marker_personage"}			{view start  "marker_personage_acute"}		}		{on "start_veterancy"			{view start  "marker_veterancy"}			{delay 3.5				{view pause "marker_veterancy"}			}		}		{on "stop_veterancy"			{view pause "marker_veterancy"}		}		{on "hide_veterancy"			{view hide "marker_veterancy"}		}		{on "start_blinded"		                  				{view start  "marker_blinded"}		}		{on "stop_blinded"			{view pause "marker_blinded"}		}		{on "capture"			{tags add "capturer"}		}				{on "charge"			{tags add "charge"}		}	}	




{"armor_plate"	
	{inflammation_time 0.25}		
		{on bullet_hit overload			
			{delay 0.1			   
				{if not "overheating"					                               					      					
				{spawn "marker_armor_hold"}			   
				}			 
				{set "overheating" 0}			
			}			
			{if not under_water				
				{if stuff "bullet"					
					{spawn "sand_hit_bul"}				
						else {inherited}				
				}			
			}				
			{if volume "armor_plate"				
			{if stuff "hmgun"					
			{volumes "soft_plate" disable blast}					
			{blastwave c4 0.4 r0 0.4 r1 0.41}					
			{delay 0.1 {volumes "soft_plate" enable blast}}				else stuff "autocannon_small"					{volumes "soft_plate" disable blast}					{blastwave c4 0.6 r0 0.4 r1 0.41}					{delay 0.1 {volumes "soft_plate" enable blast}}				}			}		}		{on pierce			{call "armor_plate_pierce"}			{if stuff "bullet"			  {if not volume "soft_plate"				{call "armor_plate_pierce"}			  }			}		}		{on "armor_plate_pierce"		    {set "overheating" 1}			{if hit_side front				                                               	                                        			else				                                               	                                        			}		}		{on break_armor			(define "break_plate"				volume "%plate"				{volumes "%plate" disable bullet}			)			{if ("break_plate" plate(front_plate))			else ("break_plate" plate(rear_plate))			else ("break_plate" plate(sider_plate))			else ("break_plate" plate(sidel_plate))			else ("break_plate" plate(front_ceramic))			else ("break_plate" plate(rear_ceramic))			else ("break_plate" plate(sider_ceramic))			else ("break_plate" plate(sidel_ceramic))			else ("break_plate" plate(soft_plate))			}		}		{on "burn_volume"			{if not burned				{able "burning" 1}				{tex_morph "burned" 10}				{add_view "smoke_dead_small" "burn_fire"	"root"}				{view start "burn_fire"}				{delay 6 2 "burn_die"					{able "burning" 0}					{view stop "burn_fire"}					{if terrain_fx "puddle"						{call "stop_burn"}					else						{add_view "smoke_dead_small1" "burn_fire_b" 	"root"}						{view start "burn_fire_b"}						{delay 7.5 1.5	{view stop "burn_fire_b"}}					}				}				{burn time 17}                  			}		}	}	                                                                                                                                       	                                                                             	
{"armor_plate armor_plate_usa"		{on "armor_plate_pierce" overload			
{if hit_side front				                                                	                                        			
else				                                                	                                        				                                                                                                                			
}		}	}	                      	                                                   