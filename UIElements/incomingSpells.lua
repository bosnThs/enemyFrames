	-------------------------------------------------------------------------------
	local playerName = UnitName'player'
	local enabled, refresh = false, true
	local refreshInterval, nextRefresh = 1/60, 0
	
	local unitsLimit, units = 3, {}
	local playerCastList = {}
	local BACKDROP 	= {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],}
	local frameMovable = false
	-------------------------------------------------------------------------------
	local 	incFrame = CreateFrame('Frame',"incFrame", UIParent)
			incFrame:ClearAllPoints()
			incFrame:SetPoint('CENTER', UIParent, 0, 270)
			incFrame:SetWidth(160)
			incFrame:SetHeight(20)
			
			incFrame:SetMovable(true)
			incFrame:SetClampedToScreen(true)
			
			incFrame:SetScript('OnDragStart', function() if frameMovable then this:StartMoving() end end)
			incFrame:SetScript('OnDragStop', function() if frameMovable then  this:StopMovingOrSizing() end end)
			incFrame:RegisterForDrag('LeftButton')
			
			incFrame:SetBackdrop(BACKDROP)
			incFrame:SetBackdropColor(0, 0, 0, 0) 
			
			incFrame.border = CreateBorder(nil, incFrame, 16)
			incFrame.border:Hide()
			
			incFrame.title = incFrame:CreateFontString(nil, 'OVERLAY')
			incFrame.title:SetFont(STANDARD_TEXT_FONT, 14, 'OUTLINE')
			incFrame.title:SetPoint('CENTER', incFrame, 'CENTER', 0, 3)
			incFrame.title:SetText('')
	-------------------------------------------------------------------------------
	for i=1,unitsLimit do
		units[i] = CreateIncomingSpellsFrame(incFrame)
		units[i]:SetPoint('TOP', i == 1 and incFrame or units[i-1].arrow,'BOTTOM', 0, -6)
		units[i]:Hide()
	end
	-------------------------------------------------------------------------------
	local incomingSpellsOnUpdate = function()
		local newTable = {}		
		for k, v in ipairs(playerCastList) do
			v['castinfo'] = SPELLCASTINGCOREgetCast(v['name'])
			if not v['castinfo'] or v['castinfo'].spell ~= v['spell'] then
				if not v['castinfo'] then print(v['name'] .. ' no castinfo') end
				if v['castinfo'] and v['castinfo'].spell ~= v['spell'] then print(v['name'] .. ' ' .. v['castinfo'].spell .. ' ~= ' .. v['spell']) end
				refresh = true
			else
				table.insert(newTable, v)			
			end
		end
		playerCastList = newTable	
		
		-- draw elements	
		for i = 1, unitsLimit do
			if playerCastList[i] then
				local c = playerCastList[i]['castinfo']
				if c then
					if refresh then
						units[i].icon:SetTexture(c.icon)
						units[i].caster:SetText(c.caster)
						
						if c.class then
							local colour = RAID_CLASS_COLORS[c.class]
							units[i].caster:SetTextColor(colour.r, colour.g, colour.b)
						end
						
						units[i].arrow:SetMinMaxValues(0, c.timeEnd - c.timeStart)
						if c.school then
							units[i].arrow:SetStatusBarColor(c.school[1], c.school[2], c.school[3])
							units[i].arrow.bg:SetVertexColor(c.school[1] - .4, c.school[2] - .4, c.school[3] - .4)
						end
						
						--units[i].button.target = c.caster
						units[i].button:SetAttribute("macrotext1", '/targetexact ' .. c.caster)
						
						units[i]:Show()
					else
						-- updates castbar value
						units[i].arrow:SetValue(mod(GetTime() - c.timeStart, c.timeEnd - c.timeStart))
					end
				end
			else
				units[i]:Hide()
			end
		end
		
		refresh = false
	end
	-------------------------------------------------------------------------------
	local removeDoubleEntry = function(c)
		local newTable = {}
		for k, e in ipairs(playerCastList) do
			if e['name'] ~= c then
				table.insert(newTable, e)
			end
		end
		playerCastList = newTable
	end
	local hideEntries = function()
		for i = 1, unitsLimit do
			units[i]:Hide()
		end
	end
	-------------------------------------------------------------------------------
	local eventHandler = function()
		if event == 'ZONE_CHANGED_NEW_AREA' then
			--incFrame:Hide()
			enabled = false
			incFrame:SetScript('OnUpdate', nil)
			hideEntries()
		end
	end
	-------------------------------------------------------------------------------
	incFrame:RegisterEvent'PLAYER_ENTERING_WORLD'
	incFrame:RegisterEvent'ZONE_CHANGED_NEW_AREA'
	incFrame:SetScript('OnEvent', eventHandler)
	
	-------------------------------------------------------------------------------
	local defaultValues = function(b)
		if b then incFrame.border:Show() else incFrame.border:Hide()	end
		incFrame:EnableMouse(b)
		incFrame:SetBackdropColor(0, 0, 0, b and .6 or 0)
		incFrame.title:SetText(b and 'incoming spells' or '')
		frameMovable = b
		for i=1,unitsLimit do
			units[i].icon:SetTexture([[Interface\Icons\Inv_misc_gem_sapphire_01]])
			units[i].caster:SetText(playerName)
			if b then units[i]:Show() else units[i]:Hide() end
		end
	end
	INCOMINGSPELLSsettings = function(b)
		defaultValues(b)
	end
	INCOMINGSPELLSinit = function(b)
		enabled = b
		if enabled then
			incFrame:SetScript('OnUpdate', function()
				nextRefresh = nextRefresh - arg1
				if nextRefresh < 0 then
					incomingSpellsOnUpdate()
					nextRefresh = refreshInterval
				end
			end)
		end
	end
	INCOMINGSPELLSaddEntry = function(a_caster, a_spell)
		if not ENEMYFRAMESPLAYERDATA['incomingSpells'] then return end
	
		removeDoubleEntry(a_caster)
		local class
		local p = ENEMYFRAMECOREgetPlayer(a_caster)
		if p then class = p['class'] else return end
		print('added incoming spell')

		table.insert(playerCastList, {['name'] = a_caster, ['spell'] = a_spell, ['class'] = class})
		refresh = true
	end
	-------------------------------------------------------------------------------