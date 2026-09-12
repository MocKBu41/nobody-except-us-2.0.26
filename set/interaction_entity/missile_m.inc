{"cw_missile_old"	                	                    		{on spawn overload			("spawn")			{tags add "guided"}	{volumes disable contact}	{delay 2 {volumes enable contact}}		}		{on "add_movement_sound"}		{on "takeoff" overload}		{on "takeoff_load" overload}		{on "landing" overload}		{on "update_moveable" overload			{if not chassis "airborne" {inherited}}		}		{on engine on overload {call "engine_on"}}		{on engine off overload {call "engine_stop"}}		{on "engine_on" overload			{play_sound "fly" 1}			{ani_play "move" loop}			{play_sound "engine_start"}			{view start "engine_exhaust"}			{view start "engine_work"}			{delay 1 {view pause "engine_exhaust"}}		}		{on "engine_stop" overload			{view pause "engine_work"}			{ani_stop "move"}			{stop_sound "engine_start"}			{stop_sound "fly"}		}		{on bullet_hit overload		{if component "warhead" {call "detonate"}		else component "controls" {tags remove "guided"}		}	}	{on pierce overload		{spawn "aero_die_particle"}		{if component "engine" {call "fall"}		else component "warhead" {call "fall"}		else component "controls" {tags remove "guided"}		}	}	{on break_armor overload}	{on break overload		{if component "body"			{tags add "body_brake"}			{call "stat_break"}			{chassis_work 0}			{call "fall"}			{call "mp_destroy"}		}	}	{on repair overload}	{on "_burn" overload	{call "detonate"}}	{on "burn_volume" overload		                     	}	{on "mp_destroy" overload		{drop_orders}		{reset_manual_control}		{able select 0}		{able repaired 0}		{if not tagged "destroyed"			{if not tagged "body_break"				{components "body" break}				{call "stat_break"}			}		}		{delay 2 {tags add "destroyed"} {kick_entity_manager}}		{call "burn_emit"}	}	{on "fall" overload		{if not "fall"			{set "fall" 1}			{impulse up 0.1 com}			{call "fall_fx"}			{tags remove "air"}		}		{delay 10 {set "fall" 0}}	}	{on "fall_fx" overload		{delay 2			{add_view "smoke_aero_dead_big" "fire" "body"}			{view start "fire"}			{delay 10	{view stop "fire"}}			{burn volume "body" fx "smoke_aero_big" time 10 fake}			{burn volume "engine" fx "smoke_aero_big" time 10 fake}			{delay 10.1				{burn volume "body" fx "smoke_black" time 40 10 fake}			}		}	}	{on ground_hit overload		{spawn "spheredust_big_short"}		{call "detonate"}	}	{on contact overload		{if effector "vehicle"			{call "detonate"}		else effector "construction"			{call "detonate"}		else effector "tree"			{call "detonate"}		else effector "fence"			{if volume "part"				{call "tear_part"}			}		}	}		{on "detonate" overload			{call "explosion"}			{call "mp_destroy"}			{delay 0.1 {delete}}		}		{on "die" overload			{chassis_work 0}			{drop_orders}			{call "engine_stop"}			{stop_sound "fall"}			{stop_sound "engine_stop"}			{explosive 0}			{burn stop}			{bone hide "engine_work"}		}		{on "_explosion" overload			{call "_detonate"}			{call "mp_destroy"}			{kill_crew}			{able select 0}			{clear_inventory}			{call "die"}			{add_view "aero_die" "fire" "body"}			{add_view "aero_die_fire" "fire" "body"}			{view start "fire"}			{spawn "aero_die_particle"}			{tags add "destroyed"}			{tags remove "air"}				{impulse up 0.1 com}			{delay 0.1				(define "cut_part"					{if rand %1						{tear "piece_big_airborne_wing" bone %0							{impulse up 2 1 dir 2 1}						}					}				)				{delay_ex 0					{set "no_burn_volumes" 1}					{ani_play "death"}				}				("cut_part" args "part1"		0.5)				("cut_part" args "part2"		0.5)				("cut_part" args "part3"		0.5)				("cut_part" args "part4"		0.5)				("cut_part" args "part5"		0.5)				("cut_part" args "part6"		0.5)				("cut_part" args "wingr1"		0.5)				("cut_part" args "wingl1"		0.5)				("cut_part" args "wingr2"		0.5)				("cut_part" args "wingl2"		0.5)				("cut_part" args "body_back"	0.5)				("cut_part" args "propeller"	1.0)	                                 				("cut_part" args "propeller1"	1.0)				("cut_part" args "tail_rotor"	1.0)					{volumes disable obstacle}				{volumes "body" enable obstacle}				{volumes "body_back" disable obstacle}				{area rebuild}			}		}		{on "_detonate"		}		{on "area_disable" {area disable}}		{on "area_enable"	{area enable}}		{on "air_attack" overload}		{on "init_gun"}	}		{"airborne no_explosion"		{on ground_hit {call "die"}	{impulse up 0.1 com}}		{on "_explosion" overload			{call "die"}			{impulse up 0.1 com}			("cut_part" args "wingr2"		0.5)			("cut_part" args "wingl2"		0.5)		}		{on "fall_fx" overload}	}	{"air_part"		{on spawn			{delay 0.1				{volumes enable contact contact_ground}			}			{view stop ""}			{add_view "smoke_black" "smoke" "root"}			{view start "smoke"}			{delay 180 30				{view stop "smoke"}			}		}		{on ground_hit			{if min_speed 5				{spawn "spheredust_big_short"}			}		}	}		{"air_part wing"		{on ground_hit			{if volume "part"				{if volume_bone_level 3					{call "tear_part"}				}			}		}		{on "tear_part"			{tear "piece_big_airborne_wing" bone from_volume				{impulse up 0.1 0.05}			}		}	}	{"usa_las_dummy"		{on spawn			{tags add "usa_target_laser"}			{delay 0.25				{delete}			}		}	}	{"laser_bomb_usa"		{on spawn			{tags add "laser"}			{tags add "usa"}		}		{on "_detonate" overload			{volumes "body" disable all}			{stuff_detonate}			{if altitude 3			else			      {spawn "crater_norm_land_big" "body" terrain_texmod}			}		}	}	{"rus_las_dummy"		{on spawn			{tags add "rus_target_laser"}			{delay 0.25				{delete}			}		}	}	{"laser_bomb_rus"		{on spawn			{tags add "laser"}			{tags add "rus"}		}		{on "_detonate" overload			{volumes "body" disable all}			{stuff_detonate}			{if altitude 3			else			      {spawn "crater_norm_land_big" "body" terrain_texmod}			}		}	}	{"SAM_rus"		{on spawn			{tags add "radar"}			{tags add "rus"}		}		{on "_detonate" overload			{volumes "body" disable all}			{stuff_detonate}			{if altitude 2			else			      {spawn "crater_norm_land" "body" terrain_texmod}			}		}	}	{"SAM_usa"		{on spawn			{tags add "radar"}			{tags add "usa"}		}		{on "_detonate" overload			{volumes "body" disable all}			{stuff_detonate}			{if altitude 2			else			      {spawn "crater_norm_land" "body" terrain_texmod}			}		}	}	{"IR_ff_rus"		{on spawn			{tags add "IR_ff"}			{tags add "rus"}		}		{on "_detonate" overload			{volumes "body" disable all}			{stuff_detonate}			{if altitude 2			else			      {spawn "crater_norm_land" "body" terrain_texmod}			}		}	}	{"IR_ff_usa"		{on spawn			{tags add "IR_ff"}			{tags add "usa"}		}		{on "_detonate" overload			{volumes "body" disable all}			{stuff_detonate}			{if altitude 2			else			      {spawn "crater_norm_land" "body" terrain_texmod}			}		}	}	{"Maverick"		{on spawn			{add_view	"rocket_smoke_st"		"engine_work"				"tail"}			{add_view	"rocket_smoket"		"engine_work"				"tail1"}			{add_view	"smoke_white_steam"		"engine_work"				"tail1"}			{add_view	"smoke_white_steam"		"engine_work"				"tail2"}			{add_view	"startsmoke_big"		"engine_exhaust"				"tail"}			{link_sound "fly"				"vehicle/engine/Missile/MissileEngine"			}			{link_sound "engine_start"				"weapon/shot/reactive/katyusha_burst"			}			{view pause "engine_exhaust"}			{view pause "engine_work"}		}		{on engine on 	                                                                          			{delay 12			     {if tagged "defined_placement"				{call "fall"}			     }			}		}	}	{"x-25ml"		{on spawn			{add_view	"rocket_smoke_st"		"engine_work"				"tail1"}			{add_view	"rocket_smoke_st"		"engine_work"				"tail2"}			{add_view	"rocket_smoket"		"engine_work"				"tail"}			{add_view	"smoke_white_steam"		"engine_work"				"tail"}			{add_view	"startsmoke_big"		"engine_exhaust"				"tail1"}			{add_view	"startsmoke_big"		"engine_exhaust"				"tail2"}			{link_sound "fly"				"vehicle/engine/Missile/MissileEngine"			}			{link_sound "engine_start"				"weapon/shot/reactive/katyusha_burst"			}			{view pause "engine_exhaust"}			{view pause "engine_work"}			{tags add "air_start"}		}		{on engine on 	                                                                          			{delay 15			     {if tagged "defined_placement"				{call "fall"}			     }			}		}	}	{"r-73"		{on spawn			{add_view	"rocket_smoke_st"		"engine_work"				"tail"}			{add_view	"rocket_smoket"		"engine_work"				"tail1"}			{add_view	"smoke_white_steam"		"engine_work"				"tail1"}			{add_view	"smoke_white_steam"		"engine_work"				"tail2"}			{add_view	"startsmoke_big"		"engine_exhaust"				"tail"}			{link_sound "fly"				"vehicle/engine/Missile/MissileEngine"			}			{link_sound "engine_start"				"weapon/shot/reactive/katyusha_burst"			}			{view pause "engine_exhaust"}			{view pause "engine_work"}		}		{on engine on 	                                                                          			{delay 4	                   			     {if tagged "defined_placement"				{call "fall"}			     }			}		}	}	{"aim-9l"		{on spawn			{add_view	"rocket_smoke_st"		"engine_work"				"tail"}			{add_view	"rocket_smoket"		"engine_work"				"tail1"}			{add_view	"smoke_white_steam"		"engine_work"				"tail1"}			{add_view	"smoke_white_steam"		"engine_work"				"tail2"}			{add_view	"startsmoke_big"		"engine_exhaust"				"tail"}			{link_sound "fly"				"vehicle/engine/Missile/MissileEngine"			}			{link_sound "engine_start"				"weapon/shot/reactive/katyusha_burst"			}			{view pause "engine_exhaust"}			{view pause "engine_work"}		}		{on engine on 	                                                                          			{delay 4	                   			     {if tagged "defined_placement"				{call "fall"}			     }			}		}	}		{"48n6e2"		{on spawn			{add_view	"rocket_smoke_st"		"engine_work"				"tail"}			{add_view	"rocket_smoket"		"engine_work"				"tail1"}			{add_view	"smoke_white_steam"		"engine_work"				"tail1"}			{add_view	"smoke_white_steam"		"engine_work"				"tail2"}			{add_view	"startsmoke_big"		"engine_exhaust"				"tail"}			{link_sound "fly"				"vehicle/engine/Missile/MissileEngine"			}			{link_sound "engine_start"				"weapon/shot/reactive/katyusha_burst"			}			{view pause "engine_exhaust"}			{view pause "engine_work"}		}		{on engine on 	                                                                          			{delay 15	                   			     {if tagged "defined_placement"				{call "fall"}			     }			}		}	}	                                                                  		                                                         	{"proj_dummy"		{on "link_effects"			{delay 0 {with_linked_entity "missile" 				{add_view	"proj_smoke"		"proj_tail"		"root"}				{add_view	"proj_smoke30"		"proj_tail30"		"root"}				{add_view	"proj_smoke20"		"proj_tail20"		"root"}				{add_view	"proj_smoke10"		"proj_tail10"		"root"}			}}			{call "link_effects1"}			{call "manage_effects"}		}		{on "manage_effects"			{call "manage_effects1"}			{call "launch_procedures"}		}		{on "start_guidance_seq"			{call "launch"}			{call "chdir_repeater"}		}	     {on "check_direction"		                                            			{impulse forward 0.5 up 0.1 com}	                             		{gravity 0.1}		{delay 0.01 {impulse forward -0.1 com}{gravity 0.01}}		{delay 0.02 {impulse up -0.1 com}{gravity 0.01}}		{delay 0.03 {impulse forward 0.1 com}{gravity 0.01}}		{delay 0.04 {impulse up 0.1 com}{gravity 0.01}}		{delay 0.05 {impulse forward 0.1 com}{gravity 0.01}}		{delay 0.06 {impulse up -0.1 com}{gravity 0.01}}		{delay 0.07 {impulse forward -0.1 com}{gravity 0.01}}		{delay 0.08 {impulse up 0.1 com}{gravity 0.01}}		{delay 0.09 {impulse up -0.1 com}{gravity 0.01}}		{delay 0.10 {impulse up 0.1 com}{gravity 0.01}}		{delay 0.11 {impulse up -0.1 com}{gravity 0.01}}		{delay 0.12 {impulse up 0.1 com}{gravity 0.01}}		{delay 0.13 {impulse up -0.1 com}{gravity 0.01}}		{delay 0.14 {impulse up 0.1 com}{gravity 0.01}}		{delay 0.15 {impulse up -0.1 com}{gravity 0.01}}					{delay 0.05 			{call "change_direction"}		}			     }	     {on "turn_off_ik"		{ik_enable "stage_hor01" 0}{ik_enable "stage_ver01" 0}		{ik_enable "stage_hor02" 0}{ik_enable "stage_ver02" 0}		{ik_enable "stage_hor03" 0}{ik_enable "stage_ver03" 0}		{ik_enable "stage_hor04" 0}{ik_enable "stage_ver04" 0}		{ik_enable "stage_hor05" 0}{ik_enable "stage_ver05" 0}		{ik_enable "stage_hor06" 0}{ik_enable "stage_ver06" 0}		{ik_enable "stage_hor07" 0}{ik_enable "stage_ver07" 0}		{ik_enable "stage_hor08" 0}{ik_enable "stage_ver08" 0}		{ik_enable "stage_hor09" 0}{ik_enable "stage_ver09" 0}		{ik_enable "stage_hor10" 0}{ik_enable "stage_ver10" 0}		{ik_enable "stage_hor11" 0}{ik_enable "stage_ver11" 0}		{ik_enable "stage_hor12" 0}{ik_enable "stage_ver12" 0}		{ik_enable "stage_hor13" 0}{ik_enable "stage_ver13" 0}		{ik_enable "stage_hor14" 0}{ik_enable "stage_ver14" 0}		{ik_enable "stage_hor15" 0}{ik_enable "stage_ver15" 0}		{ik_enable "stage_hor16" 0}{ik_enable "stage_ver16" 0}		{ik_enable "stage_hor17" 0}{ik_enable "stage_ver17" 0}		{ik_enable "stage_hor18" 0}{ik_enable "stage_ver18" 0}		{ik_enable "stage_hor19" 0}{ik_enable "stage_ver19" 0}		{ik_enable "stage_hor20" 0}{ik_enable "stage_ver20" 0}		{ik_enable "stage_hor21" 0}{ik_enable "stage_ver21" 0}		{ik_enable "stage_hor22" 0}{ik_enable "stage_ver22" 0}		{ik_enable "stage_hor23" 0}{ik_enable "stage_ver23" 0}		{ik_enable "stage_hor24" 0}{ik_enable "stage_ver24" 0}		{ik_enable "stage_hor25" 0}{ik_enable "stage_ver25" 0}		{ik_enable "stage_hor26" 0}{ik_enable "stage_ver26" 0}		{ik_enable "stage_hor27" 0}{ik_enable "stage_ver27" 0}		{ik_enable "stage_hor28" 0}{ik_enable "stage_ver28" 0}		{ik_enable "stage_hor29" 0}{ik_enable "stage_ver29" 0}		{ik_enable "stage_hor30" 0}{ik_enable "stage_ver30" 0}		{ik_enable "stage_hor31" 0}{ik_enable "stage_ver31" 0}		{ik_enable "stage_hor32" 0}{ik_enable "stage_ver32" 0}		{ik_enable "stage_hor33" 0}{ik_enable "stage_ver33" 0}		{ik_enable "stage_hor34" 0}{ik_enable "stage_ver34" 0}		{ik_enable "stage_hor35" 0}{ik_enable "stage_ver35" 0}		{ik_enable "stage_hor36" 0}{ik_enable "stage_ver36" 0}		{ik_enable "stage_hor37" 0}{ik_enable "stage_ver37" 0}		{ik_enable "stage_hor38" 0}{ik_enable "stage_ver38" 0}		{ik_enable "stage_hor39" 0}{ik_enable "stage_ver39" 0}		{ik_enable "stage_hor40" 0}{ik_enable "stage_ver40" 0}	     }		    {on "change_stage"	     	     	     {update_visibility_patch}	        {if tagged "stage_01" {tags remove "stage_01"} {tags add "stage_02"} {ik_enable "stage_hor02" 1}{ik_enable "stage_ver02" 1}{ik_enable "stage_hor01" 0}{ik_enable "stage_ver01" 0}{tags add "start"}		else tagged "stage_02" {tags remove "stage_02"} {tags add "stage_03"} {ik_enable "stage_hor03" 1}{ik_enable "stage_ver03" 1}{ik_enable "stage_hor02" 0}{ik_enable "stage_ver02" 0}		else tagged "stage_03" {tags remove "stage_03"} {tags add "stage_04"} {ik_enable "stage_hor04" 1}{ik_enable "stage_ver04" 1}{ik_enable "stage_hor03" 0}{ik_enable "stage_ver03" 0}		else tagged "stage_04" {tags remove "stage_04"} {tags add "stage_05"} {ik_enable "stage_hor05" 1}{ik_enable "stage_ver05" 1}{ik_enable "stage_hor04" 0}{ik_enable "stage_ver04" 0}		else tagged "stage_05" {tags remove "stage_05"} {tags add "stage_06"} {ik_enable "stage_hor06" 1}{ik_enable "stage_ver06" 1}{ik_enable "stage_hor05" 0}{ik_enable "stage_ver05" 0}		else tagged "stage_06" {tags remove "stage_06"} {tags add "stage_07"} {ik_enable "stage_hor07" 1}{ik_enable "stage_ver07" 1}{ik_enable "stage_hor06" 0}{ik_enable "stage_ver06" 0}		else tagged "stage_07" {tags remove "stage_07"} {tags add "stage_08"} {ik_enable "stage_hor08" 1}{ik_enable "stage_ver08" 1}{ik_enable "stage_hor07" 0}{ik_enable "stage_ver07" 0}		else tagged "stage_08" {tags remove "stage_08"} {tags add "stage_09"} {ik_enable "stage_hor09" 1}{ik_enable "stage_ver09" 1}{ik_enable "stage_hor08" 0}{ik_enable "stage_ver08" 0}		else tagged "stage_09" {tags remove "stage_09"} {tags add "stage_10"}  {ik_enable "stage_hor10" 1}{ik_enable "stage_ver10" 1}{ik_enable "stage_hor09" 0}{ik_enable "stage_ver09" 0}{tags add "50m_fly"}		else tagged "stage_10" {tags remove "stage_10"} {tags add "stage_11"} {ik_enable "stage_hor11" 1}{ik_enable "stage_ver11" 1}{ik_enable "stage_hor10" 0}{ik_enable "stage_ver10" 0}		else tagged "stage_11" {tags remove "stage_11"} {tags add "stage_12"} {ik_enable "stage_hor12" 1}{ik_enable "stage_ver12" 1}{ik_enable "stage_hor11" 0}{ik_enable "stage_ver11" 0}		else tagged "stage_12" {tags remove "stage_12"} {tags add "stage_13"} {ik_enable "stage_hor13" 1}{ik_enable "stage_ver13" 1}{ik_enable "stage_hor12" 0}{ik_enable "stage_ver12" 0}		else tagged "stage_13" {tags remove "stage_13"} {tags add "stage_14"} {ik_enable "stage_hor14" 1}{ik_enable "stage_ver14" 1}{ik_enable "stage_hor13" 0}{ik_enable "stage_ver13" 0}		else tagged "stage_14" {tags remove "stage_14"} {tags add "stage_15"} {ik_enable "stage_hor15" 1}{ik_enable "stage_ver15" 1}{ik_enable "stage_hor14" 0}{ik_enable "stage_ver14" 0}		else tagged "stage_15" {tags remove "stage_15"} {tags add "stage_16"} {ik_enable "stage_hor16" 1}{ik_enable "stage_ver16" 1}{ik_enable "stage_hor15" 0}{ik_enable "stage_ver15" 0}		else tagged "stage_16" {tags remove "stage_16"} {tags add "stage_17"} {ik_enable "stage_hor17" 1}{ik_enable "stage_ver17" 1}{ik_enable "stage_hor16" 0}{ik_enable "stage_ver16" 0}		else tagged "stage_17" {tags remove "stage_17"} {tags add "stage_18"} {ik_enable "stage_hor18" 1}{ik_enable "stage_ver18" 1}{ik_enable "stage_hor17" 0}{ik_enable "stage_ver17" 0}		else tagged "stage_18" {tags remove "stage_18"} {tags add "stage_19"} {ik_enable "stage_hor19" 1}{ik_enable "stage_ver19" 1}{ik_enable "stage_hor18" 0}{ik_enable "stage_ver18" 0}		else tagged "stage_19" {tags remove "stage_19"} {tags add "stage_20"} {ik_enable "stage_hor20" 1}{ik_enable "stage_ver20" 1}{ik_enable "stage_hor19" 0}{ik_enable "stage_ver19" 0}{tags add "100m_fly"}		else tagged "stage_20" {tags remove "stage_20"} {tags add "stage_21"} {ik_enable "stage_hor21" 1}{ik_enable "stage_ver21" 1}{ik_enable "stage_hor20" 0}{ik_enable "stage_ver20" 0}		else tagged "stage_21" {tags remove "stage_21"} {tags add "stage_22"} {ik_enable "stage_hor22" 1}{ik_enable "stage_ver22" 1}{ik_enable "stage_hor21" 0}{ik_enable "stage_ver21" 0}		else tagged "stage_22" {tags remove "stage_22"} {tags add "stage_23"} {ik_enable "stage_hor23" 1}{ik_enable "stage_ver23" 1}{ik_enable "stage_hor22" 0}{ik_enable "stage_ver22" 0}		else tagged "stage_23" {tags remove "stage_23"} {tags add "stage_24"} {ik_enable "stage_hor24" 1}{ik_enable "stage_ver24" 1}{ik_enable "stage_hor23" 0}{ik_enable "stage_ver23" 0}		else tagged "stage_24" {tags remove "stage_24"} {tags add "stage_25"} {ik_enable "stage_hor25" 1}{ik_enable "stage_ver25" 1}{ik_enable "stage_hor24" 0}{ik_enable "stage_ver24" 0}		else tagged "stage_25" {tags remove "stage_25"} {tags add "stage_26"} {ik_enable "stage_hor26" 1}{ik_enable "stage_ver26" 1}{ik_enable "stage_hor25" 0}{ik_enable "stage_ver25" 0}		else tagged "stage_26" {tags remove "stage_26"} {tags add "stage_27"} {ik_enable "stage_hor27" 1}{ik_enable "stage_ver27" 1}{ik_enable "stage_hor26" 0}{ik_enable "stage_ver26" 0}		else tagged "stage_27" {tags remove "stage_27"} {tags add "stage_28"} {ik_enable "stage_hor28" 1}{ik_enable "stage_ver28" 1}{ik_enable "stage_hor27" 0}{ik_enable "stage_ver27" 0}		else tagged "stage_28" {tags remove "stage_28"} {tags add "stage_29"} {ik_enable "stage_hor29" 1}{ik_enable "stage_ver29" 1}{ik_enable "stage_hor28" 0}{ik_enable "stage_ver28" 0}		else tagged "stage_29" {tags remove "stage_29"} {tags add "stage_30"} {ik_enable "stage_hor30" 1}{ik_enable "stage_ver30" 1}{ik_enable "stage_hor29" 0}{ik_enable "stage_ver29" 0}{tags add "150m_fly"}		else tagged "stage_30" {tags remove "stage_30"} {tags add "stage_31"} {ik_enable "stage_hor31" 1}{ik_enable "stage_ver31" 1}{ik_enable "stage_hor30" 0}{ik_enable "stage_ver30" 0}		else tagged "stage_31" {tags remove "stage_31"} {tags add "stage_32"} {ik_enable "stage_hor32" 1}{ik_enable "stage_ver32" 1}{ik_enable "stage_hor31" 0}{ik_enable "stage_ver31" 0}		else tagged "stage_32" {tags remove "stage_32"} {tags add "stage_33"} {ik_enable "stage_hor33" 1}{ik_enable "stage_ver33" 1}{ik_enable "stage_hor32" 0}{ik_enable "stage_ver32" 0}		else tagged "stage_33" {tags remove "stage_33"} {tags add "stage_34"} {ik_enable "stage_hor34" 1}{ik_enable "stage_ver34" 1}{ik_enable "stage_hor33" 0}{ik_enable "stage_ver33" 0}		else tagged "stage_34" {tags remove "stage_34"} {tags add "stage_35"} {ik_enable "stage_hor35" 1}{ik_enable "stage_ver35" 1}{ik_enable "stage_hor34" 0}{ik_enable "stage_ver34" 0}		else tagged "stage_35" {tags remove "stage_35"} {tags add "stage_36"} {ik_enable "stage_hor36" 1}{ik_enable "stage_ver36" 1}{ik_enable "stage_hor35" 0}{ik_enable "stage_ver35" 0}		else tagged "stage_36" {tags remove "stage_36"} {tags add "stage_37"} {ik_enable "stage_hor37" 1}{ik_enable "stage_ver37" 1}{ik_enable "stage_hor36" 0}{ik_enable "stage_ver36" 0}		else tagged "stage_37" {tags remove "stage_37"} {tags add "stage_38"} {ik_enable "stage_hor38" 1}{ik_enable "stage_ver38" 1}{ik_enable "stage_hor37" 0}{ik_enable "stage_ver37" 0}		else tagged "stage_38" {tags remove "stage_38"} {tags add "stage_39"} {ik_enable "stage_hor39" 1}{ik_enable "stage_ver39" 1}{ik_enable "stage_hor38" 0}{ik_enable "stage_ver38" 0}		else tagged "stage_39" {tags remove "stage_39"} {tags add "stage_40"}  {ik_enable "stage_hor40" 1}{ik_enable "stage_ver40" 1}{ik_enable "stage_hor39" 0}{ik_enable "stage_ver39" 0}{tags add "200m_fly"}		else tagged "stage_40" 			{tags remove "stage_40"} 			{if tagged "cwps_extended_range2" 				{call "spawn_presecond_stage"}			else tagged "cwps_extended_range"				{call "spawn_second_stage"}			else 				{call "detonate"}			}	        }		{call "check_altitude"}		{if not altitude 15			{delay 0.05 {call "check_altitude"} }			{delay 0.1 {call "check_altitude"} }		}	    }		{on "check_altitude"			{with_linked_entity "missile"				{if not altitude 0.1					{if not tagged "underwater_launch"						                                  						{spawn "proj_deleter" "root"						{delay 0.2 {delete}}						}	                       					}				else not altitude 10					{if tagged "underwater_launch"						{spawn "ex_water_big"}					}					{tags remove "underwater_launch"}					{view pause "proj_tail10"}					{view pause "proj_tail20"}					{view pause "proj_tail30"}					{view pause "proj_tail"}				else not altitude 20					{tags remove "underwater_launch"}					{view start "proj_tail10"}					{view pause "proj_tail20"}					{view pause "proj_tail30"}					{view pause "proj_tail"}				else not altitude 30					{tags remove "underwater_launch"}					{view pause "proj_tail10"}					{view start "proj_tail20"}					{view pause "proj_tail30"}					{view pause "proj_tail"}				else not altitude 40					{tags remove "underwater_launch"}					{view pause "proj_tail10"}					{view pause "proj_tail20"}					{view start "proj_tail30"}					{view pause "proj_tail"}				else					{tags remove "underwater_launch"}					{view pause "proj_tail10"}					{view pause "proj_tail20"}					{view pause "proj_tail30"}					{view start "proj_tail"}				}			}		}	     {on overlap end	     }		     {on "detonate"	       {if not "detonate"			{set "detonate" 1}			{call "spawn_missile"}			{with_linked_entity "missile"				{delete}			}			{delete}	       }	     }		     {on "destroyed_by_kaz"	       {if not "detonate"			{set "detonate" 1}			{with_linked_entity "missile"				{stuff_detonate}			}			{delete}	       }	     }	     {on "destroyed_by_ground"	       {if not "detonate"			{set "detonate" 1}			{call "spawn_missile_ground"}			{with_linked_entity "missile"				{delete}			}			{delete}	       }	     }		     {on "spawn_missile"		 {weapon_work "targeting_sys_anti_jamming" 0}	     }	     {on "spawn_missile_ground"	     }	                                                      		 		{on "check_no_signal"			{delay 0.5 {if tagged "no_power" {tags remove "guided"}  {weapon_work "targeting_sys" 0} {weapon_work "targeting_sys_anti_jamming" 0}}}		}	     {on contact	     	{if effector "small wood" {with_effector {call "break"}{with_effector}}			else effector "proj_deleter"		                                     		                        		                     				{call "destroyed_by_ground"}			else effector "proj_point"				{call "detonate"}	                                                     			else effector "smoke_cloud"				{if tagged "smoke_vulnerable" {if tagged "guided" {tags remove "guided"}     {weapon_work "targeting_sys" 0} {weapon_work "targeting_sys_anti_jamming" 0}      }}			else effector "kaz"			else effector "trophy_proj_initiator" {call "destroyed_by_kaz"} {with_effector {volumes disable contact}{with_effector}}			else effector "targetable_missile"				{call "detonate"}			else effector "targetable_impactor"				{call "detonate"}			else volume "second_det"				{if effector "vehicle" {call "detonate"}				else {volumes "second_det" disable contact} {delay 0.1 {volumes "second_det" enable contact}}}			else effector "proj_dummy"	                     				{if volume "proximity"	{volumes "proximity" disable contact} {delay 0.1 {volumes "proximity" enable contact}}				else {call "detonate"}}			else effector "projectile_impactor"				{if volume "proximity"	{volumes "proximity" disable contact} {delay 0.1 {volumes "proximity" enable contact}}				else {call "detonate"}}				else				{call "detonate"}			}	     }	     {on ground_hit overload		{call "detonate"}	     }	     {on pierce overload	          {if not stuff "proj_pointer"				{call "detonate"}	           }	     }	     {on blast_hit		{call "detonate"}	     }	     {on bullet_hit overload			{if stuff "trophy" {call "destroyed_by_kaz"}			else stuff "radiowave" {with_linked_entity "missile" {call "missile_lock"}}			else stuff "anti_smallmissile" {with_linked_entity "missile" {call "missile_lock_long"}}			}	     }	 }	 	(define "speed_fast"		               		{on "chdir_repeater" overload			{delay (/	0.16	%coeff) {call "check_direction"}}			{delay (/	0.32	%coeff) {call "check_direction"}}			{delay (/	0.48	%coeff) {call "check_direction"}}			{delay (/	0.64	%coeff) {call "check_direction"}}			{delay (/	0.8	%coeff) {call "check_direction"}}			{delay (/	0.96	%coeff) {call "check_direction"}}			{delay (/	1.12	%coeff) {call "check_direction"}}			{delay (/	1.28	%coeff) {call "check_direction"}}			{delay (/	1.44	%coeff) {call "check_direction"}}			{delay (/	1.6	%coeff) {call "check_direction"}}			{delay (/	1.76	%coeff) {call "check_direction"}}			{delay (/	1.92	%coeff) {call "check_direction"}}			{delay (/	2.08	%coeff) {call "check_direction"}}			{delay (/	2.24	%coeff) {call "check_direction"}}			{delay (/	2.4	%coeff) {call "check_direction"}}			{delay (/	2.56	%coeff) {call "check_direction"}}			{delay (/	2.72	%coeff) {call "check_direction"}}			{delay (/	2.88	%coeff) {call "check_direction"}}			{delay (/	3.04	%coeff) {call "check_direction"}}			{delay (/	3.2	%coeff) {call "check_direction"}}			{delay (/	3.36	%coeff) {call "check_direction"}}			{delay (/	3.52	%coeff) {call "check_direction"}}			{delay (/	3.68	%coeff) {call "check_direction"}}			{delay (/	3.84	%coeff) {call "check_direction"}}			{delay (/	4	%coeff) {call "check_direction"}}			{delay (/	4.16	%coeff) {call "check_direction"}}			{delay (/	4.32	%coeff) {call "check_direction"}}			{delay (/	4.48	%coeff) {call "check_direction"}}			{delay (/	4.64	%coeff) {call "check_direction"}}			{delay (/	4.8	%coeff) {call "check_direction"}}			{delay (/	4.96	%coeff) {call "check_direction"}}			{delay (/	5.12	%coeff) {call "check_direction"}}			{delay (/	5.28	%coeff) {call "check_direction"}}			{delay (/	5.44	%coeff) {call "check_direction"}}			{delay (/	5.6	%coeff) {call "check_direction"}}			{delay (/	5.76	%coeff) {call "check_direction"}}			{delay (/	5.92	%coeff) {call "check_direction"}}			{delay (/	6.08	%coeff) {call "check_direction"}}			{delay (/	6.24	%coeff) {call "check_direction"}}			{delay (/	6.4	%coeff) {call "check_direction"}}			}		{on "launch" overload {ani_play "center_veryfast" (* 0.75 %coeff)}	}	)	(define "speed_normal"		               		{on "chdir_repeater" overload			{delay (/	0.213	%coeff) {call "check_direction"}}			{delay (/	0.426	%coeff) {call "check_direction"}}			{delay (/	0.639	%coeff) {call "check_direction"}}			{delay (/	0.852	%coeff) {call "check_direction"}}			{delay (/	1.065	%coeff) {call "check_direction"}}			{delay (/	1.278	%coeff) {call "check_direction"}}			{delay (/	1.491	%coeff) {call "check_direction"}}			{delay (/	1.704	%coeff) {call "check_direction"}}			{delay (/	1.917	%coeff) {call "check_direction"}}			{delay (/	2.13	%coeff) {call "check_direction"}}			{delay (/	2.343	%coeff) {call "check_direction"}}			{delay (/	2.556	%coeff) {call "check_direction"}}			{delay (/	2.769	%coeff) {call "check_direction"}}			{delay (/	2.982	%coeff) {call "check_direction"}}			{delay (/	3.195	%coeff) {call "check_direction"}}			{delay (/	3.408	%coeff) {call "check_direction"}}			{delay (/	3.621	%coeff) {call "check_direction"}}			{delay (/	3.834	%coeff) {call "check_direction"}}			{delay (/	4.047	%coeff) {call "check_direction"}}			{delay (/	4.26	%coeff) {call "check_direction"}}			{delay (/	4.473	%coeff) {call "check_direction"}}			{delay (/	4.686	%coeff) {call "check_direction"}}			{delay (/	4.899	%coeff) {call "check_direction"}}			{delay (/	5.112	%coeff) {call "check_direction"}}			{delay (/	5.325	%coeff) {call "check_direction"}}			{delay (/	5.538	%coeff) {call "check_direction"}}			{delay (/	5.751	%coeff) {call "check_direction"}}			{delay (/	5.964	%coeff) {call "check_direction"}}			{delay (/	6.177	%coeff) {call "check_direction"}}			{delay (/	6.39	%coeff) {call "check_direction"}}			{delay (/	6.603	%coeff) {call "check_direction"}}			{delay (/	6.816	%coeff) {call "check_direction"}}			{delay (/	7.029	%coeff) {call "check_direction"}}			{delay (/	7.242	%coeff) {call "check_direction"}}			{delay (/	7.455	%coeff) {call "check_direction"}}			{delay (/	7.668	%coeff) {call "check_direction"}}			{delay (/	7.881	%coeff) {call "check_direction"}}			{delay (/	8.094	%coeff) {call "check_direction"}}			{delay (/	8.307	%coeff) {call "check_direction"}}			{delay (/	8.52	%coeff) {call "check_direction"}}			}		{on "launch" overload {ani_play "center_fast" (* 0.5625 %coeff)}	}	)	(define "speed_slow"		               		{on "chdir_repeater" overload			{delay (/	0.24	%coeff) {call "check_direction"}}			{delay (/	0.48	%coeff) {call "check_direction"}}			{delay (/	0.72	%coeff) {call "check_direction"}}			{delay (/	0.96	%coeff) {call "check_direction"}}			{delay (/	1.2	%coeff) {call "check_direction"}}			{delay (/	1.44	%coeff) {call "check_direction"}}			{delay (/	1.68	%coeff) {call "check_direction"}}			{delay (/	1.92	%coeff) {call "check_direction"}}			{delay (/	2.16	%coeff) {call "check_direction"}}			{delay (/	2.4	%coeff) {call "check_direction"}}			{delay (/	2.64	%coeff) {call "check_direction"}}			{delay (/	2.88	%coeff) {call "check_direction"}}			{delay (/	3.12	%coeff) {call "check_direction"}}			{delay (/	3.36	%coeff) {call "check_direction"}}			{delay (/	3.6	%coeff) {call "check_direction"}}			{delay (/	3.84	%coeff) {call "check_direction"}}			{delay (/	4.08	%coeff) {call "check_direction"}}			{delay (/	4.32	%coeff) {call "check_direction"}}			{delay (/	4.56	%coeff) {call "check_direction"}}			{delay (/	4.8	%coeff) {call "check_direction"}}			{delay (/	5.04	%coeff) {call "check_direction"}}			{delay (/	5.28	%coeff) {call "check_direction"}}			{delay (/	5.52	%coeff) {call "check_direction"}}			{delay (/	5.76	%coeff) {call "check_direction"}}			{delay (/	6	%coeff) {call "check_direction"}}			{delay (/	6.24	%coeff) {call "check_direction"}}			{delay (/	6.48	%coeff) {call "check_direction"}}			{delay (/	6.72	%coeff) {call "check_direction"}}			{delay (/	6.96	%coeff) {call "check_direction"}}			{delay (/	7.2	%coeff) {call "check_direction"}}			{delay (/	7.44	%coeff) {call "check_direction"}}			{delay (/	7.68	%coeff) {call "check_direction"}}			{delay (/	7.92	%coeff) {call "check_direction"}}			{delay (/	8.16	%coeff) {call "check_direction"}}			{delay (/	8.4	%coeff) {call "check_direction"}}			{delay (/	8.64	%coeff) {call "check_direction"}}			{delay (/	8.88	%coeff) {call "check_direction"}}			{delay (/	9.12	%coeff) {call "check_direction"}}			{delay (/	9.36	%coeff) {call "check_direction"}}			{delay (/	9.6	%coeff) {call "check_direction"}}		}		{on "launch" overload {ani_play "center" (* 0.5 %coeff)}}	)	(define "antislip"		{on "check_altitude"			{with_linked_entity "missile"				{if not altitude 1.0					{if not tagged "underwater_launch"						{spawn "proj_point_dummy" "root"}						{spawn "proj_deleter" "root"						{delay 0.1 {delete}}						}	                       					}				}				}		}		)	{"proj_dummy fast"		{on spawn		     {call "turn_off_ik"}		     {tags add "guided"}			 {call "check_no_signal"}		     {volumes "missile" disable contact blast}		     {volumes "target" disable contact blast}		     {volumes "target1" disable contact blast}		     {delay 0.1 			     {volumes "missile" enable contact}			     {volumes "target" enable bullet blast}			     {volumes "target1" enable bullet blast}		     }		     {delay 1 			     {volumes "proximity" enable contact}		     }	                 		     {delay 0				{call "link_effects"}				{impulse forward 2 com}{gravity 0.01}				{tags add "stage_01"} {ik_enable "stage_hor01" 1}{ik_enable "stage_ver01" 1}			               				{call "start_guidance_seq"}		     }		}				(define "try_launch_stage"		       tagged "stage_%0"			{if not tagged "guided"			       {if rand 0.3				("turn_to" args %0 left hor)			        else rand 0.7				("turn_to" args %0 right hor)			        }			       {if rand 0.3				("turn_to" args %0 top ver)			        else rand 0.7				("turn_to" args %0 bottom ver)			        }			}		)				("speed_fast" coeff(1))			(define "turn_to"		        {if not "%2_dir_checked"			{ani_play "stage_%2%0_%1" 0.35}		        }		)			     {on "change_direction"		{if ("try_launch_stage" args 01)		else ("try_launch_stage" args 02)		else ("try_launch_stage" args 03)		else ("try_launch_stage" args 04)		else ("try_launch_stage" args 05)		else ("try_launch_stage" args 06)		else ("try_launch_stage" args 07)		else ("try_launch_stage" args 08)		else ("try_launch_stage" args 09)		else ("try_launch_stage" args 10)		else ("try_launch_stage" args 11)		else ("try_launch_stage" args 12)		else ("try_launch_stage" args 13)		else ("try_launch_stage" args 14)		else ("try_launch_stage" args 15)		else ("try_launch_stage" args 16)		else ("try_launch_stage" args 17)		else ("try_launch_stage" args 18)		else ("try_launch_stage" args 19)		else ("try_launch_stage" args 20)		else ("try_launch_stage" args 21)		else ("try_launch_stage" args 22)		else ("try_launch_stage" args 23)		else ("try_launch_stage" args 24)		else ("try_launch_stage" args 25)		else ("try_launch_stage" args 26)		else ("try_launch_stage" args 27)		else ("try_launch_stage" args 28)		else ("try_launch_stage" args 29)		else ("try_launch_stage" args 30)		else ("try_launch_stage" args 31)		else ("try_launch_stage" args 32)		else ("try_launch_stage" args 33)		else ("try_launch_stage" args 34)		else ("try_launch_stage" args 35)		else ("try_launch_stage" args 36)		else ("try_launch_stage" args 37)		else ("try_launch_stage" args 38)		else ("try_launch_stage" args 39)		else ("try_launch_stage" args 40)		}		{set "left_overlap" 0}		{set "right_overlap" 0}		{set "top_overlap" 0}		{set "bottom_overlap" 0}		{set "hor_dir_checked" 0}		{set "ver_dir_checked" 0}		{call "change_stage"}	     }	}		{"proj_dummy normal"		{on spawn		     {call "turn_off_ik"}		     {tags add "guided"}			 {call "check_no_signal"}		     {volumes "missile" disable contact blast}		     {volumes "target" disable contact blast}		     {volumes "target1" disable contact blast}		     {delay 0.1 			     {volumes "missile" enable contact}			     {volumes "target" enable bullet blast}			     {volumes "target1" enable bullet blast}		     }		     {delay 1 			     {volumes "proximity" enable contact}		     }	                 		     {delay 0				{call "link_effects"}				{impulse forward 2 com}{gravity 0.01}				{tags add "stage_01"} {ik_enable "stage_hor01" 1}{ik_enable "stage_ver01" 1}			               				{call "start_guidance_seq"}		     }		}			(define "try_launch_stage"		       tagged "stage_%0"			{if not tagged "guided"			       {if rand 0.3				("turn_to" args %0 left hor)			        else rand 0.7				("turn_to" args %0 right hor)			        }			       {if rand 0.3				("turn_to" args %0 top ver)			        else rand 0.7				("turn_to" args %0 bottom ver)			        }			}		)		("speed_normal" coeff(1))			(define "turn_to"		        {if not "%2_dir_checked"			{ani_play "stage_%2%0_%1" 0.1}		        }		)			     {on "change_direction"		{if ("try_launch_stage" args 01)		else ("try_launch_stage" args 02)		else ("try_launch_stage" args 03)		else ("try_launch_stage" args 04)		else ("try_launch_stage" args 05)		else ("try_launch_stage" args 06)		else ("try_launch_stage" args 07)		else ("try_launch_stage" args 08)		else ("try_launch_stage" args 09)		else ("try_launch_stage" args 10)		else ("try_launch_stage" args 11)		else ("try_launch_stage" args 12)		else ("try_launch_stage" args 13)		else ("try_launch_stage" args 14)		else ("try_launch_stage" args 15)		else ("try_launch_stage" args 16)		else ("try_launch_stage" args 17)		else ("try_launch_stage" args 18)		else ("try_launch_stage" args 19)		else ("try_launch_stage" args 20)		else ("try_launch_stage" args 21)		else ("try_launch_stage" args 22)		else ("try_launch_stage" args 23)		else ("try_launch_stage" args 24)		else ("try_launch_stage" args 25)		else ("try_launch_stage" args 26)		else ("try_launch_stage" args 27)		else ("try_launch_stage" args 28)		else ("try_launch_stage" args 29)		else ("try_launch_stage" args 30)		else ("try_launch_stage" args 31)		else ("try_launch_stage" args 32)		else ("try_launch_stage" args 33)		else ("try_launch_stage" args 34)		else ("try_launch_stage" args 35)		else ("try_launch_stage" args 36)		else ("try_launch_stage" args 37)		else ("try_launch_stage" args 38)		else ("try_launch_stage" args 39)		else ("try_launch_stage" args 40)		}		{set "left_overlap" 0}		{set "right_overlap" 0}		{set "top_overlap" 0}		{set "bottom_overlap" 0}		{set "hor_dir_checked" 0}		{set "ver_dir_checked" 0}		{call "change_stage"}	     }	}	{"proj_dummy slow"		{on spawn		     {call "turn_off_ik"}		     {tags add "guided"}			 {call "check_no_signal"}		     {volumes "missile" disable contact blast}		     {volumes "target" disable contact blast}		     {volumes "target1" disable contact blast}		     {delay 0.4 			     {volumes "missile" enable contact}			     {volumes "target" enable bullet blast}			     {volumes "target1" enable bullet blast}		     }		     {delay 1 			     {volumes "proximity" enable contact}		     }	                 		     {delay 0				{call "link_effects"}				{impulse forward 2 com}{gravity 0.01}				{tags add "stage_01"} {ik_enable "stage_hor01" 1}{ik_enable "stage_ver01" 1}			               				{call "start_guidance_seq"}					     }		}				(define "try_launch_stage"		       tagged "stage_%0"			{if not tagged "guided"			       {if rand 0.3				("turn_to" args %0 left hor)			        else rand 0.7				("turn_to" args %0 right hor)			        }			       {if rand 0.3				("turn_to" args %0 top ver)			        else rand 0.7				("turn_to" args %0 bottom ver)			        }			}		)		("speed_slow" coeff(1))			(define "turn_to"		        {if not "%2_dir_checked"			{ani_play "stage_%2%0_%1" 0.2}		        }		)				     {on "change_direction"		{if ("try_launch_stage" args 01)		else ("try_launch_stage" args 02)		else ("try_launch_stage" args 03)		else ("try_launch_stage" args 04)		else ("try_launch_stage" args 05)		else ("try_launch_stage" args 06)		else ("try_launch_stage" args 07)		else ("try_launch_stage" args 08)		else ("try_launch_stage" args 09)		else ("try_launch_stage" args 10)		else ("try_launch_stage" args 11)		else ("try_launch_stage" args 12)		else ("try_launch_stage" args 13)		else ("try_launch_stage" args 14)		else ("try_launch_stage" args 15)		else ("try_launch_stage" args 16)		else ("try_launch_stage" args 17)		else ("try_launch_stage" args 18)		else ("try_launch_stage" args 19)		else ("try_launch_stage" args 20)		else ("try_launch_stage" args 21)		else ("try_launch_stage" args 22)		else ("try_launch_stage" args 23)		else ("try_launch_stage" args 24)		else ("try_launch_stage" args 25)		else ("try_launch_stage" args 26)		else ("try_launch_stage" args 27)		else ("try_launch_stage" args 28)		else ("try_launch_stage" args 29)		else ("try_launch_stage" args 30)		else ("try_launch_stage" args 31)		else ("try_launch_stage" args 32)		else ("try_launch_stage" args 33)		else ("try_launch_stage" args 34)		else ("try_launch_stage" args 35)		else ("try_launch_stage" args 36)		else ("try_launch_stage" args 37)		else ("try_launch_stage" args 38)		else ("try_launch_stage" args 39)		else ("try_launch_stage" args 40)		}		{set "left_overlap" 0}		{set "right_overlap" 0}		{set "top_overlap" 0}		{set "bottom_overlap" 0}		{set "hor_dir_checked" 0}		{set "ver_dir_checked" 0}		{call "change_stage"}	     }	}			                        	               	           	                                              	   	                          	                        	                                            	   	  	{"proj_restrictor"		{on spawn {delay 0.1 {delete}}}		{on bullet_hit {delete}}	}	{"rpg_restrictor"		{on spawn {delay 0.2 {delete}}}		{on bullet_hit {delete}}	}	{"projectile_impactor"		{on spawn		                                            			{delay 0.1				{call "link_sound"}			}		}		{on "link_sound"			{if linked				{link_sound "fly"	"vehicle/engine/Missile/MissileEngine"}				{play_sound "fly" 1}				{tags add "cwps_missile_minimap"}			}		}		{on "detonate"		    {if altitude 0			 {spawn "proj_restrictor" "root" x}			 {stuff_detonate}			  else   			  			                     					{gravity 0}	                         				                 				{impulse up 2.0}				{call "underground_detonate"}				  											}		}		{on "underground_detonate"		    {if altitude 0			                                    			 {stuff_detonate}			  else   		  			    {impulse up 2.0}				{delay 0.01 {call "underground_detonate"}}							}		}		{on contact 			{call "detonate"}		}		{on ground_hit			{call "detonate"}		}		{on pierce 			{if not stuff "proj_pointer"				{call "detonate"}			}		}		{on blast			{if min_energy 0.3				{call "detonate"}			}		}	}		{"switchblade300_impactor"	    {on "detonate" overload			 {volumes disable all}				              			 {spawn "blast_restrictor_directional" "root" x}			 {stuff_detonate}		}	}	{"krasnopol_impactor"	    {on spawn			{volumes enable contact_ground}		}		{on ground_hit		    {stuff_detonate}		}		{on contact		    {stuff_detonate}		}	}	{"projectile_impactor silent"		{on "link_sound" overload			{if linked				{tags add "cwps_missile_minimap"}			}		}	}	{"projectile_impactor propfan"		{on "link_sound" overload			{if linked				{link_sound "fly"	"vehicle/airborne/small_UAV/small_UAV_work"}				{play_sound "fly" 1}				{tags add "cwps_missile_minimap"}			}		}	}	{"shahed136_base_impactor_link"		{on "link_sound" overload			{if linked				{link_sound "fly"	"vehicle/airborne/small_uav/shahed136_engine"}				{play_sound "fly" 1}				{tags add "cwps_missile_minimap"}			}		}	}	{"projectile_impactor  efp_core"		{on "detonate" overload			{stuff_detonate}		}	}		{"spawned_warhead"		{on spawn			{volumes disable contact bullet blast contact_ground}			{delay 0.2				{if not linked					{volumes enable contact blast contact_ground}				}			}		}	}		{"targetable_impactor"		{on spawn			{delay 0.5				{volumes "body" enable bullet}			}			{components "antimissile_t" break}			{ani_play "hit" loop}					}	     {on bullet_hit overload			{if stuff "trophy" {call "destroyed_by_kaz"}			else stuff "radiowave" {call "missile_lock"}			else stuff "anti_smallmissile" {call "missile_lock_long"}			}	     }	    {on "missile_lock"			{kill_delay "targ_for_missile"}			{components "antimissile_t" repair}			{delay_ex 3 "targ_for_missile"				{components "antimissile_t" break}			}	     }		 {on "missile_lock_long"			{kill_delay "targ_for_missile"}			{components "antimissile_t" repair}			{delay_ex 10 "targ_for_missile"				{components "antimissile_t" break}			}	     }	}		{"underwater_launch"		{on spawn			{if not altitude 0				{tags add "underwater_launch"}				{delay 0.05					{with_linked_entity "missile"						{tags add "underwater_launch"}					}				}				}		}	}	
{"torpedo_impactor"		
	{on "detonate" overload			
		{spawn "proj_restrictor" "root" x}			
		{stuff_detonate}		
	}	
}	                                                            		
{"proj_point"		
	{on spawn			
		{delay 2.1 "normal_hide" {delete}}			
		{delay 2 "emergency_hide" {delete}}			
		{delay 0.2			    
			{if tagged "cwps_ground_attack"					
				{kill_delay "normal_hide"}					
				{kill_delay "emergency_hide"}					
				{delay 50 {delete}}			    
			}			
		}			
		{delay 5			
			{if tagged "inertial_gs"		     
				{delay 1 			    
					{volumes "target" disable bullet visible}				 
					{volumes "body" disable bullet visible}			 
				}		     
			}			
		}		
	}		
	{on overlap begin			
		{if tagged "cwps_ground_attack" {delay 1 {delete}}}			
		{if effector "cwps_rangefinder"				
			{with_effector					
				{call "top_attack"}			    
			}			
		}			
		{if tagged "proj_vitebsk"			
			{volumes disable bullet visible}			
		}		
	}	
}		
{"proj_point_acc"	   
	{on spawn	      {impulse up 0.01 com} {gravity 0.0}		  {delay_ex 1.0 {physics_work 1}  {impulse rnd_dir 0.11 com} 			  }		  {delay_ex 2.0   {impulse rnd_dir 0.11 com}                                                                                                    			  }		   {delay_ex 3.0  {impulse rnd_dir 0.21 com}			   }		    {delay_ex 4.0  {impulse rnd_dir 0.35 com}				}			 {delay_ex 5.0  {impulse rnd_dir  0.45 com}				 }	    }		{on contact overload		 {if effector "vehicle"		  {delete}                                                       		 }		}	}	{"proj_point_dummy"	     {on spawn 		  {delay 0.1 {delete}}		 }		 {on ground_hit			              			                                 			                  		 }   	}	{"proj_point_ground"	     {on spawn		 {impulse up -0.01 com}		 {gravity 0.0}		  {delay_ex 1  {impulse forward 0.31 com}  			  }		 {delay_ex 2.0  {impulse forward 1.01 com}                                                                                                 			  }		   {delay_ex 3.0  {impulse forward -2.11 com}                                                                                               			   }		   {delay_ex 4.0  {impulse forward 1.11 com}			   }		   {delay_ex 5.0  {impulse forward -1.11 com}			   }		 }		{on contact overload		{if effector "vehicle"                                           		 {if not effector "cannon"                                                                            		  {if not tagged "ground_far"           		   {delete}		  }		 }		}		 {if effector "proj_point_acc" {with_effector {physics_work 0}{with_effector}}                                                                                                           		   {delete}		 }		}	}			
{"cwps3_proj_point"		
	{on spawn overload			
		{components "rus_active" break}			
		{components "rus_antiship" break}			
		{components "rus_ir" break}			
		{components "rus_laser" break}			
		{components "rus_laser_spot" break}			
		{components "rus_other" break}			
		{components "rus_radpassive" break}						
		{components "usa_active" break}			
		{components "usa_antiship" break}			
		{components "usa_ir" break}			
		{components "usa_laser" break}			
		{components "usa_other" break}			
		{components "usa_radpassive" break}			
		{ani_play "hide"}			
		{delay 0.1 {player -1}}		
	}		
	{on "sp_convoy_attack"	            			
		{spawn "sp_convoy_assistor" "basis" x no_normal no_position}		
	}		
	{on overlap begin overload		
		{if tagged "forward"		  
		{volumes enable bullet}		  
		{ani_wind "forward1" begin}		   
		{ani_wind "forward2" begin}		   
		{ani_wind "forward3" begin}		   
		{ani_wind "forward4" begin}		  
		{ani_wind "forward5" begin}		  
		{ani_wind "forward6" begin}			
		{tags add "stop_forward"}		
		{delay_ex 1 
			{if tagged "stop_forward" 
			{tags remove "stop_forward"}} 
			{volumes disable bullet}}		
		}			
		{if effector "cwps_rangefinder"							
			{with_effector					                    			    }			 			
		}		
	}		
	{on bullet_hit				             			
		{if stuff "cwps2"				
		{kill_delay "incoming"}				
		{set "stop" 1}				
		{ani_wind "forward1" begin}				
		{delay 2 "incoming" {set "stop" 0}}			
		}		
	}	
	(define "actions"		
		{on "start_%country_%type"			
			{components "%country_%type" repair}			
			(mod "mp" {player 1})			
			(mod not "mp" {player 15})			
			(mod "coop" {player 7})			
			{ani_wind "hide" begin}			
			{tags add "cwps3_locked"}		
		}		
		{on "stop_%country_%type"			
			{components "%country_%type" break}				
			{if not work "rus_active"			
				{if not work "rus_antiship"			
					{if not work "rus_ir"			
					{if not work "rus_laser"			
					{if not work "rus_laser_spot"			
					{if not work "rus_other"			
					{if not work "usa_radpassive"				
					{if not work "usa_active"			
					{if not work "usa_antiship"			
					{if not work "usa_ir"			
					{if not work "usa_laser"			
					{if not work "usa_other"			
					{if not work "usa_radpassive"				
					{player -1}				
					{ani_play "hide"}				
					{tags remove "cwps3_locked"}				
					}
					}
					}
					}
					}
					}
					}
					}
					}
					}
					}
				}
			}		
		}	
	)	
	("actions" country(rus) type(active))	
	("actions" country(rus) type(antiship))
	("actions" country(rus) type(ir))	
	("actions" country(rus) type(laser))	
	("actions" country(rus) type(laser_spot))	
	("actions" country(rus) type(other))	
	("actions" country(rus) type(radpassive))			
	("actions" country(usa) type(active))	
	("actions" country(usa) type(antiship))	
	("actions" country(usa) type(ir))	
	("actions" country(usa) type(laser))	
	("actions" country(usa) type(other))	
	("actions" country(usa) type(radpassive))							
}	
{"cw_bullet_target"	    {on spawn		    {impulse up -5}	        (mod "mp"{player 1}) (mod not "mp"{player 7})			{delay 3 {delete}}	    }	}	{"balmis_detector"	    {on spawn			{delay 1 {delete}}	    }	    {on contact		    {if effector "radioproximity"		    {volumes disable contact}			{if altitude 5			    {physics_work 0}			    {volumes enable bullet}				{with_effector					{call "detonate"}				}			}			}				}	}	{"proj_point_guide"	    {on spawn		    {tags add "1111t"}		  (mod "mp"{player 1}) (mod not "mp"{player 7})			{if not altitude 15			  {volumes disable bullet visible}			}			{delay 1 {delete}}	    }	}	{"antirad_spawner"		{on spawn	overload				{delay 0.1 {spawn "cwship_informer" "basis" local_offset 0 0 40 {tags add "antirad_linked"} {impulse up 3 com}}}			{delay 1 					{if not linked  {delete}				else 				{spawn "cwship_informer" "body_holder" local_offset 0 0 300 {tags add "antirad_linked"} {impulse up 3 com}}				}			}		}		{on "start"			                            			{with_linked_entity "point"				{able "minimap" 1}				{volumes "body" enable visible}				{volumes "target" enable visible}				{components "body" repair}			}		}		{on "stop"			{ani_stop "rand_move"}			{with_linked_entity "point"				{able "minimap" 0}				{volumes "body" disable visible}				{volumes "target" disable visible}				{components "body" break}			}		}	}	{"minimap_antirad"		{on spawn	overload			{delay 1 {if not linked {delete}}}		}	}	{"proj_point_rus_large_antirad"		{on overlap begin overload			{if effector "cwps_antirad_usa"				{with_effector {call "top_attack"}}			}		}	}	{"proj_point_rus_antirad"		{on overlap begin overload			{if effector "cwps_antirad_usa"				{with_effector {call "top_attack"}}			}		}	}	{"proj_point_usa_large_antirad"		{on overlap begin overload			{if effector "cwps_antirad_rus"				{with_effector {call "top_attack"}}			}		}	}	{"proj_point_usa_antirad"		{on overlap begin overload			{if effector "cwps_antirad_rus"				{with_effector {call "top_attack"}}			}		}	}	{"minimap_antirad"		{on spawn	overload			{delay 1 {if not linked {delete}}}		}	}	{"proj_point_rus_large_antirad"		{on overlap begin overload			{if effector "cwps_antirad_usa"				{with_effector {call "top_attack"}}			}		}	}	{"proj_point_rus_antirad"		{on overlap begin overload			{if effector "cwps_antirad_usa"				{with_effector {call "top_attack"}}			}		}	}	{"proj_point_usa_large_antirad"		{on overlap begin overload			{if effector "cwps_antirad_rus"				{with_effector {call "top_attack"}}			}		}	}	{"proj_point_usa_antirad"		{on overlap begin overload			{if effector "cwps_antirad_rus"				{with_effector {call "top_attack"}}			}		}	}	)	{"smoke_volume"		{on spawn			{delay 0.1 {gravity 0.01} {constrain_velocity 0.5}}			{tags add "smoke"}			{volumes "smoke1" enable visible contact}			{update_visibility_patch}			{delay 0.5				{volumes "smoke2" enable visible contact} {update_visibility_patch}			}			{delay 1				{volumes "smoke3" enable visible contact} {update_visibility_patch}			}			{delay 10 {hide 1}}		}	}		{"smoke_volume_ground"		{on spawn			{delay 0.1 {gravity 0.01} {constrain_velocity 0.5}}			{tags add "smoke"}			{volumes "smoke1" enable visible contact}			{update_visibility_patch}			{delay 2				{volumes "smoke2" enable visible contact}	{update_visibility_patch}			}			{delay 5				{volumes "smoke3" enable visible contact}	{update_visibility_patch}			}			{delay 60 {hide 1}}		}	}	{"piece_missile_booster"		{on spawn 			{delay 10 {hide 3}}			{delay 0.1 				{volumes "part" enable contact_ground}				{volumes "part1" enable contact_ground}				{volumes "part2" enable contact_ground}				{volumes "part3" enable contact_ground}				{volumes "part4" enable contact_ground}				{volumes "starter" enable contact_ground}			    {if not "fall" {impulse up -0.1 forward 30 rnd_dir 2}}				{set "fall" 1}			}			{delay 1 				{volumes "part" enable contact contact_ground}				{volumes "part1" enable contact contact_ground}				{volumes "part2" enable contact contact_ground}				{volumes "part3" enable contact contact_ground}				{volumes "part4" enable contact contact_ground}				{volumes "starter" enable contact contact_ground}			}			{add_view "steam" "steam" "root"}			{view start "steam"}			{view show "steam"}		}		{on ground_hit			{view stop "steam"}			{view pause "steam"}		}	}	{"sub_helper"		{on spawn 			{volumes "body" disable contact}			{if altitude -1 {tags add "surface_launch"}			else {tags add "underwater_launch"}}			{delay 1 {volumes "body" enable contact}}			{if tagged "surface_launch" 				{volumes "ballast1" disable float}				{volumes "body" disable contact}				{delay 2 {volumes "body" enable contact}}			}			{volumes "ballast2" disable float}			{impulse forward 50 com}			{ani_play "on_start"}			{delay 0.5 {call "check_altitiude"}}			{delay 10 {hide}}		}		{on "check_altitiude"			{kill_delay "check_altitiude"}			{if not tagged "destroyed"				{if tagged "surface_launch"					{if not altitude -5						{tags add "underwater_launch"}						{tags remove "surface_launch"}						{volumes "ballast1" enable float}					}				}				{if altitude -4				  {if tagged "underwater_launch"					{call "spawn_missile"}				  }				}				{delay 0.5 "check_altitiude" {call "check_altitiude"}}			}		}		{on "detonate" overload			{if not tagged "destroyed" {inherited}}		}		(define "spawn_spherewaters"			  {if not tagged "spawn_underwater"			    {tags add "spawn_underwater"}				{spawn "spherewater_big"}				{spawn "spherewater_big2" local_offset -50 0 0}				{spawn "spherewater_big2" local_offset -100 0 0}				{spawn "spherewater_big2" local_offset -150 0 0}			  }		)		{on ground_hit overload		  {if terrain_fx "water"			("spawn_spherewaters")		  else terrain_fx "shallow_water"		  	("spawn_spherewaters")		  else terrain_fx "deep_water"		  	("spawn_spherewaters")		  else {inherited}		  }		}	}	{"caliber_sub_helper"		{on "spawn_missile" 			{spawn "ex_water_big"}			{spawn "3m14_carrier" "foresight2" x}			{bone cut "part1"}			{tags add "destroyed"}			{volumes "body" disable contact bullet blast}		}	}	{"caliber54_sub_helper"		{on "spawn_missile" 			{spawn "ex_water_big"}			{spawn "3m54_carrier" "foresight2" x}			{bone cut "part1"}			{tags add "destroyed"}			{volumes "body" disable contact bullet blast}		}	}	{"vodopad_sub_helper"		{on "spawn_missile" 			{spawn "ex_water_big"}			{spawn "vodopad_carrier" "foresight2" x}			{delete}		}	}	{"veter_sub_helper"		{on "spawn_missile" 			{spawn "ex_water_big"}			{spawn "veter_carrier" "foresight2" x}			{delete}		}	}	{"harpoon_sub_helper"		{on spawn			{delay 0.1 {constrain_velocity 10}}		}		{on "spawn_missile" 			{spawn "ex_water_big"}			{spawn "ugm-84a_carrier" "foresight2" x}			{tags add "destroyed"}			{volumes "body" disable contact bullet blast}		}	}	                                                         		{"cwps_rangefinder"		{on spawn			{volumes "rangefinder" enable overlap}		}		{on "top_attack"			{volumes "rangefinder" disable overlap}		}	}	{"cwps_top_attack"		{on spawn			{ani_play "top_attack_on" 1}			{delay 2.5 {ani_play "top_attack_off" 1}}		}		{on "top_attack"			{ani_play "top_attack_off" 1}		}	}	{"cwps_gorka"		{on spawn			{ani_play "gorka" 0.4}		}	}	{"cwps_antiroof"		{on spawn			{delay 0.1 {ani_play "antiroof" 0.3}}		}	}	{"surfaceproximity"		{on contact overload			{if volume "proximity"				{if not effector_velocity 1					{volumes "proximity" disable contact}					{delay 0.1 {volumes "proximity" enable contact}}				else {inherited}				}			else {inherited}			}		}	}	{"radioproximity"		{on contact overload			{if volume "proximity"				{if not effector "steel"					{volumes "proximity" disable contact}					 {volumes "proximity" enable contact}				else {inherited}				}			else {inherited}			}		}	}	{"ir_seeker"	     {on bullet_hit overload			{if stuff "ir_soep_ammo" {if tagged "guided" {tags remove "guided"}  {weapon_work "targeting_sys" 0} {weapon_work "targeting_sys_anti_jamming" 0} }			else {inherited}			}	     }	}	{"cwps_torpedo"		{on spawn {volumes "rangefinder" disable all} {volumes "rangefinder" enable overlap}			{add_view "wash_torpedo_small" "tail" "missile_point"}	{view start "tail"}			}		{on overlap begin			{if effector "submarine" 			                                 			{volumes "rangefinder" disable all}			{ani_play "down" 1.3}}		}	                          	                          		                    	                         	                                	            	    	                                    	           	         	       	}	{"allow_manual_control"	(define "cwps_abort"		{volumes "missile" disable select touch}		{able select 0}	)		(define "cwps_mis_cntrl_time"		{delay_ex %time "cwps_mis_cntrl_time"			{with_effector 				{if tagged "no_missile_control"					{with_effector ("cwps_abort")}				else tagged "destroyed"					{with_effector ("cwps_abort")}				else tagged "no_power"					{with_effector ("cwps_abort")}				else not operatable					{with_effector ("cwps_abort")}				else tagged "contusion"					{with_effector ("cwps_abort")}				}				{with_effector}			}		}	)			(define "cwps_mis_cntrl"	                                                          						("cwps_mis_cntrl_time" time(0.5))						("cwps_mis_cntrl_time" time(1.0))						("cwps_mis_cntrl_time" time(1.5))						("cwps_mis_cntrl_time" time(2.0))						("cwps_mis_cntrl_time" time(2.5))						("cwps_mis_cntrl_time" time(3.0))						("cwps_mis_cntrl_time" time(3.5))						("cwps_mis_cntrl_time" time(4.0))						("cwps_mis_cntrl_time" time(4.5))						("cwps_mis_cntrl_time" time(5.0))						("cwps_mis_cntrl_time" time(5.5))						("cwps_mis_cntrl_time" time(6.0))						("cwps_mis_cntrl_time" time(6.5))						("cwps_mis_cntrl_time" time(7.0))						("cwps_mis_cntrl_time" time(7.5))						("cwps_mis_cntrl_time" time(8.0))						("cwps_mis_cntrl_time" time(8.5))						("cwps_mis_cntrl_time" time(9.0))						("cwps_mis_cntrl_time" time(9.5))						("cwps_mis_cntrl_time" time(10.0))						("cwps_mis_cntrl_time" time(10.5))						("cwps_mis_cntrl_time" time(11.0))						("cwps_mis_cntrl_time" time(11.5))						("cwps_mis_cntrl_time" time(12.0))						("cwps_mis_cntrl_time" time(12.5))						("cwps_mis_cntrl_time" time(13.0))						("cwps_mis_cntrl_time" time(13.5))						("cwps_mis_cntrl_time" time(14.0))						("cwps_mis_cntrl_time" time(14.5))						("cwps_mis_cntrl_time" time(15.0))		)		{on spawn			{if altitude 3		    {volumes "control_probe" disable contact}			{delay 3 {volumes "control_probe" enable contact}}			}		}		{on contact overload			{if volume "control_probe" 			  {if effector "vehicle_common"				{volumes "control_probe" disable all} ("cwps_mis_cntrl")			  else {volumes "control_probe" disable all}			  }			else {inherited}			}		}	}	{"heavy_antiship"	     {on blast_hit overload		  {if min_energy 1		    {if rand 0.8				{call "detonate"}			else  				{spawn "aero_die_particle" "missile_point" x}				{if rand 0.5					{burn fx "aero_die_fire" fake}				}						{if rand 0.5					{tags remove "guided"}  {weapon_work "targeting_sys" 0} {weapon_work "targeting_sys_anti_jamming" 0}				}			}					  }	     }	     {on blast overload	     }		  {on break_armor			{if component "missile" {call "detonate"}}	     }		{on contact overload			{if effector "proj_deleter"				{call "destroyed_by_ground"}			else not effector "proj_dummy" {inherited}}		}	}		{"medium_antiship"	     {on blast_hit overload		  {if min_energy 1		    {if rand 0.5				{call "detonate"}			else  				{spawn "aero_die_particle" "missile_point" x}				{if rand 0.5					{burn fx "aero_die_fire" fake}				}						{if rand 0.5					{tags remove "guided"}  {weapon_work "targeting_sys" 0} {weapon_work "targeting_sys_anti_jamming" 0}				}			}					  }	     }	     {on blast overload	     }		  {on break_armor			{if component "missile" {call "detonate"}}	     }		{on contact overload			{if effector "proj_deleter"				{call "destroyed_by_ground"}			else not effector "proj_dummy" {inherited}}		}	}		{"heavy_antiship_impactor_link"	     {on pierce overload	     }		 {on bullet_hit overload	     }	     {on blast_hit overload	     }	     {on blast overload	     }		{on contact overload		}	}	                                    	                          	                      	                                                                     	                                      	                        	                      	                                        	(define "tracer"		{on "manage_effects1"			                                          			                                                			                            			                           			   		}	)	
(define "CWPS_proj"	"%missilename_carrier"		
	{on spawn		   
		{weapon_work "targeting_sys" 0}			
		{weapon_work "targeting_sys_anti_jamming" 1}			
		{if rand %rotation {ani_play "rotation" 0.5 loop}}			
		{if rand %rand_move {delay 0.3 {ani_play "rand_move" 0.75 loop}}}			
		{if rand %smoke_vulnerable {tags add "smoke_vulnerable"}}			
		{if rand 
			( * 1 %decoyprob) 
			{weapon_work "targeting_sys_anti_jamming" 0} 
			{weapon_work "targeting_sys" 1} 			
			{damage_report "root" "component/jamming_work"}			
		}			
		{call "spawn2"}					
	}		
	{on "spawn_missile"			
		{spawn "%missilename_impactor" "missile_point" x				
		{impulse up 4 forward 50 com}				
				{delay 0.01 {call "detonate"}}			
		}		
	}		
	{on "spawn_missile_ground"			
		{spawn "%missilename_impactor" "missile_point" x				
			{bone hide "root"}				                               				
			{delay 0.01 {impulse up 0.1 com}{call "detonate"}}			
		}		
	}			
	{on "change_stage"				
		{if tagged "stage_%range" {if not tagged "cwps_extended_range" {call "detonate"}}}		
	}		
	{on "manage_effects"			
		{delay 0.02 
			{with_linked_entity "missile" 				
				{add_view	"%tail"			"proj_jet"			"tail"}				
				(mod not "mp"				
					{view start "proj_jet"}				
					{view show "proj_jet"}				
				)					
				(mod "mp"				
					{if altitude 10				    
						{view start "proj_jet"}				   
						{view show "proj_jet"}				
					}				
				)			
			}
		}			
		{delay %eng_time
			{with_linked_entity "missile" 				
				{view pause "proj_jet"}				
				{view stop "proj_jet"}				
				{view hide "proj_jet"}			
			}
		}		
	}	
)	(define "CWPS_torpedo"	"%missilename_carrier"		{on spawn			{if rand %rotation {ani_play "rotation" 0.5 loop}}			{if rand %rand_move {delay 0.3 {ani_play "rand_move" 0.75 loop}}}			{if rand %smoke_vulnerable {tags add "smoke_vulnerable"}}			{call "spawn2"}		}		{on "spawn_missile"		  {with_linked_entity "missile"			{spawn "%missilename_impactor" "root" x				{impulse up 4 forward 50 com}				{delay 0.01 {call "detonate"}}			}		  }		}		{on "spawn_missile_ground"			{spawn "%missilename_impactor" "root" x				{bone hide "root"}				                               				{delay 0.01 {impulse up 0.1 com}{call "detonate"}}			}		}			{on "change_stage"				{if tagged "stage_%range" {if not tagged "cwps_extended_range" {call "detonate"}}}		}		{on "manage_effects"			{delay 0.02 {with_linked_entity "missile" 				{add_view	"%tail"			"proj_jet"			"tail"}				{view start "proj_jet"}				{view show "proj_jet"}			}}			{delay %eng_time {with_linked_entity "missile" 				{view pause "proj_jet"}				{view stop "proj_jet"}				{view hide "proj_jet"}			}}		}	)	(define "CWPS_proj_2stage"	"%missilename_carrier"		{on spawn		    {weapon_work "targeting_sys" 0}			{weapon_work "targeting_sys_anti_jamming" 1}			{if rand %rotation {ani_play "rotation" 0.5 loop}}			{if rand %rand_move {ani_play "rand_move" 0.75 loop}}			{if rand %smoke_vulnerable {tags add "smoke_vulnerable"}}			{call "spawn2"}	            {if rand (* 0.8 %decoyprob)  {weapon_work "targeting_sys_anti_jamming" 0} {weapon_work "targeting_sys" 1}				{damage_report "root" "component/jamming_work"}				}					}		{on "spawn_missile"			{spawn "%missilename_impactor" "missile_point" x				{impulse up 4 forward 50 com}				{delay 0.01 {call "detonate"}}			}		}		{on "spawn_missile_ground"			{spawn "%missilename_impactor" "missile_point" x				{bone hide "root"}				                               				{delay 0.01 {impulse up 0.1 com}{call "detonate"}}			}		}		{on "change_stage" overload		     {if  tagged "cwps_extended_range"			{if tagged "stage_%range40plus"  {call "spawn_second_stage"}			else tagged  "stage_0%range40plus"  {call "spawn_second_stage"}			}		     }			{inherited}		}		{on "link_effects"		}		{on "manage_effects" overload			{if  not tagged "cwps_not_first_stage" 				{delay 0.02 {with_linked_entity "missile" 					{add_view	"%tail"			"proj_jet"			"tail"}					{view start "proj_jet"}					{view show "proj_jet"}				}}			}			{delay %eng_time {with_linked_entity "missile" 				{view pause "proj_jet"}				{view stop "proj_jet"}				{view hide "proj_jet"}			}}			{tags add "cwps_extended_range"}			{call "launch_procedures"}		}		{on "spawn_second_stage"			{spawn "%missilename_carrier" "missile_point" x 				{tags add "cwps_not_first_stage"}				{delay 0.1 {tags remove "cwps_extended_range"}}				{delay 0.2 {tags remove "cwps_extended_range"}}				{delay 0.3 {tags remove "cwps_extended_range"}}				{delay 0.1 {with_linked_entity "missile" {ani_wind "on_start"  end}}}				{with_linked_entity "missile" 					{bone cut "part1"}{bone cut "part2"}{bone cut "part3"}{bone cut "part4"}					{bone cut "part"}{bone cut "starter"}{bone cut "starter1"}{bone cut "starter2"}				}			} 			{delete}		}	)	(define "CWPS_proj_3stage"	"%missilename_carrier"		{on spawn		    {weapon_work "targeting_sys" 0}			{weapon_work "targeting_sys_anti_jamming" 1}			{if rand %rotation {ani_play "rotation" 0.5 loop}}			{if rand %rand_move {ani_play "rand_move" 0.75 loop}}			{if rand %smoke_vulnerable {tags add "smoke_vulnerable"}}			{call "spawn2"}	              {if rand (* 0.6 %decoyprob)  {weapon_work "targeting_sys_anti_jamming" 0} {weapon_work "targeting_sys" 1}				  {damage_report "root" "component/jamming_work"}				  }					}		{on "spawn_missile"			{spawn "%missilename_impactor" "missile_point" x				{impulse up 4 forward 50 com}				{delay 0.01 {call "detonate"}}			}		}		{on "spawn_missile_ground"			{spawn "%missilename_impactor" "missile_point" x				{bone hide "root"}				                               				{delay 0.01 {impulse up 0.1 com}{call "detonate"}}			}		}		{on "change_stage" overload		     {if not tagged "cwps_extended_range2"		          {if tagged "cwps_extended_range"						{if tagged "stage_%range80plus"  {call "spawn_second_stage"}						else tagged "stage_0%range80plus"  {call "spawn_second_stage"}}		           }		     }			{inherited}		}		{on "link_effects"			{delay 0 {with_linked_entity "missile" 				{add_view	"%tail"			"proj_jet"			"tail"}			}}		}		{on "manage_effects" overload			{if  not tagged "cwps_not_first_stage" 				{delay 0.02 {with_linked_entity "missile" 					{add_view	"%tail"			"proj_jet"			"tail"}					{view start "proj_jet"}					{view show "proj_jet"}				}}			}			{delay %eng_time {with_linked_entity "missile" 				{view pause "proj_jet"}				{view stop "proj_jet"}				{view hide "proj_jet"}			}}			{tags add "cwps_extended_range2"}			{call "launch_procedures"}		}		{on "spawn_presecond_stage"			{spawn "%missilename_carrier" "missile_point" x 				{tags add "cwps_not_first_stage"}				{delay 0.5 {tags remove "cwps_extended_range2"}{tags add "cwps_extended_range"}}				{delay 0.1 {with_linked_entity "missile" {ani_wind "on_start"  end}}}				{with_linked_entity "missile" 					{bone cut "part1"}{bone cut "part2"}{bone cut "part3"}{bone cut "part4"}					{bone cut "part"}{bone cut "starter"}{bone cut "starter1"}{bone cut "starter2"}				}			} 			{delete}		}		{on "spawn_second_stage"			{spawn "%missilename_carrier" "missile_point" x 				{tags add "cwps_not_first_stage"}				{delay 0.1 {tags remove "cwps_extended_range2"}{tags remove "cwps_extended_range"}}				{delay 0.2 {tags remove "cwps_extended_range2"}{tags remove "cwps_extended_range"}}				{delay 0.5 {tags remove "cwps_extended_range2"}{tags remove "cwps_extended_range"}}				{delay 0.1 {with_linked_entity "missile" {ani_wind "on_start"  end}}}				{with_linked_entity "missile" 					{bone cut "part1"}{bone cut "part2"}{bone cut "part3"}{bone cut "part4"}					{bone cut "part"}{bone cut "starter"}{bone cut "starter1"}{bone cut "starter2"}				}			} 			{delete}		}		)	


