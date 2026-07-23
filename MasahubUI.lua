-- merged script with red-to-green gradient fill + rounded progress bar
local CONFIG = {
    AUTO_STEAL_ENABLED = true,
    HOLD_MIN = 1.3,
    HOLD_MAX = 2.6,
    ENTRY_DELAY = 0.3,
    COOLDOWN = 0.05,
    STEAL_RANGE = 10,
    PRIME_RANGE = 80,

    -- UI
    GUI_NAME = "IrishAutoGrabRounded",
    WIDTH = 408,
    HEIGHT = 44,
    LEFT_WIDTH = 250,
    RIGHT_WIDTH = 158,
    OUTLINE = Color3.fromRGB(229, 229, 235),
    INNER_OUTLINE = Color3.fromRGB(118, 118, 126),
    BG = Color3.fromRGB(1, 1, 2),
    BG_SOFT = Color3.fromRGB(7, 7, 9),
    TEXT = Color3.fromRGB(248, 248, 249),
    MUTED = Color3.fromRGB(223, 223, 228),

    -- Couleurs du dégradé de progression
    START_LEFT = Color3.fromRGB(255, 50, 50),   -- rouge vif
    START_RIGHT = Color3.fromRGB(20, 0, 0),     -- noir rougeâtre
    END_LEFT = Color3.fromRGB(50, 255, 50),     -- vert vif
    END_RIGHT = Color3.fromRGB(0, 50, 0),       -- noir verdâtre
}

local S = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    Stats = game:GetService("Stats"),
}

local Packages = S.ReplicatedStorage:WaitForChild("Packages")
local Datas = S.ReplicatedStorage:WaitForChild("Datas")
local Synchronizer = require(Packages:WaitForChild("Synchronizer"))
local AnimalsData = require(Datas:WaitForChild("Animals"))
S.LocalPlayer = S.Players.LocalPlayer

local allAnimalsCache, PromptMemoryCache, InternalStealCache = {}, {}, {}
local stealConnection = nil

local StealState = {
    active = false, startTime = 0, phase = "idle",
    label = "", lastResult = "", lastResultTime = 0,
    totalSteals = 0, failedSteals = 0,
}

-- ==================== MÊMES FONCTIONS MÉTIER (script1) ====================
local function isMyBaseAnimal(animalData) -- ... identique ...
    if not animalData or not animalData.plot then return false end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(animalData.plot)
    if not plot then return false end
    local channel = Synchronizer:Get(plot.Name)
    if channel then
        local owner = channel:Get("Owner")
        if owner then
            if typeof(owner) == "Instance" and owner:IsA("Player") then
                return owner.UserId == S.LocalPlayer.UserId
            elseif typeof(owner) == "table" and owner.UserId then
                return owner.UserId == S.LocalPlayer.UserId
            elseif typeof(owner) == "Instance" then
                return owner == S.LocalPlayer
            end
        end
    end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yourBase = sign:FindFirstChild("YourBase")
        if yourBase and yourBase:IsA("BillboardGui") then
            return yourBase.Enabled == true
        end
    end
    return false
end

local function findProximityPromptForAnimal(animalData) -- ... identique ...
    if not animalData then return nil end
    local cached = PromptMemoryCache[animalData.uid]
    if cached and cached.Parent then return cached end
    local plot = workspace.Plots:FindFirstChild(animalData.plot)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    local podium = podiums:FindFirstChild(animalData.slot)
    if not podium then return nil end
    local base = podium:FindFirstChild("Base")
    if not base then return nil end
    local spawn = base:FindFirstChild("Spawn")
    if not spawn then return nil end
    local attach = spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, p in ipairs(attach:GetChildren()) do
        if p:IsA("ProximityPrompt") then
            PromptMemoryCache[animalData.uid] = p
            return p
        end
    end
    return nil
end

local function getAnimalPosition(animalData) -- ... identique ...
    local plot = workspace.Plots:FindFirstChild(animalData.plot)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    local podium = podiums:FindFirstChild(animalData.slot)
    if not podium then return nil end
    return podium:GetPivot().Position
end

local function distToAnimal(animalData) -- ... identique ...
    local character = S.LocalPlayer.Character
    if not character then return math.huge end
    local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
    if not hrp then return math.huge end
    local pos = getAnimalPosition(animalData)
    if not pos then return math.huge end
    return (hrp.Position - pos).Magnitude
