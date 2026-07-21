local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- 既存のXrayGUIがあれば削除
local function cleanupOldXrayGUI()
	local old = playerGui:FindFirstChild("XrayGUI")
	if old then old:Destroy() end
end
cleanupOldXrayGUI()

-- ===== ScreenGui =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MasaHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 既存のmasahub GUIをクリア
for _, kid in pairs(playerGui:GetChildren()) do
	if kid.Name == "MasaHubGui" and kid ~= screenGui then
		kid:Destroy()
	end
end

-- ===== 通知システム =====
local notificationFrame = Instance.new("Frame")
notificationFrame.Name = "NotificationFrame"
notificationFrame.Size = UDim2.new(0, 300, 0, 0)
notificationFrame.Position = UDim2.new(0.5, -150, 0, 10)
notificationFrame.BackgroundTransparency = 1
notificationFrame.Parent = screenGui

local notificationLayout = Instance.new("UIListLayout")
notificationLayout.Padding = UDim.new(0, 5)
notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
notificationLayout.FillDirection = Enum.FillDirection.Vertical
notificationLayout.Parent = notificationFrame

local function showNotification(text, color)
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, 0, 0, 30)
	notif.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
	notif.BackgroundTransparency = 0.2
	notif.BorderSizePixel = 0
	notif.Parent = notificationFrame

	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 6)
	notifCorner.Parent = notif

	local notifStroke = Instance.new("UIStroke")
	notifStroke.Color = color or Color3.fromRGB(180, 0, 0)
	notifStroke.Thickness = 1
	notifStroke.Parent = notif

	local notifLabel = Instance.new("TextLabel")
	notifLabel.Size = UDim2.new(1, 0, 1, 0)
	notifLabel.BackgroundTransparency = 1
	notifLabel.Text = text
	notifLabel.TextColor3 = color or Color3.fromRGB(255, 60, 60)
	notifLabel.TextSize = 14
	notifLabel.Font = Enum.Font.GothamBold
	notifLabel.Parent = notif

	-- フェードイン
	notif.BackgroundTransparency = 1
	notifStroke.Transparency = 1
	notifLabel.TextTransparency = 1

	local fadeIn = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.2,
	})
	local fadeInStroke = TweenService:Create(notifStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0,
	})
	local fadeInText = TweenService:Create(notifLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	})

	fadeIn:Play()
	fadeInStroke:Play()
	fadeInText:Play()

	-- 3秒後にフェードアウトして削除
	task.delay(3, function()
		local fadeOut = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
		})
		local fadeOutStroke = TweenService:Create(notifStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1,
		})
		local fadeOutText = TweenService:Create(notifLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			TextTransparency = 1,
		})

		fadeOut:Play()
		fadeOutStroke:Play()
		fadeOutText:Play()

		fadeOut.Completed:Connect(function()
			notif:Destroy()
		end)
	end)
end

-- ===== ドラッグ移動ヘルパー =====
local function makeDraggable(frame, handle)
	handle = handle or frame
	local dragging = false
	local dragStart, startPos
	local moved = false

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = frame.Position
			local conn
			conn = input.Changed:Connect(function(prop)
				if prop == "UserInputState" and input.UserInputState == Enum.UserInputState.End then
					dragging = false
					conn:Disconnect()
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			if delta.Magnitude > 5 then
				moved = true
			end
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	return function() return moved end
end

-- ===== メインフレーム（小さい正方形） =====
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 80, 0, 80)
mainFrame.Position = UDim2.new(0.5, -40, 0.5, -40)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local borderThing = Instance.new("UIStroke")
borderThing.Color = Color3.fromRGB(180, 0, 0)
borderThing.Thickness = 2
borderThing.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
borderThing.Parent = mainFrame

-- ===== メインボタン（中央のMA） =====
local btnThing = Instance.new("TextButton")
btnThing.Name = "MainButton"
btnThing.Size = UDim2.new(1, 0, 1, 0)
btnThing.Position = UDim2.new(0, 0, 0, 0)
btnThing.BackgroundTransparency = 1
btnThing.BorderSizePixel = 0
btnThing.AutoButtonColor = false
btnThing.Text = "MA"
btnThing.TextColor3 = Color3.fromRGB(255, 60, 60)
btnThing.Font = Enum.Font.GothamBold
btnThing.TextSize = 28
btnThing.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = btnThing

local btnBorder = Instance.new("UIStroke")
btnBorder.Color = Color3.fromRGB(180, 0, 0)
btnBorder.Thickness = 1
btnBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
btnBorder.Parent = btnThing

-- ===== 開閉UI（やや小さめ・中央配置・移動可能） =====
local uiPanel = Instance.new("Frame")
uiPanel.Name = "UIPanel"
uiPanel.Size = UDim2.new(0, 320, 0, 350)
uiPanel.Position = UDim2.new(0.5, -160, 0.5, -175)
uiPanel.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
uiPanel.BackgroundTransparency = 0.1
uiPanel.BorderSizePixel = 0
uiPanel.Visible = false
uiPanel.Active = true
uiPanel.ClipsDescendants = true
uiPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = uiPanel

local panelBorder = Instance.new("UIStroke")
panelBorder.Color = Color3.fromRGB(180, 0, 0)
panelBorder.Thickness = 2
panelBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
panelBorder.Parent = uiPanel