(define "CWPS_proj_4stage"	"%missilename_carrier"		
	{on spawn		    
		{weapon_work "targeting_sys" 0}			
		{weapon_work "targeting_sys_anti_jamming" 1}			
		{if rand %rotation {ani_play "rotation" 0.5 loop}}			
		{if rand %rand_move {ani_play "rand_move" 0.75 loop}}			
		{if rand %smoke_vulnerable {tags add "smoke_vulnerable"}}			
		{call "spawn2"}	             
		{if rand (* 76.6 %decoyprob)  
			{weapon_work "targeting_sys_anti_jamming" 0} 
			{weapon_work "targeting_sys" 1}				 
			{damage_report "root" "component/jamming_work"}				  
		}					
	}		
	{on "spawn_missile"			
		{spawn "%missilename_impactor" "missile_point" x				
			{impulse up 4 forward 200 com}				
			{delay 0.01 {call "detonate"}}			
		}		
	}		
	{on "spawn_missile_ground"			
		{spawn "%missilename_impactor" "missile_point" x				
			{bone hide "root"}				                               				
			{delay 0.01 {impulse up 0.1 com}{call "detonate"}}			
		}		
	}		
	{on "change_stage" overload		    
		{if not tagged "cwps_extended_range2"		         
			{if tagged "cwps_extended_range"						
				{if tagged "stage_%range100plus"  
				{call "spawn_second_stage"}						
					else tagged "stage_0%range100plus"  {call "spawn_second_stage"}}		           
			}		     
		}			
			{inherited}		
	}		
	{on "link_effects"			
		{delay 0 
			{with_linked_entity "missile" 				
				{add_view	"%tail"			"proj_jet"			"tail"}			}}		
		}		
		{on "manage_effects" overload			
			{if  not tagged "cwps_not_first_stage" 				
				{delay 0.02 
					{with_linked_entity "missile" 					
						{add_view	"%tail"			"proj_jet"			"tail"}					
						{view start "proj_jet"}					
						{view show "proj_jet"}				
					}
				}			
			}			
			{delay %eng_time 
				{with_linked_entity "missile" 				
					{view pause "proj_jet"}				
					{view stop "proj_jet"}				
					{view hide "proj_jet"}			
				}
			}			
			{tags add "cwps_extended_range2"}			
			{call "launch_procedures"}		
		}		
		{on "spawn_presecond_stage"			
			{spawn "%missilename_carrier" "missile_point" x 				
				{tags add "cwps_not_first_stage"}				
				{delay 0.5 
					{tags remove "cwps_extended_range3"}
					{tags add "cwps_extended_range2"}
				}				
				{delay 0.1
					{with_linked_entity "missile" {ani_wind "on_start"  end}}
				}	
				{with_linked_entity "missile" 				
					{bone cut "part1"}
					{bone cut "part2"}
					{bone cut "part3"}
					{bone cut "part4"}					
					{bone cut "part"}
					{bone cut "starter"}
					{bone cut "starter1"}
					{bone cut "starter2"}				
				}			
			} 			
				{delete}		
			}		
		{on "spawn_presecond_stage2"			
			{spawn "%missilename_carrier" "missile_point" x 				
				{tags add "cwps_not_first_stage"}				
				{delay 0.5 
					{tags remove "cwps_extended_range2"}
					{tags add "cwps_extended_range"}
				}				
				{delay 0.1
					{with_linked_entity "missile" {ani_wind "on_start"  end}}
				}	
				{with_linked_entity "missile" 				
					{bone cut "part1"}
					{bone cut "part2"}
					{bone cut "part3"}
					{bone cut "part4"}					
					{bone cut "part"}
					{bone cut "starter"}
					{bone cut "starter1"}
					{bone cut "starter2"}				
				}			
			} 			
				{delete}		
			}

			{on "spawn_second_stage"			
				{spawn "%missilename_carrier" "missile_point" x 				
				{tags add "cwps_not_first_stage"}				
				{delay 0.1 {tags remove "cwps_extended_range2"}
				{tags remove "cwps_extended_range"}}				
				{delay 0.2 {tags remove "cwps_extended_range2"}
					{tags remove "cwps_extended_range"}
				}				
				{delay 0.5 
					{tags remove "cwps_extended_range2"}
					{tags remove "cwps_extended_range"}}				
					{delay 0.1 
						{with_linked_entity "missile" {ani_wind "on_start"  end}}
					}				
					{with_linked_entity "missile" 					
						{bone cut "part1"}
						{bone cut "part2"}
						{bone cut "part3"}
						{bone cut "part4"}					
						{bone cut "part"}{bone cut "starter"}
						{bone cut "starter1"}{bone cut "starter2"}				
					}			
					} 			
					{delete}		
				}		
		)