end

local function pickClosest() -- ... identique ...
    local character = S.LocalPlayer.Character
    if not character then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
    if not hrp then return nil end
    local best, bestDist = nil, math.huge
    for _, animalData in ipairs(allAnimalsCache) do
        if isMyBaseAnimal(animalData) then continue end
        local pos = getAnimalPosition(animalData)
        if not pos then continue end
        local dist = (hrp.Position - pos).Magnitude
        if dist > CONFIG.PRIME_RANGE then continue end
        if dist < bestDist then bestDist, best = dist, animalData end
    end
    return best
end

local function buildStealCallbacks(prompt) -- ... identique ...
    if InternalStealCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(conns1) == "table" then
        for _, conn in ipairs(conns1) do
            if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end
        end
    end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(conns2) == "table" then
        for _, conn in ipairs(conns2) do
            if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end
        end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then
        InternalStealCache[prompt] = data
    end
end

local function executeStealAsync(prompt, animalData) -- ... identique ...
    local data = InternalStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    local label = animalData.name or "Animal"
    StealState.active, StealState.startTime, StealState.phase, StealState.label = true, tick(), "holding", label
    task.spawn(function()
        for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
        task.wait(CONFIG.HOLD_MIN)
        StealState.phase = "waitingRange"
        local alreadyInRange = distToAnimal(animalData) <= CONFIG.STEAL_RANGE
        local fired = false
        while true do
            if tick() - StealState.startTime > CONFIG.HOLD_MAX then break end
            if not prompt.Parent then break end
            if distToAnimal(animalData) <= CONFIG.STEAL_RANGE then
                if not alreadyInRange then task.wait(CONFIG.ENTRY_DELAY) end
                for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
                fired = true
                break
            end
            task.wait()
        end
        if fired then
            StealState.totalSteals += 1
            StealState.lastResult = "Stole " .. label
        else
            StealState.failedSteals += 1
            StealState.lastResult = "Missed window: " .. label
        end
        StealState.active, StealState.phase = false, "idle"
        StealState.lastResultTime = tick()
        task.wait(CONFIG.COOLDOWN)
        data.ready = true
    end)
    return true
end

local function attemptSteal(prompt, animalData) -- ... identique ...
    if not prompt or not prompt.Parent then return false end
    buildStealCallbacks(prompt)
    if not InternalStealCache[prompt] then return false end
    return executeStealAsync(prompt, animalData)
end

local function scanAllPlots() -- ... identique ...
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return 0 end
    local newCache = {}
    for _, plot in ipairs(plots:GetChildren()) do
        local channel = Synchronizer:Get(plot.Name)
        if not channel then continue end
        local animalList = channel:Get("AnimalList")
        if not animalList then continue end
        local owner = channel:Get("Owner")
        if not owner then continue end
        for slot, animalData in pairs(animalList) do
            if type(animalData) == "table" then
                local animalName = animalData.Index
                local animalInfo = AnimalsData[animalName]
                if not animalInfo then continue end
                table.insert(newCache, {
                    name = animalInfo.DisplayName or animalName,
                    plot = plot.Name,
                    slot = tostring(slot),
                    uid = plot.Name .. "_" .. tostring(slot),
                })
            end
        end
    end
    allAnimalsCache = newCache
    return #allAnimalsCache
end

local function startAutoSteal() -- ... identique ...
    if stealConnection then return end
    stealConnection = S.RunService.Heartbeat:Connect(function()
        if not CONFIG.AUTO_STEAL_ENABLED then return end
        if StealState.active then return end
        local target = pickClosest()
        if not target then return end
        local prompt = PromptMemoryCache[target.uid]
        if not prompt or not prompt.Parent then prompt = findProximityPromptForAnimal(target) end
        if prompt then attemptSteal(prompt, target) end
    end)
end

local function stopAutoSteal()
    if stealConnection then stealConnection:Disconnect() end
    stealConnection = nil
end

-- ==================== INTERFACE (script2 avec améliorations) ====================
local gui, pillFrame, leftSection, leftFill, percentLabel, statsLabel
local fillGradient  -- garder une référence pour changer la couleur

local function safeDisconnect(conn)
    if conn then conn:Disconnect() end
end

