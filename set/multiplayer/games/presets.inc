(define "unit_limits"
{unitLimits "tankman=6;strike=1;vs=4;p=2;t14=2;max5=5;shahed136=20;max6=6;precision_munition=5;wagnerpvo=1"}
)
(define "buttons"
{buttons "common supl vvs_hqcar pvo_hqcar artbr_hqcar vdv_hqcar mot_hqcar armbr_hqcar specbr_hqcar usaf_hqcar usaaa_hqcar usart_hqcar idf_hqcar usarmy_hqcar usmc_hqcar nrf_hqcar natoaa_hqcar abn_hqcar bund_hqcar gb_hqcar fra_hqcar cnair_hqcar cnsam_hqcar cnart_hqcar cnheavy_hqcar cnmed_hqcar cnsco_hqcar vvc_hqcar arta_hqcar ukr_aa_hqcar dhv_hqcar meh_hqcar morh_hqcar poct_hqcar vvsw_hqcar pvow_hqcar artbrw_hqcar naem_hqcar wagnera_hqcar"}
)

;====test_rezim=====
(define "instant_test"
	{common
		{unitset
			{value "%unitset"}
		}
				{commandPoints "*=1;vvs=1;pvo=1;artbr=1;vdv=1;mot=1;armbr=1;specbr=1;usaf=1;usa_aa=1;usart=1;idf=1;usarmy=1;usmc=1;nrf=1;nato_aa=1;abn=1;bund=1;gb=1;fra=1;cnair=1;cnart=1;cnheavy=1;cnmed=1;cnsam=1;cnsco=1;vvc=1;arta=1;ukr_aa=1;dhv=1;meh=1;morh=1;poct=1;vvsw=1;pvow=1;artbrw=1;naem=1;wagnera=1"} 
		{unitLimits ""}
;		{chargeFactors "*=%cf"}
       ;  {unitLimits "tankman=6;strike=1;vs=4;p=2;wagnerpvo=1"}
		{balancingFactorBonus {cp 55000.0} {mp 1.0}}
		{chargeFactors
			{value "*=0"}
			;{available "*=0 *=0.5 *=1.0 *=1.5 *=2.0 *=2.5 *=5.0 *=10.0"}
		}
		{budgets
			{vehicle
				{mode "without_update"}
				{resource 
					{start 		%start}
					{finish 	100000}
					{speed 		0}
					{limitmin	1000}
					{limitmax	100000}
					{speedset 	"100000"}
				} 
				("buttons")
				;gb_hqcar fra_hqcar
			}
			{hqcar
				{mode "standard"}
				{resource
					{start		110}
					{finish		110}
					{growTime	70}		; in seconds
					{growTable	"0.45"}
					{payback
						{cp			"0		50		100		150		400"}
						{restore	"0.35	0.30	0.20	0.05	0.9"}
					}
				}
				{buttons "hqcar"}
			}
		} 
	}
	{bots
		(include "bots_generic_brig.inc")
	}
)

(define "instant_test_nobrigades"
	{common
		{unitset
			{value "%unitset"}
		}
		{commandPoints "*=55000"} 
;		{chargeFactors "*=%cf"}
		; {unitLimits "tankman=6;strike=1;vs=4;p=2;wagnerpvo=1"}
		{balancingFactorBonus {cp 1.0} {mp 1.0}}
		{chargeFactors
			{value "*=0"}
			;{available "*=0 *=0.5 *=1.0 *=1.5 *=2.0 *=2.5 *=5.0 *=10.0"}
		}
		{budgets
			{vehicle
				{mode "without_update"}
				{resource 
					{start 		%start}
					{finish 	100000}
					{speed 		0}
					{limitmin	1000}
					{limitmax	100000}
					{speedset 	"100000"}
				} 
				("buttons")
			}
			("no_hq_cars")
		} 
	}
	{bots
		(include "bots_generic.inc")
	}
)

