local E, L, V, P, G = unpack(select(2, ...))
local AB = E:GetModule('ActionBars')
local LSM = E.Libs.LSM

local unpack, ipairs, pairs = unpack, ipairs, pairs
local gsub, match = string.gsub, string.match
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver

local NUMMULTICASTBUTTONSPERPAGE = NUMMULTICASTBUTTONSPERPAGE or 4

-- bar is created unconditionally so the frame exists if CreateTotemBar runs
local bar = CreateFrame('Frame', 'ElvUIBarTotem', E.UIParent, 'SecureHandlerStateTemplate')
bar:SetFrameStrata('LOW')

local SLOTBORDERCOLORS = {
	summon   = {r=0,    g=0,    b=0   },
	EARTHTOTEMSLOT = {r=0.23, g=0.45, b=0.13},
	FIRETOTEMSLOT  = {r=0.58, g=0.23, b=0.10},
	WATERTOTEMSLOT = {r=0.19, g=0.48, b=0.60},
	AIRTOTEMSLOT   = {r=0.42, g=0.18, b=0.74},
}

local HAS_MULTICAST = function()
	return _G.MultiCastActionBarFrame
		and _G.MultiCastSummonSpellButton
		and _G.MultiCastRecallSpellButton
end


local function StyleTotemSlotSafe(button, slot)
	if not button then return end
	-- Only apply backdrop/template, skip overlay/background on Grimfall	
	local ok, err = pcall(function()
		button:SetTemplate('Default')
		button:StyleButton()
	end)	
	local color = SLOTBORDERCOLORS[slot]
	if color and button.backdrop then
		button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		button.ignoreBorderColors = true
	end
end

function AB:MultiCastFlyoutFrameOpenButtonShow(button, type, parent)
	if not button or not parent then return end
	local color = (type == 'page') and SLOTBORDERCOLORS.summon or SLOTBORDERCOLORS[parent:GetID()]
	if color and button.backdrop then
		button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
	end
	button:ClearAllPoints()
	if AB.db.barTotem.flyoutDirection == 'UP' then
		button:Point('BOTTOM', parent, 'TOP')
		if button.icon then button.icon:SetRotation(0) end
	elseif AB.db.barTotem.flyoutDirection == 'DOWN' then
		button:Point('TOP', parent, 'BOTTOM')
		if button.icon then button.icon:SetRotation(3.14) end
	end
end

function AB:MultiCastActionButtonUpdate(button, _, _, slot)
	if not button then return end
	local color = SLOTBORDERCOLORS[slot]
	if color and button.backdrop then
		button:SetBackdropBorderColor(color.r, color.g, color.b)
	end
	if InCombatLockdown() then
		bar.eventFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end
	button:ClearAllPoints()
	if button.slotButton then
		button:SetAllPoints(button.slotButton)
	end
end

function AB:StyleTotemSlotButton(button, slot)
	StyleTotemSlotSafe(button, slot)
end

function AB:SkinSummonButton(button)
	if not button then return end
	local name = button:GetName()
	if not name then return end
	local icon      = _G[name..'Icon']
	local highlight = _G[name..'Highlight']
	local normal    = _G[name..'NormalTexture']
	local ok = pcall(function()
		button:SetTemplate('Default')
		button:StyleButton()
		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer('ARTWORK')
			icon:SetInside(button)
		end
		if highlight then highlight:SetTexture(nil) end
		if normal then
			normal:SetTexture(nil)
			normal.SetTexture = E.noop
		end
	end)
	-- Silently skip on Grimfall if button type doesn't support this
end

