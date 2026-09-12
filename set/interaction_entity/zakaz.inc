{"zakaz_smerch"

}
(define "kamaz_arm"	

	{on "add_movement_sound" overload	
		{link_sound "move"			"vehicle/Wheels/Paz_loop"}
		{link_sound "engine"			"vehicle/engine/Kamaz_engine"}		
		{link_sound "exhaust"			"vehicle/engine/Kamaz_start"}		
		{link_sound "engine_end"		"vehicle/engine/Kamaz_shut_off"}				
	}
)
(define "kamaz_arm_flag"	

	{on "add_movement_sound" overload	
		{link_sound "move"			"vehicle/Wheels/Paz_loop"}
		{link_sound "engine"			"vehicle/engine/Kamaz_engine"}		
		{link_sound "exhaust"			"vehicle/engine/Kamaz_start"}		
		{link_sound "engine_end"		"vehicle/engine/Kamaz_shut_off"}				
	}
)
(define "smerch"	

	{on "add_movement_sound" overload	
		{link_sound "move"			"vehicle/Wheels/Paz_loop"}
		{link_sound "engine"			"vehicle/engine/Ural_engine"}		
		{link_sound "exhaust"			"vehicle/engine/Ural_4320_start"}		
		{link_sound "engine_end"		"vehicle/engine/Ural_4320_shut_off"}				
	}
	{on fire "gun"
		{if not tagged "fx_chot_v1" {tags add "fx_chot"}}
		{if tagged "fx_chot" {ani_play "lags" 100}}
		{delay 1 {tags add "fx_chot_v1"}}
		{ani_play "fire"}
		{spawn "dust_shot_big_3" "fx_pusk"}
		{spawn "cannon400_fire" "fx_pusk2" x}
		{ani_play "lags" 100}
		{delay 4.8 {tags remove "fx_chot"} {tags remove "fx_chot_v1"}}
		{delay 5 {if not tagged "fx_chot" {ani_play "lags" -1}}}
        }
	
)
(define "smerch_rus"	

	{on "add_movement_sound" overload	
		{link_sound "move"			"vehicle/Wheels/Paz_loop"}
		{link_sound "engine"			"vehicle/engine/Ural_engine"}		
		{link_sound "exhaust"			"vehicle/engine/Ural_4320_start"}		
		{link_sound "engine_end"		"vehicle/engine/Ural_4320_shut_off"}				
	}
	{on fire "gun"
		{if not tagged "fx_chot_v1" {tags add "fx_chot"}}
		{if tagged "fx_chot" {ani_play "lags" 100}}
		{delay 1 {tags add "fx_chot_v1"}}
		{ani_play "fire"}
		{spawn "dust_shot_big_3" "fx_pusk"}
		{spawn "cannon400_fire" "fx_pusk2" x}
		{ani_play "lags" 100}
		{delay 4.8 {tags remove "fx_chot"} {tags remove "fx_chot_v1"}}
		{delay 5 {if not tagged "fx_chot" {ani_play "lags" -1}}}
        }
	
)
{"kraz_coguar_ags"
	{on "update_lights"
          {if rain {ani_play "rain"} else {ani_stop "rain"}}
     }
}
{"kraz_coguar_hcb"
	{on "update_lights"
          {if rain {ani_play "rain"} else {ani_stop "rain"}}
     }
}
{"kraz_coguar_pkm"
	{on "update_lights"
          {if rain {ani_play "rain"} else {ani_stop "rain"}}
     }
}

{"smerch" ("smerch")	}
{"bmd1_ukr" {on spawn{tex_morph "ukr_vdv" 0}}}