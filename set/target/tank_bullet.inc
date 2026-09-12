{selector
 	{type "tank_bullet"}

	{group
	    {ignore {class proj_rus_antirad}}
		{ignore {class proj_usa_antirad}}
;		{sort {class human} {weapon "fg"} }
		{sort {class human} {weapon}}
		{sort {class human}}
		{sort distance}
	}
}
