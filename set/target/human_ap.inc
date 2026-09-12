{selector
	{unit "human" "ap"}

	{group
	    {ignore {class proj_rus_antirad}}
		{ignore {class proj_usa_antirad}}
		{sort {class tank}}
		{sort {class armoredcar}}
		{sort {class car}}
		{sort {attacking}}
		;{sort {in_range 60}}
		{sort distance}
    }
}