-- ===== パネルトップバー =====
local panelTopBar = Instance.new("Frame")
panelTopBar.Name = "PanelTitleBar"
panelTopBar.Size = UDim2.new(1, 0, 0, 35)
panelTopBar.BackgroundTransparency = 1
panelTopBar.Parent = uiPanel

local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1, -50, 1, 0)
panelTitle.Position = UDim2.new(0, 10, 0, 0)
panelTitle.BackgroundTransparency = 1
panelTitle.Text = "masahub"
panelTitle.TextColor3 = Color3.fromRGB(255, 60, 60)
panelTitle.TextSize = 14
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextXAlignment = Enum.TextXAlignment.Left
panelTitle.Parent = panelTopBar

-- ===== 閉じるボタン（×） =====
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -30, 0.5, -12)
closeButton.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
closeButton.BackgroundTransparency = 0.2
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = panelTopBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local closeStroke = Instance.new("UIStroke")
closeStroke.Color = Color3.fromRGB(180, 0, 0)
closeStroke.Thickness = 1
closeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
closeStroke.Parent = closeButton

-- ===== パネルライン =====
local panelLine = Instance.new("Frame")
panelLine.Size = UDim2.new(1, -16, 0, 1)
panelLine.Position = UDim2.new(0, 8, 0, 35)
panelLine.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
panelLine.BackgroundTransparency = 0.3
panelLine.BorderSizePixel = 0
panelLine.Parent = uiPanel

-- ===== パネルスクロール =====
local panelScroll = Instance.new("ScrollingFrame")
panelScroll.Name = "ScrollFrame"
panelScroll.Size = UDim2.new(1, 0, 1, -45)
panelScroll.Position = UDim2.new(0, 0, 0, 45)
panelScroll.BackgroundTransparency = 1
panelScroll.BorderSizePixel = 0
panelScroll.ScrollBarThickness = 6
panelScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
panelScroll.Parent = uiPanel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.Parent = panelScroll

local scrollPadding = Instance.new("UIPadding")
scrollPadding.PaddingTop = UDim.new(0, 10)
scrollPadding.PaddingBottom = UDim.new(0, 10)
scrollPadding.PaddingLeft = UDim.new(0, 10)
scrollPadding.PaddingRight = UDim.new(0, 10)
scrollPadding.Parent = panelScroll