;====standart====
(define "hq_cars"
			{hqcar
				{mode "standard"}
				{resource
					{start		%size}
					{finish		%size}
					{growTime	70}		; in seconds
					{growTable	"0.45"}
					{payback
						{cp			"0		50		100		150		400"}
						{restore	"0.35	0.25	0.15	0.05	0.05"}
					}
				}
				{buttons "hqcar"}
			}
)
(define "no_hq_cars"
			{hqcardummy
				{mode "standard"}
				{resource
					{start		1}
					{finish		5}
					{growTime	70}		; in seconds
					{growTable	"0.45"}
					{payback
						{cp			"0		50		100		150		400"}
						{restore	"0.35	0.30	0.20	0.05	0.05"}
					}
				}
				{buttons "hqcardummy"}
			}
)
(define "without_update"
				{mode "without_update"}
				{resource 
					{start 		%start}
					{finish 	%finish}
					{speed 		0}
					{limitmin	100}
					{limitmax	10000}
					{speedset 	"100 200 300 400 500 600 800 900 1000 1200 1500 1800 2000 4000 8000 10000"}
				} 
)
(define "with_payback"
				{mode "with_payback"}
				{resource 
					{start 		%start}
					{finish 	%finish}
;					{growTime	3623} ; ÷åì ìåíüøå òåì áûñòðåå èäóò î÷êè, 0.25 ïðè 10 ìèíóòàõ ïðèìåðíî ðàç â 1 ñåê, ïðè 20 â 2
;					{growTable 	"0.6 0.6 0.7 0.7 0.8 0.8 0.9 0.9 0.9 1.0 1.0 1.0"} ; ñêîðîñòü ðîñòà îòíîñèòåëüíî êîë-âà î÷êîâ, åñëè 
;					{restoreBegin 	1.25}	; points per sec  Ñêîðîñòü âîçâðàòà î÷êîâ çà ïîãèáøèõ þíèòîâ
;					{restoreEnd 	1.25}	; points per sec 
;					{speedset "300 400"}


					{growTime	9311}		; in seconds
					{limitmin	500}
					{limitmax	5000}
					{speedset 	"500 1000 2000 3000 4000 5000"}
					
					
					{growTable	"0.45"}
					{payback
						{cp			"0		50		100		150		400"}
						{restore	"0.35	0.30	0.20	0.05	0.05"}
					}
					
					
				}   
)
(define "period_update"
				{mode "with_update"}
				{resource 
					{start 		%start}
					{finish 	%finish}
					{speed 		350}
					{period 	300}
					{limitmin	1}
					{limitmax	1000}
					{speedset 	"100 200 250 300 350 400 450 500 550 600"}
				} 
)
(define "periodical_update"
				{mode "custom"}
				{resource 
					{start 		%start}
					{finish 	%finish}
					{growTime	1800}		; in seconds
					{growTable 	"0.45 0.46 0.46	0.46 0.51 0.51 0.51	0.52 0.53 0.53 0.55	0.60 0.61 0.62 0.63	0.70 0.75 0.75 0.75	0.75 0.85 0.85 0.85	0.85 0.85 1.07 1.07 1.07 1.07 1.07"} ; ðåàëüíîå ÷èñëî(1.0)=(%finish-%start)/(60*ñóììà èç íàáîðà ÷èñåë growTable) Ôîðìóëà äëÿ 30 ÷èñåë growTable è {growTime	1800}
					            ;1m   2m   3m   4m   5m   6m   7m   8m   9m   10m  11m  12m  13m  14m  15m  16m  17m  18m  19m  20m  21m  22m  23m  24m  25m  26m  27m  28m  29m  30m
					{payback
						{cp			"-350		-199		-120		-60		0"}
						{restore	"0.5	0.50	0.3	0.1	0.01"}
					}
					{limitmin	%start}
					{limitmax	50000}
					{speedset 	"%start 1000 1500 1800 2400 3000 3600 7200"}
				} 
)
(define "low_periodical_update"
				{mode "standard"}
				{resource 
					{start 		%start}
					{finish 	%finish}
					{growTime	1400}		; in seconds
					{growTable 	"1.0"}
					
					
					{payback
						{cp 		"-200 -150		0		201"}  
						{restore 	"0.1  0.1	    0	    0"}
					}
				} 
)
(define "game_brigade_blitz"
	{common
		{unitset
			{value "%unitset"}
		}
				{commandPoints "*=1;vvs=1;pvo=1;artbr=1;vdv=1;mot=1;armbr=1;specbr=1;usaf=1;usa_aa=1;usart=1;idf=1;idf=1;usarmy=1;usmc=1;nrf=1;nato_aa=1;abn=1;bund=1;gb=1;fra=1;cnair=1;cnart=1;cnheavy=1;cnmed=1;cnsam=1;cnsco=1"} 
;		{chargeFactors "*=%cf"}
 ("unit_limits")
		{balancingFactorBonus {cp 1.0} {mp 1.0}}
		{chargeFactors
			{value "*=0.0"}
			{available "*=0 *=0.5 *=1.0 *=1.5 *=2.0 *=2.5 *=5.0 *=10.0"}
		}
		{budgets
			{vehicle
				("without_update" start(%start) finish(%finish))
				("buttons")
			}
			("extra_units")
			("hq_cars" hq_restore_speed(%hq_restore_speed) size(%size))
		} 
	}
	{bots
		(include "bots_generic_brig.inc")
	}
)
;====================rezim======
(define "game_brigade_without_update"
	{common
		{unitset
			{value "%unitset"}
		}
				{commandPoints "*=1;vvs=1;pvo=1;artbr=1;vdv=1;mot=1;armbr=1;specbr=1;usaf=1;usa_aa=1;usart=1;idf=1;usarmy=1;usmc=1;nrf=1;nato_aa=1;abn=1;bund=1;gb=1;fra=1;cnair=1;cnart=1;cnheavy=1;cnmed=1;cnsam=1;cnsco=1;vvc=1;arta=1;ukr_aa=1;dhv=1;meh=1;morh=1;poct=1;vvsw=1;pvow=1;artbrw=1;naem=1;wagnera=1"} 
;		{chargeFactors "*=%cf"}
 	("unit_limits")
		{balancingFactorBonus {cp 1.0} {mp 1.0}}
		{chargeFactors
			{value "*=1.0"}
			{available "*=0 *=0.25 *=0.5 *=0.6 *=0.7 *=0.8 *=0.9 *=1.0 *=1.1 *=1.2 *=1.3 *=1.4 *=1.5 *=2.0"}
		}
		{budgets
			{vehicle
				("without_update" start(%start) finish(%finish))
				("buttons")
			}
			("hq_cars" hq_restore_speed(%hq_restore_speed) size(%size))
		} 
	}
	{bots
		(include "bots_generic_brig.inc")
	}
)
(define "game_brigade_with_payback"
	{common
		{unitset
			{value "%unitset"}
		}
				{commandPoints "*=1;vvs=1;pvo=1;artbr=1;vdv=1;mot=1;armbr=1;specbr=1;usaf=1;usa_aa=1;usart=1;idf=1;usarmy=1;usmc=1;nrf=1;nato_aa=1;abn=1;bund=1;gb=1;fra=1;cnair=1;cnart=1;cnheavy=1;cnmed=1;cnsam=1;cnsco=1;vvc=1;arta=1;ukr_aa=1;dhv=1;meh=1;morh=1;poct=1;vvsw=1;pvow=1;artbrw=1;naem=1;wagnera=1"} 
;		{chargeFactors "*=%cf"}
("unit_limits")
		{balancingFactorBonus {cp 1.0} {mp 1.0}}
		{chargeFactors
			{value "*=1.0"}
			{available "*=0 *=0.25 *=0.5 *=0.6 *=0.7 *=0.8 *=0.9 *=1.0 *=1.1 *=1.2 *=1.3 *=1.4 *=1.5 *=2.0"}
		}
		{budgets
			{vehicle
				("with_payback" start(%start) finish(%finish))
				("buttons")
			}
			("hq_cars" hq_restore_speed(%hq_restore_speed) size(%size))
		} 
	}
	{bots
		(include "bots_generic_brig.inc")
	}
)
(define "game_brigade_with_periodical_update"
	{common
		{unitset
			{value "%unitset"}
			{available "vvs pvo artbr vdv mot armbr specbr usaf usa_aa usart idf usarmy usmc nrf nato_aa abn bund gb fra cnair cnsam cnart cnheavy cnmed common supl vvc arta ukr_aa dhv meh morh poct vvsw pvow artbrw naem wagnera"}
		}
			{commandPoints "*=1;vvs=1;pvo=1;artbr=1;vdv=1;mot=1;armbr=1;specbr=1;usaf=1;usa_aa=1;usart=1;idf=1;usarmy=1;usmc=1;nrf=1;nato_aa=1;abn=1;bund=1;gb=1;fra=1;cnair=1;cnart=1;cnheavy=1;cnmed=1;cnsam=1;cnsco=1;vvc=1;arta=1;ukr_aa=1;dhv=1;meh=1;morh=1;poct=1;vvsw=1;pvow=1;artbrw=1;naem=1;wagnera=1"} 
;		{chargeFactors "*=%cf"}
 ("unit_limits")
		{balancingFactorBonus {cp 1.0} {mp 1.0}}
		{chargeFactors
			{value "*=1.0"}
			{available "*=0 *=0.25 *=0.5 *=0.6 *=0.7 *=0.8 *=0.9 *=1.0 *=1.1 *=1.2 *=1.3 *=1.4 *=1.5 *=2.0"}
		}
		{budgets
			{vehicle 
                ("periodical_update" start(%start) finish(%finish))
				("buttons")
			}
			("hq_cars" hq_restore_speed(%hq_restore_speed) size(%size))
		} 
	}
	{bots
		(include "bots_generic_brig.inc")
	}
)
(define "game_brigade_with_period_update"
	{common
		{unitset
			{value "%unitset"}
		}
				{commandPoints "*=1;vvs=1;pvo=1;artbr=1;vdv=1;mot=1;armbr=1;specbr=1;usaf=1;usa_aa=1;usart=1;idf=1;usarmy=1;usmc=1;nrf=1;nato_aa=1;abn=1;bund=1;gb=1;fra=1;cnair=1;cnart=1;cnheavy=1;cnmed=1;cnsam=1;cnsco=1;vvc=1;arta=1;ukr_aa=1;dhv=1;meh=1;morh=1;poct=1;vvsw=1;pvow=1;artbrw=1;naem=1;wagnera=1"} 
;		{chargeFactors "*=%cf"}
("unit_limits")
		{balancingFactorBonus {cp 1.0} {mp 1.0}}
		{chargeFactors
			{value "*=1.0"}
			{available "*=0 *=0.25 *=0.5 *=0.6 *=0.7 *=0.8 *=0.9 *=1.0 *=1.1 *=1.2 *=1.3 *=1.4 *=1.5 *=2.0"}
		}
		{budgets
			{vehicle 
                ("period_update" start(%start) finish(%finish))
				("buttons")
			}
			("hq_cars" hq_restore_speed(%hq_restore_speed) size(%size))
		} 
	}
	{bots
		(include "bots_generic_brig.inc")
	}
)
(define "game_brigade_with_lowperiodical_update"
	{common
		{unitset
			{value "%unitset"}
		}
				{commandPoints "*=1;vvs=1;pvo=1;artbr=1;vdv=1;mot=1;armbr=1;specbr=1;usaf=1;usa_aa=1;usart=1;idf=1;usarmy=1;usmc=1;nrf=1;nato_aa=1;abn=1;bund=1;gb=1;fra=1;cnair=1;cnart=1;cnheavy=1;cnmed=1;cnsam=1;cnsco=1;vvc=1;arta=1;ukr_aa=1;dhv=1;meh=1;morh=1;poct=1;vvsw=1;pvow=1;artbrw=1;naem=1;wagnera=1"} 
;		{chargeFactors "*=%cf"}
("unit_limits")
		{balancingFactorBonus {cp 1.0} {mp 1.0}}
		{chargeFactors
			{value "*=1.0"}
			{available "*=0 *=0.25 *=0.5 *=0.6 *=0.7 *=0.8 *=0.9 *=1.0 *=1.1 *=1.2 *=1.3 *=1.4 *=1.5 *=2.0"}
		}
		{budgets
			{vehicle 
               	("low_periodical_update" start(%start) finish(%finish))
				{buttons "common supl    vdv_hqcar mot_hqcar armbr_hqcar specbr_hqcar    idf_hqcar usarmy_hqcar usmc_hqcar    bund_hqcar gb_hqcar fra_hqcar cnheavy_hqcar cnmed_hqcar cnsco_hqcar dhv_hqcar meh_hqcar morh_hqcar poct_hqcar    naem_hqcar wagnera_hqcar"}
			}
			("hq_cars" hq_restore_speed(%hq_restore_speed) size(%size))
		} 
	}
	{bots
		(include "bots_generic_brig.inc")
	}
)
(define "game_normal_without_update"
	{common
		{unitset
			{value "%unitset"}
		}
		{commandPoints "*=%cp"} 
;		{chargeFactors "*=%cf"}
 ("unit_limits")
		{balancingFactorBonus {cp 1.0} {mp 1.0}}
		{chargeFactors
			{value "*=1.0"}
			{available "*=0 *=0.25 *=0.5 *=0.6 *=0.7 *=0.8 *=0.9 *=1.0 *=1.1 *=1.2 *=1.3 *=1.4 *=1.5 *=2.0"}
		}
		{budgets
			{vehicle
				("without_update" start(%start) finish(%finish))
					("buttons")
			}
			("no_hq_cars")
		} 
	}
	{bots
		(include "bots_generic.inc")
	}
)
(define "game_normal_with_payback"
	{common
		{unitset
			{value "%unitset"}
		}
		{commandPoints "*=%cp"} 
;		{chargeFactors "*=%cf"}
("unit_limits")
		{balancingFactorBonus {cp 1.0} {mp 1.0}}
		{chargeFactors
			{value "*=1.0"}
			{available "*=0 *=0.25 *=0.5 *=0.6 *=0.7 *=0.8 *=0.9 *=1.0 *=1.1 *=1.2 *=1.3 *=1.4 *=1.5 *=2.0"}
		}
		{budgets
			{vehicle
				("with_payback" start(%start) finish(%finish))
				("buttons")
			}
			("no_hq_cars")
		} 
	}
	{bots
		(include "bots_generic.inc")
	}
)