local function destroyExistingGui()
    local playerGui = S.LocalPlayer:WaitForChild("PlayerGui")
    local old = playerGui:FindFirstChild(CONFIG.GUI_NAME)
    if old then old:Destroy() end
end

local function makeCorner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = instance
    return c
end

local function makeStroke(instance, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = instance
    return s
end

local function enableDragging(target, handle)
    local dragging, dragStart, startPos, moved = false
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, false
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not moved then
                        CONFIG.AUTO_STEAL_ENABLED = not CONFIG.AUTO_STEAL_ENABLED
                        if CONFIG.AUTO_STEAL_ENABLED then startAutoSteal() else stopAutoSteal() end
                    end
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            if not moved and (math.abs(delta.X) > 4 or math.abs(delta.Y) > 4) then moved = true end
            if moved then
                target.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    S.UserInputService.InputChanged:Connect(function(input)
        if dragging and moved and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function getPingMs()
    local ping = 0
    pcall(function() ping = math.floor(S.LocalPlayer:GetNetworkPing() * 1000) end)
    if ping > 0 then return ping end
    local network = S.Stats:FindFirstChild("Network")
    if network and network:FindFirstChild("ServerStatsItem") then
        local serverStats = network.ServerStatsItem
        local dataPing = serverStats:FindFirstChild("Data Ping")
        if dataPing then
            pcall(function() ping = math.floor(dataPing:GetValue()) end)
        end
    end
    return ping
end

local function updateProgress(progress)
    progress = math.clamp(progress, 0, 1)
    if leftFill then
        leftFill.Size = UDim2.new(progress, 0, 1, 0)
    end
    if percentLabel then
        percentLabel.Text = string.format("%d%%", math.floor(progress * 100 + 0.5))
    end

    -- Mise à jour du gradient de couleur
    if fillGradient then
        local leftColor = CONFIG.START_LEFT:Lerp(CONFIG.END_LEFT, progress)
        local rightColor = CONFIG.START_RIGHT:Lerp(CONFIG.END_RIGHT, progress)
        fillGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, leftColor),
            ColorSequenceKeypoint.new(1, rightColor),
        })
    end
end