(include "missile_settings2.inc")		{"switchblade300_carrier"	    {on spawn		    {delay 6.5	       		{with_linked_entity "missile"			    	{spawn "proj_deleter" "root"			    	    {delay 0.2 {delete}}			    	}			    }			}			}	    {on "check_altitude"			{with_linked_entity "missile"				{if not altitude 1.0					{if not tagged "underwater_launch"						                                  						{spawn "proj_deleter" "root"						 {delete}						                     						}	                       					}				}				}		}		{on fire "targeting_sys_anti_jamming"		    {with_linked_entity "missile"			    {spawn "proj_deleter" "root"				 {delete}				                     				}		    }		}		{on "spawn_missile" overload			{spawn "switchblade300_impactor" "missile_point" x				{call "detonate"}			}		}	}	{"krasnopol_carrier"	    {on "spawn_missile" overload			                                              			                                  			                               			  		}		{on "spawn_missile_ground" overload			                                              			                                  			                                                   			  		}		{on "check_altitude" overload			{with_linked_entity "missile"				{if not altitude 2.0				    {stuff_detonate}				else					{if not altitude 8.0						                                  						                             						                     						                          						{spawn "krasnopol_impactor" "root" x			            	{impulse up -2.5 forward 50 com}			            	{delay 5.1 {impulse up 0.1 com}{call "detonate"}}			            }						{delete}				    }					}				}			{delay 0.1 {call "check_altitude"}}		}		                                   	                           		                       		                                  		                                  		              		      		             	          	      	}		{"agm-154_carrier"		{on "spawn_missile"			{spawn "agm-154_impactor" "missile_point" x				{impulse up 0.1 forward 50 com}				{delay 0.1 {call "detonate"}}			}		}		{on "spawn_missile_ground"			{spawn "agm-154_impactor" "missile_point" x				{bone hide "root"}				                               				{delay 0.01 {impulse up 0.1 com}{call "detonate"}}			}		}		{on "manage_effects" overload			{tags add "cwps_extended_range"}			{delay 0.7 {if tagged "cwps_extended_range" {with_linked_entity "missile" {ani_play "on_start"}}}}		}		{on "top_attack" overload	                       	                                 			{volumes disable all}			{spawn "agm-154_impactor" "missile_point" x				{ani_wind "on_start"  end}				{impulse up 0.1 forward 30 com}{gravity 0.2}				{ani_play "cargo"}				{volumes disable all}				{delay 1.1 {volumes disable all} {spawn "agm-154_cluster" offset 0 0 -15}}				{delay 1.6 {spawn "agm-154_cluster" offset 0 0 -15}}				{delay 2.1 {spawn "agm-154_cluster" offset 0 0 -15}}				{delay 2.2 {spawn "aero_die_particle"}{delete}}			}			{delete}		}		{on "spawn_second_stage"			{spawn "agm-154_carrier" "missile_point" x 				{delay 0.5 {tags remove "cwps_extended_range"}}				{delay 0.1 {with_linked_entity "missile" {ani_wind "on_start"  end}}}			} 			{delete}		}		("speed_normal" coeff(0.84))	}	{"pbk-500u_carrier"	    (define "spread_pbk"		{delay %delay (* 0.5 %delay) {spawn "spbe-d" offset %x %y 0}}		)		{on "spawn_missile"			{spawn "pbk-500u_impactor" "missile_point" x				{impulse up 0.1 forward 50 com}				{delay 0.1 {call "detonate"}}			}		}		{on "spawn_missile_ground"			{spawn "pbk-500u_impactor" "missile_point" x				{bone hide "root"}				                               				{delay 0.01 {impulse up 0.1 com}{call "detonate"}}			}		}		{on "manage_effects" overload			{tags add "cwps_extended_range"}		}		{on "top_attack" overload	                       	                                 			{volumes disable all}			{spawn "pbk-500u_impactor" "missile_point" x				{volumes disable all}				{impulse up 0.1 forward 30 com}{gravity 0.2}				("spread_pbk" delay(0.3) x(0) y(0))			    ("spread_pbk" delay(0.3) x(250) y(0))			    ("spread_pbk" delay(0.3) x(-250) y(0))			    ("spread_pbk" delay(0.3) x(0) y(250))			    ("spread_pbk" delay(0.3) x(0) y(-250))			    ("spread_pbk" delay(0.3) x(250) y(250))			    ("spread_pbk" delay(0.3) x(250) y(-250))			    ("spread_pbk" delay(0.3) x(-250) y(-250))			    ("spread_pbk" delay(0.3) x(-250) y(250))			    ("spread_pbk" delay(0.3) x(450) y(0))			    ("spread_pbk" delay(0.3) x(-450) y(0))			    ("spread_pbk" delay(0.3) x(0) y(450))			    ("spread_pbk" delay(0.3) x(0) y(-450))			    ("spread_pbk" delay(0.3) x(450) y(-600))			    ("spread_pbk" delay(0.3) x(-450) y(600))				                             				                              				                              				                              				                              				                              				                              				                              				                              				                              				                              				                              				                              				                              				                              				{delay 2.0 {spawn "aero_die_particle"}{delete}}			}			{delete}		}		{on "change_stage" overload		   {if  not tagged "cwps_extended_range"			{if tagged "stage_17"  {call "top_attack"}}		   }			{inherited}		}		{on "spawn_second_stage"			{spawn "pbk-500u_carrier" "missile_point" x 				{delay 0.5 {tags remove "cwps_extended_range"}}			} 			{delete}		}		("speed_normal" coeff(0.84))	}	{"igla_s_carrier"		{on spawn		{weapon_work "targeting_sys" 0}		{weapon_work "targeting_sys_anti_jamming" 1}		{ani_play "rotation" 0.5 loop}		{if rand ( * 1 0.2) {weapon_work "targeting_sys_anti_jamming" 0} {weapon_work "targeting_sys" 1}		{damage_report "root" "component/jamming_work"}		}		}		{on "spawn_missile"		  {if tagged "100m_fly"			{spawn "igla_s_impactor" "missile_point" x				{impulse up 0.1 forward 50 com}	{delay 0.1 {call "detonate"}}			}		     else tagged "50m_fly"			{spawn "igla_s1_impactor" "missile_point" x				{impulse up 0.1 forward 50 com}	{delay 0.1 {call "detonate"}}			}		     else 			{spawn "igla_s2_impactor" "missile_point" x				{impulse up 0.1 forward 50 com}	{delay 0.1 {call "detonate"}}			}		  }		}		{on "spawn_missile_ground"			{spawn "igla_s_impactor" "missile_point" x				{bone hide "root"}				                               				{delay 0.01 {impulse up 0.1 com}{call "detonate"}}			}		}		{on "change_stage" {if tagged "stage_17" {call "detonate"}}}		{on "manage_effects"			{delay 0 {with_linked_entity "missile" 				{add_view	"proj_jet_sam"			"proj_jet"			"tail"}				{view show "proj_jet"}				{view start "proj_jet"}			}}			{delay 1.5 {with_linked_entity "missile" 				{view pause "proj_jet"}				{view stop "proj_jet"}				{view hide "proj_jet"}			}}		}		("speed_normal" coeff(1.07))	}		{"tow2b_carrier"		{on spawn			{weapon_work "targeting_sys" 0}		{weapon_work "targeting_sys_anti_jamming" 1}		{tags add "smoke_vulnerable"}		{if rand ( * 1 0.25) {weapon_work "targeting_sys_anti_jamming" 0} {weapon_work "targeting_sys" 1}		{damage_report "root" "component/jamming_work"}		}		}		{on "spawn_missile"			{spawn "tow2b_impactor" "missile_point" x				{impulse up 0.1 forward 25 com}				{delay 0.01 {spawn "tow2b_core" {impulse up -10 forward 0.1 com}}}				{delay 0.05 {spawn "tow2b_core" {impulse up -10 forward -1.1 com}}} 				{delay 0.5 {call "detonate"}}			}		}		{on "spawn_missile_ground"			{spawn "tow2b_impactor" "missile_point" x				{bone hide "root"}				                               				{delay 0.01 {impulse up 0.1 com}{call "detonate"}}			}		}		{on "change_stage"	{if tagged "stage_35" {call "detonate"}}}		{on "manage_effects"			{delay 0 {with_linked_entity "missile" 				{add_view	"proj_jet_atgm"			"proj_jet"			"tail"}				{view show "proj_jet"}				{view start "proj_jet"}			}}			{delay 0.5 {with_linked_entity "missile" 				{view pause "proj_jet"}				{view stop "proj_jet"}				{view hide "proj_jet"}			}}		}		("speed_normal" coeff(0.84))		("tracer" tracer(tracer_tow) bone(tail))	}		{"sraw_rock_carrier"		{on "spawn_missile"			{spawn "sraw_rock_impactor" "missile_point" x				{impulse up 0.1 forward 15 com}				{call "detonate"}			}		}		{on "spawn_missile_ground"			{spawn "sraw_rock_impactor" "missile_point" x				{bone hide "root"}				                               				{delay 0.01 {impulse up 0.1 com}{call "detonate"}}			}		}		{on "change_stage"				{if tagged "stage_19" {if not tagged "cwps_extended_range" {call "detonate"}}}		}		{on "manage_effects"			{delay 0 {with_linked_entity "missile" 				{add_view	"proj_jet_atgm"			"proj_jet"			"tail"}				{view show "proj_jet"}				{view start "proj_jet"}			}}			{delay 0.5 {with_linked_entity "missile" 				{view pause "proj_jet"}				{view stop "proj_jet"}				{view hide "proj_jet"}			}}		}		("speed_slow" coeff(1.50))	}	{"sraw_rock_impactor" {on "detonate" overload {spawn "sraw_core" "body" {impulse up -10 forward 1.1 com}} {delay 0.01 {stuff_detonate}}}}		{"nlaw_rocket_carrier"		{on "spawn_missile"			{spawn "nlaw_rocket_impactor" "missile_point" x				{impulse up 0.1 forward 15 com}				{call "detonate"}			}		}		{on "spawn_missile_ground"			{spawn "nlaw_rocket_impactor" "missile_point" x				{bone hide "root"}				                               				{delay 0.01 {impulse up 0.1 com}{call "detonate"}}			}		}		{on "change_stage"				{if tagged "stage_19" {if not tagged "cwps_extended_range" {call "detonate"}}}		}		{on "manage_effects"			{delay 0 {with_linked_entity "missile" 				{add_view	"proj_jet_atgm"			"proj_jet"			"tail"}				{view show "proj_jet"}				{view start "proj_jet"}			}}			{delay 0.5 {with_linked_entity "missile" 				{view pause "proj_jet"}				{view stop "proj_jet"}				{view hide "proj_jet"}			}}		}		("speed_slow" coeff(1.50))	}	{"nlaw_rocket_impactor" {on "detonate" overload {spawn "nlaw_core" "body" {impulse up -10 forward 1.1 com}} {delay 0.01 {stuff_detonate}}}}		{"r17_script"		{on spawn overload			{volumes disable contact}			{physics_work 0}			{add_view	"proj_smoke"		"proj_tail"		"tail"}		}		{on "fall"			{ani_play "fall" callback}			{view start "proj_tail"}		}		{on animation_end "fall"			{delete}		}		{on "spawn_missile" overload		}		{on "detonate" overload}	}		{"missile_script"		{on spawn overload	                            			{physics_work 0}			{add_view	"proj_smoke"		"proj_tail"		"tail"}			{if tagged "fall" {call "fall"}}		}		("speed_normal" coeff(0.33))		{on "fall"			{tags add "fall"}			{ani_play "fall" callback}			{view start "proj_tail"}			{delay 10 {call "chdir_repeater"}}		}		{on "detonate" overload			{stuff_detonate}		}		{on animation_end "fall"			{call "detonate"}		}		{on "spawn_missile" overload		}	}		{"krasnopol_test"	    {on spawn overload			{tags add "test"}			            			{tags add "moving"}			{impulse up 0 dir 0.1 forward 1000 com} {constrain_velocity 100}			{call "move"}			{call "up"}			{delay 1 			    {if altitude 10			        {impulse fz 55 10}			        else 			        {gravity 50}			        {impulse fz 90}			    }			}			{delay 6 			    {tags remove "moving"}			    {ik_enable "gun_rot" 0}			    {ik_enable "gun" 0}				{gravity 50}				{impulse fz 80.0}							}		}		{on ik begin "gun_rot"		    {if tagged "moving"		    {tags add "stop"}			}		}		{on ik end "gun_rot"		    {tags remove "stop"}		}	    {on fire "gun"			{impulse up 0 dir 0.1 forward 0 com}			{call "move"}			{call "up"}		}		{on "move" overload		    {if tagged "moving"		        {spawn "proj_cont" "cont_vol" x {impulse up 0 dir 0.0 forward 1000 com}} {constrain_velocity 100}				{impulse fz 0.3}			    {delay 0.033 {call "move"}}		    }		}		{on "up" overload		                        		                                                         			                             			  		}		{on contact overload		{if effector "proj_cont"			{if volume "cont_vol"			{impulse up 0 dir 1000.0 forward 0 com}				}	        else					{call "stuff_detonate"}		}		}		{on grounded on			{call "stuff_detonate"}		}		{on ground_hit			{call "stuff_detonate"}		}		{on blast overload		}		{on blast_hit overload		                 		}		{on "stuff_detonate"		    {if not tagged "stuff_detonate"				{tags add "stuff_detonate"}				{volumes disable blast}	            {stuff_detonate}				}			}	}			
{"x59m_test"	    
		{on spawn overload		   
			{ik_enable "gun_rot" 0}		    
			{ik_enable "gun" 0}			
			{tags add "test"}			              			
			{tags add "moving"}			
			{volumes disable contact}			
			{volumes "part1" disable blast}			
			{volumes "part2" disable blast}			
			{impulse up -1.1 forward 30 com}								
			{delay 1.5			  
				{impulse up 0 dir 0.0 forward 160 com}				
				{call "move"}				
				{volumes enable contact}				
				{tags add "starting"}			    
				{add_view	"proj_jet_small"			"proj_jet_main"			"tail1"}			   
				{add_view	"proj_jet_sam"			"proj_jet"			"tail"}			    
				{view start "proj_tail"}			    {view start "proj_jet"}						   
				{add_view	"proj_smoke"		"proj_tail"		"root"}				
				{add_view	"proj_smoke30"		"proj_tail30"		"root"}				
				{add_view	"proj_smoke20"		"proj_tail20"		"root"}				
				{add_view	"proj_smoke10"		"proj_tail10"		"root"}									    
				{link_sound "fly"	"vehicle/engine/Missile/MissileEngine"}				
				{play_sound "fly" 1}				
				{tags add "cwps_missile_minimap"}							
			}									
			{ani_play "on_start"}						
			{delay 4.5 				
				{view stop "proj_jet"}				
				{view hide "proj_jet"}				
				{view start "proj_jet_main"}				 
				{tear "piece_missile_booster" bone "part1"{impulse forward 25}}				
				{tear "piece_small_steel" bone "part2" {impulse forward 25}}				 
				{tags remove "starting"}				
				{ik_enable "gun_rot" 1}			   
				{ik_enable "gun" 1}			
			}			 			
			{delay 4.5 			   
				{view pause "proj_jet_main"}				
				{view stop "proj_jet_main"}				
				{view hide "proj_jet_main"}											
			}			
			{delay 22 				
				{tags add "moving_slow"}				
				{impulse up 0 dir 0.0 forward 1 com}				
				{gravity 150.0}				
				{ik_enable "gun_rot" 0}			    
				{ik_enable "gun" 0}				
				{call "move"}			
			}			
			{delay 27 	           
				{gravity 700.0}				
				{impulse up 0.15}				
				{call "stuff_detonate"}			
			}		
		}		                       		                        		                      		   		  		                     		                         		  	    
		{on fire "gun"			
			{impulse up 0 dir 0.1 forward 0 com}			
			{call "move"}			
			{call "up"}		
		}		
		{on "move" overload		    
			{if tagged "moving"		       
				{spawn "proj_cont" "cont_vol" x {impulse up 0 dir 0.0 forward 10 com}} 
				{constrain_velocity 15}			    
				{delay 0.033 {call "move"}}		    
			}		
		}		
		{on "up" overload}		
		{on contact overload		
			{if effector "proj_cont"			
			{if volume "cont_vol"			
				{if tagged "starting"			
					{impulse up 0 dir 900.0 forward 0 com}	        
						else tagged "moving_slow"				
					{impulse up 0 dir 13.0 forward 0 com}			
						else tagged "moving"			
					{impulse up 0 dir 20.0 forward 0 com}			
				}			
			}	        
			else	       
				{volumes disable blast}					
				{call "stuff_detonate"}		
			}		
		}		
		{on grounded on			
		{call "stuff_detonate"}		
		}		
		{on blast overload	        
			{if min_energy 0.3				
				{call "stuff_detonate"}			
			}				
		}		
		{on blast_hit overload		    
			{if min_energy 0.3				
				{call "stuff_detonate"}			
			}			
		}		
		{on pierce 			
			{if not stuff "proj_pointer"				
				{call "stuff_detonate"}			
			}		
		}		
		{on "stuff_detonate"		   
			 {if not tagged "stuff_detonate"				
				 {tags add "stuff_detonate"}				
				 {volumes disable blast}	            
			 	{stuff_detonate}				
			 }			
		}		
		(include "flares_and_chaff.inc")		
		{on bullet_hit			
			{if stuff "blinding_laser"				
			{tags add "blinding_laser"}				
			{ani_wind "visor1" end}{ani_wind "visor2" end}{ani_wind "visor3" end}{ani_wind "visor4" end}				
			{ani_wind "visor5" end}{ani_wind "visor6" end}{ani_wind "visor7" end}{ani_wind "visor8" end}				
			{tags add "no_missile_control"}				
			{kill_delay "blinding_laser"}				
			{delay 2 "blinding_laser"					
				{tags remove "blinding_laser"}					
				{if work "driver_triplex" {ani_wind "visor2" begin}{ani_wind "visor90deg_2" begin}}					
				{if work "commander_triplex" {ani_wind "visor1" begin}{ani_wind "visor90deg_1" begin}}					
				{if work "additional_triplex" {ani_wind "visor3" begin}{ani_wind "visor90deg_3" begin}}					
				{if work "additional_triplex1" {ani_wind "visor4" begin}{ani_wind "visor90deg_4" begin}}					
				{if work "additional_triplex2" {ani_wind "visor5" begin}{ani_wind "visor90deg_5" begin}}					
				{if work "additional_triplex3" {ani_wind "visor6" begin}{ani_wind "visor90deg_6" begin}}					
				{if work "additional_triplex4" {ani_wind "visor7" begin}{ani_wind "visor90deg_7" begin}}					
				{if work "additional_triplex5" {ani_wind "visor8" begin}{ani_wind "visor90deg_8" begin}}					
				{call "update_weaponry"}					
				{call "update_power"}				
			}			
			else stuff "proj_pointer" {call "check_proj_type"}	                                                                    				
				{if not tagged "cannon_proj"						
				{if stuff "ground_laser_rus" {spawn "proj_point_rus_laser_acc" (mod "mp"{player 1}) (mod not "mp"{player 7})					{delay 10 {delete}}}					}					
				{if stuff "ground_laser_usa" {spawn "proj_point_usa_laser_acc" (mod "mp"{player 1}) (mod not "mp"{player 7})					{delay 10 {delete}}}					}										
				{if stuff "ground_other_rus" {spawn "proj_point_rus_other_acc" (mod "mp"{player 1}) (mod not "mp"{player 7})					{delay 10 {delete}}}					}					
				{if stuff "ground_other_usa" {spawn "proj_point_usa_other_acc" (mod "mp"{player 1}) (mod not "mp"{player 7})					{delay 10 {delete}}}					}					
				{if stuff "ground_other_usa_far" {spawn "proj_point_usa_other_acc" (mod "mp"{player 1}) (mod not "mp"{player 7})					{delay 27 {delete}}}					}										
				{if stuff "ground_active_rus" {spawn "proj_point_rus_active_acc" (mod "mp"{player 1}) (mod not "mp"{player 7})					{delay 10 {delete}}}					}					
				{if stuff "ground_active_usa" {spawn "proj_point_usa_active_acc" (mod "mp"{player 1}) (mod not "mp"{player 7})					{delay 10 {delete}}}					}										
				{if stuff "ground_ir_rus" {spawn "proj_point_rus_ir_acc" (mod "mp"{player 1}) (mod not "mp"{player 7})					{delay 10 {delete}}}					}					
				{if stuff "ground_ir_usa" {spawn "proj_point_usa_ir_acc" (mod "mp"{player 1}) (mod not "mp"{player 7})					{delay 10 {delete}}}					}				
				}			                       			
				else volume "LampL" {if work "LampL" {spawn "glass_hit"} {components "LampL" break}}			
				else  volume "LampR" {if work "LampR" {spawn "glass_hit"} {components "LampR" break}}			
				else  volume "LampT" {if work "LampT" {spawn "glass_hit"} {components "LampT" break}}			
				else  volume "LampT1" {if work "LampT1" {spawn "glass_hit"} {components "LampT1" break}}			
				else  volume "LampT2" {if work "LampT2" {spawn "glass_hit"} {components "LampT2" break}}			
			}			
			{if stuff "hesh_type_dmg" {spawn "cw_cumulative_frestrict" inv_normal}			
				else stuff "cm_type_dmg cm" {spawn "rpg_restrictor" inv_normal}}	                                              		
		}	
}	
{"proj_cont"	{on spawn {delay 0.3 {delete}}}	{on contact overload {delete}}	}