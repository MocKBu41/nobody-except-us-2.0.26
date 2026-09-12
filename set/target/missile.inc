{selector
	{type "missile"}

	{group
		{sort {class antiship_missile}}
		
		{sort {class decoy_chaff} time_to_aim}
	    {sort {class decoy_flare} time_to_aim}
	    {sort {class decoy_optic}}
		{sort {class AA_missile}}
		{sort {class proj_rus_ir}}
		{sort {class proj_rus_ir}}
		{sort {class airborne} time_to_aim}
		{sort {class Helicopter} time_to_aim}
		{sort {class small_UAV} time_to_aim}
		{sort {class proj_cwps3} time_to_aim}
		{sort {class proj_rus_radpassive} time_to_aim}
		{sort {class proj_usa_radpassive} time_to_aim}
		
		{sort time_to_aim}
	}
}
{selector
	{type "antimissile"}
	{group
		{sort distance}
	}
}
{selector
	{type "corr"}
	{group
	   {sort {class proj_cwps3}} 
	   {sort time_to_aim}
	}
}
{selector
	{type "laser_guided_shell"}
	{group
	   {sort {class proj_cwps3}}
	   ;{sort {class proj_rus_laser_uas}}
       ;{sort distance}	   
	   ;{sort {class proj_rus_laser_guide}} 
	}
}
{selector
	{type "missile_antirad"}

	{group
		{sort distance}
	}
}