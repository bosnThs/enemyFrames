	-------------------------------------------------------------------------------
	local flagCarriers, fcTemp = {}, {}
	-------------------------------------------------------------------------------
	function WSGHANDLERsetFlagCarriers(fc)
		flagCarriers = fc
	end
	-------------------------------------------------------------------------------
	local eventHandler = function()

		if event ~= 'RAID_ROSTER_UPDATE' then
			-- Flag for Alliance flag for horde. thanks blizzard
			local pick 	= 'The (.+) (.+) was picked up by (.+)!'	local bpick  = string.find(arg1, pick)
			local drop 	= 'The (.+) (.+) was dropped by (.+)!'		local bdrop  = string.find(arg1, drop)
			local score = 'captured the (.+) (.+)!'					local bscore = string.find(arg1, score)
			
			if bpick then
				local flag 		= gsub(arg1, pick, '%1')
				local carrier 	= gsub(arg1, pick, '%3')
				
				flagCarriers[flag] = carrier
			end
			
			if bdrop then
				local flag 		= gsub(arg1, drop, '%1')
				
				flagCarriers[flag] = nil
			end
			
			if bscore then
				flagCarriers = {}
			end
			
			if bpick or bdrop or bscore then
				ENEMYFRAMECOREUpdateFlagCarriers(flagCarriers)
			end
		else
			fcTemp['Alliance'] = flagCarriers['Alliance'] 	and flagCarriers['Alliance'] 	or ' '
			fcTemp['Horde']    = flagCarriers['Horde'] 		and flagCarriers['Horde'] 		or ' '
			
			if flagCarriers['Alliance'] or  flagCarriers['Horde'] then
				sendMSG('EFC', fcTemp['Alliance'], fcTemp['Horde'], true)
			end
		end
	end
	-------------------------------------------------------------------------------
	local f = CreateFrame'Frame'
	f:RegisterEvent'PLAYER_ENTERING_WORLD'
	f:RegisterEvent'ZONE_CHANGED_NEW_AREA'
	f:RegisterEvent'CHAT_MSG_BG_SYSTEM_ALLIANCE' 
	f:RegisterEvent'CHAT_MSG_BG_SYSTEM_HORDE'
	f:RegisterEvent'RAID_ROSTER_UPDATE'
	f:SetScript('OnEvent', function()	if event == 'PLAYER_ENTERING_WORLD' or event == 'ZONE_CHANGED_NEW_AREA' then	flagCarriers = {}
										else	eventHandler()	end
							end)
	-------------------------------------------------------------------------------
	SLASH_WSGHANDLER1 = '/wsg'
	SlashCmdList["WSGHANDLER"] = function(msg)
		print('flags:')
		for k, v in pairs(flagCarriers) do
			print(k .. ' - ' .. v)
		end
	end