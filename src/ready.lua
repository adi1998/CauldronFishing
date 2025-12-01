---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

mod.hectateFishingSuccessReactions = {
	{
		RandomRemaining = true,
		PreLineWait = 0.65,
		ChanceToPlay = 1,
		AllowTalkOverTextLines = true,
		Queue = "Interrupt",
		ObjectType = "NPC_Hecate_01",
		Cooldowns =
			{
			},
		GameStateRequirements = {
			{
				FunctionName = "RequiredAlive",
				FunctionArgs = { Units = { "NPC_Hecate_01", }, Alive = true },
			}
		},
		-- Source = { LineHistoryName = "NPC_Hecate_01", SubtitleColor = Color.HecateVoice },
		{ Cue = "/VO/Hecate_0610", Text = "You'd use our cauldron thus?" },
		{ Cue = "/VO/Hecate_0611", Text = "An odd use of our craft." },
		{ Cue = "/VO/Hecate_0613", Text = "A Witch ought to eat..." },
		{ Cue = "/VO/Hecate_0386", Text = "And caught." },
		{ Cue = "/VO/Hecate_0691", Text = "See that, Sisters?" },
		{ Cue = "/VO/Hecate_0331", Text = "You've done it..." },
		{ Cue = "/VO/Hecate_0362", Text = "Find anything good?" },
	}
}

mod.hectateFishingFailureReactions = {
	{
		RandomRemaining = true,
		PreLineWait = 0.65,
		ChanceToPlay = 1,
		AllowTalkOverTextLines = true,
		Queue = "Interrupt",
		ObjectType = "NPC_Hecate_01",
		Cooldowns =
			{
			},
		GameStateRequirements = {
			{
				FunctionName = "RequiredAlive",
				FunctionArgs = { Units = { "NPC_Hecate_01", }, Alive = true },
			}
		},
		{ Cue = "/VO/Hecate_0391", Text = "Alas" },
		{ Cue = "/VO/Hecate_0393", Text = "Outmaneuvered..." },
		{ Cue = "/VO/Hecate_0390", Text = "{#Emph}Mm, tsk-tsk-tsk." },
		{ Cue = "/VO/Hecate_0123", Text = "Try something else!" },
		{ Cue = "/VO/Hecate_0362", Text = "Find anything good?" },
		{ Cue = "/VO/Hecate_0479", Text = "So it goes at times." },
	}
}

function mod.SpawnCauldronFishing()
	local LidId = game.GetIdsByType({Name = "CrossroadsCauldronLid01"})

	if game.CurrentHubRoom.Name == "Hub_Main" and #LidId == 0 then
		mod.CauldronId = 558175 -- CriticalItemWorldObject01
		local offsetY = -110
		local offsetX = 5
		mod.FishingPointId = game.SpawnObstacle({Name="FishingPoint", DestinationId=mod.CauldronId, OffsetY=offsetY, Scale=0.2, OffsetX = offsetX})
		table.insert(game.GlobalVoiceLines.FishNotCaughtReactionLines,mod.hectateFishingFailureReactions)
	end
end

function mod.PlayHecateSuccessVO()
	print("HecateSuccessVO")
	game.thread(game.PlayVoiceLines, mod.hectateFishingSuccessReactions, true)
end

modutil.mod.Path.Wrap("StartDeathLoopPresentation", function(base, currentRun)
	mod.SpawnCauldronFishing()
	base(currentRun)
end)

modutil.mod.Path.Wrap("EnterHubRoomPresentation", function(base, currentRun, currentRoom)
	print("fishing state:",game.CurrentRun.Hero.FishingState)
	if game.CurrentRun.Hero.FishingState == nil then
		mod.SpawnCauldronFishing()
	end
    base(currentRun, currentRoom)
end)

function mod.CheckForNoGifting()
	local inactiveFishingPoints = game.GetInactiveIdsByType({Name = "FishingPoint"})
	print("idlen", #inactiveFishingPoints)
	local isGiftingActive = false
	local GiftingFishingId = 585640
	return game.Contains(inactiveFishingPoints, GiftingFishingId)
end

function mod.CheckCauldronFishing()
	return game.CurrentHubRoom ~= nil and game.CurrentHubRoom.Name == "Hub_Main" and mod.CheckForNoGifting()
end

function GetKeysFromTable(list)
    local retval = {}
    for key, _ in pairs(list) do
        table.insert(retval, key)
    end
    return retval
end

modutil.mod.Path.Wrap("GetCurrentFishingBiomeName", function(base)
	if mod.CheckCauldronFishing() then
		mod.PlayHecateSuccessVO()
		local FishBiomeList = GetKeysFromTable(game.FishingData.BiomeFish)
		local randomIndex = math.random(1, #FishBiomeList)
		local randomFishBiome = FishBiomeList[randomIndex]
		print("fishbiome:", randomFishBiome)
		return randomFishBiome
	end
	return base()
end)

modutil.mod.Path.Wrap("FishingStartPresentation", function(base,source,args)
	if args["FishingPointId"] == mod.FishingPointId then
		modutil.mod.Path.Wrap("AngleTowardTarget", function(base,args)
			if args["DestinationId"] == mod.FishingPointId then
				base({ Id = game.CurrentRun.Hero.ObjectId, DestinationId = mod.CauldronId })
			else
				base(args)
			end
		end)
	end
	base(source,args)
end)