function AB:MultiCastFlyoutFrameToggleFlyout(frame, type, parent)
	if not frame then return end
	if frame.top then frame.top:SetTexture(nil) end
	if frame.middle then frame.middle:SetTexture(nil) end
	local color = (type == 'page') and SLOTBORDERCOLORS.summon or SLOTBORDERCOLORS[parent and parent:GetID()]
	local numButtons = 0
	for i, button in ipairs(frame.buttons or {}) do
		if not button.isSkinned then
			pcall(function()
				button:SetTemplate('Default')
				button:StyleButton()
			end)
			self:HookScript(button, 'OnEnter', 'TotemOnEnter')
			self:HookScript(button, 'OnLeave', 'TotemOnLeave')
			if button.icon then
				button.icon:SetDrawLayer('ARTWORK')
				button.icon:SetInside(button)
			end
			bar.buttons[button] = true
			button.isSkinned = true
		end
		if button:IsShown() then
			numButtons = numButtons + 1
			button:Size(AB.db.barTotem.buttonsize)
			button:ClearAllPoints()
			if AB.db.barTotem.flyoutDirection == 'UP' then
				if i == 1 then
					button:Point('BOTTOM', parent, 'TOP', 0, AB.db.barTotem.flyoutSpacing)
				else
					button:Point('BOTTOM', frame.buttons[i-1], 'TOP', 0, AB.db.barTotem.flyoutSpacing)
				end
			elseif AB.db.barTotem.flyoutDirection == 'DOWN' then
				if i == 1 then
					button:Point('TOP', parent, 'BOTTOM', 0, -AB.db.barTotem.flyoutSpacing)
				else
					button:Point('TOP', frame.buttons[i-1], 'BOTTOM', 0, -AB.db.barTotem.flyoutSpacing)
				end
			end
			if color and button.backdrop then
				button:SetBackdropBorderColor(color.r, color.g, color.b)
			end
			if button.icon then button.icon:SetTexCoord(unpack(E.TexCoords)) end
		end
	end

	if color then
		if frame.buttons and frame.buttons[1] and frame.buttons[1].backdrop then
			frame.buttons[1]:SetBackdropBorderColor(color.r, color.g, color.b)
		end
		if MultiCastFlyoutFrameCloseButton and MultiCastFlyoutFrameCloseButton.backdrop then
			MultiCastFlyoutFrameCloseButton.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	end
	frame:ClearAllPoints()
	if MultiCastFlyoutFrameCloseButton then
		MultiCastFlyoutFrameCloseButton:ClearAllPoints()
	end
	if AB.db.barTotem.flyoutDirection == 'UP' then
		frame:Point('BOTTOM', parent, 'TOP')
		if MultiCastFlyoutFrameCloseButton then
			MultiCastFlyoutFrameCloseButton:Point('TOP', frame, 'TOP')
			if MultiCastFlyoutFrameCloseButton.icon then
				MultiCastFlyoutFrameCloseButton.icon:SetRotation(3.14)
			end
		end
	elseif AB.db.barTotem.flyoutDirection == 'DOWN' then
		frame:Point('TOP', parent, 'BOTTOM')
		if MultiCastFlyoutFrameCloseButton then
			MultiCastFlyoutFrameCloseButton:Point('BOTTOM', frame, 'BOTTOM')
			if MultiCastFlyoutFrameCloseButton.icon then
				MultiCastFlyoutFrameCloseButton.icon:SetRotation(0)
			end
		end
	end
	if MultiCastFlyoutFrameCloseButton then
		frame:Height(AB.db.barTotem.buttonsize * AB.db.barTotem.flyoutSpacing * numButtons
			+ MultiCastFlyoutFrameCloseButton:GetHeight())
	end
end

function AB:TotemOnEnter()
	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), AB.db.barTotem.alpha)
	end
end

function AB:TotemOnLeave()
	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
	end
end

