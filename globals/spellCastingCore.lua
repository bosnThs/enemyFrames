local castsList = {}
local buffsList = {}

local playerName = UnitName'player'

local removeExpiredTableEntries = function(currentTime, tab)
	local newTable = {}
	if tab then
		for k, e in pairs(tab) do
			if currentTime < e.timeEnd then
				newTable[k] = e
			end
		end
	end
	return newTable
end

local tablesMaintenance = function(reset)
	if reset then
		castsList = {} buffsList = {}
	else
		local currentTime = GetTime()
		-- CASTS
		castsList = removeExpiredTableEntries(currentTime, castsList)
		-- BUFFS
		for k, e in pairs(buffsList) do
			buffsList[k] = removeExpiredTableEntries(currentTime, buffsList[k])			
		end
	end
end
-----handle cast subfunctions-----------------------------------------------
---------------------------------------------------------------------------
local newCast = function(a_source, a_dest, a_spellID, a_spellSchool)
	local currentTime = GetTime()
	local spellData = {}
	spellData.caster 		= a_source
	spellData.target 		= a_dest and a_dest
	
	local name, _, icon, cost, isFunnel, _, castTimeMS = GetSpellInfo(a_spellID)
	
	--if isFunnel then print(name .. ' is funnel') end
	local castTime = castTimeMS / 1000	-- comes in ms
	local inverse = false
	local interrupt = true
	if SPELLINFO_CHANNELED_SPELLCASTS_TO_TRACK[name] then
		castTime = SPELLINFO_CHANNELED_SPELLCASTS_TO_TRACK[name]['casttime']
		inverse = true
		if(SPELLINFO_CHANNELED_SPELLCASTS_TO_TRACK[name]['immune']) then 
			interrupt = false
		else
			interrupt = true
		end
			
	end
	if SPELLINFO_SPELLCASTS_TO_TRACK[name] then
		--interrupt = SPELLINFO_SPELLCASTS_TO_TRACK[name]['immune'] and false or true
		if(SPELLINFO_SPELLCASTS_TO_TRACK[name]['immune']) then 
			interrupt = false
		else
			interrupt = true
		end
		--spellData.class 		= SPELLINFO_SPELLCASTS_TO_TRACK[name]['class'] and SPELLINFO_SPELLCASTS_TO_TRACK[name]['class'] or nil
	end
	if castTime == 0 then return end
	
	spellData.spell 		= name
	spellData.icon 			= icon
	spellData.timeStart 	= currentTime
	spellData.timeEnd 		= currentTime + castTime
	spellData.school 		= a_spellSchool and RGB_SPELL_SCHOOL_COLORS[a_spellSchool]
	spellData.inverse    	= inverse
	spellData.interruptable	= interrupt
	
	castsList[a_source] = spellData
	
	if playerName == spellData.target then
		print(spellData.caster .. ' - ' .. spellData.spell .. ' > ' .. playerName)
		INCOMINGSPELLSaddEntry(spellData.caster, spellData.spell)
	end
end

local removeCast = function(a_caster)
	if castsList[a_caster] then
		castsList[a_caster].timeEnd = castsList[a_caster].timeStart
	end
end

local removeChanneledCast = function(a_source, a_dest, a_spell)
	if castsList[a_caster] and castsList[a_caster].target == a_dest and castsList[a_caster].spell == a_spell then
		castsList[a_caster].timeEnd = castsList[a_caster].timeStart
		parsingCheck(false, true)
	end
end

-----handle buff subfunctions-----------------------------------------------
---------------------------------------------------------------------------
local newBuff = function(a_source, a_dest, a_spellID)
	local currentTime = GetTime()
	local newBuff = {}
	
	newBuff.caster 		= a_source and a_source
	newBuff.target 		= a_dest and a_dest
	local name, _, icon, cost, isFunnel, _, castTimeMS = GetSpellInfo(a_spellID)
	
	local buffData = SPELLINFO_BUFFS_TO_TRACK[name]
	if not buffData or not buffData['prio'] then return end
	--if not buffData['prio'] then return end
	
	newBuff.buff 		= name
	newBuff.icon 		= icon
	newBuff.prio		= buffData['prio']
	newBuff.border		= buffData['type'] and RGB_BORDER_DEBUFFS_COLOR[buffData['type']] or {.1, .1, .1}
	newBuff.timeStart 	= currentTime
	newBuff.timeEnd 	= currentTime + buffData['duration']
	
	buffsList[a_dest] = buffsList[a_dest] and buffsList[a_dest] or {}
	buffsList[a_dest][name] = newBuff
end

local removeBuff = function(a_source, a_dest, a_spell)
	if buffsList[a_dest] and buffsList[a_dest][a_spell] then
		buffsList[a_dest][a_spell].timeEnd = buffsList[a_dest][a_spell].timeStart
	end