-- ===== トグル行ヘルパー（1クリック=1回発火） =====
local function createToggleRow(name, onClick, getState)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 50)
	row.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
	row.BorderSizePixel = 0
	row.Active = true
	row.Parent = panelScroll

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 8)
	rowCorner.Parent = row

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(255, 60, 60)
	label.TextSize = 16
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local switch = Instance.new("Frame")
	switch.Size = UDim2.new(0, 50, 0, 26)
	switch.Position = UDim2.new(1, -60, 0.5, -13)
	switch.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
	switch.BorderSizePixel = 0
	switch.Parent = row

	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(1, 0)
	switchCorner.Parent = switch

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 22, 0, 22)
	knob.Position = UDim2.new(0, 2, 0.5, -11)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = switch

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function update()
		if getState() then
			TweenService:Create(knob, tweenInfo, {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
			switch.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
		else
			TweenService:Create(knob, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
			switch.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
		end
	end

	-- デバウンス: 1クリックで複数回発火するのを防止
	local lastClick = 0
	row.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			local now = os.clock()
			if now - lastClick < 0.25 then return end
			lastClick = now
			onClick()
			update()
		end
	end)

	update()
	return { row = row, update = update }
end

-- ===== ドラッグ有効化（メインフレームのみ） =====
local mainWasDragged = makeDraggable(mainFrame, btnThing)

-- ===== 機能 =====
local panelOpen = false

local function setPanelOpen(open)
	panelOpen = open
	uiPanel.Visible = open
end

btnThing.MouseButton1Click:Connect(function()
	if mainWasDragged() then return end
	setPanelOpen(not panelOpen)
end)

closeButton.MouseButton1Click:Connect(function()
	setPanelOpen(false)
end)

-- ===== ドラッグ有効化（UIパネル） =====
makeDraggable(uiPanel, panelTopBar)

-- ===== X-Ray 機能 =====
local xrayEnabled = false
local xrayConnection
local xrayOriginals = {} -- Part -> 元のTransparency

local function startXRay()
	if xrayConnection then
		xrayConnection:Disconnect()
		xrayConnection = nil
	end

	xrayConnection = RunService.Heartbeat:Connect(function()
		local Plots = Workspace:FindFirstChild("Plots")
		if Plots then
			for _, Plot in ipairs(Plots:GetChildren()) do
				if Plot:IsA("Model") and Plot:FindFirstChild("Decorations") then
					for _, Part in ipairs(Plot.Decorations:GetDescendants()) do
						if Part:IsA("BasePart") then
							if xrayOriginals[Part] == nil then
								xrayOriginals[Part] = Part.Transparency
							end
							Part.Transparency = 0.8
						end
					end
				end
			end
		end
	end)
end

local function stopXRay()
	if xrayConnection then
		xrayConnection:Disconnect()
		xrayConnection = nil
	end

	-- 元の透明度に復元
	for Part, orig in pairs(xrayOriginals) do
		if Part and Part.Parent then
			Part.Transparency = orig
		end
	end
	xrayOriginals = {}
end

local function toggleXRay()
	xrayEnabled = not xrayEnabled
	if xrayEnabled then
		startXRay()
		showNotification("X-Ray: ON", Color3.fromRGB(0, 255, 0))
		print("X-Ray: ON")
	else
		stopXRay()
		showNotification("X-Ray: OFF", Color3.fromRGB(255, 0, 0))
		print("X-Ray: OFF")
	end
end

-- ===== Antibee 機能 =====
local antibeeEnabled = false
local antibeeConnections = {}
local FOV_LOCK = 70
local originalFOV = camera.FieldOfView

local blacklist = {
	"BlurEffect", "ColorCorrectionEffect", "BloomEffect", "SunRaysEffect",
	"DepthOfFieldEffect", "Atmosphere", "Sky", "Smoke", "ParticleEmitter",
	"Beam", "Trail", "Highlight", "PostEffect", "SurfaceAppearance",
	"Fire", "Sparkles", "Explosion", "PointLight", "SpotLight", "SurfaceLight",
	"Shadows", "Blur", "Fog", "ColorGradingEffect", "ToneMappingEffect",
	"VignetteEffect", "GodRays", "Glare", "ChromaticAberrationEffect",
	"DistortionEffect", "LensFlare", "SunFlare", "LightInfluence",
	"AmbientOcclusionEffect", "RefractionEffect", "HeatDistortion",
	"GlitchEffect", "ScreenSpaceReflection", "MotionBlur", "VolumetricLight",
	"RainEffect", "SnowEffect", "LightningEffect", "NeonGlow",
	"ContrastCorrection", "ShadowMap", "Clouds", "FogVolume", "WaterEffect",
	"WindEffect", "PixelateEffects", "FilmGrainEffect", "CRTShader",
	"NightVisionEffect", "InfraredEffect", "HazeEffect", "ColorBalanceEffect",
	"DynamicLight", "AmbientEffect", "ScreenDistortion", "ScanlineEffect",
	"UnderwaterEffect", "ThermalVision", "ShockwaveEffect", "FlashEffect",
	"ExplosionLight", "VFXPart", "GlitchScreen", "ScreenFlash",
	"OverlayEffect", "ShadowEffect", "GhostEffect", "FogEmitter",
	"WindEmitter", "HeatWave", "SunGlow", "ColorOverlay", "VisionDistort",
	"EchoEffect", "ScreenOverlay", "RenderEffect", "VisualEffect",
	"LightingEffect", "CameraEffect", "WeatherEffect", "SmokeTrail",
	"FireTrail", "NeonEffect", "RefractionLayer", "PostProcessingEffect",
	"VisualNoise", "ScreenNoise",
}

local function isBlacklisted(obj)
	for _, name in ipairs(blacklist) do
		if obj:IsA(name) then
			return true
		end
	end
	return false
end

local function clearEffects()
	for _, v in pairs(Lighting:GetDescendants()) do
		if isBlacklisted(v) then
			v:Destroy()
		end
	end
end

local moveVector = Vector3.zero

local function startAntibee()
	for _, conn in ipairs(antibeeConnections) do
		conn:Disconnect()
	end
	antibeeConnections = {}
	moveVector = Vector3.zero

	clearEffects()

	local descConn = Lighting.DescendantAdded:Connect(function(obj)
		task.wait()
		if isBlacklisted(obj) then
			obj:Destroy()
		end
	end)
	table.insert(antibeeConnections, descConn)

	local fovConn = RunService.RenderStepped:Connect(function()
		if camera and camera.FieldOfView ~= FOV_LOCK then
			camera.FieldOfView = FOV_LOCK
		end
	end)
	table.insert(antibeeConnections, fovConn)

	local inputConn = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Gamepad1
			or input.UserInputType == Enum.UserInputType.Touch then
			if input.KeyCode == Enum.KeyCode.Thumbstick1 then
				moveVector = Vector3.new(input.Position.X, 0, -input.Position.Y)
			end
		end
	end)
	table.insert(antibeeConnections, inputConn)

	-- ゲームパッド/タッチ入力がある時だけMove（キーボード移動を上書きしない）
	local moveConn = RunService.RenderStepped:Connect(function()
		if moveVector.Magnitude > 0.15 then
			local char = player.Character
			if char then
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid:Move(moveVector, true)
				end
			end
		end
	end)
	table.insert(antibeeConnections, moveConn)
end

local function stopAntibee()
	for _, conn in ipairs(antibeeConnections) do
		conn:Disconnect()
	end
	antibeeConnections = {}
	moveVector = Vector3.zero
	-- FOVを元に戻す
	if camera then
		camera.FieldOfView = originalFOV
	end
end

local function toggleAntibee()
	antibeeEnabled = not antibeeEnabled
	if antibeeEnabled then
		startAntibee()
		showNotification("Antibee: ON", Color3.fromRGB(0, 255, 0))
		print("Antibee: ON")
	else
		stopAntibee()
		showNotification("Antibee: OFF", Color3.fromRGB(255, 0, 0))
		print("Antibee: OFF")
	end
end

-- ===== Anti Ragdoll 機能 =====
local antiRagdollEnabled = false

local function setupAntiRagdoll(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	for _, state in pairs({Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.FallingDown,
		Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.Dead}) do
		hum:SetStateEnabled(state, false)
	end
	hum.StateChanged:Connect(function(_, new)
		if antiRagdollEnabled and (new == Enum.HumanoidStateType.Ragdoll or
			new == Enum.HumanoidStateType.FallingDown or
			new == Enum.HumanoidStateType.Physics or
			new == Enum.HumanoidStateType.Dead) then
			hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
		end
	end)
end

local function toggleAntiRagdoll()
	antiRagdollEnabled = not antiRagdollEnabled
	if player.Character then setupAntiRagdoll(player.Character) end
	if antiRagdollEnabled then
		showNotification("Anti Ragdoll: ON", Color3.fromRGB(0, 255, 0))
	else
		showNotification("Anti Ragdoll: OFF", Color3.fromRGB(255, 0, 0))
	end
	print("Anti Ragdoll: " .. (antiRagdollEnabled and "ON" or "OFF"))
end

player.CharacterAdded:Connect(function(c)
	task.wait(0.4)
	if antiRagdollEnabled then setupAntiRagdoll(c) end
end)

-- ===== Auto Kick 機能 =====
local autoKickEnabled = false
local autoKickConnections = {}
local KEYWORD = "you stole"
local KICK_MESSAGE = "MASAHUB:auto kick"

local function hasKeyword(text)
	if typeof(text) ~= "string" then return false end
	return string.find(string.lower(text), KEYWORD) ~= nil
end

local function kick()
	pcall(function()
		player:Kick(KICK_MESSAGE)
	end)
end

local function watchObject(obj)
	if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
		return
	end
	if hasKeyword(obj.Text) then
		kick()
		return
	end
	local conn = obj:GetPropertyChangedSignal("Text"):Connect(function()
		if hasKeyword(obj.Text) then
			kick()
		end
	end)
	table.insert(autoKickConnections, conn)
end

local function scan(parent)
	for _, obj in ipairs(parent:GetDescendants()) do
		watchObject(obj)
	end
end

local function watchGui(gui)
	scan(gui)
	local conn = gui.DescendantAdded:Connect(function(desc)
		watchObject(desc)
	end)
	table.insert(autoKickConnections, conn)
end

local function startAutoKick()
	for _, conn in ipairs(autoKickConnections) do
		conn:Disconnect()
	end
	autoKickConnections = {}

	-- 既存のGUIをスキャン
	for _, gui in ipairs(playerGui:GetChildren()) do
		watchGui(gui)
	end

	-- 新しいGUIを監視
	local childAddedConn = playerGui.ChildAdded:Connect(function(gui)
		watchGui(gui)
	end)
	table.insert(autoKickConnections, childAddedConn)

	print("Auto Kick: ON")
end

local function stopAutoKick()
	for _, conn in ipairs(autoKickConnections) do
		conn:Disconnect()
	end
	autoKickConnections = {}
	print("Auto Kick: OFF")
end

local function toggleAutoKick()
	autoKickEnabled = not autoKickEnabled
	if autoKickEnabled then
		startAutoKick()
		showNotification("Auto Kick: ON", Color3.fromRGB(0, 255, 0))
	else
		stopAutoKick()
		showNotification("Auto Kick: OFF", Color3.fromRGB(255, 0, 0))
	end
end

-- ===== Player ESP 機能 =====
local playerESPEnabled = false
local espConnections = {}

local function createESP(plr)
	if plr == player then return end
	if not plr.Character then return end
	if plr.Character:FindFirstChild("followme@rznnq") then return end
	local char = plr.Character
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	if not (hrp and head) then return end

	local hitbox = Instance.new("BoxHandleAdornment")
	hitbox.Name = "follow me @rznnq"
	hitbox.Adornee = hrp
	hitbox.Size = Vector3.new(4, 6, 2)
	hitbox.Color3 = Color3.fromRGB(128, 0, 128)
	hitbox.Transparency = 0.6
	hitbox.ZIndex = 10
	hitbox.AlwaysOnTop = true
	hitbox.Parent = char

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "cpsito riko"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = char

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = plr.DisplayName or plr.Name
	label.TextColor3 = Color3.fromRGB(255, 0, 255)
	label.Font = Enum.Font.Arcade
	label.TextScaled = true
	label.TextStrokeTransparency = 0.7
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Parent = billboard
end

local function removeESP(plr)
	if not plr.Character then return end
	local hitbox = plr.Character:FindFirstChild("follow me @rznnq")
	local nameGui = plr.Character:FindFirstChild("cpsito riko")
	if hitbox then hitbox:Destroy() end
	if nameGui then nameGui:Destroy() end
end

local function enableESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			if plr.Character then
				createESP(plr)
			end
			local conn = plr.CharacterAdded:Connect(function()
				task.wait(0.1)
				if playerESPEnabled then
					createESP(plr)
				end
			end)
			table.insert(espConnections, conn)
		end
	end

	local playerAddedConn = Players.PlayerAdded:Connect(function(plr)
		if plr == player then return end
		local charAddedConn = plr.CharacterAdded:Connect(function()
			task.wait(0.1)
			if playerESPEnabled then
				createESP(plr)
			end
		end)
		table.insert(espConnections, charAddedConn)
	end)
	table.insert(espConnections, playerAddedConn)
end

local function disableESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		removeESP(plr)
	end
	for _, conn in ipairs(espConnections) do
		if conn and conn.Connected then
			conn:Disconnect()
		end
	end
	espConnections = {}
end

local function togglePlayerESP()
	playerESPEnabled = not playerESPEnabled
	if playerESPEnabled then
		enableESP()
		showNotification("Player ESP: ON", Color3.fromRGB(0, 255, 0))
		print("Player ESP: ON")
	else
		disableESP()
		showNotification("Player ESP: OFF", Color3.fromRGB(255, 0, 0))
		print("Player ESP: OFF")
	end
end

-- ===== ESP Timer 機能 =====
local espTimerEnabled = false
local espTimerConnection
local baseEspInstances = {}

local function createBaseESP(plot, mainPart)
	if baseEspInstances[plot.Name] then
		baseEspInstances[plot.Name]:Destroy()
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "rznnq" .. plot.Name
	billboard.Size = UDim2.new(0, 50, 0, 25)
	billboard.StudsOffset = Vector3.new(0, 5, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = mainPart
	billboard.MaxDistance = 1000
	billboard.Parent = plot
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.Arcade
	label.TextColor3 = Color3.fromRGB(255, 255, 0)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.Parent = billboard
	baseEspInstances[plot.Name] = billboard
	return billboard
end

local function updateBaseESP()
	local plotsFolder = Workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		local purchases = plot:FindFirstChild("Purchases")
		local plotBlock = purchases and purchases:FindFirstChild("PlotBlock")
		local mainPart = plotBlock and plotBlock:FindFirstChild("Main")
		local billboard = baseEspInstances[plot.Name]

		local timeLabel = mainPart
			and mainPart:FindFirstChild("BillboardGui")
			and mainPart.BillboardGui:FindFirstChild("RemainingTime")

		if timeLabel and mainPart then
			billboard = billboard or createBaseESP(plot, mainPart)
			local label = billboard:FindFirstChildWhichIsA("TextLabel")
			if label then
				label.Text = timeLabel.Text
			end
		elseif billboard then
			billboard:Destroy()
			baseEspInstances[plot.Name] = nil
		end
	end
end

local function startESPTimer()
	if espTimerConnection then
		espTimerConnection:Disconnect()
		espTimerConnection = nil
	end
	espTimerConnection = RunService.RenderStepped:Connect(updateBaseESP)
end

local function stopESPTimer()
	if espTimerConnection then
		espTimerConnection:Disconnect()
		espTimerConnection = nil
	end
	for _, billboard in pairs(baseEspInstances) do
		if billboard then
			billboard:Destroy()
		end
	end
	baseEspInstances = {}
end

local function toggleESPTimer()
	espTimerEnabled = not espTimerEnabled
	if espTimerEnabled then
		startESPTimer()
		showNotification("ESP Timer: ON", Color3.fromRGB(0, 255, 0))
		print("ESP Timer: ON")
	else
		stopESPTimer()
		showNotification("ESP Timer: OFF", Color3.fromRGB(255, 0, 0))
		print("ESP Timer: OFF")
	end
end

-- ===== Infinity Jump 機能 =====
local infinityJumpEnabled = false
local infinityJumpConnection
local boosting = false
local boostForce = 25
local boostFrames = 2
local boostCooldown = 0.12
local lastBoost = 0

local function applyBoost(root)
	if not root or boosting then return end
	local now = tick()
	if now - lastBoost < boostCooldown then return end
	lastBoost = now
	boosting = true

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(0, math.huge, 0)
	bv.P = 1250
	bv.Velocity = Vector3.new(root.Velocity.X, boostForce, root.Velocity.Z)
	bv.Parent = root

	local frameCount = 0
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if frameCount < boostFrames then
			frameCount = frameCount + 1
			bv.Velocity = bv.Velocity + Vector3.new(0, 0.01, 0)
		else
			bv:Destroy()
			conn:Disconnect()
			boosting = false
		end
	end)
end

local function startInfinityJump()
	if infinityJumpConnection then
		infinityJumpConnection:Disconnect()
		infinityJumpConnection = nil
	end

	infinityJumpConnection = RunService.Heartbeat:Connect(function()
		if not infinityJumpEnabled then return end
		local char = player.Character
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			local root = char:FindFirstChild("HumanoidRootPart")
			if humanoid and humanoid.Health > 0 and root then
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					applyBoost(root)
				end
			end
		end
	end)
end

local function stopInfinityJump()
	if infinityJumpConnection then
		infinityJumpConnection:Disconnect()
		infinityJumpConnection = nil
	end
	boosting = false
end

local function toggleInfinityJump()
	infinityJumpEnabled = not infinityJumpEnabled
	if infinityJumpEnabled then
		startInfinityJump()
		showNotification("Infinity Jump: ON", Color3.fromRGB(0, 255, 0))
		print("Infinity Jump: ON")
	else
		stopInfinityJump()
		showNotification("Infinity Jump: OFF", Color3.fromRGB(255, 0, 0))
		print("Infinity Jump: OFF")
	end
end

-- ===== Desync 機能 =====
local desyncEnabled = false
local desyncConnection

local DESYNC_FLAGS = {
	{"DFIntS2PhysicsSenderRate", "-30"},
	{"WorldStepMax", "-1"},
	{"DFIntTouchSenderMaxBandwidthBps", "-1"},
	{"DFFlagUseClientAuthoritativePhysicsForHumanoids", "True"},
	{"DFFlagClientCharacterControllerPhysicsOverride", "True"},
	{"DFIntSimBlockLargeLocalToolWeldManipulationsThreshold", "-1"},
	{"DFIntClientPhysicsMaxSendRate", "2147483647"},
	{"DFIntPhysicsSenderRate", "2147483647"},
	{"DFIntClientPhysicsSendRate", "2147483647"},
	{"DFIntNetworkSendRate", "2147483647"},
	{"DFIntDebugSimPrimalNewtonIts", "0"},
	{"DFIntDebugSimPrimalPreconditioner", "0"},
	{"DFIntDebugSimPrimalPreconditionerMinExp", "0"},
	{"DFIntDebugSimPrimalToleranceInv", "0"},
	{"DFIntMinClientSimulationRadius", "2147000000"},
	{"DFIntMaxClientSimulationRadius", "2147000000"},
	{"DFIntClientSimulationRadiusBuffer", "2147000000"},
	{"DFIntMinimalSimRadiusBuffer", "2147000000"},
	{"DFIntSimVelocityCorrectionDampening", "0"},
	{"DFIntSimPositionCorrectionDampening", "0"},
	{"DFFlagDebugDisablePositionCorrection", "True"},
	{"GameNetPVHeaderRotationalVelocityZeroCutoffExponent", "-2147483647"},
	{"GameNetPVHeaderLinearVelocityZeroCutoffExponent", "-2147483647"},
	{"DFIntUnstickForceAttackInTenths", "-20"},
}

local function spamFlags()
	if setfflag then
		for _, flagData in ipairs(DESYNC_FLAGS) do
			pcall(function()
				setfflag(flagData[1], flagData[2])
			end)
		end
	end
end

local function startDesync()
	if desyncConnection then
		desyncConnection:Disconnect()
		desyncConnection = nil
	end
	desyncConnection = RunService.RenderStepped:Connect(spamFlags)
end

local function stopDesync()
	if desyncConnection then
		desyncConnection:Disconnect()
		desyncConnection = nil
	end
	if setfflag then
		pcall(function()
			for _, flagData in ipairs(DESYNC_FLAGS) do
				setfflag(flagData[1], "False")
			end
		end)
	end
end

local function toggleDesync()
	desyncEnabled = not desyncEnabled
	if desyncEnabled then
		startDesync()
		showNotification("Desync: ON", Color3.fromRGB(0, 255, 0))
		print("Desync: ON")
	else
		stopDesync()
		showNotification("Desync: OFF", Color3.fromRGB(255, 0, 0))
		print("Desync: OFF")
	end
end

-- ===== NoClip 機能 =====
local noClipEnabled = false
local noClipConnection

local function setNoClip(enabled)
	local char = player.Character
	if not char then return end

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = not enabled
		end
	end
end

local function startNoClip()
	setNoClip(true)
	noClipConnection = player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		if noClipEnabled then
			setNoClip(true)
		end
	end)
end

local function stopNoClip()
	setNoClip(false)
	if noClipConnection then
		noClipConnection:Disconnect()
		noClipConnection = nil
	end
end

local function toggleNoClip()
	noClipEnabled = not noClipEnabled
	if noClipEnabled then
		startNoClip()
		showNotification("NoClip: ON", Color3.fromRGB(0, 255, 0))
		print("NoClip: ON")
	else
		stopNoClip()
		showNotification("NoClip: OFF", Color3.fromRGB(255, 0, 0))
		print("NoClip: OFF")
	end
end

-- ===== TP 機能 =====
local tpEnabled = false
local tpButton
local spawnPosition = nil
local lastPosition = nil
local isAtSpawn = false
local tpKeybind = nil
local tpKeybindButton = nil
local keybindSettingMode = false
local saveSettingsButton = nil

-- ===== 設定保存システム =====
local settings = {
	tpKeybind = nil,
}

local function saveSettings()
	settings.tpKeybind = tpKeybind
	-- ここで設定を保存（必要に応じて拡張）
	showNotification("Settings Saved", Color3.fromRGB(0, 255, 0))
	print("Settings Saved")
end

local function loadSettings()
	if settings.tpKeybind then
		tpKeybind = settings.tpKeybind
		if tpKeybindButton then
			tpKeybindButton.Text = tpKeybind.Name
		end
	end
end

local function equipFlyingCarpet()
	local backpack = player:FindFirstChild("Backpack")
	if not backpack then return end

	local carpet = backpack:FindFirstChild("Flying Carpet")
	local broom = backpack:FindFirstChild("Witch's Broom")
	
	local tool = carpet or broom
	if tool then
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:EquipTool(tool)
		end
	end
end

local function teleportTo(position)
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	hrp.CFrame = CFrame.new(position)
	equipFlyingCarpet()
end

local function createTPButton()
	if tpButton then return end

	tpButton = Instance.new("TextButton")
	tpButton.Name = "TPButton"
	tpButton.Size = UDim2.new(0, 60, 0, 60)
	tpButton.Position = UDim2.new(1, -70, 0.5, -30)
	tpButton.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
	tpButton.BackgroundTransparency = 0.1
	tpButton.BorderSizePixel = 0
	tpButton.AutoButtonColor = false
	tpButton.Text = "TP"
	tpButton.TextColor3 = Color3.fromRGB(255, 60, 60)
	tpButton.Font = Enum.Font.GothamBold
	tpButton.TextSize = 18
	tpButton.Parent = screenGui

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 10)
	btnCorner.Parent = tpButton

	local btnBorder = Instance.new("UIStroke")
	btnBorder.Color = Color3.fromRGB(180, 0, 0)
	btnBorder.Thickness = 2
	btnBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnBorder.Parent = tpButton

	tpButton.MouseButton1Click:Connect(function()
		local char = player.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		if not spawnPosition then
			spawnPosition = hrp.Position
			showNotification("Spawn Position Saved", Color3.fromRGB(0, 255, 0))
			return
		end

		if isAtSpawn then
			if lastPosition then
				teleportTo(lastPosition)
				isAtSpawn = false
				showNotification("TP: Back to last position", Color3.fromRGB(0, 255, 0))
			end
		else
			lastPosition = hrp.Position
			teleportTo(spawnPosition)
			isAtSpawn = true
			showNotification("TP: To spawn", Color3.fromRGB(0, 255, 0))
		end
	end)