function AB:PositionAndSizeBarTotem()
	if not HAS_MULTICAST() then return end
	if InCombatLockdown() then
		if bar and bar.eventFrame then
			bar.eventFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
		end
		return
	end

	local buttonSpacing = E:Scale(self.db.barTotem.buttonspacing)
	local size          = E:Scale(self.db.barTotem.buttonsize)

	-- Grimfall: numActiveSlots may be 0/nil for Hero class, default 4
	local numActiveSlots = (MultiCastActionBarFrame.numActiveSlots
		and MultiCastActionBarFrame.numActiveSlots > 0)
		and MultiCastActionBarFrame.numActiveSlots or NUMMULTICASTBUTTONSPERPAGE

	-- bar:Width(size * 2 + numActiveSlots * buttonSpacing * 2 + numActiveSlots - 1)
	-- MultiCastActionBarFrame:Width(size * 2 + numActiveSlots * buttonSpacing * 2 + numActiveSlots - 1)
	-- bar:Height(size * 2)
	-- MultiCastActionBarFrame:Height(size * 2)
	
	local totalButtons = numActiveSlots + 2 -- summon + active slots + recall
	local totalWidth = (totalButtons * size) + ((totalButtons - 1) * buttonSpacing) + (E.Border * 2)
	bar:Width(totalWidth)
	MultiCastActionBarFrame:Width(totalWidth)
	bar:Height(size * 2)
	MultiCastActionBarFrame:Height(size * 2)

	bar.db       = self.db.barTotem
	bar.mouseover = self.db.barTotem.mouseover

	if bar.mouseover then bar:SetAlpha(0)
	else bar:SetAlpha(self.db.barTotem.alpha) end

	local visibility = bar.db.visibility
	if visibility and match(visibility, "[\n\r]") then
		visibility = gsub(visibility, "[\n\r]","")
	end
	RegisterStateDriver(bar, 'visibility', visibility)

	-- Force show: Blizzard hides MultiCastActionBarFrame for non-Shaman
	MultiCastActionBarFrame:Show()
	if not bar.mouseover then bar:Show() end

	-- Position SummonSpellButton
	if MultiCastSummonSpellButton then
		MultiCastSummonSpellButton:ClearAllPoints()
		MultiCastSummonSpellButton:Size(size)
		MultiCastSummonSpellButton:Point('BOTTOMLEFT', MultiCastActionBarFrame, 'BOTTOMLEFT', E.Border*2, E.Border*2)
	end

	-- Position slot buttons
	for i = 1, numActiveSlots do
		local button     = _G['MultiCastSlotButton'..i]
		local lastButton = _G['MultiCastSlotButton'..(i-1)]
		if button then
			button:ClearAllPoints()
			button:Size(size)
			if i == 1 then
				if MultiCastSummonSpellButton then
					button:Point('LEFT', MultiCastSummonSpellButton, 'RIGHT', buttonSpacing, 0)
				else
					button:Point('BOTTOMLEFT', MultiCastActionBarFrame, 'BOTTOMLEFT', E.Border*2, E.Border*2)
				end
			else
				if lastButton then
					button:Point('LEFT', lastButton, 'RIGHT', buttonSpacing, 0)
				end
			end
		end
	end

	-- Anchor action buttons to their slot buttons
	for i = 1, 12 do
		local actionButton = _G['MultiCastActionButton'..i]
		if actionButton and actionButton.slotButton then
			actionButton:ClearAllPoints()
			actionButton:SetAllPoints(actionButton.slotButton)
		end
	end

	-- Position RecallSpellButton after last slot
	if MultiCastRecallSpellButton then
		local lastSlot = _G['MultiCastSlotButton'..numActiveSlots]
		MultiCastRecallSpellButton:Size(size)
		if lastSlot then
			MultiCastRecallSpellButton:ClearAllPoints()
			MultiCastRecallSpellButton:Point('LEFT', lastSlot, 'RIGHT', buttonSpacing, 0)
		end
	end

	if MultiCastFlyoutFrameCloseButton then
		MultiCastFlyoutFrameCloseButton:Width(size)
	end
	if MultiCastFlyoutFrameOpenButton then
		MultiCastFlyoutFrameOpenButton:Width(size)
	end
end

function AB:UpdateTotemBindings()
	if not HAS_MULTICAST() then return end

	local color = self.db.fontColor
	local alpha = self.db.hotkeytext and 1 or 0

	local function styleHotKey(button)
		if not button then return end
		local name = button:GetName()
		local hotKey = name and _G[name..'HotKey']
		if not hotKey then return end

		hotKey:SetTextColor(color.r, color.g, color.b, alpha)
		hotKey:FontTemplate(LSM:Fetch('font', self.db.font), self.db.fontSize, self.db.fontOutline)
		self:FixKeybindText(button)
	end

	styleHotKey(_G.MultiCastSummonSpellButton)
	styleHotKey(_G.MultiCastRecallSpellButton)

	for i = 1, 12 do
		styleHotKey(_G['MultiCastActionButton'..i])
	end
