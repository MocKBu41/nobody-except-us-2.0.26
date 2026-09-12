{selector
	{unit "human" "fg"}

	{group
	    {ignore {class proj_rus_antirad}}
		{ignore {class proj_usa_antirad}}
		{sort {class tank}}
		{sort {class armoredcar}}
		{sort {in_range 60}}
		{sort distance}
    }
}