end

local function removeTPButton()
	if tpButton then
		tpButton:Destroy()
		tpButton = nil
	end
end

local function createKeybindButton()
	if tpKeybindButton then return end

	tpKeybindButton = Instance.new("TextButton")
	tpKeybindButton.Name = "KeybindButton"
	tpKeybindButton.Size = UDim2.new(0, 60, 0, 30)
	tpKeybindButton.Position = UDim2.new(1, -70, 0.5, 40)
	tpKeybindButton.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
	tpKeybindButton.BackgroundTransparency = 0.1
	tpKeybindButton.BorderSizePixel = 0
	tpKeybindButton.AutoButtonColor = false
	tpKeybindButton.Text = tpKeybind and tpKeybind.Name or "Set Key"
	tpKeybindButton.TextColor3 = Color3.fromRGB(255, 60, 60)
	tpKeybindButton.Font = Enum.Font.GothamBold
	tpKeybindButton.TextSize = 12
	tpKeybindButton.Parent = screenGui

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = tpKeybindButton

	local btnBorder = Instance.new("UIStroke")
	btnBorder.Color = Color3.fromRGB(180, 0, 0)
	btnBorder.Thickness = 1
	btnBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnBorder.Parent = tpKeybindButton

	tpKeybindButton.MouseButton1Click:Connect(function()
		keybindSettingMode = true
		tpKeybindButton.Text = "Press Key..."
		tpKeybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 0)
		showNotification("Press a key to bind", Color3.fromRGB(255, 255, 0))
	end)