(define "game_normal_with_periodical_update"
	{common
		{unitset
			{value "%unitset"}
		}
		{commandPoints "*=%cp"} 
;		{chargeFactors "*=%cf"}
("unit_limits")
		{balancingFactorBonus {cp 1.0} {mp 1.0}}
		{chargeFactors
			{value "*=1.0"}
			{available "*=0 *=0.25 *=0.5 *=0.6 *=0.7 *=0.8 *=0.9 *=1.0 *=1.1 *=1.2 *=1.3 *=1.4 *=1.5 *=2.0"}
		}
		{budgets
			{vehicle 
                ("periodical_update" start(%start) finish(%finish))
				("buttons")
			}
			("no_hq_cars")
		} 
	}
	{bots
		(include "bots_generic.inc")
	}
)
;=================================
(define "brigade_presets"
    {"p:brigade_200_periodical_update_%gametype"	{gameMode "periodical_update"}		{unitMode "brigades%desc"}	{specMode "army_200"}
		("game_brigade_with_periodical_update" unitset(%unitset_brigade) cf(1) start(450) finish(8000) size(110))
		{ranked}
	}
	{"p:brigade_200_lowperiodical_update_%gametype"	{gameMode "periodical_update"}		{unitMode "lowbrigades%desc"}	{specMode "army_200"}
		("game_brigade_with_lowperiodical_update" unitset(%unitset_brigade) cf(1) start(180) finish(1200) size(110))
		{ranked}
	}
	{"p:brigade_200_period_update_%gametype"	{gameMode "period_update"}		{unitMode "brigades%desc"}	{specMode "army_200"}
		("game_brigade_with_period_update" unitset(%unitset_brigade) cf(1) start(450) finish(700) size(110))
		{ranked}
	}
	{"p:brigade_200_with_payback_%gametype"	{gameMode "with_payback"}		{unitMode "brigades%desc"}	{specMode "army_200"}
		("game_brigade_with_payback" unitset(%unitset_brigade) cf(1) start(450) finish(8000) size(110))
	}
	{"p:brigade_200_without_update_%gametype"	{gameMode "without_update"}		{unitMode "brigades%desc"}	{specMode "army_200"}
		("game_brigade_without_update" unitset(%unitset_brigade) cf(1) start(450) finish(8000) size(110))
	}
)
(define "normal_presets"
	{"p:normal_200_periodical_update_%gametype"		{gameMode "periodical_update"}		{unitMode "Vnormal%desc"}	{specMode "army_200"}
		("game_normal_with_periodical_update" unitset(%unitset) cp(200) cf(1) start(400) finish(8000))
	}
	{"p:normal_160_periodical_update_%gametype"		{gameMode "periodical_update"}		{unitMode "Vnormal%desc"}	{specMode "division_160"}
		("game_normal_with_periodical_update" unitset(%unitset) cp(160) cf(1) start(320) finish(8000))
	}
	{"p:normal_140_periodical_update_%gametype"		{gameMode "periodical_update"}		{unitMode "Vnormal%desc"}	{specMode "regiment_140"}
		("game_normal_with_periodical_update" unitset(%unitset) cp(140) cf(1) start(280) finish(8000))
	}
	{"p:normal_120_periodical_update_%gametype"		{gameMode "periodical_update"}		{unitMode "Vnormal%desc"}	{specMode "battalion_120"}
		("game_normal_with_periodical_update" unitset(%unitset) cp(120) cf(1) start(240) finish(8000))
	}
	{"p:normal_100_periodical_update_%gametype"		{gameMode "periodical_update"}		{unitMode "Vnormal%desc"}	{specMode "company_100"}
		("game_normal_with_periodical_update" unitset(%unitset) cp(100) cf(1) start(200) finish(8000))
	}
	{"p:normal_80_periodical_update_%gametype"		{gameMode "periodical_update"}		{unitMode "Vnormal%desc"}	{specMode "platoon_80"}
		("game_normal_with_periodical_update" unitset(%unitset) cp(80) cf(1) start(80) finish(8000))
	}
	{"p:normal_60_periodical_update_%gametype"		{gameMode "periodical_update"}		{unitMode "Vnormal%desc"}	{specMode "squad_60"}
		("game_normal_with_periodical_update" unitset(%unitset) cp(60) cf(1) start(60) finish(8000))
	}
;============================
	{"p:normal_200_with_payback_%gametype"		{gameMode "periodical_update"}		{unitMode "Vnormal%desc"}	{specMode "army_200"}
		("game_normal_with_payback" unitset(%unitset) cp(400) cf(1) start(400) finish(8000))
	}
	{"p:normal_160_with_payback_%gametype"		{gameMode "with_payback"}		{unitMode "Vnormal%desc"}	{specMode "division_160"}
		("game_normal_with_payback" unitset(%unitset) cp(160) cf(1) start(320) finish(8000))
	}
	{"p:normal_140_with_payback_%gametype"		{gameMode "with_payback"}		{unitMode "Vnormal%desc"}	{specMode "regiment_140"}
		("game_normal_with_payback" unitset(%unitset) cp(140) cf(1) start(280) finish(8000))
	}
	{"p:normal_120_with_payback_%gametype"		{gameMode "with_payback"}		{unitMode "Vnormal%desc"}	{specMode "battalion_120"}
		("game_normal_with_payback" unitset(%unitset) cp(120) cf(1) start(240) finish(8000))
	}
	{"p:normal_100_with_payback_%gametype"		{gameMode "with_payback"}		{unitMode "Vnormal%desc"}	{specMode "company_100"}
		("game_normal_with_payback" unitset(%unitset) cp(100) cf(1) start(200) finish(8000))
	}
	{"p:normal_80_with_payback_%gametype"		{gameMode "with_payback"}		{unitMode "Vnormal%desc"}	{specMode "platoon_80"}
		("game_normal_with_payback" unitset(%unitset) cp(80) cf(1) start(80) finish(8000))
	}
	{"p:normal_60_with_payback_%gametype"		{gameMode "with_payback"}		{unitMode "Vnormal%desc"}	{specMode "squad_60"}
		("game_normal_with_payback" unitset(%unitset) cp(60) cf(1) start(60) finish(8000))
	}
;============================
	{"p:normal_200_without_update_%gametype"		{gameMode "periodical_update"}		{unitMode "Vnormal%desc"}	{specMode "army_200"}
		("game_normal_without_update" unitset(%unitset) cp(400) cf(1) start(400) finish(8000))
	}
	{"p:normal_160_without_update_%gametype"		{gameMode "without_update"}		{unitMode "Vnormal%desc"}	{specMode "division_160"}
		("game_normal_without_update" unitset(%unitset) cp(160) cf(1) start(320) finish(8000))
	}
	{"p:normal_140_without_update_%gametype"		{gameMode "without_update"}		{unitMode "Vnormal%desc"}	{specMode "regiment_140"}
		("game_normal_without_update" unitset(%unitset) cp(140) cf(1) start(280) finish(8000))
	}
	{"p:normal_120_without_update_%gametype"		{gameMode "without_update"}		{unitMode "Vnormal%desc"}	{specMode "battalion_120"}
		("game_normal_without_update" unitset(%unitset) cp(120) cf(1) start(240) finish(8000))
	}
	{"p:normal_100_without_update_%gametype"		{gameMode "without_update"}		{unitMode "Vnormal%desc"}	{specMode "company_100"}
		("game_normal_without_update" unitset(%unitset) cp(100) cf(1) start(200) finish(8000))
	}
	{"p:normal_80_without_update_%gametype"		{gameMode "without_update"}		{unitMode "Vnormal%desc"}	{specMode "platoon_80"}
		("game_normal_without_update" unitset(%unitset) cp(80) cf(1) start(80) finish(8000))
	}
	{"p:normal_60_without_update_%gametype"		{gameMode "without_update"}		{unitMode "Vnormal%desc"}	{specMode "squad_60"}
		("game_normal_without_update" unitset(%unitset) cp(60) cf(1) start(60) finish(8000))
	}
;============================

)

