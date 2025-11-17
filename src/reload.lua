---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,
-- 	so only assign to values or define things here.


function mod.SpawnCauldronFishing()
	local LidId = GetIdsByType({Name = "CrossroadsCauldronLid01"})

	if game.CurrentHubRoom.Name == "Hub_Main" and #LidId == 0 then
		local CauldronId = 558175 -- CriticalItemWorldObject01
		local offsetY = -110
		local offsetX = 10
		SpawnObstacle({Name="FishingPoint", DestinationId=CauldronId, OffsetY=offsetY, Scale=0.2})
	end
end

modutil.mod.Path.Wrap("StartDeathLoopPresentation", function(base, source, args)
	mod.SpawnCauldronFishing()
	base(source,args)
end)

modutil.mod.Path.Wrap("EnterHubRoomPresentation", function(base, source, args)
	print("fishing state:",game.CurrentRun.Hero.FishingState)
	local LidId = GetIdsByType({Name = "CrossroadsCauldronLid01"})
	if game.CurrentRun.Hero.FishingState == nil then
		mod.SpawnCauldronFishing()
	end
    base(source, args)
end)

modutil.mod.Path.Wrap("GetCurrentFishingBiomeName", function(base,source,args)
	if game.CurrentHubRoom ~= nil and game.CurrentHubRoom.Name == "Hub_Main" then
		local FishBiomeList = {"F","G","H","I","N","O","P","Q","Chaos"}
		local randomIndex = math.random(1, #FishBiomeList)
		local randomFishBiome = FishBiomeList[randomIndex]
		print("fishbiome:",randomFishBiome)
		return randomFishBiome
	end
	return base(source,args)
end)