end

local function removeKeybindButton()
	if tpKeybindButton then
		tpKeybindButton:Destroy()
		tpKeybindButton = nil
	end
	keybindSettingMode = false
end

local function executeTP()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if not spawnPosition then
		spawnPosition = hrp.Position
		showNotification("Spawn Position Saved", Color3.fromRGB(0, 255, 0))
		return
	end

	if isAtSpawn then
		if lastPosition then
			teleportTo(lastPosition)
			isAtSpawn = false
			showNotification("TP: Back to last position", Color3.fromRGB(0, 255, 0))
		end
	else
		lastPosition = hrp.Position
		teleportTo(spawnPosition)
		isAtSpawn = true
		showNotification("TP: To spawn", Color3.fromRGB(0, 255, 0))
	end
end

-- キー入力検出
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if keybindSettingMode and input.KeyCode ~= Enum.KeyCode.Unknown then
		tpKeybind = input.KeyCode
		keybindSettingMode = false
		if tpKeybindButton then
			tpKeybindButton.Text = tpKeybind.Name
			tpKeybindButton.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
		end
		showNotification("Keybind set: " .. tpKeybind.Name, Color3.fromRGB(0, 255, 0))
		return
	end
	
	if tpEnabled and tpKeybind and input.KeyCode == tpKeybind then
		executeTP()
	end
