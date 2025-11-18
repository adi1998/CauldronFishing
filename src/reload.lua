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
		mod.FishingPointID = SpawnObstacle({Name="FishingPoint", DestinationId=CauldronId, OffsetY=offsetY, Scale=0.2})
	end
end

local hectateFishingSuccessReactions = {
	{
		RandomRemaining = true,
		PreLineWait = 0.35,
		ChanceToPlay = 1,
		GameStateRequirements = {
			{
				FunctionName = "RequiredAlive",
				FunctionArgs = { Units = { "NPC_Hecate_01", }, Alive = true },
			}
		},
		Source = { LineHistoryName = "NPC_Hecate_01", SubtitleColor = Color.HecateVoice },
		{ Cue = "/VO/Hecate_0610", Text = "You'd use our cauldron thus?" },
		{ Cue = "/VO/Hecate_0611", Text = "An odd use of our craft." },
		{ Cue = "/VO/Hecate_0613", Text = "A Witch ought to eat..." },
		{ Cue = "/VO/Hecate_0386", Text = "And caught." },
		{ Cue = "/VO/Hecate_0691", Text = "See that, Sisters?" },
		{ Cue = "/VO/Hecate_0331", Text = "You've done it..." },
		{ Cue = "/VO/Hecate_0362", Text = "Find anything good?" },
	}
}

local hectateFishingFailureReactions = {
	{
		RandomRemaining = true,
		PreLineWait = 0.35,
		ChanceToPlay = 1,
		GameStateRequirements = {
			{
				FunctionName = "RequiredAlive",
				FunctionArgs = { Units = { "NPC_Hecate_01", }, Alive = true },
			}
		},
		Source = { LineHistoryName = "NPC_Hecate_01", SubtitleColor = Color.HecateVoice },
		{ Cue = "/VO/Hecate_0613", Text = "Alas" },
		{ Cue = "/VO/Hecate_0393", Text = "Outmaneuvered..." },
		{ Cue = "/VO/Hecate_0390", Text = "{#Emph}Mm, tsk-tsk-tsk." },
		{ Cue = "/VO/Hecate_0123", Text = "Try something else!" },
		{ Cue = "/VO/Hecate_0362", Text = "Find anything good?" },
		{ Cue = "/VO/Hecate_0691", Text = "See that, Sisters?" },
		{ Cue = "/VO/Hecate_0479", Text = "So it goes at times." },
	}
}

function mod.PlayHecateFailureVO()

	print("HecateFailureVO")
	thread(PlayVoiceLines, hectateFishingFailureReactions, true)
	print("HecateFailureVO2")
end

function mod.PlayHecateSuccessVO()

	print("HecateSuccessVO")
	thread(PlayVoiceLines, hectateFishingSuccessReactions, true)
end

modutil.mod.Path.Wrap("UseFishingPoint", function(base, source, args)
	base(source,assert)
	if mod.CheckCauldronFishing() and game.CurrentRun.Hero.FishingState ~= nil and game.CurrentRun.Hero.FishingState ~= "Success" then
		mod.PlayHecateFailureVO()
	end
end)

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

function mod.CheckForNoGifting()
	local inactiveFishingPoints = GetInactiveIdsByType({Name = "FishingPoint"})
	print("idlen", #inactiveFishingPoints)
	local isGiftingActive = false
	local GiftingFishingId = 585640
	return Contains(inactiveFishingPoints, GiftingFishingId)
end

function mod.CheckCauldronFishing()
	return game.CurrentHubRoom ~= nil and game.CurrentHubRoom.Name == "Hub_Main" and mod.CheckForNoGifting()
end

modutil.mod.Path.Wrap("GetCurrentFishingBiomeName", function(base,source,args)
	if mod.CheckCauldronFishing() then
		mod.PlayHecateSuccessVO()
		local FishBiomeList = {"F", "G", "H", "I", "N", "O", "P", "Q", "Chaos"}
		local randomIndex = math.random(1, #FishBiomeList)
		local randomFishBiome = FishBiomeList[randomIndex]
		print("fishbiome:", randomFishBiome)
		return randomFishBiome
	end
	return base(source,args)
end)



