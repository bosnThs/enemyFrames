	-------------------------------------------------------------------------------
	local refreshInterval, nextRefresh = 1/60, 0
	local f = CreateFrame'Frame'
	-------------------------------------------------------------------------------
	local isPlate = function(frame)     
		local threatRegion, overlayRegion = frame:GetRegions()
		if not overlayRegion or overlayRegion:GetObjectType() ~= 'Texture' or overlayRegion:GetTexture() ~= [[Interface\Tooltips\Nameplate-Border]] then
			return false
		end
		return true
	end
	-------------------------------------------------------------------------------
	local addSmooth = function(plate)
		if not plate.smooth then
			local health = plate:GetChildren()
			SmoothBar(health)
			plate.smooth = true
		end
	end
	-------------------------------------------------------------------------------
	local addRaidTarget = function(plate, n, raidTargets)
		local _, _, name = plate:GetRegions()
		if not plate.raidTarget then
			-- create killtarget icon
			plate.raidTarget = plate:CreateTexture(nil, 'OVERLAY')
			plate.raidTarget:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
			plate.raidTarget:SetHeight(38)	plate.raidTarget:SetWidth(38)
			plate.raidTarget:SetPoint('BOTTOM', name, 'TOP', 0, 5)
		end
		
		if raidTargets[n] and ENEMYFRAMESPLAYERDATA['nameplatesRaidMarks'] then 
			local tCoords = RAID_TARGET_TCOORDS[raidTargets[n]['icon']]			
			plate.raidTarget:SetTexCoord(tCoords[1], tCoords[2], tCoords[3], tCoords[4])
			plate.raidTarget:Show() 
		else 
			plate.raidTarget:Hide() 
		end		
	end
	-------------------------------------------------------------------------------
	local function round(num, idp)
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end
	local getTimerLeft = function(tEnd)
		local t = tEnd - GetTime()
		if t > 3 then return round(t, 0) else return round(t, 1) end
	end
	-------------------------------------------------------------------------------
	local TEXTURE = [[Interface\TARGETINGFRAME\UI-StatusBar]]--[[Interface\AddOns\enemyFrames\globals\resources\barTexture.tga]]
	local BACKDROP = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],}
	local BORDER_TEXTURE = [[Interface\Tooltips\Nameplate-Border]]
	local SHIELD_TEXTURE = [[Interface\Tooltips\Nameplate-CastBar-Shield]]
	local addCastbar = function(plate, name, castInfo, isTarget, isTargetPlayer, castborder, shieldBorder, spellicon)
		local healthBar, originalCastBar  = plate:GetChildren()
		if not plate.castBar then
			
			plate.castBar = CreateFrame('StatusBar', nil, plate)
			plate.castBar:SetStatusBarTexture(TEXTURE)
			plate.castBar:SetStatusBarColor(0.1, 0.8, 0.1)
			plate.castBar:SetBackdrop(BACKDROP)
			plate.castBar:SetBackdropColor(0, 0, 0)
			plate.castBar:SetHeight(10)
			plate.castBar:SetPoint('LEFT', plate, 25, 0)
			plate.castBar:SetPoint('RIGHT', plate, -8, 0)
			plate.castBar:SetPoint('TOP', healthBar, 'BOTTOM', 0, -10)
			
			--plate.castBar.border = CreateBorder(nil, plate.castBar, 12)
			--plate.castBar.border:SetPadding(1.2)
			
			plate.castBar.border = plate.castBar:CreateTexture(nil, 'OVERLAY')
			plate.castBar.border:SetTexture(BORDER_TEXTURE)
			--plate.castBar.border:SetTexCoord(1, 0, 0, 1)
			plate.castBar.border:SetPoint('LEFT', plate, 0, 0)
			plate.castBar.border:SetPoint('TOP', healthBar, 'BOTTOM', 0, 12)
			plate.castBar.border:SetPoint('BOTTOMRIGHT', plate.castBar, 4, -4)
						
			plate.castBar.spark = plate.castBar:CreateTexture(nil, 'OVERLAY')
			plate.castBar.spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
			plate.castBar.spark:SetHeight(26)	
			plate.castBar.spark:SetWidth(26)
			plate.castBar.spark:SetBlendMode('ADD')

			plate.castBar.text = plate.castBar:CreateFontString(nil, 'OVERLAY')
			plate.castBar.text:SetTextColor(1, 1, 1)
			plate.castBar.text:SetFont(STANDARD_TEXT_FONT, 10) --, 'OUTLINE')
			plate.castBar.text:SetShadowOffset(1, -1)
			plate.castBar.text:SetShadowColor(0, 0, 0)
			plate.castBar.text:SetPoint('LEFT', plate.castBar, 2, 1)
			plate.castBar.text:SetText'Polymorph'

			plate.castBar.timer = plate.castBar:CreateFontString(nil, 'OVERLAY')
			plate.castBar.timer:SetTextColor(1, 1, 1)
			plate.castBar.timer:SetFont(STANDARD_TEXT_FONT, 9) --, 'OUTLINE')
			plate.castBar.timer:SetPoint('RIGHT', plate.castBar, -3, 0)
					
			plate.castBar.iconborder = CreateFrame('Frame', nil, plate.castBar)
			plate.castBar.iconborder:SetWidth(12) plate.castBar.iconborder:SetHeight(12)
			plate.castBar.iconborder:SetPoint('RIGHT', plate.castBar, 'LEFT', -5, 1)
			
			plate.castBar.icon = plate.castBar.iconborder:CreateTexture(nil, 'OVERLAY')--'OVERLAY', nil, 7)
			plate.castBar.icon:SetAllPoints()
			plate.castBar.icon:SetTexCoord(.078, .92, .079, .937)
			
			plate.castBar.icon:SetTexture([[Interface\Icons\Spell_nature_polymorph]])
			
			plate.castBar.iconborder.b = CreateBorder(nil, plate.castBar.iconborder, 6)

		end

		--plate.castBar:Show()
		plate.castBar:Hide()
		plate.castBar.text:Hide()
		
		if ENEMYFRAMESPLAYERDATA['nameplatesCastbar'] and _G['enemyFramesSettings']:IsShown() then
			plate.castBar:Show()
		end
		if ENEMYFRAMESPLAYERDATA['nameplatesCastbarText'] then
			plate.castBar.text:Show()
		end
		
		--castborder:Show()
		if isTarget and not isTargetPlayer then	return end		-- allow og castbar

		if ENEMYFRAMESPLAYERDATA['nameplatesCastbar'] then
			--local castInfo = SPELLCASTINGCOREgetCast(name)
			if not castInfo then castInfo = SPELLCASTINGCOREgetCast(name) end
			if castInfo then
			
				originalCastBar:Hide()		-- replaces og castbar
				castborder:Hide()
				shieldBorder:Hide()
				spellicon:Hide()
				
				local currentTime = GetTime()
				if  currentTime <= castInfo.timeEnd then
					plate.castBar:SetMinMaxValues(0, castInfo.timeEnd - castInfo.timeStart)
					local sparkPosition
					if castInfo.inverse then
						plate.castBar:SetValue(mod((castInfo.timeEnd - currentTime), castInfo.timeEnd - castInfo.timeStart))
						
						sparkPosition = (castInfo.timeEnd - currentTime) / (castInfo.timeEnd - castInfo.timeStart)
					else
						plate.castBar:SetValue(mod((currentTime - castInfo.timeStart), castInfo.timeEnd - castInfo.timeStart))

						sparkPosition = (currentTime - castInfo.timeStart) / (castInfo.timeEnd - castInfo.timeStart)
					end
					plate.castBar.text:SetText(castInfo.spell)
					plate.castBar.timer:SetText(getTimerLeft(castInfo.timeEnd)..'s')
					plate.castBar.icon:SetTexture(castInfo.icon)
					plate.castBar:SetAlpha(plate:GetAlpha())
					-- border colors
					--plate.castBar.iconborder.b:SetColor(castInfo.borderClr[1], castInfo.borderClr[2], castInfo.borderClr[3])
					--plate.castBar.border:SetVertexColor(castInfo.borderClr[1], castInfo.borderClr[2], castInfo.borderClr[3])
					if castInfo.interruptable then
						plate.castBar.border:SetTexture(BORDER_TEXTURE)
						plate.castBar.border:SetTexCoord(1, 0, 0, 1)
						plate.castBar.border:SetPoint('LEFT', plate, 0, 0)
						plate.castBar.border:SetPoint('TOP', healthBar, 'BOTTOM', 0, 12)
						plate.castBar.border:SetPoint('BOTTOMRIGHT', plate.castBar, 4, -4)						
					else		
						plate.castBar.border:SetTexture(SHIELD_TEXTURE)
						plate.castBar.border:SetTexCoord(0, 1, 0, 1)
						plate.castBar.border:SetPoint('LEFT', plate, 0, 0)
						plate.castBar.border:SetPoint('TOP', healthBar, 'BOTTOM', 0, 0)
						plate.castBar.border:SetPoint('BOTTOMRIGHT', plate.castBar, 4, -11)			
					end
					
					plate.castBar:SetStatusBarColor(0.9, 0.6, 0)	-- yellow while casting
					if (castInfo.timeEnd - currentTime) < 0.1 then
						plate.castBar:SetStatusBarColor(0.1, 0.8, 0.1)	-- green when finished casting
					end
					
					
					-- spark
					if ( sparkPosition < 0 ) then
						sparkPosition = 0
					end
					plate.castBar.spark:SetPoint('CENTER', plate.castBar, 'LEFT', sparkPosition * plate.castBar:GetWidth(), 0)
					--
					plate.castBar:Show()
				end
			end
		end

	end
	-------------------------------------------------------------------------------
	local addBuffs = function(plate, name)
		local maxBuffs = 4
		
		if not plate.buffs then			
			plate.buffs = {}
			for i = 1, maxBuffs do
				local buffWidth, buffHeight = 20, 18--20, 16
				
				plate.buffs[i] = CreateFrame('Frame', 'NamePlateBuff'..i, plate)
				plate.buffs[i]:SetWidth(buffWidth) plate.buffs[i]:SetHeight(buffHeight)
				plate.buffs[i]:SetFrameLevel(2)
				
				--scale
				plate.buffs[i]:SetScale(ENEMYFRAMESPLAYERDATA['plateDebuffSize'] and ENEMYFRAMESPLAYERDATA['plateDebuffSize'] or 1)
				
				if i == 1 then
					plate.buffs[i]:SetPoint('BOTTOMLEFT', plate, 'TOPLEFT', 5, 0)
				else
					plate.buffs[i]:SetPoint('LEFT', plate.buffs[i-1], 'RIGHT', 8, 0)
				end
						
				plate.buffs[i].border = CreateBorder(nil, plate.buffs[i], 12)
				plate.buffs[i].border:SetPadding(1.2)

				plate.buffs[i].icon = plate.buffs[i]:CreateTexture(nil, 'ARTWORK')
				plate.buffs[i].icon:SetAllPoints()
				plate.buffs[i].icon:SetTexCoord(.1, .9, .25, .75)
				plate.buffs[i].icon:SetTexture([[Interface\Icons\Spell_frost_frostnova]])

				plate.buffs[i].duration = plate.buffs[i].border:CreateFontString(nil, 'OVERLAY')--, 'GameFontNormalSmall')
				plate.buffs[i].duration:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
				plate.buffs[i].duration:SetTextColor(.9, .9, .2, 1)
				plate.buffs[i].duration:SetPoint('CENTER', plate.buffs[i], 'BOTTOM', 0, -2)
				plate.buffs[i].duration:SetText('8')
				
				-- cooldown
				--plate.buffs[i].cdframe = CreateFrame('Frame', 'platebuff'..i..'cdframe', plate.buffs[i])
				--plate.buffs[i].cdframe:SetWidth(buffWidth) plate.buffs[i].cdframe:SetHeight(buffHeight)
				--plate.buffs[i].cdframe:SetFrameLevel(1)
				--plate.buffs[i].cdframe:SetPoint('CENTER', plate.buffs[i], 0, -1)
				plate.buffs[i].cd = CreateCooldown(plate.buffs[i], .42, true)
				plate.buffs[i].cd:SetFrameLevel(3)
				plate.buffs[i].cd:SetAlpha(1)
				--plate.buffs[i].cd = CreateFrame('Cooldown', nil, plate.buffs[i])
				--plate.buffs[i].cd:SetAllPoints()
				--plate.buffs[i].cd:SetFrameLevel(2)
				--plate.buffs[i].cd:SetReverse(true)
			end
		end
		
        for i = 1, maxBuffs do
			if ENEMYFRAMESPLAYERDATA['nameplatesdebuffs'] and _G['enemyFramesSettings']:IsShown() then
				plate.buffs[i]:Show()
			else
				plate.buffs[i]:Hide()
			end
			if ENEMYFRAMESPLAYERDATA['plateDebuffSize'] and plate.buffs[i]:GetScale() ~= ENEMYFRAMESPLAYERDATA['plateDebuffSize'] then
				plate.buffs[i]:SetScale(ENEMYFRAMESPLAYERDATA['plateDebuffSize'])
			end
        end
		
		if ENEMYFRAMESPLAYERDATA['nameplatesdebuffs'] then
			local buffList = SPELLCASTINGCOREgetPrioBuff(name)
			--buffList = buffList and buffList[maxBuffs] or nil
			
			if not buffList then return end
			--local currentTime = GetTime()
			--local j = 1
			for i, e in ipairs(buffList) do
				if i > maxBuffs then break end
				if not e then break end
				plate.buffs[i]:Show()
				plate.buffs[i].icon:SetTexture(e.icon)
				plate.buffs[i].duration:SetText(getTimerLeft(e.timeEnd))

				local r, g, b = e.border[1], e.border[2], e.border[3]
				plate.buffs[i].border:SetColor( r, g, b)

				plate.buffs[i].cd:SetTimers(e.timeStart, e.timeEnd)
				--plate.buffs[i].cd:SetCooldown(e.timeStart, e.timeEnd - e.timeStart)
				plate.buffs[i].cd:Show()
				
				--if e.timeEnd < currentTime then
				--	i = i + 1
				--end				
			end
		end

	end
	-------------------------------------------------------------------------------
	local function namePlateHandlerOnUpdate()
		local nt, nmo = UnitName'target', UnitName'mouseover'
		local isTargetPlayer = UnitIsPlayer('target')
		local raidTargets = ENEMYFRAMECOREGetRaidTarget()
		local list = {}
		local frames = {WorldFrame:GetChildren()}
		for _, plate in ipairs(frames) do
			if isPlate(plate) and plate:IsVisible() then
				local healthBar = plate:GetChildren()
				local _, healthborder, castborder, shieldBorder, spellicon, highlight, name = plate:GetRegions()
				
				local n, h = name:GetText(), healthBar:GetValue()
				-- fills a list to help display accurate health values of enemies with visible plates
				-- redudant to include target and mouseover units
				if n ~= nt and n ~= nmo then
					list[n] = {['name'] = n, ['health'] = h}
				end
				
				-- additional nameplate elements
				local unit = ENEMYFRAMECOREgetPlayer(n)
				if unit then
					-- raid target
					addRaidTarget(plate, unit['name'], raidTargets)					
					
				elseif plate.raidTarget then
					plate.raidTarget:Hide()
				end
				
				local castData
				if unit then castData = unit['castData'] end
				-- castbar	
				addCastbar(plate, n, castData, n == nt, isTargetPlayer, castborder, shieldBorder, spellicon)

				-- buffs
				--if ENEMYFRAMESPLAYERDATA['nameplatesdebuffs'] then
					--local buffList
					--if unit then buffList = unit['buffList'] end
					addBuffs(plate, n)
				--end
				
				addSmooth(plate)
			end
		end
		
		-- check if table is not empty
		if next(list) ~= nil then
			ENEMYFRAMECORESetPlayersData(list)
		end
	end
	-------------------------------------------------------------------------------
	f:SetScript('OnUpdate', function()
		--nextRefresh = nextRefresh - arg1
		--if nextRefresh < 0 then
			namePlateHandlerOnUpdate()
			--nextRefresh = refreshInterval
		--end
	end)
	-------------------------------------------------------------------------------