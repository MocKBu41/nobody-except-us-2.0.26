{selector
 	{type "cannon_shell"}
	{group
	    {ignore {class proj_rus_antirad}}
		{ignore {class proj_usa_antirad}}
		{sort {class tank}}
		{sort {class armoredcar}}
		{sort {class car}}
		{sort {weapon "fg"}}
		{sort {weapon}}
		{sort distance}
	}

	{group
		{sort {attacking}}
		{sort distance}
	}
}

