MaxSquadSize = 12
OrderRotationPeriod = 600000 -- 2 min; 1000 tic == 1 sec
FlagPriority = {Captured = 1, Enemy = 3, Neutral = 2}
SpecialPoints = 16

-- Work it harder, make it better!

UnitClass = {
	Infantry = "Infantry",
	Vehicle = "Vehicle",
	Tank = "Tank",
	ATTank = "ATTank",
	ATInfantry = "ATInfantry",
	HeavyTank = "HeavyTank",
	Hero = "Hero"
}


function readAllUnits(sq,units,army)
	local mod_folder_name = "nobody except us 2.0.26"				-- Mod folder name here.

	local path = "mods\\"..mod_folder_name.."\\resource\\set\\multiplayer\\units\\"	-- Path to units folder. Example: "mods\\"..mod_folder_name.."\\resource\\set\\multiplayer\\units\\"
														-- SET FOLDER MUST NOT BE ARCHIVED! EXTRACT IT TO RESOURCE FOLDER! Maybe this requirment will be removed soon.
	local army = BotApi.Instance.army
	--print(" parsing units for " .. army)

	local sq = path .. "units_nato.set"	
	readUnitsRaw(sq,units,army)
	local sq = path .. "units_ch.set"	
	readUnitsRaw(sq,units,army)
	local sq = path .. "units_rus.set"
	readUnitsRaw(sq,units,army)
	local sq = path .. "units_usa.set"
	readUnitsRaw(sq,units,army)
	local sq = path .. "units_nov.set"
	readUnitsRaw(sq,units,army)
	local sq = path .. "units_ukr.set"
	readUnitsRaw(sq,units,army)
	local sq = path .. "units_wagner.set"
	readUnitsRaw(sq,units,army)

	
	--print("Number of units read: ", units.count)
end