end
----------------------------------------------------------------------------
local parsingCheck = function(out, display)
	if (not out) and display then
		print('Parsing failed:')
		print(event)	-- COMBAT_LOG_EVENT_UNFILTERED
		print(arg1)		-- timestamp
		print(arg2)		-- event
		print(arg3)		-- source GUID
		print(arg4)		-- source
		print(arg5)		-- source flags
		if not arg6 then return end
		print(arg6)		-- destination GUID
		print(arg7)		-- destination
		print(arg8)		-- destination flags
		print(arg9)		-- spellID
		print(arg10)	-- spellname
		print(arg11)	-- spellschool
	end
end

local combatLogParserFunctions = {
	['SPELL_CAST_START'] = function()
		newCast(arg4, arg7, arg9, arg11)
	end,
	['SPELL_CAST_FAILED'] = function()
		removeCast(arg4)
		--print( arg4 .. ' failed ' .. arg10)
		--parsingCheck(false, true)
	end,
	['SPELL_CAST_FAILED_FULL_TEXT'] = function()
		removeCast(arg4)
		print( arg4 .. ' failed ' .. arg2)
		--parsingCheck(false, true)
	end,
	['SPELL_CAST_SUCCESS'] = function()
		newCast(arg4, arg7, arg9, arg11)
	end,
	['SPELL_CAST_CHANNELED'] = function()
		print('channeling')
		--parsingCheck(false, true)
	end,
	['SPELL_AURA_APPLIED'] = function()
		--print(arg4 .. ' - ' .. arg9 .. ' > ' .. arg7)
		newBuff(arg4, arg7, arg9)
		--parsingCheck(false, true)
	end,
	['SPELL_AURA_REMOVED'] = function()
		removeChanneledCast(arg4, arg7, arg10)
		removeBuff(arg4, arg7, arg10)
	end,
}

local removeFinishedCast = function(a_source, a_spell)
	if castsList[a_source] and castsList[a_source].spell == a_spell then
		removeCast(a_source)
		parsingCheck(false, true)
		return true
	end
	return false
end

local combatlogParser = function()
	if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		if combatLogParserFunctions[arg2] then
			combatLogParserFunctions[arg2]()
		else
			--if not removeFinishedCast(arg4, arg10) then
			--	parsingCheck(false, false)
			--end
			parsingCheck(false, false)
		end
	end
end

-- GLOBAL ACCESS FUNCTIONS

SPELLCASTINGCOREgetCast = function(a_caster)
	if not a_caster then return nil end
	return castsList[a_caster]
end

SPELLCASTINGCOREupdateCast = function(a_caster, a_timeEnd, a_interrupt, a_spellTarget)
	if not a_caster then return end
	if castsList[a_caster] then
		castsList[a_caster].timeEnd 		= a_timeEnd
		castsList[a_caster].interruptable	= a_interrupt
		if a_spellTarget and not castsList[a_caster].target then 
			castsList[a_caster].target = a_spellTarget			
			
			if a_spellTarget == playerName then
				print(castsList[a_caster].caster .. ' - ' .. castsList[a_caster].spell .. ' > ' .. playerName)
				INCOMINGSPELLSaddEntry(castsList[a_caster].caster, castsList[a_caster].spell)
			end
		end
	end
end

SPELLCASTINGCOREremoveCast = function(a_caster)
	if not a_caster then return end
	removeCast(a_caster)
end

SPELLCASTINGCOREgetSetBuffs = function(a_source, a_buffList)
	buffsList[a_source] = a_buffList
end


local function sortPriobuff(tab, e)
	for k, v in pairs(tab) do
		if e.prio > v.prio then	
			table.insert(tab, k, e)
			return tab
		end
	end
	table.insert(tab, e)
	return tab
end

SPELLCASTINGCOREgetPrioBuff = function(a_source)
	if not a_source then return nil end
	local buffs = buffsList[a_source]
	if not buffs then return nil end
	
	local prioList = {}
	for i, e in pairs(buffs) do
		prioList = sortPriobuff(prioList, e)
	end
	
	return prioList
end
------------------------------------

local f = CreateFrame('Frame', 'spellCastingCore', UIParent)
f:SetScript('OnUpdate', function()
	tablesMaintenance(false)
end)

f:RegisterEvent'PLAYER_ENTERING_WORLD'
--f:RegisterEvent'CHAT_MSG_MONSTER_EMOTE'
f:RegisterEvent'COMBAT_LOG_EVENT_UNFILTERED'

--f:RegisterAllEvents()
--f:UnregisterEvent'CHAT_MSG_CHANNEL'

f:SetScript('OnEvent', function()
	if event == 'PLAYER_ENTERING_WORLD' then
		tablesMaintenance(true)
	else 
		combatlogParser()
	end
end)

--
	
SLASH_PROCESSCAST1 = '/pct'
SlashCmdList["PROCESSCAST"] = function(msg)
	for k, v in pairs(buffList) do
		print(v.caster .. ' ' .. v.spell)
	end
	print(' test')
end