{"grenade"		
	{on spawn}		
	{on "onThrow"			                     			
		{volumes "body" disable contact}		
	}		
	{on "onThrowActivate"			
		{volumes "body" enable contact}		
	}		
	{on contact			
		{view stop "trace"}			
		{if stuff_activated				
		{if effector "human"					
		{call "fall_down"}				
		else effector "cannon"					{link_grenade_to_nearest_human teleport}				}			}		}		{on "in_hole"			{break_window_in_hole}			{link_grenade_to_nearest_human}		}		{on ground_hit			                    		}		{on "fall_down"			{volumes disable contact}			{fall_down}		}		{on bullet_hit	                          	            {call "detonate"}	          		}		{on blast			{if min_energy 0.3				{call "detonate"}			}		}	}		{"grenade training"		{on spawn			{tags add "grenade"}		}	}	{"f1c_script"		{on spawn			{tags add "f1c_script"}			{delay 2.5 {delete}}		}	}		{"grenade contact"		{on ground_hit			{if stuff_activated				{if not name "water"					{call "ground_detonate"}				}			}		}		{on "in_hole" overload}		{on contact			{if stuff_activated				{call "contact_detonate"}			}		}		{on "ground_detonate"			{call "detonate"}		}		{on "contact_detonate"			{call "detonate"}		}		{on "detonate"			{stuff_detonate}		}		{on "fall_down" overload}	}		{"grenade smoke"		{on spawn			{call "add_smoke"}			{link_sound "smoke" "detonation/grenade_smoke/grenade_smoke"}		}		{on "add_smoke"			{add_view "smoke_cover-up_small"	"smoke1" "root"}			{add_view "smoke_cover-up_norm"		"smoke2" "root"}			{add_view "smoke_cover-up_big"		"smoke3" "root"}		}		{on "onThrow"			{volumes disable touch select}		}		{on "activate"			{if not under_water				{play_sound "smoke" 1}				{tags add "smoke"}				{view stop "smoke1"}				{view start "smoke2"}				{volumes "smoke1" enable visible}				{spawn "smoke_volume_ground"}				{update_visibility_patch}				{delay 2					{view stop "smoke2"}					{view start "smoke3"}					{volumes "smoke1" disable visible}					{volumes "smoke2" enable visible}					{update_visibility_patch}				}				{delay 5					{volumes "smoke2" disable visible}					{volumes "smoke3" enable visible}					{update_visibility_patch}				}				{delay 60					{view stop "smoke3"}					{stop_sound "smoke"}				}				{delay 62					{hide 1}				}			else {hide 1}}		}		{on ground_hit			{if stuff_activated				{if not "activated"					{set "activated" 1}					{if under_water						{hide 1}					else						{delay 3							{call "activate"}						}					}				}			}		}		{on contact			{if stuff_activated				{if not "activated"					{set "activated" 1}					{delay 3						{call "activate"}					}				}			}		}	}		{"grenade smoke yellow"		{on "add_smoke" overload			{add_view "smoke_yellow_small"	"smoke1" "root"}			{add_view "smoke_yellow_norm"	"smoke2" "root"}			{add_view "smoke_yellow_big"	"smoke3" "root"}		}	}		{"grenade smoke mortar_smoke"		{on spawn			{volumes disable touch select}			{call "activate"}		}	}	{"smoke_probe"		{on spawn		    {delay 0.5 {delete}}		}		{on bullet_hit overload			{impulse up 0.01 com}			{gravity 0.01}			{volumes "body" disable all}			{if 				(define "check_dir"					 tagged "%dir"						{if stuff "tanksmoke_airburst"							{spawn "smoke_shell_fly" "smoke%dir" x 								{impulse up 50 2 forward 100 rnd_dir 2.5 com}								{gravity 0.9}								{delay 0.2									{spawn "ex_smokeshell"}									{spawn "smoke_volume"}									{delete}								}							}						else stuff "tanksmoke"							{spawn "smoke_shell_fly" "smoke%dir" x 								{impulse up 0.1 forward 30 rnd_dir 2.5}								{add_view	"wp_smoke"	"grenade_tail"	"root"}								{view start "grenade_tail"}								{view show		"grenade_tail"}							}						}				 				)				("check_dir" dir(0_0))				else ("check_dir" dir(0_m10))				else ("check_dir" dir(0_m20))				else ("check_dir" dir(0_m30))				else ("check_dir" dir(0_m40))				else ("check_dir" dir(0_10))				else ("check_dir" dir(0_20))				else ("check_dir" dir(0_30))				else ("check_dir" dir(0_40))				else ("check_dir" dir(15_0))				else ("check_dir" dir(15_m10))				else ("check_dir" dir(15_m20))				else ("check_dir" dir(15_m30))				else ("check_dir" dir(15_m40))				else ("check_dir" dir(15_10))				else ("check_dir" dir(15_20))				else ("check_dir" dir(15_30))				else ("check_dir" dir(15_40))				else ("check_dir" dir(30_0))				else ("check_dir" dir(30_m10))				else ("check_dir" dir(30_m20))				else ("check_dir" dir(30_m30))				else ("check_dir" dir(30_m40))				else ("check_dir" dir(30_10))				else ("check_dir" dir(30_20))				else ("check_dir" dir(30_30))				else ("check_dir" dir(30_40))				else			}				{delete}		}		}	{"molotov_coctail"		{on bullet_hit			{fire radius 1.5 time 40 heating 1 effector}			{call "detonate"}		}		{on blast			{if min_energy 0.3				{fire radius 1.5 time 40 heating 1 effector}				{call "detonate"}			}		}		{on "ground_detonate"			{fire radius 1.5 time 40 heating 1}		}		{on "contact_detonate" overload			{if effector "construction"				{volumes disable bullet contact blast}				{fire radius 1 time 40 heating 1 effector}				{burn volume fx "smoke_dead_small" time 40 5 fake even_law}				{delay 0.1					{call "detonate"}				}			else				{with_effector {burn fx "fire_molot" time 40 5 fake} {with_effector}}				{call "detonate"}			}		}	}	{"smoke_shell_fly"		{on spawn			{delay 5 {spawn "smoke_shell"} {delete}}		}		{on ground_hit			{if stuff_activated				{if not "activated"					{set "activated" 1}					{if under_water						{hide 1}					else						{spawn "smoke_shell"} {delete}					}				}			}		}		{on contact			{if stuff_activated				{if not "activated"					{set "activated" 1}					{delay 3						{spawn "smoke_shell"} {delete}					}				}			}		}	}	{"smoke_shell"	               		{on spawn			{call "activate"}		}		{on ground_hit			{if stuff_activated				{if not "activated"					{set "activated" 1}					{if under_water						{hide 1}					else						{delay 3							{call "activate"}						}					}				}			}		}		{on contact			{if stuff_activated				{if not "activated"					{set "activated" 1}					{delay 3						{call "activate"}					}				}			}		}	}		                                   	{"vog_25p_exp"		{on spawn			{impulse up 10 1 rnd_dir 1}			{delay 0.12				{stuff_detonate}			}		}	}	{"vog_25pm_exp"		{on spawn			{impulse up 10 1 rnd_dir 1}			{delay 0.12				{stuff_detonate}			}		}	}	{"m397p_exp"		{on spawn			{impulse up 10 1 rnd_dir 1}			{delay 0.12				{stuff_detonate}			}		}	}	{"mk30abm_fg_exp"		{on spawn			{if altitude 1 {stuff_detonate}			else				{impulse up 20 6 rnd_dir 20}				{delay 0.04					{stuff_detonate}				}			}		}	}	{"shell_fr_gpr-ab-t_40mm_exp"		{on spawn			{if altitude 1 {stuff_detonate}			else				{impulse up 20 6 rnd_dir 20}				{delay 0.04					{stuff_detonate}				}			}		}	}	{"shell_ger_abm_120_exp"		{on spawn			{if altitude 1 {stuff_detonate}			else				{impulse up 20 6 rnd_dir 20}				{delay 0.06					{stuff_detonate}				}			}		}	}	{"grenade_xm25_fg_exp"		{on spawn			{impulse up 8 1 rnd_dir 1}			{delay 0.15				{stuff_detonate}			}		}	}	                                                                          	               	                                                        	                               	                                	                                 	                                 	
		(define "cluster_spreader_1gen"		
			{on spawn			
				{volumes "body" disable contact blast}			
				{impulse up 5 com}			
				{delay 0.1 {spawn %0}}			
				{delay 0.2 {spawn %0}}			
				{delay 0.3 {spawn %0}}			
				{delay 0.4 {spawn %0}}			
				{delay 0.5 {spawn %0}}			
				{delay 0.6 {spawn %0}}			
				{delay 0.7 {spawn %0}}			
				{delay 0.8 {spawn %0}}			
				{delay 0.9 {spawn %0} {delete}}			
				{delay 1 {delete}	}                   		
			}	
		)	
		(define "cluster_spreader_2gen_big"		
			{on spawn			
				{volumes "body" disable contact blast}			
				{impulse up 5 com}			
				{delay 0.1 {spawn %0 {impulse up 2 rnd_dir 10}}}			
				{delay 0.2 {spawn %0 {impulse up 2 rnd_dir 10}}}			
				{delay 0.3 {spawn %0 {impulse up 2 rnd_dir 10}}}			
				{delay 0.4 {spawn %0 {impulse up 2 rnd_dir 10}}}			
				{delay 0.5 {spawn %0 {impulse up 2 rnd_dir 10}}}			
				{delay 0.6 {spawn %0 {impulse up 2 rnd_dir 10}}}			
				{delay 0.7 {spawn %0 {impulse up 2 rnd_dir 10}}}			
				{delay 0.8 {spawn %0 {impulse up 2 rnd_dir 10}}}			
				{delay 0.9 {spawn %0 {impulse up 2 rnd_dir 10}} {delete}}			
				{delay 1 {delete}}                   		
			}	
		)	
		(define "cluster_spreader_2gen_small"		
			{on spawn			
				{volumes "body" disable contact blast}			
				{impulse up 5 com}			
				{delay 0.1 {spawn %0 {impulse up 3 rnd_dir 10}}}			
				{delay 0.2 {spawn %0 {impulse up 3 rnd_dir 10}}}			
				{delay 0.3 {spawn %0 {impulse up 3 rnd_dir 10}}}			
				{delay 0.4 {spawn %0 {impulse up 3 rnd_dir 10}}}			
				{delay 0.5 {spawn %0 {impulse up 3 rnd_dir 10}}}			
				{delay 0.6 {spawn %0 {impulse up 3 rnd_dir 10}} {delete}}			
				{delay 0.7 {delete}	}                   		
			}	
		)	
		(define "cluster_shell_1up"		
			{spawn %subm  no_position no_normal {impulse up 15 0.5 dir %forward rnd_dir %spread com}}	
		)	
		(define "cluster_shell_2up"		
			{spawn %subm  no_position no_normal {impulse up 15 0.5 dir %forward rnd_dir %spread com}}		
			{spawn %subm  no_position no_normal {impulse up 22 0.5 dir (+ %forward 15) rnd_dir %spread com}}	
		)	
		(define "cluster_shell_5up"		
			("cluster_shell_1up" subm(%subm) forward(%forward) spread(%spread))		
			("cluster_shell_2up" subm(%subm) forward(%forward) spread(%spread))		
			("cluster_shell_2up" subm(%subm) forward(%forward) spread(%spread))	
		)	
		(define "cluster_shell_5"		
			{spawn %subm {impulse up 1 0.5 dir 25 0.5 rnd_dir (* 0.5 %spread)}}		
			{spawn %subm {impulse up 1 0.5 dir 25 0.5 rnd_dir (* 1.0 %spread)}}		
			{spawn %subm {impulse up 1 0.5 dir 25 0.5 rnd_dir (* 1.5 %spread)}}		
			{spawn %subm {impulse up 1 0.5 dir 25 0.5 rnd_dir (* 2.0 %spread)}}		
			{spawn %subm {impulse up 1 0.5 dir 25 0.5 rnd_dir (* 2.5 %spread)}}	
		)	
		(define "cluster_shell_10"		
			("cluster_shell_5" subm(%subm) spread(%spread))		
			("cluster_shell_5" subm(%subm) spread(%spread))	
		)	
		(define "cluster_shell_20"		
			("cluster_shell_10" subm(%subm) spread(%spread))		
			("cluster_shell_10" subm(%subm) spread(%spread))	
		)	
		(define "cluster_shell_30"		
			("cluster_shell_20" subm(%subm) spread(%spread))		
			("cluster_shell_10" subm(%subm) spread(%spread))	
		)	
		(define "cluster_shell_40"		
			("cluster_shell_20" subm(%subm) spread(%spread))		
			("cluster_shell_20" subm(%subm) spread(%spread))	
		)	
		(define "cluster_shell_50"		
			("cluster_shell_20" subm(%subm) spread(%spread))		
			("cluster_shell_30" subm(%subm) spread(%spread))	
		)	
		(define "cluster_shell_60"		
			("cluster_shell_30" subm(%subm) spread(%spread))		
			("cluster_shell_30" subm(%subm) spread(%spread))	
		)	
		(define "cluster_shell_70"		
			("cluster_shell_20" subm(%subm) spread(%spread))		
			("cluster_shell_50" subm(%subm) spread(%spread))	
		)	
		(define "cluster_shell_100"		
			("cluster_shell_50" subm(%subm) spread(%spread))		
			("cluster_shell_50" subm(%subm) spread(%spread))	
		)	
		(define "cluster_shell_150"		
				("cluster_shell_50" subm(%subm) spread(%spread))		
				("cluster_shell_50" subm(%subm) spread(%spread))		
				("cluster_shell_50" subm(%subm) spread(%spread))	
		)	
		(define "cluster_shell_200"		
			("cluster_shell_50" subm(%subm) spread(%spread))		
			("cluster_shell_50" subm(%subm) spread(%spread))		
			("cluster_shell_50" subm(%subm) spread(%spread))		
			("cluster_shell_50" subm(%subm) spread(%spread))	
		)		
		{"cw_shell_fuse_detector"	
			{on spawn {impulse up -555 com} {delay 5.0 {delete}}}	}	
			{"cw_shell_radio_fuse_detector"		
				{on spawn {delay 1.5 {delete}}}				
				{on contact		                         		                                 		                            		                                 		   		
					{if altitude 15 {volumes "body" enable bullet}}	    
				}			
			}	{"cw_shell_cl_detector"		{on spawn {delay 1.5 {delete}}			{if not altitude 15				{volumes "body" enable bullet}			}		}		{on bullet_hit			{if not hit_side bottom			{if stuff "bullet152_RUS rok"		        				{spawn "ex_air_big"}				("cluster_shell_40" subm("cluster_subm_152") spread(10))				{bullet_detonate}			else stuff "bullet155_USA cl"		         				{spawn "ex_air_big"}				("cluster_shell_60" subm("m42_submunition") spread(10))				{bullet_detonate}			else stuff "bullet155_cn cl"		                                				{spawn "ex_air_big"}				("cluster_shell_60" subm("m42_submunition") spread(10))				{bullet_detonate}			else stuff "bullet120_cn cl"		         				{spawn "ex_air_big"}				("cluster_shell_30" subm("type90_submunition") spread(10))				{bullet_detonate}			else stuff "bullet122_cn cl"		         				{spawn "ex_air_big"}				("cluster_shell_30" subm("type90_submunition") spread(10))				{bullet_detonate}			else stuff "rbk_cn cl"	         				{spawn "ex_air_big"}				("cluster_shell_50" subm("250-3_submunition") spread(10))				{bullet_detonate}			else stuff "cluster"				{spawn "cluster_expl" no_normal no_position}				{bullet_detonate}			else stuff "m270_aw"				{bullet_detonate}				}			}		}	}	{"cw_shell_cl_detector_lowalt"		{on spawn {delay 1.5 {delete}}			{if not altitude 10				{volumes "body" enable bullet}			}		}		{on bullet_hit			{if stuff "rbk_cn tb"	                 	                        			else stuff "cluster"				{spawn "cluster_expl" no_normal no_position}			}		}	}	{"cw_shell_r_detector"		{on spawn {delay 1.5 {delete}}			{if not altitude 5				{volumes "body" enable bullet}			}		}		{on bullet_hit		{if not hit_side bottom			{bullet_detonate}		}		}	}	{"cw_shell_spbe_detector"		{on spawn {delay 1.5 {delete}}			{if not altitude 20				{volumes "body" enable bullet}			}		}		{on bullet_hit			{if stuff "bullet155_USA spbe"		        				{spawn "ex_air_big"}				("cluster_shell_2up" subm("smart155") forward(30) spread(2 1))			else stuff "cluster"				{spawn "cluster_expl" no_normal no_position}			}		}	}	
{"cw_rocket_cl_detector"		
	{on spawn {delay 1.5 {delete}}			
		{if not altitude 35				
			{volumes "body" enable bullet}			
		}		
	}		
	{on bullet_hit			
		{if stuff "m270 cl"		         				
			{spawn "ex_air_big"}				
				("cluster_shell_200" subm("m77_mlrs_submunition") spread(13))			
					else stuff "ATACMS cl"	         				
						{spawn "ex_air_big"}				
						("cluster_shell_150" subm("m74_mlrs_submunition") spread(17))	
					
					else stuff "lars2 mine"
						{spawn "ex_air_big"}				
						("cluster_shell_5" subm("at2_mine_in_fly") spread(12))			
					else stuff "grad mine"		        				
						{spawn "ex_air_big"}				
						("cluster_shell_5" subm("pom_2") spread(12))			
					else stuff "grad spbe"		        				
						{spawn "ex_air_big"}				
						("cluster_shell_2up" subm("spbe_9n282") 
							forward(40) spread(2 1))			
					else stuff "grad clcn"		         				
						{spawn "ex_air_big"}	              				
						("cluster_shell_30" subm("type90_submunition") spread(10))			
					else stuff "grad cl"		         				
						{spawn "ex_air_big"}				
						("cluster_shell_30" subm("9m218_submunition") spread(10))			
					
					else stuff "9m525 cl"		         				
						{spawn "ex_air_big"}				
						("cluster_shell_70" subm("9n235_submunition") spread(10))			
					else stuff "9m549 cl"		         				
						{spawn "ex_air_big"}				
						("cluster_shell_70" subm("9n235_submunition") spread(7))			
					else stuff "9m55k3 mine"		         				
						{spawn "ex_air_big"}				
						("cluster_shell_40" subm("pom_2") spread(15))			
					else stuff "9m531 cl"		              				
						{spawn "ex_air_big"}				
						("cluster_shell_200" subm("9m218_submunition") spread(13))			
					else stuff "9m546 cl"		          				
						{spawn "ex_air_big"}				
						("cluster_shell_200" subm("9m218_submunition") spread(13))			
					else stuff "9m533 spbe"		       				{spawn "ex_air_big"}				("cluster_shell_5up" subm("spbe_9n282") forward(40) spread(6 1))			
		else stuff "phl03 cl brc4"		          				{spawn "ex_air_big"}	              				("cluster_shell_150" subm("type90_submunition") spread(13))	
		else stuff "9m27 k"		        	{spawn "ex_air_big"}				("cluster_shell_50" subm("9m218_submunition") spread(10))
		else stuff "tochka cl"		        {spawn "ex_air_big"}				("cluster_shell_200" subm("250-3_submunition")   forward(40) spread(20))	
		
		else stuff "cluster"				{spawn "cluster_expl" no_normal no_position}			
		}		
	}	
}
{"cw_rocket_oa_detector"		
	{on spawn {delay 1.5 {delete}}			
		{if not altitude 45				
			{volumes "body" enable bullet}			
		}		
	}		
	{on bullet_hit			
		{if stuff "grad oa"					         				
				{spawn "ex_air_big"}				
				("cluster_shell_20" subm("zab_2_5_var1") spread(5))	
			else stuff "9m27 oa"		         				
						{spawn "ex_air_big"}				
						("cluster_shell_20" subm("zab_2_5_var1") spread(5))	
			else stuff "iskander cl"		    
						{spawn "ex_air_big"}			
						("cluster_shell_200" subm("250-3_submunition")   spread(12))
			else stuff "grom cl"	         				
						{spawn "ex_air_big"}				
						("cluster_shell_200" subm("250-3_submunition")  spread(12))
		}		
	}	
}

