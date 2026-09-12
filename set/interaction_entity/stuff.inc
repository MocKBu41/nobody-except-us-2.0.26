(define "weapon_fx"		
	{"stuff weapon %tag"			
		{on spawn				
			{add_view "%shell" "shell" "FXshell"}				
			{call "start_update_lights"}								
			{if not stuff "sd" 					
			{add_view "%flash" "flashbarrel" "foresight3"}				
			}				
			{add_view "we_smoke" "smoke_or" "foresight3"}				
		}		
	}
)		
("weapon_fx" 
	tag(pistol)		
	shell(smg_gilz) 
	flash(flash_gun_small))	
	("weapon_fx" 
		tag(rifle)		
		shell(zenit_gilz) 
		flash(flash_gun_big))	
	("weapon_fx" 
		tag(shotgun)		
		shell(zenit_gilz) 
		flash(flash_shotgun))	
	("weapon_fx" 
		tag(smg)		
		shell(smg_gilz)
		flash(flash_gun_small))
	("weapon_fx" 
		tag(mgun)	
		shell(zenit_gilz) 
		flash(flash_gun_big))	
	("weapon_fx" 
		tag(gra_launch)
		shell(none) 
		flash(startsm_grl))		
{"stuff weapon"		
	{on "link" {call "start_update_lights"}}		
	{on "start_update_lights"			
		{call "update_lights"}			
		{kill_delay "update_lights"}			
		{delay 15 2 "update_lights"				
			{if linked					
				{call "start_update_lights"}				
					else
					{call "update_lights"}				
			}			
		}		
	}		
	{on "fire"			
		{view show	"flashbarrel"}			
		{view start	"flashbarrel"}			
		{view show	"smoke_or"}			
		{view start	"smoke_or"}			
		{view show	"shells_we"}			
		{view start	"shells_we"}				
		{view start	"flame"}			
		{view start	"bullet"}			
		{view start	"smoke_body"}			
		{ani_play "recoil"}			
		{view start "shell"}			
		{delay 0.2 "shell"				
			{view pause "shell"}			
		}						
		{kill_delay "fire"}			
		{kill_delay "shells_we"}			
		{delay 0.2				
			{view pause	"shells_we"}		       
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
	}	
}	
{"stuff weapon lg" 		
	{on spawn 	
		{add_view "laser_day" "laser1" "foresight3"} 
		{call "start_update_lights"}
	}		
	{on "update_lights"			
		{if linked 
			{view start "laser1"} 
			{view show "laser1"}			
			else 
			{view stop "laser1"} 
			{view hide "laser1"}			
		}		
	}	
}	
{"stuff weapon lgs" 		
	{on spawn 	
		{add_view "laser_day" "laser1" "FxLaser"} 
		{call "start_update_lights"}}		
		{on "update_lights"			
			{if linked 
				{view start "laser1"} 
				{view show "laser1"}			
				else 
				{view stop "laser1"} 
				{view hide "laser1"}			
			}		
		}	
}	
{"stuff weapon fn" 		
	{on spawn			
		{add_view 	"weap_light"		"light"	"foresight3"}				
		{add_view 	"light_vehicle"	"light"			"foresight3"}			
		{call "update_lights"}		
	}		
	{on "update_lights"			
		{if not linked				
		{view stop "light"}	
		{view hide "light"}			
		else not sunlight				
			{view start "light"}	
			{view show "light"}			
			else				
			{view stop "light"}	
			{view hide "light"}			
		}		
	}	
}	
{"weapon laser_designator"		
	{on "link" 			
		{add_view "laser_designator" "laser_designator" "foresight3"}			
		{view hide "laser_designator"}		
	}		
	{on "fire"			
		{view start "laser_designator"}			
		{view show "laser_designator"}			
		{delay 0.6	
		{view hide "laser_designator"}{view pause "laser_designator"}}		
	}	
}	
{"stuff weapon rocketlauncher"		
	{on "fire"			
		{spawn "bazooka_shot" "fxshot" x}		
	}	
}	
{"igla weapon" 
	{on "fire"
		{delay 0.01 
			{spawn "igla_s_carrier" "Foresight3"   x}
		}
	}
}	
{"verba weapon" 
	{on "fire"
		{delay 0.01 
			{spawn "9m336_carrier" "Foresight3"   x}
		}
	}
}
{"stinger weapon" 
	{on "fire" 
		{delay 0.01 
			{spawn "fim-92a_carrier" "Foresight3"   x}
		}
	}
}	
{"eryx weapon" 
	{on "fire"		
		{delay 0.01 
			{spawn "eryx_rock_carrier" "Foresight3"   x}
		}			
		{spawn "eryx_tubus" "root" x				
			{impulse up 2.5 0.7 dir 2.5 0.7 cz 0.2 0.1 forward -2 0.5 com}			
		}	
	}
}	
{"javelin weapon" 
	{on "fire"			
		{delay 0.01 
			{spawn "jav_rock_carrier" "Foresight3"   x}
		}			
		{spawn "jav_tubus" "root" x				
			{impulse up 2.5 0.7 dir 2.5 0.7 cz 0.2 0.1 forward -2 0.5 com}			
		}	
	}
}	
{"sraw weapon" 
	{on "fire" 
		{delay 0.01 
			{spawn "sraw_rock_carrier" "Foresight3"   x}
		}
	}
}		
{"stuff weapon flame_thrower"		
	{on spawn			
		{add_view "flamer_fire"			"flame"	"foresight3"}			
		{add_view "flamer_fire_barrel"	"fire"	"foresight3"}		
	}		
	{on "link"			
		{view show	"fire"}			
		{view start	"fire"}		
	}		
	{on "fire" override			
		{view start	"flame"}			
		{kill_delay "fire"}			
		{delay 0.4 "fire"				
			{view pause	"flame"}			
		}		
	}	
}

;===============neu

	