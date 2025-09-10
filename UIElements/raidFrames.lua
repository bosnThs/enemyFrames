	-------------------------------------------------------------------------------
	local addFlagIcon = function(raidIndexButton, flagTex)
		if raidIndexButton then
			raidIndexButton.flagFrame = CreateFrame('Frame', nil, raidIndexButton)
			raidIndexButton.flagFrame:SetFrameLevel(80)
			raidIndexButton.flagFrame.flagIcon = raidIndexButton.flagFrame:CreateTexture(nil, 'OVERLAY')
			raidIndexButton.flagFrame.flagIcon:SetWidth(24) raidIndexButton.flagFrame.flagIcon:SetHeight(24)
			raidIndexButton.flagFrame.flagIcon:SetPoint('CENTER', raidIndexButton, 0, -4)
			raidIndexButton.flagFrame.flagIcon:SetTexture(flagTex)
			raidIndexButton.flagFrame:Show()
		end
	end
	-------------------------------------------------------------------------------
	local hideFlagIcons = function()
		for i=1, NUM_RAID_PULLOUT_FRAMES do
			local frame = _G["RaidPullout"..i]
			for j=1, frame.numPulloutButtons do
				local raidIndexButton = _G[frame:GetName().."Button"..j]
				if raidIndexButton and raidIndexButton.flagFrame then raidIndexButton.flagFrame:Hide() end
			end
		end
	end
	local drawFlagIcon = function(flagCarrier, flagTex)	
		for i=1, NUM_RAID_PULLOUT_FRAMES do
			local frame = _G["RaidPullout"..i]
			for j=1, frame.numPulloutButtons do
				local raidIndexButton = _G[frame:GetName().."Button"..j]
				local unit = raidIndexButton.unit
				if UnitName(unit) == flagCarrier then					
					if raidIndexButton.flagIcon then
						raidIndexButton.flagFrame.flagIcon:SetTexture(flagTex)
						raidIndexButton.flagFrame:Show()
					else
						addFlagIcon(raidIndexButton, flagTex)
					end
				end
			end
		end
	end
	-------------------------------------------------------------------------------
	RAIDFRAMEUpdateFlagCarrier = function(fc)
		local of = UnitFactionGroup('player') == 'Alliance' and 'Horde' or 'Alliance'
		local flagTex = SPELLINFO_WSG_FLAGS[of]['worldFrameIcon']		
		local flagCarrier = fc[of] and fc[of] or ''
		
		hideFlagIcons()
		drawFlagIcon(flagCarrier, flagTex)
	end
	RAIDFRAMEhideFlagIcons = function()
		hideFlagIcons()
	end
	-------------------------------------------------------------------------------	