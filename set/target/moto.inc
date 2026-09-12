{selector
	{type "moto"}

	{group
	    {ignore {class proj_rus_antirad}}
		{ignore {class proj_usa_antirad}}
		{sort {class human} {weapon "ap"}}
		{sort {class human} {weapon}}
		{sort {class car}}
		{sort time_to_aim}
	}
	{group
		{sort distance}
	}
}