;==================================================================================================================
(define "custom_presets"
     {presets
	("brigade_presets" gametype(%gametype) desc(%desc) unitset_brigade(%unitset_brigade))
	("normal_presets" gametype(%gametype) desc(%desc) unitset(%unitset))
     }
)

(define "monotype_presets"
     {presets
	("normal_presets" gametype(%gametype) desc(%desc) unitset(%unitset))
     }
)

(define "duel_presets"
     {presets
	{"p:duel_%lives_duel_Vduel%desc"		{gameMode "duel"}		{unitMode "Vduel%desc"}	{specMode "duel_%lives"}
	   {common
		{unitset
			{value "%unitset"}
		}
		{commandPoints "*=%cp"} 
		{chargeFactors "*=0"}
		{budgets
			{vehicle
				{mode "without_update"}
				{resource 
					{start 		%maxcost}
					{finish 	10000}
					{speed 		0}
					{limitmin	%maxcost}
					{limitmax	%maxcost}
					{speedset 	"%maxcost"}
				} 
					("buttons")
			}
		} 
	   }
	}
    }
)

;îáû÷íûé íàáîð âîéñê â áðèãàäå è â åäèíîì êîìàíäîâàíèè
;("custom_presets" gametype() desc() unitset_brigade(all|additional) unitset(all|additional^hqcar))
("custom_presets" gametype() desc() unitset_brigade(all|additional^hqcarhqcardummy) unitset(all|additional^hqcar))

;Òàíêîâûé áîé
("monotype_presets" gametype(tank_mono) desc(tank_mono) unitset(supply|tanks_only))

;Áèàòëîí
;("duel_presets" desc(biatlon) unitset(biatlon)lives(1) cp(1) maxcost(5))

;Òåñòîâûå
{presets
	{"wu:without_update_timers"
		{gameMode "without_update"}
		{unitMode "test"}
		{specMode "test_a"}
		("instant_test" cf(0) start(100000) unitset(all|additional))
	}
	{"wu:without_update_notimers"
		{gameMode "without_update"}
		{unitMode "test"}
		{specMode "test_b"}
		("instant_test" cf(1) start(100000) unitset(all|additional))
	}
	{"wu:without_update_timers_nobrig"
		{gameMode "without_update"}
		{unitMode "test_nobrig"}
		{specMode "test_a"}
		("instant_test_nobrigades" cf(0) start(100000) unitset(all|additional^hqcar))
	}
	{"wu:without_update_notimers_nobrig"
		{gameMode "without_update"}
		{unitMode "test_nobrig"}
		{specMode "test_b"}
		("instant_test_nobrigades" cf(1) start(100000) unitset(all|additional^hqcar))
	}
}