end

function AB:CreateTotemBar()
	if not HAS_MULTICAST() then return end
	self.bar = bar
	bar:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 250)
	bar.buttons = {}
	bar.eventFrame = CreateFrame('Frame')
	bar.eventFrame:Hide()
	bar.eventFrame:SetScript('OnEvent', function(self)
		AB:PositionAndSizeBarTotem()
		self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	end)
	
	MultiCastActionBarFrame:SetParent(bar)
	MultiCastActionBarFrame:ClearAllPoints()
	MultiCastActionBarFrame:SetPoint('BOTTOMLEFT', bar, 'BOTTOMLEFT', -E.Border, -E.Border)
	MultiCastActionBarFrame:SetScript('OnUpdate', nil)
	MultiCastActionBarFrame:SetScript('OnShow', nil)
	MultiCastActionBarFrame:SetScript('OnHide', nil)
	MultiCastActionBarFrame.SetParent = E.noop
	MultiCastActionBarFrame.SetPoint  = E.noop

	-- Hide decorative regions only
	for i = 1, MultiCastActionBarFrame:GetNumRegions() do
		local region = select(i, MultiCastActionBarFrame:GetRegions())
		if region:IsObjectType('Texture') then
			region:SetTexture(nil)
			region:Hide()
			region:SetAlpha(0)
		end
	end

	self:HookScript(MultiCastActionBarFrame, 'OnEnter', 'TotemOnEnter')
	self:HookScript(MultiCastActionBarFrame, 'OnLeave', 'TotemOnLeave')
	if MultiCastFlyoutFrame then
		self:HookScript(MultiCastFlyoutFrame, 'OnEnter', 'TotemOnEnter')
		self:HookScript(MultiCastFlyoutFrame, 'OnLeave', 'TotemOnLeave')
	end

	-- Style close/open flyout buttons (visual only)
	local closeButton = MultiCastFlyoutFrameCloseButton
	if closeButton then
		pcall(function()
			closeButton:CreateBackdrop('Default', true, true)
			closeButton.backdrop:SetPoint('TOPLEFT', 0, -E.Border + E.Spacing)
			closeButton.backdrop:SetPoint('BOTTOMRIGHT', 0, E.Border + E.Spacing)
			closeButton.icon = closeButton:CreateTexture(nil, 'ARTWORK')
			closeButton.icon:Size(16)
			closeButton.icon:SetPoint('CENTER')
			closeButton.icon:SetTexture(E.Media.Textures.ArrowUp)
			closeButton.normalTexture:SetTexture('')
			closeButton:StyleButton()
			closeButton.hover:SetInside(closeButton.backdrop)
			closeButton.pushed:SetInside(closeButton.backdrop)
		end)
		bar.buttons[closeButton] = true
	end

	local openButton = MultiCastFlyoutFrameOpenButton
	if openButton then
		pcall(function()
			openButton:CreateBackdrop('Default', true, true)
			openButton.backdrop:SetPoint('TOPLEFT', 0, -E.Border + E.Spacing)
			openButton.backdrop:SetPoint('BOTTOMRIGHT', 0, E.Border + E.Spacing)
			openButton.icon = openButton:CreateTexture(nil, 'ARTWORK')
			openButton.icon:Size(16)
			openButton.icon:SetPoint('CENTER')
			openButton.icon:SetTexture(E.Media.Textures.ArrowUp)
			openButton.normalTexture:SetTexture('')
			openButton:SetHitRectInsets(0, 0, 0, 0)
			openButton:StyleButton()
			openButton.hover:SetInside(openButton.backdrop)
			openButton.pushed:SetInside(openButton.backdrop)
		end)
		bar.buttons[openButton] = true
	end

	self:SkinSummonButton(MultiCastSummonSpellButton)
	bar.buttons[MultiCastSummonSpellButton] = true

	-- Hook RecallSpellButton SetPoint to enforce our spacing
	hooksecurefunc(MultiCastRecallSpellButton, 'SetPoint', function(self, point, attachTo, anchorPoint, xOffset, yOffset)
		local buttonSpacing = E:Scale(AB.db.barTotem.buttonspacing)

		if xOffset ~= buttonSpacing then
			if InCombatLockdown() then
				bar.eventFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
				return
			end

			self:SetPoint(point, attachTo, anchorPoint, buttonSpacing, yOffset or 0)
		end
	end)

	self:SkinSummonButton(MultiCastRecallSpellButton)
	bar.buttons[MultiCastRecallSpellButton] = true

	-- Style slot buttons — minimal, no overlay/background manipulation
	for i = 1, NUMMULTICASTBUTTONSPERPAGE do
		local button = _G['MultiCastSlotButton'..i]
		if button then
			button:SetHitRectInsets(0, 0, 0, 0)
			pcall(function()
				button:StyleButton()
				button:SetTemplate('Default')
				
				if button.background then
					button.background:SetDrawLayer('ARTWORK')
					button.background:SetInside(button)
				end
				if button.overlay then
					button.overlay:SetTexture(nil)
					button.overlay.SetTexture = E.noop
				end
			end)
			bar.buttons[button] = true
		end
	end

	-- Style action buttons — do NOT override OnClick or pickup logic
	for i = 1, 12 do
		local button   = _G['MultiCastActionButton'..i]
		local icon     = _G['MultiCastActionButton'..i..'Icon']
		local normal   = _G['MultiCastActionButton'..i..'NormalTexture']
		local cooldown = _G['MultiCastActionButton'..i..'Cooldown']
		if button then
			button:SetHitRectInsets(0, 0, 0, 0)
			pcall(function()
				button:StyleButton()
				if icon then
					icon:SetTexCoord(unpack(E.TexCoords))
					icon:SetDrawLayer('ARTWORK')
					icon:SetInside()
				end
				if button.overlay then
					button.overlay:SetTexture(nil)
					button.overlay.SetTexture = E.noop
				end
				if normal then
					normal:SetTexture(nil)
					normal:Hide()
					normal:SetAlpha(0)
					normal.SetTexture = E.noop
				end
				local hotKey = _G['MultiCastActionButton'..i..'HotKey']
				if hotKey then hotKey.SetVertexColor = E.noop end
				if cooldown then E:RegisterCooldown(cooldown) end
			end)
			-- DO NOT hook SetPoint on action buttons — Grimfall manages their position
			-- DO NOT override OnClick — breaks totem assignment
			bar.buttons[button] = true
		end
	end

	for button in pairs(bar.buttons) do
		button:HookScript('OnEnter', AB.TotemOnEnter)
		button:HookScript('OnLeave', AB.TotemOnLeave)
	end

	self:UpdateTotemBindings()

	-- Hook update functions that DO exist on Grimfall
	-- (these are the slot/summon/recall update functions, not MultiCastActionBarFrameUpdate)
	if type(_G.MultiCastSummonSpellButtonUpdate) == 'function' then
		hooksecurefunc('MultiCastSummonSpellButtonUpdate', function()
			if not InCombatLockdown() then AB:PositionAndSizeBarTotem() end
		end)
	end
	if type(_G.MultiCastRecallSpellButtonUpdate) == 'function' then
		hooksecurefunc('MultiCastRecallSpellButtonUpdate', function()
			if not InCombatLockdown() then AB:PositionAndSizeBarTotem() end
		end)
	end
	if type(_G.MultiCastSlotButtonUpdate) == 'function' then
		hooksecurefunc('MultiCastSlotButtonUpdate', function()
			if not InCombatLockdown() then AB:PositionAndSizeBarTotem() end
		end)
	end

	self:PositionAndSizeBarTotem()

	E:CreateMover(bar, 'ElvBarTotem', L['TUTORIALTITLE47'] or 'Totem Bar', nil, nil, nil,
		'ALL', 'ACTIONBARS', nil, 'actionbar,barTotem')
end