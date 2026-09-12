{selector
	{unit "human" "AA_missile"}

	{group
	    {ignore {class proj_rus_antirad}}
		{ignore {class proj_usa_antirad}}
	    {sort {in_range 200} {class airborne}}
		{sort {in_range 200} {class Helicopter}}
		{sort {in_range 200} {class small_UAV}}
		{ignore {class human}}
		{ignore {class tank}}
		{ignore {class armoredcar}}
		{ignore {class car}}
		{ignore {class light_tank}}
		{ignore {class cannon}}
	}
}