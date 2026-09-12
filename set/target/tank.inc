{selector
	{type "tank"}

	{group
	    {ignore {class proj_rus_antirad}}
		{ignore {class proj_usa_antirad}}
;		{ignore {class airborne}}
		{select {weapon "ap"}}
		{select {weapon "fg"}}
        
		{sort {weapon "ap"} {attacking} {class tank}}
		{sort {weapon "ap"} {attacking}}
		{sort {in_range 50}}
		{sort {weapon "ap"} {threating} {class tank}}
		{sort {weapon "ap"} {threating}}
		{sort {weapon "ap"} {class tank}}
		{sort {weapon "ap"}}
		{sort {weapon "fg"} {attacking}}
		{sort {weapon "fg"} {threating}}
		{sort {weapon "fg"}}
		{sort {in_range 180}}
		{sort time_to_aim}
	}

	{group
		{sort {class tank}}
		{sort {class armoredcar}}
		{sort {class car}}
		{sort time_to_aim}
	}
}