end)

local function toggleTP()
	tpEnabled = not tpEnabled
	if tpEnabled then
		createTPButton()
		createKeybindButton()
		showNotification("TP: ON", Color3.fromRGB(0, 255, 0))
		print("TP: ON")
	else
		removeTPButton()
		removeKeybindButton()
		showNotification("TP: OFF", Color3.fromRGB(255, 0, 0))
		print("TP: OFF")
	end
end

-- スポーン位置を初期保存
if player.Character then
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		spawnPosition = hrp.Position
	end
end

player.CharacterAdded:Connect(function(char)
	task.wait(1)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		spawnPosition = hrp.Position
		isAtSpawn = true
	end
end)

-- ===== Auto Steal 機能 =====
local autoStealEnabled = false
local autoStealConnection = nil
 local STEAL_RADIUS = 60
local STEAL_DURATION = 1.4
local isStealing = false
local StealData = {}

local function getHRP()
	local c = player.Character
	if c then return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso") end
	return nil
end

local function isMyPlotByName(pn)
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return false end
	local plot = plots:FindFirstChild(pn)
	if not plot then return false end
	local sign = plot:FindFirstChild("PlotSign")
	if sign then
		local yb = sign:FindFirstChild("YourBase")
		if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
	end
	return false
end

local function findNearestPrompt()
	local hrp = getHRP()
	if not hrp then return nil end
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	local nearest, dist = nil, math.huge
	for _, plot in ipairs(plots:GetChildren()) do
		if isMyPlotByName(plot.Name) then continue end
		local pods = plot:FindFirstChild("AnimalPodiums")
		if not pods then continue end
		for _, pod in ipairs(pods:GetChildren()) do
			local base = pod:FindFirstChild("Base")
			if not base then continue end
			local spawn = base:FindFirstChild("Spawn")
			if not spawn then continue end
			local d = (spawn.Position - hrp.Position).Magnitude
			if d <= STEAL_RADIUS and d < dist then
				local att = spawn:FindFirstChild("PromptAttachment")
				if att then
					for _, p in ipairs(att:GetChildren()) do
						if p:IsA("ProximityPrompt") and p.ActionText and p.ActionText:find("Steal") then
							nearest, dist = p, d
						end
					end
				end
			end
		end
	end
	return nearest
