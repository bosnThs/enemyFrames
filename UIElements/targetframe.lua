	-------------------------------------------------------------------------------
	local raidTargetFrame = CreateFrame('Frame', nil, TargetFrame)
	raidTargetFrame:SetFrameLevel(2)
	raidTargetFrame:SetHeight(36)	raidTargetFrame:SetWidth(36)
	raidTargetFrame:SetPoint('CENTER', TargetPortrait, 'TOP')
	
	raidTargetFrame.icon = raidTargetFrame:CreateTexture(nil, 'OVERLAY')
	raidTargetFrame.icon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	raidTargetFrame.icon:SetAllPoints()
	-------------------------------------------------------------------------------
	local refreshInterval, nextRefresh = 1/60, 0
	local flagCarriers = {}
	local showText = true
	local targetPrioBuff
	-------------------------------------------------------------------------------
	local TEXTURE = [[Interface\AddOns\enemyFrames\globals\resources\barTexture.tga]]
    local BACKDROP = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],}
	
	TargetFrame.EFcast = CreateFrame('StatusBar', 'enemyFramesTargetFrameCastbar', TargetFrame)
    TargetFrame.EFcast:SetStatusBarTexture(TEXTURE)
    TargetFrame.EFcast:SetStatusBarColor(1, .4, 0)
    TargetFrame.EFcast:SetBackdrop(BACKDROP)
    TargetFrame.EFcast:SetBackdropColor(0, 0, 0)
    TargetFrame.EFcast:SetHeight(10)
	TargetFrame.EFcast:SetWidth(160)
	--TargetFrame.EFcast:ClearAllPoints()
	TargetFrame.EFcast:SetPoint('LEFT', TargetFrame, 'LEFT', 26, -45)
	
    TargetFrame.EFcast:SetValue(0)
    TargetFrame.EFcast:Hide()
	
	TargetFrame.EFcast:SetMovable(true) TargetFrame.EFcast:SetUserPlaced(true)
	TargetFrame.EFcast:SetClampedToScreen(true)
	TargetFrame.EFcast:RegisterForDrag'LeftButton' TargetFrame.EFcast:EnableMouse(true)
	local castbarmoveable = false
	TargetFrame.EFcast:SetScript('OnDragStart', function() if castbarmoveable then this:StartMoving() end end)
	TargetFrame.EFcast:SetScript('OnDragStop', function() if castbarmoveable then this:StopMovingOrSizing() end end)
	
	TargetFrame.EFcast.border = CreateBorder(nil, TargetFrame.EFcast, 6.5, 1/8.5)
	TargetFrame.EFcast.border:SetPadding(2.5, 1.7)
	
	TargetFrame.EFcast.spark = TargetFrame.EFcast:CreateTexture(nil, 'OVERLAY')
	TargetFrame.EFcast.spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	TargetFrame.EFcast.spark:SetHeight(26)	
	TargetFrame.EFcast.spark:SetWidth(26)
	TargetFrame.EFcast.spark:SetBlendMode('ADD')

    TargetFrame.EFcast.text = TargetFrame.EFcast:CreateFontString(nil, 'OVERLAY')
    TargetFrame.EFcast.text:SetTextColor(1, 1, 1)
    TargetFrame.EFcast.text:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
    --TargetFrame.EFcast.text:SetShadowOffset(1, -1)
    TargetFrame.EFcast.text:SetShadowColor(0, 0, 0)
    TargetFrame.EFcast.text:SetPoint('LEFT', TargetFrame.EFcast, 2, .5)
    TargetFrame.EFcast.text:SetText('drag-me')

    TargetFrame.EFcast.timer = TargetFrame.EFcast:CreateFontString(nil, 'OVERLAY')
    TargetFrame.EFcast.timer:SetTextColor(1, 1, 1)
    TargetFrame.EFcast.timer:SetFont(STANDARD_TEXT_FONT, 9, 'OUTLINE')
    --TargetFrame.EFcast.timer:SetShadowOffset(1, -1)
    TargetFrame.EFcast.timer:SetShadowColor(0, 0, 0)
    TargetFrame.EFcast.timer:SetPoint('RIGHT', TargetFrame.EFcast, -1, .5)
    TargetFrame.EFcast.timer:SetText'3.5s'

    TargetFrame.EFcast.icon = TargetFrame.EFcast:CreateTexture(nil, 'OVERLAY', nil, 7)
    TargetFrame.EFcast.icon:SetWidth(18) TargetFrame.EFcast.icon:SetHeight(16)
    TargetFrame.EFcast.icon:SetPoint('RIGHT', TargetFrame.EFcast, 'LEFT', -8, 0)
    TargetFrame.EFcast.icon:SetTexCoord(.1, .9, .15, .85)
	TargetFrame.EFcast.icon:SetTexture([[Interface\Icons\Inv_misc_gem_sapphire_01]])
	
	local ic = CreateFrame('Frame', nil, TargetFrame.EFcast)
    ic:SetAllPoints(TargetFrame.EFcast.icon)
	
	TargetFrame.EFcast.icon.border = CreateBorder(nil, ic, 12.8)
	TargetFrame.EFcast.icon.border:SetPadding(1)
	
	TargetFrame.IntegratedCastBar = CreateFrame('StatusBar', 'enemyFramesTargetFrameCastbar', TargetFrame)
    TargetFrame.IntegratedCastBar:SetStatusBarTexture(TEXTURE)
    TargetFrame.IntegratedCastBar:SetStatusBarColor(1, .4, 0)
    TargetFrame.IntegratedCastBar:SetBackdrop(BACKDROP)
    TargetFrame.IntegratedCastBar:SetBackdropColor(0, 0, 0, .9)
	TargetFrame.IntegratedCastBar:SetPoint('TOPLEFT', TargetFrameNameBackground, 'TOPLEFT')
	TargetFrame.IntegratedCastBar:SetPoint('BOTTOMRIGHT', TargetFrameNameBackground, 'BOTTOMRIGHT')
	TargetFrame.IntegratedCastBar:SetFrameLevel(1)
	TargetFrame.IntegratedCastBar:SetMinMaxValues(0, 10)
	TargetFrame.IntegratedCastBar:SetValue(6)
	--[[
	TargetFrame.IntegratedCastBar.bg = TargetFrame.IntegratedCastBar:CreateTexture(nil, 'ARTWORK')
	TargetFrame.IntegratedCastBar.bg:SetTexture(0, 0, 0, .7)
	TargetFrame.IntegratedCastBar.bg:SetAllPoints()	]]--
	
	TargetFrame.IntegratedCastBar.spark = TargetFrame.IntegratedCastBar:CreateTexture(nil, 'OVERLAY')
	TargetFrame.IntegratedCastBar.spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	TargetFrame.IntegratedCastBar.spark:SetHeight(34)--TargetFrameNameBackground:GetHeight())	
	TargetFrame.IntegratedCastBar.spark:SetWidth(32)
	TargetFrame.IntegratedCastBar.spark:SetBlendMode('ADD')
	
	TargetFrame.IntegratedCastBar.spellText = TargetFrame.IntegratedCastBar:CreateFontString(nil, 'OVERLAY')
    TargetFrame.IntegratedCastBar.spellText:SetTextColor(1, 1, 1)
    TargetFrame.IntegratedCastBar.spellText:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
    TargetFrame.IntegratedCastBar.spellText:SetShadowColor(0, 0, 0)
    TargetFrame.IntegratedCastBar.spellText:SetPoint('LEFT', TargetFrame.IntegratedCastBar, 1, .5)
    TargetFrame.IntegratedCastBar.spellText:SetText('Polymorph') 
	
	TargetFrame.IntegratedCastBar.timer = TargetFrame.IntegratedCastBar:CreateFontString(nil, 'OVERLAY')
    TargetFrame.IntegratedCastBar.timer:SetTextColor(1, 1, 1)
    TargetFrame.IntegratedCastBar.timer:SetFont(STANDARD_TEXT_FONT, 8, 'OUTLINE')
    TargetFrame.IntegratedCastBar.timer:SetShadowColor(0, 0, 0)
    TargetFrame.IntegratedCastBar.timer:SetPoint('RIGHT', TargetFrame.IntegratedCastBar, -2, .5)
    TargetFrame.IntegratedCastBar.timer:SetText'3.5s'
	-------------------------------------------------------------------------------
	local function round(num, idp)
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end
	local getTimerLeft = function(tEnd, l)
		local t = tEnd - GetTime()
		if not l then l = 3 end
		if t > l then return round(t, 0) else return round(t, 1) end
	end
	-------------------------------------------------------------------------------
	local showCast = function()
		if castbarmoveable then
			if ENEMYFRAMESPLAYERDATA['targetFrameCastbar'] then
				TargetFrame.EFcast:Show()
			else
				TargetFrame.EFcast:Hide()
			end
			if ENEMYFRAMESPLAYERDATA['integratedTargetFrameCastbar'] then
				TargetFrame.IntegratedCastBar:Show()
				--TargetFrameNameBackground:SetDrawLayer'BACKGROUND'
				TargetFrameNameBackground:SetAlpha(.3)
				--TargetName:Hide()	
			else
				TargetFrame.IntegratedCastBar:Hide()
				--TargetFrameNameBackground:SetDrawLayer'BORDER'
				TargetFrameNameBackground:SetAlpha(1)
				--TargetName:Show()
			end		
		else
			TargetFrame.EFcast:Hide()
			TargetFrame.IntegratedCastBar:Hide()
			--TargetFrameNameBackground:SetDrawLayer'BORDER'
			TargetFrameNameBackground:SetAlpha(1)
			--TargetName:Show()
		end
		if UnitExists'target' then
			local v = SPELLCASTINGCOREgetCast(UnitName'target')
			if v ~= nil then
				if GetTime() < v.timeEnd then
					TargetFrame.EFcast:SetMinMaxValues(0, v.timeEnd - v.timeStart)
					TargetFrame.IntegratedCastBar:SetMinMaxValues(0, v.timeEnd - v.timeStart)
					local sparkPosition
					if v.inverse then
						TargetFrame.EFcast:SetValue(mod((v.timeEnd - GetTime()), v.timeEnd - v.timeStart))
						TargetFrame.IntegratedCastBar:SetValue(mod((v.timeEnd - GetTime()), v.timeEnd - v.timeStart))
						
						sparkPosition = (v.timeEnd - GetTime()) / (v.timeEnd - v.timeStart)
					else
						TargetFrame.EFcast:SetValue(mod((GetTime() - v.timeStart), v.timeEnd - v.timeStart))
						TargetFrame.IntegratedCastBar:SetValue(mod((GetTime() - v.timeStart), v.timeEnd - v.timeStart))	

						sparkPosition = (GetTime() - v.timeStart) / (v.timeEnd - v.timeStart)
					end
					
					TargetFrame.EFcast.text:SetText(string.sub(v.spell, 1, 20))
					TargetFrame.IntegratedCastBar.spellText:SetText(string.sub(v.spell, 1, 15))
					TargetFrame.EFcast.timer:SetText(getTimerLeft(v.timeEnd)..'s')
					TargetFrame.IntegratedCastBar.timer:SetText(getTimerLeft(v.timeEnd)..'s')
					TargetFrame.EFcast.icon:SetTexture(v.icon)
					-- border colors
					--TargetFrame.EFcast.icon.border:SetColor(v.borderClr[1], v.borderClr[2], v.borderClr[3])
					--TargetFrame.EFcast.border:SetColor(v.borderClr[1], v.borderClr[2], v.borderClr[3])
					--
					-- spark
					if ( sparkPosition < 0 ) then
						sparkPosition = 0
					end
					TargetFrame.IntegratedCastBar.spark:SetPoint('CENTER', TargetFrame.IntegratedCastBar, 'LEFT', sparkPosition * TargetFrameNameBackground:GetWidth(), -1)
					TargetFrame.EFcast.spark:SetPoint('CENTER', TargetFrame.EFcast, 'LEFT', sparkPosition * TargetFrame.EFcast:GetWidth(), 0)
					--
					if ENEMYFRAMESPLAYERDATA['targetFrameCastbar'] then
						TargetFrame.EFcast:Show()
					end
					if ENEMYFRAMESPLAYERDATA['integratedTargetFrameCastbar'] then
						TargetFrame.IntegratedCastBar:Show()
						--TargetFrameNameBackground:SetDrawLayer'BACKGROUND'
						TargetFrameNameBackground:SetAlpha(.3)
						--TargetName:Hide()							
					end	
				end
			end
		end
    end
	-------------------------------------------------------------------------------
	TARGETFRAMEsetFC = function(fc)
		flagCarriers = fc
	end
	-------------------------------------------------------------------------------
	local targetDebuffFrame = CreateFrame('Frame', 'TargetPortraitDebuff', TargetFrame)
	targetDebuffFrame:SetFrameLevel(1)
	targetDebuffFrame:SetPoint('TOPLEFT', TargetFramePortrait, 'TOPLEFT', 7, -2)
	targetDebuffFrame:SetPoint('BOTTOMRIGHT', TargetFramePortrait, 'BOTTOMRIGHT', -5.5, 4)
	
	
	-- circle texture
	local targetPortraitbgFrame = CreateFrame('Frame', nil, targetDebuffFrame)
	targetPortraitbgFrame:SetFrameLevel(1)
	targetPortraitbgFrame:SetPoint('TOPLEFT', TargetFramePortrait, 'TOPLEFT', 7, -2)
	targetPortraitbgFrame:SetPoint('BOTTOMRIGHT', TargetFramePortrait, 'BOTTOMRIGHT', -5.5, 4)
	
	targetPortraitbgFrame.bgText = targetDebuffFrame:CreateTexture(nil, 'OVERLAY')
	targetPortraitbgFrame.bgText:SetPoint('TOPLEFT', TargetFramePortrait, 'TOPLEFT', 3.5, -4.5)
	targetPortraitbgFrame.bgText:SetPoint('BOTTOMRIGHT', TargetFramePortrait, 'BOTTOMRIGHT', -3.5, 2.5)
	targetPortraitbgFrame.bgText:SetVertexColor(.3, .3, .3)
	targetPortraitbgFrame.bgText:SetTexture([[Interface\AddOns\enemyFrames\globals\resources\portraitBg.tga]])
	-- debuff texture
	targetDebuffFrame.debuffText = targetDebuffFrame:CreateTexture(nil, 'OVERLAY')
	targetDebuffFrame.debuffText:SetPoint('TOPLEFT', TargetFramePortrait, 'TOPLEFT', 7.5, -8)
	targetDebuffFrame.debuffText:SetPoint('BOTTOMRIGHT', TargetFramePortrait, 'BOTTOMRIGHT', -7.5, 4.5)	
	targetDebuffFrame.debuffText:SetTexCoord(.12, .88, .12, .88)
	-- duration text
	local PlayerPortraitDurationFrame = CreateFrame('Frame', nil, targetDebuffFrame)
	PlayerPortraitDurationFrame:SetAllPoints()
	PlayerPortraitDurationFrame:SetFrameLevel(3)
	
	targetDebuffFrame.duration = PlayerPortraitDurationFrame:CreateFontString(nil, 'OVERLAY')--, 'GameFontNormalSmall')
	targetDebuffFrame.duration:SetFont(STANDARD_TEXT_FONT, 16, 'OUTLINE')
	targetDebuffFrame.duration:SetTextColor(.9, .9, .2, 1)
	targetDebuffFrame.duration:SetShadowOffset(1, -1)
	targetDebuffFrame.duration:SetShadowColor(0, 0, 0)
	targetDebuffFrame.duration:SetPoint('CENTER', TargetFramePortrait, 'CENTER', 0, -5)
	-- cooldown spiral
	targetDebuffFrame.cd = CreateFrame('Cooldown', nil, targetPortraitbgFrame)
	targetDebuffFrame.cd:SetPoint('TOPLEFT', TargetFramePortrait, 'TOPLEFT', 7.5, -8)
	targetDebuffFrame.cd:SetPoint('BOTTOMRIGHT', TargetFramePortrait, 'BOTTOMRIGHT', -7.5, 4.5)		
	targetDebuffFrame.cd:SetFrameLevel(2)
	targetDebuffFrame.cd:SetReverse(true)
	
	--TargetFrame:SetFrameLevel(0)
	-------------------------------------------------------------------------------
	local buffLimits = {MAX_TARGET_BUFFS, MAX_TARGET_DEBUFFS}
	local getPrioBuff = function(unit)
		local buffList = {}
		local ct = 1
		local prioIndex = 0
		local prioValue = 0
		local buff,debuffStack, debuffType, duration, expirationTime
	
		for i=1, 2 do
			for j=1, buffLimits[i] do
				if i == 1 then
					buff, _, _, debuffStack, debuffType, duration, expirationTime = UnitBuff(unit, j)
				else
					buff, _, _, debuffStack, debuffType, duration, expirationTime = UnitDebuff(unit, j)
				end
				
				if not buff then break end
				
				if getTimerLeft(expirationTime, 0) < 60 then
					local buffData = SPELLINFO_BUFFS_TO_TRACK[buff]
					if buffData and buffData['prio'] and buffData['prio'] > 0 and duration > 0 then				
						local buffEntry = {}
						buffEntry.buff 		= buff
						buffEntry.icon 		= buffData['icon']
						buffEntry.prio		= buffData['prio']
						buffEntry.border	= buffData['type'] and RGB_BORDER_DEBUFFS_COLOR[buffData['type']] or {.1, .1, .1}
						buffEntry.timeStart = expirationTime - duration
						buffEntry.timeEnd 	= expirationTime
						
						buffList[ct] 		= buffEntry
						
						if prioValue < buffEntry.prio then
							prioIndex = ct
							prioValue = buffEntry.prio
						end
						ct = ct + 1
						
					end
				end
			end
		end
		
		return buffList[prioIndex]
	end
	-------------------------------------------------------------------------------
	local a, maxa, b, c = .002, .058, 0, 1
	local showPortraitDebuff = function()
		if UnitExists'target' then
			local xtFaction = UnitFactionGroup'target' == 'Alliance' and 'Horde' or 'Alliance'
			local prioBuff = SPELLCASTINGCOREgetPrioBuff(UnitName'target')
			prioBuff = prioBuff and prioBuff[1] or nil

			if prioBuff then				
				local d = 1
				if b > maxa then c = -1 end
				if b < 0 then c = 1 end
				b = b + a * c 
				d = -b 
				
				--targetDebuffFrame.debuffText:SetTexCoord(.12+b, .88+d, .12+d, .88+b)
			
				targetDebuffFrame.debuffText:SetTexture(prioBuff.icon)
				targetDebuffFrame.duration:SetText(getTimerLeft(prioBuff.timeEnd))
				targetPortraitbgFrame.bgText:Show()
				targetDebuffFrame.cd:SetCooldown(prioBuff.timeStart, prioBuff.timeEnd - prioBuff.timeStart)
				targetDebuffFrame.cd:Show()
				
				local br, bg, bb = prioBuff.border[1], prioBuff.border[2], prioBuff.border[3]
				targetPortraitbgFrame.bgText:SetVertexColor(br, bg, bb)
				
			elseif UnitName'target' == flagCarriers[xtFaction] then
				targetDebuffFrame.debuffText:SetTexture(SPELLINFO_WSG_FLAGS[xtFaction]['icon'])
				targetPortraitbgFrame.bgText:Show()
				targetDebuffFrame.duration:SetText('')
				targetDebuffFrame.cd:Hide()
				targetPortraitbgFrame.bgText:SetVertexColor(.1, .1, .1)
				
			else
				targetDebuffFrame.cd:Hide()				
				targetDebuffFrame.debuffText:SetTexture()
				targetDebuffFrame.duration:SetText('')
				targetPortraitbgFrame.bgText:Hide()
			end			
		end
	end
	-------------------------------------------------------------------------------
	local function addExtras(button)
		if not button then return end
		if button.ft then return end
	
		button.ft = CreateFrame('Frame', button:GetName()..'TextFrame', button)
		button.ft:SetFrameLevel(4)
		button.ft:SetAllPoints()
		
		button.text = button.ft:CreateFontString(nil, 'OVERLAY')
		button.text:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
		button.text:SetTextColor(.9, .9, .2)
		button.text:SetShadowColor(0, 0, 0)
		button.text:SetPoint('CENTER', button, 'BOTTOM', 0, 1)	

		
		button.f = CreateFrame('Frame', button:GetName()..'CooldownFrame', button)
		button.f:SetAllPoints()
		
		--button.cd = CreateCooldown(button.f, .4, true)
		
		_G[button:GetName()..'Icon']:SetTexCoord(.05, .95, .05, .95)
		if _G[button:GetName()..'Count'] then
			_G[button:GetName()..'Count']:SetPoint('TOP', button, 'TOP', 0, -1)
		end
	end
	-------------------------------------------------------------------------------
	local limits = {MAX_TARGET_BUFFS, MAX_TARGET_DEBUFFS}
	local button, buttonName
	local debuff, debuffStack, debuffType, duration, expirationTime
	local function displayTimers(debuffList)
		
		for i=1, 2 do
			for j=1, limits[i] do
				if i == 1 then
					buttonName = 'TargetFrameBuff'..j
					debuff, _, _, debuffStack, debuffType, duration, expirationTime = UnitBuff('target', j)
				else
					buttonName = 'TargetFrameDebuff'..j
					debuff, _, _, debuffStack, debuffType, duration, expirationTime = UnitDebuff('target', j)
				end
				
				addExtras(_G[buttonName])		--buttons are created on aura update now
				button = _G[buttonName]
				if not debuff then break end
				if not button then break end
				
				button.text:Hide()
				
				if ENEMYFRAMESPLAYERDATA['targetDebuffTimers'] and getTimerLeft(expirationTime, 0) < 60 and duration > 0 then
					button.text:SetText(getTimerLeft(expirationTime, 0))	
					button.text:Show()
				end
			end
		end
	end
	-------------------------------------------------------------------------------
	local function raidTargetOnUpdate()
		local rt = ENEMYFRAMECOREGetRaidTarget()

		if UnitExists'target' and rt[UnitName'target'] then
			local tCoords = RAID_TARGET_TCOORDS[rt[UnitName'target']['icon']]
			raidTargetFrame.icon:SetTexCoord(tCoords[1], tCoords[2], tCoords[3], tCoords[4])
			raidTargetFrame:Show()
		else
			raidTargetFrame:Hide()
		end
	end
	-------------------------------------------------------------------------------	
	local dummyFrame = CreateFrame'Frame'
	dummyFrame:SetScript('OnUpdate', function()
		nextRefresh = nextRefresh - arg1
		if nextRefresh < 0 then
			if ENEMYFRAMESPLAYERDATA['targetFrameCastbar'] or ENEMYFRAMESPLAYERDATA['integratedTargetFrameCastbar'] then
				showCast()				
			else
				TargetFrame.EFcast:Hide()
				TargetFrame.IntegratedCastBar:Hide()	
				--TargetFrameNameBackground:SetDrawLayer'BORDER'
				TargetFrameNameBackground:SetAlpha(1)
				--TargetName:Show()				
			end
			if ENEMYFRAMESPLAYERDATA['targetPortraitDebuff'] then
				showPortraitDebuff()				
			else
				targetDebuffFrame.cd:Hide()				
				targetDebuffFrame.debuffText:SetTexture()
				targetDebuffFrame.duration:SetText('')
				targetPortraitbgFrame.bgText:Hide()
			end
			
			-- debuff timers
			if UnitExists('target') then
				displayTimers()
			end
			
			-- raidtarget
			raidTargetOnUpdate()
			
			nextRefresh = refreshInterval			
		end
	end)
	
	function TARGETFRAMECASTBARsettings(b)
		castbarmoveable = b
	end	
	-------------------------------------------------------------------------------
	local function eventHandler()
		--if (event == 'UNIT_AURA' and arg1 == 'target') or event == 'PLAYER_TARGET_CHANGED' then
		--	targetPrioBuff = getPrioBuff('target')
		--end
		if event == 'ZONE_CHANGED_NEW_AREA' then
			flagCarriers = {}
		end
	end
	-------------------------------------------------------------------------------
	dummyFrame:RegisterEvent'UNIT_AURA'
	dummyFrame:RegisterEvent'PLAYER_TARGET_CHANGED'
	dummyFrame:RegisterEvent'PLAYER_ENTERING_WORLD'
	dummyFrame:RegisterEvent'ZONE_CHANGED_NEW_AREA'
	dummyFrame:SetScript('OnEvent', eventHandler)
	