local function buildPillUI()
    destroyExistingGui()

    gui = Instance.new("ScreenGui")
    gui.Name = CONFIG.GUI_NAME
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = S.LocalPlayer:WaitForChild("PlayerGui")

    pillFrame = Instance.new("Frame")
    pillFrame.Name = "PillBar"
    pillFrame.AnchorPoint = Vector2.new(0.5, 0)
    pillFrame.Position = UDim2.new(0.5, 0, 0, 20)
    pillFrame.Size = UDim2.new(0, CONFIG.WIDTH, 0, CONFIG.HEIGHT)
    pillFrame.BackgroundColor3 = CONFIG.BG
    pillFrame.BorderSizePixel = 0
    pillFrame.Parent = gui
    makeCorner(pillFrame, 999)
    makeStroke(pillFrame, CONFIG.OUTLINE, 1, 0.05)

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -6, 1, -6)
    content.Position = UDim2.new(0, 3, 0, 3)
    content.BackgroundTransparency = 1
    content.ZIndex = 2
    content.Parent = pillFrame

    leftSection = Instance.new("Frame")
    leftSection.Name = "LeftSection"
    leftSection.Size = UDim2.new(0, CONFIG.LEFT_WIDTH, 1, 0)
    leftSection.BackgroundColor3 = CONFIG.BG_SOFT
    leftSection.BorderSizePixel = 0
    leftSection.ClipsDescendants = false  -- pas nécessaire avec l'arrondi du fill
    leftSection.Parent = content
    makeCorner(leftSection, 999)

    local leftOverlay = Instance.new("Frame")
    leftOverlay.Size = UDim2.new(1, 0, 1, 0)
    leftOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    leftOverlay.BackgroundTransparency = 0.988
    leftOverlay.BorderSizePixel = 0
    leftOverlay.Parent = leftSection
    makeCorner(leftOverlay, 999)

    leftFill = Instance.new("Frame")
    leftFill.Name = "ProgressFill"
    leftFill.Size = UDim2.new(0, 0, 1, 0)
    leftFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- sera masqué par le gradient
    leftFill.BorderSizePixel = 0
    leftFill.Parent = leftSection
    makeCorner(leftFill, 999)  -- <-- rend la barre arrondie pour ne pas dépasser
    leftFill.ZIndex = 1

    fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.START_LEFT),
        ColorSequenceKeypoint.new(1, CONFIG.START_RIGHT),
    })
    fillGradient.Rotation = 0
    fillGradient.Parent = leftFill

    makeStroke(leftSection, CONFIG.INNER_OUTLINE, 1, 0.18)

    local stealLabel = Instance.new("TextLabel")
    stealLabel.Name = "StealLabel"
    stealLabel.BackgroundTransparency = 1
    stealLabel.Position = UDim2.new(0, 14, 0, 0)
    stealLabel.Size = UDim2.new(0, 120, 1, 0)
    stealLabel.Font = Enum.Font.GothamBlack
    stealLabel.Text = "STEAL"
    stealLabel.TextColor3 = CONFIG.TEXT
    stealLabel.TextSize = 11
    stealLabel.TextXAlignment = Enum.TextXAlignment.Left
    stealLabel.ZIndex = 3
    stealLabel.Parent = leftSection

    percentLabel = Instance.new("TextLabel")
    percentLabel.Name = "PercentLabel"
    percentLabel.BackgroundTransparency = 1
    percentLabel.AnchorPoint = Vector2.new(1, 0)
    percentLabel.Position = UDim2.new(1, -11, 0, 0)
    percentLabel.Size = UDim2.new(0, 46, 1, 0)
    percentLabel.Font = Enum.Font.GothamBlack
    percentLabel.Text = "0%"
    percentLabel.TextColor3 = CONFIG.TEXT
    percentLabel.TextSize = 10
    percentLabel.TextXAlignment = Enum.TextXAlignment.Right
    percentLabel.ZIndex = 3
    percentLabel.Parent = leftSection

    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Position = UDim2.new(0, CONFIG.LEFT_WIDTH + 5, 0.13, 0)
    divider.Size = UDim2.new(0, 1, 0.74, 0)
    divider.BackgroundColor3 = Color3.fromRGB(216, 216, 222)
    divider.BackgroundTransparency = 0.28
    divider.BorderSizePixel = 0
    divider.ZIndex = 3
    divider.Parent = content

    rightSection = Instance.new("Frame")
    rightSection.Name = "RightSection"
    rightSection.Position = UDim2.new(0, CONFIG.LEFT_WIDTH + 11, 0, 0)
    rightSection.Size = UDim2.new(0, CONFIG.RIGHT_WIDTH - 11, 1, 0)
    rightSection.BackgroundTransparency = 1
    rightSection.Parent = content

    statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.BackgroundTransparency = 1
    statsLabel.Size = UDim2.new(1, -8, 1, 0)
    statsLabel.Position = UDim2.new(0, 8, 0, 0)
    statsLabel.Font = Enum.Font.GothamBold
    statsLabel.Text = "0 FPS | 0ms | R:" .. CONFIG.PRIME_RANGE
    statsLabel.TextColor3 = CONFIG.MUTED
    statsLabel.TextSize = 10
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Parent = rightSection

    enableDragging(pillFrame, pillFrame)
    updateProgress(0)
end

-- Mise à jour FPS + progression
local lastFrameTick = tick()
local fpsCounter = 0
local currentFps = 60
local renderConnection

local function startUIUpdater()
    safeDisconnect(renderConnection)
    lastFrameTick = tick()
    fpsCounter = 0
    renderConnection = S.RunService.RenderStepped:Connect(function()
        fpsCounter += 1
        local now = tick()
        if now - lastFrameTick >= 1 then
            currentFps = fpsCounter
            fpsCounter = 0
            lastFrameTick = now
        end

        local progress = 0
        if StealState.active then
            progress = math.clamp((tick() - StealState.startTime) / CONFIG.HOLD_MAX, 0, 1)
        end
        updateProgress(progress)

        if statsLabel then
            statsLabel.Text = string.format("%d FPS | %dms | R:%d", currentFps, getPingMs(), CONFIG.PRIME_RANGE)
        end
    end)
end

-- ==================== INITIALISATION ====================
buildPillUI()
startUIUpdater()

task.spawn(function()
    while task.wait(5) do scanAllPlots() end
end)

scanAllPlots()
if CONFIG.AUTO_STEAL_ENABLED then startAutoSteal() end
