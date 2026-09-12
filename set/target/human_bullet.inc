{selector
	{unit "human" "bullet"}

	{group
		{ignore {class proj_rus_antirad}}
		{ignore {class proj_usa_antirad}}
	    {sort {class airborne}}	
		{sort	{class human} {attacking}}	
		{sort {in_range 30} 	{class  tank}}
		{sort {in_range 30}	 {class armoredcar}}
		{sort {in_range 30}	 {class car}}
		{sort {in_range 30}	 {class light_tank}}
		{sort {in_range 30}	 {class cannon}}
		{sort {in_range 50} {threating}	{class  tank}}
		{sort {in_range 50}	{threating} {class armoredcar}}
		{sort {in_range 50}	{threating} {class car}}
		{sort {in_range 50}	{threating} {class light_tank}}
		{sort {in_range 50}	{threating} {class cannon}}
        {sort	{class human}}	
		{sort   {class  tank}}
        {sort   {class armoredcar}}
		{sort   {class car}}
		{sort   {class light_tank}}
		{sort   {class cannon}}		
		{sort	distance}

		{sort {in_range 110}}
		
		{ignore {class human} {weapon "proj_pointer"}}
	}
}