end

local function executeSteal(prompt)
	if isStealing then return end
	if not StealData[prompt] then
		StealData[prompt] = {hold = {}, trigger = {}, ready = true}
		if getconnections then
			for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
				if c.Function then table.insert(StealData[prompt].hold, c.Function) end
			end
			for _, c in ipairs(getconnections(prompt.Triggered)) do
				if c.Function then table.insert(StealData[prompt].trigger, c.Function) end
			end
		end
	end
	local data = StealData[prompt]
	if not data.ready then return end
	data.ready = false
	isStealing = true
	local startTime = tick()
	task.spawn(function()
		for _, f in ipairs(data.hold) do pcall(f) end
		while tick() - startTime < STEAL_DURATION do
			local elapsed = tick() - startTime
			task.wait()
		end
		for _, f in ipairs(data.trigger) do pcall(f) end
		task.wait(0.05)
		data.ready = true
		isStealing = false
	end)
end

local function startAutoSteal()
	if autoStealConnection then return end
	autoStealConnection = RunService.Heartbeat:Connect(function()
		if not autoStealEnabled then return end
		if isStealing then return end
		local success, prompt = pcall(findNearestPrompt)
		if success and prompt then pcall(executeSteal, prompt) end
	end)
end

local function stopAutoSteal()
	if autoStealConnection then
		autoStealConnection:Disconnect()
		autoStealConnection = nil
	end
	isStealing = false