{"cw_rocket_aw_detector"		
	{on spawn {delay 1.5 {delete}}			
		{if not altitude 25				
			{volumes "body" enable bullet}			
		}		
	}		
	{on bullet_hit			
		{if stuff "m270 aw"				
			{spawn "ex_air_big"}				
			{bullet_detonate}			
		}		
	}	
}


{"cw_rocket_aw_detector"		
	{on spawn {delay 1.5 {delete}}			
		{if not altitude 7				
			{volumes "body" enable bullet}			
		}		
	}		
	{on bullet_hit			
		{if stuff "m270 aw"				
			{spawn "ex_air_big"}				
			{bullet_detonate}			
		}		
	}	
}	                     				            	
{"rbk250_cluster"		
	{on spawn			
		{volumes "body" disable contact blast}	                     		
			("cluster_shell_70" subm("ao1_submunition") spread(10))				
			{delay 0.1 {delete}	}                   		
	}		                                                 	
}		            	
{"AGM-154_cluster"		                                                    			
	{on spawn			
		{volumes "body" disable contact blast}			
		("cluster_shell_20" subm("blu-97_submunition") spread(10))				
		{delay 0.1 {delete}	}                   		
	}		
}				
{"submunition"	                  		
	{on spawn			
		{volumes "body" disable contact blast}			
		{delay 0.1				
			{set "activated" 1}				
			{volumes "body" enable contact}			
		}			
		{delay 7 {stuff_detonate}}                   		
	}		
	{on ground_hit	                  	                                    					
		{stuff_detonate}	     	                          		
	}		
	{on contact			
		{if effector "cluster_shell"			
		else  effector "submunition"			
		else	{stuff_detonate}}		
	}	
}		
{"AO1_submunition"		
	{on spawn overload			
		{volumes "body" disable contact blast}			
		{impulse up -2 rnd_dir 8}			
		{delay 0.1				
			{set "activated" 1}				
			{volumes "body" enable contact}			
		}			
		{delay 7 {stuff_detonate}}                   		
	}	
}	
{"blu-97_submunition"		
	{on spawn overload			
		{volumes "body" disable contact blast}			
		{impulse up 2 rnd_dir 10}			
		{delay 0.1				
			{set "activated" 1}				
			{volumes "body" enable contact}			
		}		
	}		
	{on ground_hit overload	                  				
		{if not effector "cluster_shell"				      
			{if terrain_fx "sand"			
				{if rand 0.6 {stuff_detonate}}				     
					else terrain_fx "snow"					
						{if rand 0.6 {stuff_detonate}}				     
					else terrain_fx "water"					
						{if rand 0.6 {stuff_detonate}}				      
					else terrain_fx "grass"					
						{if rand 0.8 {stuff_detonate}}				     
					else					
						{stuff_detonate}				     
			}				
		}	                        	    		
	}	
}	                                                                          	                         	
{"cluster_mine"		
	{on spawn			
		{volumes "body" disable contact blast}			
		{delay 0.1				
			{set "activated" 1}				
			{volumes "body" enable contact}			
		}			
		{delay 20 3 {call "deploy"}}                   		
	}		
	{on ground_hit			
		{if "activated"				
			{if not effector "cluster_shell"					
				{delay 7 2 {call "deploy"}}				
			}			
		else 	
			{impulse up 0.2}}		
	}		
	{on "deploy" {delay 0.1 {delete}}}	
}		
{"pom_2"		
	{on "deploy"			
		{spawn "ex_bul_zenit"}			
		{spawn "pom_2_installed"}			
		{delete}		
	}	
}	
{"at2_mine_in_fly"		
	{on "deploy"			
		{spawn "ex_bul_zenit"}			
		{spawn "at2_mine"}			
		{delete}		
	}	}	                                                                          	                            	{"cluster_mine_ground"		{on spawn			{player -1}			{tags add "mine_planted"}			{volumes "detector1" disable all}	{volumes "detector2" disable all}			{volumes "detector3" disable all}	{volumes "detector4" disable all}			{bone hide "detector1"}	{bone hide "detector2"}			{bone hide "detector3"}	{bone hide "detector4"}			{delay 3				{spawn "ex_bul_zenit"}				{volumes "detector1" enable all}	{volumes "detector2" enable all}				{volumes "detector3" enable all}	{volumes "detector4" enable all}				{bone show "detector1"}	{bone show "detector2"}				{bone show "detector3"}	{bone show "detector4"}			}		}		{on "detonate" {stuff_detonate}}		{on contact {call "detonate"}}		{on blast_hit			{if min_energy 3				{if not stuff "mine"					{call "detonate"}				}			}			}	}	{"at2_mine"		{on "detonate" overload 		                  			{spawn "spbe-d_fire" "foresight" x}			{spawn "at2_mine_core" "foresight" x				{impulse up 0.1 forward 100 com}				{delay 0.1 {delete}}			}			{stuff_detonate}		     		}		{on blast		{if min_energy 1		{spawn "spbe-d_fire" "foresight" x}			{spawn "at2_mine_core" "foresight" x				{impulse up 0.1 forward 100 com}				{delay 0.1 {delete}}			}			{stuff_detonate}		}		}	}		                                                                          	                                             	{"cluster_expl"		{on spawn			{volumes "body" disable contact blast}			{impulse up 5 com}			{delay 0.1 {spawn "cluster_shell"}}			{delay 0.2 {spawn "cluster_shell"}}			{delay 0.3 {spawn "cluster_shell"}}			{delay 0.4 {spawn "cluster_shell"}}			{delay 0.5 {spawn "cluster_shell"}}			{delay 0.6 {spawn "cluster_shell"}}			{delay 0.7 {spawn "cluster_shell"}}			{delay 0.8 {spawn "cluster_shell"}}			{delay 0.9 {spawn "cluster_shell"} {delete}}			{delay 1 {delete}	}                   		}	}	{"cluster_expl_2gen"		{on spawn			{volumes "body" disable contact blast}			{impulse up 5 com}			{delay 0.1 {spawn "cluster_expl" {impulse up 2 rnd_dir 10}}}			{delay 0.2 {spawn "cluster_expl" {impulse up 2 rnd_dir 10}}}			{delay 0.3 {spawn "cluster_expl" {impulse up 2 rnd_dir 10}}}			{delay 0.4 {spawn "cluster_expl" {impulse up 2 rnd_dir 10}}}			{delay 0.5 {spawn "cluster_expl" {impulse up 2 rnd_dir 10}}}			{delay 0.6 {spawn "cluster_expl" {impulse up 2 rnd_dir 10}}}			{delay 0.7 {spawn "cluster_expl" {impulse up 2 rnd_dir 10}}}			{delay 0.8 {spawn "cluster_expl" {impulse up 2 rnd_dir 10}}}			{delay 0.9 {spawn "cluster_expl" {impulse up 2 rnd_dir 10}} {delete}}			{delay 1 {delete}	}                   		}	}		{"cluster_shell"	                  		{on spawn			{volumes "body" disable contact blast}			{impulse up 2 rnd_dir 10}			{delay 0.1				{set "activated" 1}			}			{delay 7 {delete}	{blastwave c4 4 r0 1 r1 4} {spawn "ex_anti_size1"}}                   		}		{on ground_hit			{if "activated"				{if not effector "cluster_shell"					{blastwave c4 0.7 r0 4 r1 5.5}					{blastwave c4 1.2 r0 3.8 r1 4}					{blastwave c4 2.5 r0 1 r1 2}					{spawn "ex_anti_size1"}					{delete}				}			else 				{impulse up 0.2}			}		}		{on contact			{if "activated"				{if not effector "cluster_shell"				     {if not effector "cluster_shell"					{blastwave c4 4 r0 1 r1 4}					{spawn "ex_anti_size1"}					{delete}				     }				}			else 				{impulse up 0.2}			}		}	}	                                       		               	                	                    	   	           	                     	                     	    	   	  	