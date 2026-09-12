require([[/script/multiplayer/bot.data]])

-- If something is wrong in here, feel free to tell me about it.

local Context = {
	Purchase = nil,
	SpawnInfo = nil,
	SquadTimers = {},
	TimedUnits = {}
}

function addTimedUnit(unit)
	table.insert(Context.TimedUnits, {u=unit, bought_at=Quants})
end

function updateTimedUnits(unit_to_search)
	local res=1
	if #Context.TimedUnits>0 then
		for i, timed_unit in pairs(Context.TimedUnits) do
			if timed_unit.u==unit_to_search then
				res=0
			end
			if (Quants-timed_unit.bought_at) > (timed_unit.u.charge*100) then
				Context.TimedUnits[i]=nil
			end
		end
	end
	return res
end

function readUnitsRaw(fname, units, army) 								-- Credit for parser goes to the maker of AggroAi.
	--if verbose then print("reading ", fname , " for ", army) end		-- You can enable prints for debug purposes.
	f=io.open(fname, "r")
	if f~=nil then 
		while true do
			local asRead = f:read("*l")
			local line = asRead
			if line == nil then break end
			
			line = line:gsub(";.*","")
			line = line:gsub("^%s*(.-)%s*$", "%1")
			if (line:lower():find("[(]"..army:lower().."[)]") and line:len() > 0  -- only things of the current army
				and line:find("nobot")==nil 		-- no ammo suppliers.
				
				) -- no things for the support menu (all carried weapon don't work).
				then 
				--if (verbose) then print("parsing ", line) end
				local unit = line
				unit = unit:gsub( ".*name[(]", "")
				unit = unit:gsub( "[)].*", "")

				local cost = line
				cost = cost:gsub( ".*[{]cost ", "")
				cost = cost:gsub( ".*cost[(]", "")
				cost = cost:gsub( "[})].*", "")
				cost = tonumber(cost)
				
				local fcost = cost
				if(cost == nil) then cost = 197 end
				if(cost == 0) then cost = 1 end
				if (fcost == nil) then fcost = 0 end

				local count = 0 
				local charge = 0
				local fore = 0
				local group = 0
				for uc in line:gmatch(" c[(]([^)]*)[)]") do charge = charge + tonumber(uc) 
				end
				for uc in line:gmatch(" f[(]([^)]*)[)]") do fore = fore + tonumber(uc) 
				end
				for uc in line:gmatch("[{]fore ([0-9]+)[}]") do fore = fore + tonumber(uc) 
				end
				for uc in line:gmatch(" g[(]([^)]*)[)]") do group = uc 
				end
				
				fore=1-fore
				wait_at_quant=charge*fore*50+1
				if line:find('squad') then 
					for uc in line:gmatch("c[0-9]+[(][^)]*:([0-9]+)") do
					count = count + tonumber(uc)
					end
					if count>0 then
						cost=cost/count
					end
				end
				if (count==0) or (count==nil) then 
					count=1
				end
				if unit:len()>0 and not unit:match("{") then
					if line:find("bazookers") or line:find("stormtroopers2") then 
						units[units.count] = {unit = unit.."("..army..")", count = count, class = UnitClass.ATInfantry, priority = 2, fcost = fcost,
											 cost = cost, charge = charge, fore = fore, group = group, wait_at_quant = wait_at_quant}
						units.count = units.count+1
					elseif line:find(" side( ") then
						units[units.count] = {unit = unit.."("..army..")", count = count, class = UnitClass.Infantry, priority = 6, fcost = fcost,
											 cost = cost, charge = charge, fore = fore, group = group, wait_at_quant = wait_at_quant}
						units.count=units.count+1
					else 
						units[units.count] = {unit = unit.."("..army..")", count = count, class = UnitClass.Infantry, priority = 6, fcost = fcost,
											 cost = cost, charge = charge, fore = fore, group = group, wait_at_quant = wait_at_quant}
						units.count=units.count+1
					end	
				else 
					unit = line
					unit = unit:gsub( "{\"", "")
					unit = unit:gsub( "\".*", "")

					if not unit:match("mp/") and unit:len()>0 then
						units[units.count] = { unit = unit, count = count, class = UnitClass.Vehicle, priority = 2, fcost = fcost,
							cost = cost, charge = charge, fore = fore, group = group, wait_at_quant = wait_at_quant}

						if asRead:find("hero") then 
							units[units.count].class = UnitClass.Hero
							units[units.count].priority = 3
							units[units.count].wait_at_quant = units[units.count].wait_at_quant + (units[units.count].charge*20) -- *20 == floor(*100/5)
						elseif line:find("heavy") then 
							units[units.count].class = UnitClass.HeavyTank
							units[units.count].priority = 1
						elseif line:find("b[(]v4[)]") then 
								-- if verbose then print(unit, " read as tank, p:",cost) end
								units[units.count].class = UnitClass.Tank
								units[units.count].priority = 1
						elseif line:find("b[(]v5[)]") or line:find("b[(]vet[)]") then 
								-- if verbose then print(unit, " read as anti-tank, p:",cost) end
								units[units.count].class = UnitClass.ATTank
								units[units.count].priority = 1
						end
						units.count=units.count+1
					end
				end
				--if verbose then print(units[units.count-1].unit, " read as ",units[units.count-1].class.className, " squad of ", count, " costs ", units[units.count-1].cost, " charge/initial ", charge, wait_at_quant) end
			end
		end
		io.close(f) 
	end
end

function getFlagPriority(flag)
	if	   flag.occupant==BotApi.Instance.team 	    then return FlagPriority.Captured
	elseif flag.occupant==BotApi.Instance.enemyTeam then return FlagPriority.Enemy
	else 							  				   	 return FlagPriority.Neutral end
end

function getFlagToCapture(flagPoints)
	local flags_and_priorities = {}
	local max=0
	local getFP = getFlagPriority								-- Optimisation thing here.

	for i, flag in pairs(flagPoints) do
		local cur=math.random(80)
		if cur>max then
			max=cur
		end
		table.insert(flags_and_priorities, {name=flag, priority=cur})
	end

	local length = #flags_and_priorities
	local lim=0
	local min=math.floor(length/3)
	for i, flag in pairs(flags_and_priorities) do
		if flag.priority==max then
			local t=math.random(lim, length)
			if t>min then
				return flag.name
			else
				lim=lim+1
			end
		end
	end
	for i, flag in pairs(flags_and_priorities) do
	    return flag.name
	end
end

function getFlagTable()
	local team_my=BotApi.Instance.team
	local team_enemy=BotApi.Instance.enemyTeam

	local flags = {captured=0, enemy=0, neutral=0}
	for i, flag in pairs(BotApi.Scene.Flags) do
		if 	   flag.occupant == team_my    then flags.captured = flags.captured+1
		elseif flag.occupant == team_enemy then flags.enemy    = flags.enemy+1
		else 									flags.neutral  = flags.neutral+1 end
	end

	return flags
end

function getUnitPriority(unit, enemy_has_tanks, flags)
	if unit.class==UnitClass.Infantry  and enemy_has_tanks		   then return 5 end
	if unit.class==UnitClass.Vehicle   and flags.neutral>0 		   then return 3 end
	if unit.class==UnitClass.Tank      and enemy_has_tanks		   then return 2 end
	if unit.class==UnitClass.HeavyTank and flags.enemy==0  		   then return 2 end
	if unit.class==UnitClass.Hero 	   and unit.cost<SpecialPoints then return 2 end

	if unit.class==UnitClass.HeavyTank and flags.captured<flags.enemy then
		return 3
	end

	if unit.class==ATInfantry then
		if enemy_has_tanks then
		 	return 4
		else
			return 1
		end
	end
	if unit.class==UnitClass.ATTank then
		if enemy_has_tanks then
		 	return 2
		else
			return 1
		end
	end

	return unit.priority
end

function getUnitToSpawn(units)
	if not units then
		return nil
	end
	
	local units_to_spawn={}
	local team_size=BotApi.Instance.teamSize
	local income, enemy_has_tanks, current_flags = BotApi.Commands:Income(BotApi.Instance.playerId), BotApi.Commands:EnemyHasTanks(), getFlagTable()
	local quants, updateTU, getUP = Quants, updateTimedUnits, getUnitPriority -- Some optimisation things here.
	local formula=(374*income-31.3*income*income+1.1*income*income*income-1.3) + (354.5*team_size-23*team_size*team_size-342)

	local total_rate=1
	for i, unit in pairs(units) do
		if type(unit)~="table" then
			break
		end

		if formula >= unit.cost and quants>unit.wait_at_quant then	-- Formulas
			if unit.charge>25 then
				if updateTU(unit)==0 then
					goto continue
				end
			end

			local rate = getUP(unit, enemy_has_tanks, current_flags)
			total_rate=total_rate+rate
			if rate>0 then
				table.insert(units_to_spawn, {u=unit, r=rate})
			end
		end
		::continue::
	end

	if #units_to_spawn == 0 then
		return nil
	end
	
	local selected_unit
	local rnd = math.floor(math.random()*total_rate)
	for i, unit in pairs(units_to_spawn) do
		rnd=rnd - unit.r
		if rnd < 1 then
			selected_unit=unit
			break
		end
	end
	if selected_unit.u.charge>25 then
		addTimedUnit(selected_unit.u)
	end
	if selected_unit.u.class==Hero then
		SpecialPoints=SpecialPoints-selected_unit.u.cost
	end

	return selected_unit.u
end

function onGameStart()
	math.randomseed(os.time()*BotApi.Instance.hostId)
	Quants=0

	local units={}
	units.count=1

	readAllUnits(sq, units, BotApi.Instance.army)

	Context.Purchase=units
	Context.SpawnInfo=getUnitToSpawn(Context.Purchase)
end

function onGameStop()
	for squad, timer in pairs(Context.SquadTimers) do
		if timer then
			BotApi.Events:KillQuantTimer(timer)
		end
	end
	collectgarbage("collect")		-- Maybe gc helps a little the game engine not to run out of memory after multiple games. At least i hope so...
end

function onGameQuant()
	Quants=Quants+1
	if not Context.SpawnInfo or BotApi.Commands:Spawn(Context.SpawnInfo.unit, MaxSquadSize) then
		Context.SpawnInfo=getUnitToSpawn(Context.Purchase)
	end
	
	for i, squad in pairs(BotApi.Scene.Squads) do
		if not Context.SquadTimers[squad] then
			setSquadOrder(captureFlag, squad, OrderRotationPeriod)
		end
	end
end

function captureFlag(squad)
	local flag = getFlagToCapture(BotApi.Scene.Flags)
	if flag then
		BotApi.Commands:CaptureFlag(squad, flag.name)
	end
end

function setSquadOrder(order, squad, delay)
	order(squad)
	local setTimer=function(callback)
		Context.SquadTimers[squad]=BotApi.Events:SetQuantTimer(function()
				order(squad)
				Context.SquadTimers[squad]=nil
				if BotApi.Scene:IsSquadExists(squad) then
					callback(callback)
				end
			end, delay)
	end
	setTimer(setTimer)
end

function onGameSpawn(args)
	setSquadOrder(captureFlag, args.squadId, OrderRotationPeriod)
end

BotApi.Events:Subscribe(BotApi.Events.GameStart, onGameStart)
BotApi.Events:Subscribe(BotApi.Events.GameEnd, onGameStop)
BotApi.Events:Subscribe(BotApi.Events.Quant, onGameQuant)
BotApi.Events:Subscribe(BotApi.Events.GameSpawn, onGameSpawn)