end

local function toggleAutoSteal()
	autoStealEnabled = not autoStealEnabled
	if autoStealEnabled then
		startAutoSteal()
		showNotification("Auto Steal: ON", Color3.fromRGB(0, 255, 0))
		print("Auto Steal: ON")
	else
		stopAutoSteal()
		showNotification("Auto Steal: OFF", Color3.fromRGB(255, 0, 0))
		print("Auto Steal: OFF")
	end
end

-- ===== 設定保存ボタン =====
local function createSaveButton()
	if saveSettingsButton then return end

	saveSettingsButton = Instance.new("TextButton")
	saveSettingsButton.Name = "SaveSettingsButton"
	saveSettingsButton.Size = UDim2.new(1, -20, 0, 35)
	saveSettingsButton.Position = UDim2.new(0, 10, 0, 0)
	saveSettingsButton.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
	saveSettingsButton.BackgroundTransparency = 0.2
	saveSettingsButton.BorderSizePixel = 0
	saveSettingsButton.AutoButtonColor = false
	saveSettingsButton.Text = "Save Settings"
	saveSettingsButton.TextColor3 = Color3.fromRGB(255, 60, 60)
	saveSettingsButton.Font = Enum.Font.GothamBold
	saveSettingsButton.TextSize = 14
	saveSettingsButton.Parent = panelScroll

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = saveSettingsButton

	local btnBorder = Instance.new("UIStroke")
	btnBorder.Color = Color3.fromRGB(180, 0, 0)
	btnBorder.Thickness = 1
	btnBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnBorder.Parent = saveSettingsButton

	saveSettingsButton.MouseButton1Click:Connect(function()
		saveSettings()
	end)
end

-- ===== 設定にトグルを追加 =====
createToggleRow("Xray", toggleXRay, function() return xrayEnabled end)
createToggleRow("Antibee", toggleAntibee, function() return antibeeEnabled end)
createToggleRow("Anti Ragdoll", toggleAntiRagdoll, function() return antiRagdollEnabled end)
createToggleRow("Auto Kick", toggleAutoKick, function() return autoKickEnabled end)
createToggleRow("Player ESP", togglePlayerESP, function() return playerESPEnabled end)
createToggleRow("ESP Timer", toggleESPTimer, function() return espTimerEnabled end)
createToggleRow("Infinity Jump", toggleInfinityJump, function() return infinityJumpEnabled end)
createToggleRow("Desync", toggleDesync, function() return desyncEnabled end)
createToggleRow("NoClip", toggleNoClip, function() return noClipEnabled end)
createToggleRow("TP", toggleTP, function() return tpEnabled end)
createToggleRow("Auto Steal", toggleAutoSteal, function() return autoStealEnabled end)
createSaveButton()

-- 設定をロード
loadSettings()

print("masahub UI initialized!")
