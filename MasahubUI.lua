-- This Code Published By Randomx Hub
-- discord.gg/RQyQdTzGA
-- share this script 
-- always love my members


if _G.ChilliMainLoaded then
    warn("[Chilli Hub] Already loaded!")
    return
end
_G.ChilliMainLoaded = true
_G.FlyToBestState = _G.FlyToBestState or {}
_G.TpToBestState = _G.TpToBestState or {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local PathfindingService = game:GetService("PathfindingService")
local VirtualUser = game:GetService("VirtualUser")
local ContextActionService = game:GetService("ContextActionService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera
local cloneref = cloneref or function(instance) return instance end
local gethui = gethui or function() return game:GetService("CoreGui") end
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local function getCharacter()
    return LocalPlayer.Character
end
local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end
local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end
local function waitForCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if Character then
        Character:WaitForChild("HumanoidRootPart", 10)
        Character:WaitForChild("Humanoid", 10)
    end
    return Character
end
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    waitForCharacter()
end)
local function parsePrice(text)
    if not text then return 0 end
    local num, suffix = text:match("%$?([%d%.]+)%s*([KMB]?)")
    if not num then return 0 end
    local value = tonumber(num) or 0
    if suffix == "K" then value = value * 1000
    elseif suffix == "M" then value = value * 1000000
    elseif suffix == "B" then value = value * 1000000000
    end
    return value
end
local function trim(str)
    if not str then return "" end
    return str:match("^%s*(.-)%s*$") or str
end
local function getBrainrotDisplayName(spawn)
    if not spawn or not spawn.Parent then return "" end
    local displayLabel = spawn.Parent:FindFirstChild("DisplayName")
    if not displayLabel or not displayLabel:IsA("TextLabel") then return "" end
    if displayLabel.Text == "" or displayLabel.Text == "DisplayName" then return "" end
    local rawText = trim(displayLabel.Text)
    local name = rawText:match("([^%(%[]+)")
    return trim(name) or rawText
end
local function getLocationDescription(part)
    if not part then return "[Unknown]" end
    if part:IsDescendantOf(workspace:FindFirstChild("Debris")) then
        return "[Debris / Dropped Item]"
    end
    local ancestor = part:FindFirstAncestorOfClass("Model")
    if ancestor and ancestor.Parent == workspace:FindFirstChild("Plots") then
        return "[Plot: " .. ancestor.Name .. "]"
    end
    return "[World]"
end
local function isNearLosMatteos(position)
    if not position then return false end
    local events = workspace:FindFirstChild("Events")
    if not events then return false end
    local losMatteos = events:FindFirstChild("Los Matteos")
    if not losMatteos then return false end
    local part = losMatteos:IsA("BasePart") and losMatteos or losMatteos:FindFirstChildWhichIsA("BasePart")
    if not part then return false end
    return (part.Position - position).Magnitude < 50
end
local function getPlayerCount()
    return #Players:GetPlayers()
end
local function isGrappleTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local name = string.lower(tool.Name)
    return name:find("grapple") or name:find("hook") or name:find("rope")
end
local CONFIG_FOLDER = "Chilli Hub Brainot"
local CONFIG_FILE = CONFIG_FOLDER .. "/" .. LocalPlayer.Name .. ".json"
local DefaultConfig = {
    SpeedBoost = false,
    SpeedBoost_Speed = 45,
    SpeedBoost_Key = "Q",
    SpeedBoostUIEnabled = false,
    InfinityJump = false,
    CB_Enabled = false,
    CB_Visible = true,
    CB_Speed = "16",
    CB_JumpBoost = "50",
    CB_FallIndex = 1,
    ESPHighestNPC_All = false,
    TimerESP = false,
    PlayerBox = false,
    YourBaseESP = false,
    XRayPlots = false,
    AutoCollect = false,
    CollectDelay = 0.1,
    AutoFish = false,
    AutoBuyRod = false,
    SellBrainrots = false,
    SellThresholdText = "1M",
    AutoBuyBrainrot = false,
    BrainrotThresh = "500K",
    Lockbase = false,
    AutoPreventAFK = false,
    AutoAimbotTaser = false,
    AntiRagdollConditional = false,
    AntiBeeEnabled = false,
    ReduceGraphics = false,
    FlyToBestUIEnabled = false,
    TpToBestUIEnabled = false,
    SpeedBoostUI_PosX = 30,
    SpeedBoostUI_PosY = 90,
    SB_Spam = {
        REEQUIP_DELAY = 0
    }
}
local Config = {}
for k, v in pairs(DefaultConfig) do
    Config[k] = v
end
local function loadConfig()
    if not isfolder or not isfile or not readfile then return Config end
    if not isfolder(CONFIG_FOLDER) then
        if makefolder then makefolder(CONFIG_FOLDER) end
        return Config
    end
    if not isfile(CONFIG_FILE) then return Config end
    local success, data = pcall(function()
        local content = readfile(CONFIG_FILE)
        if content and #content > 0 then
            return HttpService:JSONDecode(content)
        end
    end)
    if success and data then
        for k, v in pairs(data) do
            Config[k] = v
        end
    end
    return Config
end
local function saveConfig(updates)
    if updates then
        for k, v in pairs(updates) do
            Config[k] = v
        end
    end
    if not writefile or not isfolder then return end
    if not isfolder(CONFIG_FOLDER) then
        if makefolder then makefolder(CONFIG_FOLDER) end
    end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
    end)
end
local function mergeSpamConfig(base, override)
    local result = {}
    for k, v in pairs(base) do
        result[k] = v
    end
    if type(override) == "table" then
        for k, v in pairs(override) do
            if base[k] ~= nil and type(v) == type(base[k]) then
                result[k] = v
            end
        end
    end
    return result
end
loadConfig()
local function getPackages()
    return ReplicatedStorage:FindFirstChild("Packages")
end
local function getNet()
    local packages = getPackages()
    return packages and packages:FindFirstChild("Net")
end
local function getRemote(name)
    local net = getNet()
    return net and net:FindFirstChild(name)
end
local function getREUseItem()
    return getRemote("RE/UseItem")
end
local function getRESell()
    return getRemote("RE/PlotService/Sell")
end
local function getRFBuy()
    return getRemote("RF/CoinsShopService/RequestBuy")
end
local function getAllPlots()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return {} end
    local result = {}
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") then
            table.insert(result, plot)
        end
    end
    return result
end
local function getAnimalPodiums(plot)
    return plot and plot:FindFirstChild("AnimalPodiums")
end
local function getPodiumSpawn(podiums, index)
    local podium = podiums:FindFirstChild(tostring(index))
    if not podium then return nil end
    local base = podium:FindFirstChild("Base")
    if not base then return nil end
    local spawn = base:FindFirstChild("Spawn")
    return spawn
end
local function findHighestValueBrainrot()
    local highestValue = 0
    local highestSpawn = nil
    local highestName = ""
    local highestPlot = nil
    local plots = getAllPlots()
    for _, plot in ipairs(plots) do
        local podiums = getAnimalPodiums(plot)
        if podiums then
            for i = 1, 40 do
                local spawn = getPodiumSpawn(podiums, i)
                if spawn then
                    local position = spawn.Position
                    if not isNearLosMatteos(position) then
                        local name = getBrainrotDisplayName(spawn)
                        local parent = spawn.Parent
                        if parent then
                            for _, child in ipairs(parent:GetDescendants()) do
                                if child:IsA("TextLabel") and child.Text and child.Text ~= "" then
                                    local price = parsePrice(child.Text)
                                    if price > highestValue then
                                        highestValue = price
                                        highestSpawn = spawn
                                        highestName = name ~= "" and name or ("Podium " .. i)
                                        highestPlot = plot
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local debris = workspace:FindFirstChild("Debris")
    if debris then
        for _, item in ipairs(debris:GetChildren()) do
            if string.lower(item.Name) == "lucky block" or item:IsA("Model") then
                for _, child in ipairs(item:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        local price = parsePrice(child.Text)
                        if price > highestValue then
                            highestValue = price
                            highestSpawn = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
                            highestName = item.Name
                            highestPlot = nil
                        end
                    end
                end
            end
        end
    end
    return highestSpawn, highestValue, highestName, highestPlot
end
local Connections = {}
local function addConnection(name, connection)
    if Connections[name] then
        pcall(function() Connections[name]:Disconnect() end)
    end
    Connections[name] = connection
end
local function removeConnection(name)
    if Connections[name] then
        pcall(function() Connections[name]:Disconnect() end)
        Connections[name] = nil
    end
end
local function clearConnections()
    for name, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}
end
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0, 0))
end)
local SpeedBoost = {
    Enabled = false,
    Speed = 45,
    Connection = nil
}
function SpeedBoost.getSpeed()
    local speed = tonumber(Config.SpeedBoost_Speed) or 45
    return math.clamp(speed, 16, 200)
end
function SpeedBoost.start()
    if SpeedBoost.Connection then return end
    SpeedBoost.Enabled = true
    SpeedBoost.Connection = RunService.RenderStepped:Connect(function()
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = SpeedBoost.getSpeed()
        end
    end)
end
function SpeedBoost.stop()
    SpeedBoost.Enabled = false
    if SpeedBoost.Connection then
        SpeedBoost.Connection:Disconnect()
        SpeedBoost.Connection = nil
    end
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = 16
    end
end
local GrappleSpam = {
    Enabled = false,
    Connection = nil,
    CurrentTool = nil,
    REEQUIP_DELAY = 0
}
function GrappleSpam.findGrappleTool()
    local char = getCharacter()
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if isGrappleTool(tool) then
            return tool
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if isGrappleTool(tool) then
                return tool
            end
        end
    end
    return nil
end
function GrappleSpam.equip()
    local tool = GrappleSpam.findGrappleTool()
    if not tool then return false end
    local humanoid = getHumanoid()
    if not humanoid then return false end
    if tool.Parent ~= getCharacter() then
        humanoid:EquipTool(tool)
        task.wait(GrappleSpam.REEQUIP_DELAY)
    end
    GrappleSpam.CurrentTool = tool
    return true
end
function GrappleSpam.unequip()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid:UnequipTools()
    end
    GrappleSpam.CurrentTool = nil
end
function GrappleSpam.fire(targetPosition)
    local remote = getREUseItem()
    if not remote then return end
    pcall(function()
        remote:FireServer(1.983, targetPosition)
    end)
end
function GrappleSpam.start(targetPosition)
    if GrappleSpam.Connection then return end
    GrappleSpam.Enabled = true
    GrappleSpam.Connection = RunService.Heartbeat:Connect(function()
        if not GrappleSpam.Enabled then return end
        if GrappleSpam.equip() then
            GrappleSpam.fire(targetPosition)
            task.wait(0.1)
            GrappleSpam.unequip()
            task.wait(GrappleSpam.REEQUIP_DELAY)
        end
    end)
end
function GrappleSpam.stop()
    GrappleSpam.Enabled = false
    if GrappleSpam.Connection then
        GrappleSpam.Connection:Disconnect()
        GrappleSpam.Connection = nil
    end
    GrappleSpam.unequip()
end
local JumpBoost = {
    Enabled = false,
    Power = 50
}
function JumpBoost.apply()
    local humanoid = getHumanoid()
    if not humanoid then return end
    local power = tonumber(Config.CB_JumpBoost) or 50
    humanoid.UseJumpPower = true
    humanoid.JumpPower = power
end
function JumpBoost.reset()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = 50
    end
end
local FalldownController = {
    Attachment = nil,
    VectorForce = nil,
    Connection = nil,
    FallIndex = 1
}
local FALL_OPTIONS = {
    [1] = {name = "Normal", multiplier = 1},
    [2] = {name = "Light", multiplier = 0.5},
    [3] = {name = "Floaty", multiplier = 0.25},
    [4] = {name = "Moon", multiplier = 0.1},
    [5] = {name = "Zero-G", multiplier = 0}
}
function FalldownController.setup()
    local hrp = getHRP()
    if not hrp then return end
    FalldownController.clear()
    local attach = Instance.new("Attachment")
    attach.Name = "DTK_Fall_Attach"
    attach.Parent = hrp
    FalldownController.Attachment = attach
    local force = Instance.new("VectorForce")
    force.Name = "DTK_Falldown"
    force.Attachment0 = attach
    force.RelativeTo = Enum.ActuatorRelativeTo.World
    force.ApplyAtCenterOfMass = true
    force.Force = Vector3.new(0, 0, 0)
    force.Parent = hrp
    FalldownController.VectorForce = force
end
function FalldownController.start()
    FalldownController.setup()
    if not FalldownController.VectorForce then return end
    FalldownController.Connection = RunService.RenderStepped:Connect(function(dt)
        local hrp = getHRP()
        if not hrp or not FalldownController.VectorForce then return end
        local fallOption = FALL_OPTIONS[FalldownController.FallIndex] or FALL_OPTIONS[1]
        local multiplier = fallOption.multiplier
        if multiplier == 1 then
            FalldownController.VectorForce.Force = Vector3.new(0, 0, 0)
        else
            local counterForce = hrp.AssemblyMass * workspace.Gravity * (1 - multiplier)
            FalldownController.VectorForce.Force = Vector3.new(0, counterForce, 0)
        end
    end)
end
function FalldownController.stop()
    if FalldownController.Connection then
        FalldownController.Connection:Disconnect()
        FalldownController.Connection = nil
    end
    FalldownController.clear()
end
function FalldownController.clear()
    if FalldownController.VectorForce then
        FalldownController.VectorForce:Destroy()
        FalldownController.VectorForce = nil
    end
    if FalldownController.Attachment then
        FalldownController.Attachment:Destroy()
        FalldownController.Attachment = nil
    end
end
local InfinityJump = {
    Enabled = false,
    InputConnection = nil,
    MobileConnections = {}
}
function InfinityJump.start()
    if InfinityJump.InputConnection then return end
    InfinityJump.Enabled = true
    InfinityJump.InputConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if not InfinityJump.Enabled then return end
        if input.KeyCode == Enum.KeyCode.Space then
            local humanoid = getHumanoid()
            local hrp = getHRP()
            if humanoid and hrp then
                if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, humanoid.JumpPower, hrp.Velocity.Z)
                end
            end
        end
    end)
    InfinityJump.bindMobileJump()
end
function InfinityJump.bindMobileJump()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("ImageButton") and string.find(string.lower(gui.Name), "jump") then
            local conn = gui.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    local humanoid = getHumanoid()
                    local hrp = getHRP()
                    if humanoid and hrp and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, humanoid.JumpPower, hrp.Velocity.Z)
                    end
                end
            end)
            table.insert(InfinityJump.MobileConnections, conn)
        end
    end
end
function InfinityJump.stop()
    InfinityJump.Enabled = false
    if InfinityJump.InputConnection then
        InfinityJump.InputConnection:Disconnect()
        InfinityJump.InputConnection = nil
    end
    for _, conn in ipairs(InfinityJump.MobileConnections) do
        pcall(function() conn:Disconnect() end)
    end
    InfinityJump.MobileConnections = {}
end
local Fly = {
    Enabled = false,
    Speed = 50,
    BodyGyro = nil,
    BodyVelocity = nil,
    Connection = nil
}
function Fly.start()
    if Fly.Connection then return end
    local hrp = getHRP()
    if not hrp then return end
    Fly.Enabled = true
    Fly.BodyGyro = Instance.new("BodyGyro")
    Fly.BodyGyro.P = 9e4
    Fly.BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    Fly.BodyGyro.cframe = hrp.CFrame
    Fly.BodyGyro.Parent = hrp
    Fly.BodyVelocity = Instance.new("BodyVelocity")
    Fly.BodyVelocity.velocity = Vector3.new(0, 0, 0)
    Fly.BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    Fly.BodyVelocity.Parent = hrp
    Fly.Connection = RunService.RenderStepped:Connect(function()
        if not Fly.Enabled then return end
        local hrp = getHRP()
        if not hrp or not Fly.BodyGyro or not Fly.BodyVelocity then return end
        Fly.BodyGyro.cframe = Camera.CFrame
        local moveDir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end
        Fly.BodyVelocity.velocity = moveDir * Fly.Speed
    end)
end
function Fly.stop()
    Fly.Enabled = false
    if Fly.Connection then
        Fly.Connection:Disconnect()
        Fly.Connection = nil
    end
    if Fly.BodyGyro then
        Fly.BodyGyro:Destroy()
        Fly.BodyGyro = nil
    end
    if Fly.BodyVelocity then
        Fly.BodyVelocity:Destroy()
        Fly.BodyVelocity = nil
    end
end
local Noclip = {
    Enabled = false,
    Connection = nil
}
function Noclip.start()
    if Noclip.Connection then return end
    Noclip.Enabled = true
    Noclip.Connection = RunService.Stepped:Connect(function()
        if not Noclip.Enabled then return end
        local char = getCharacter()
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end
function Noclip.stop()
    Noclip.Enabled = false
    if Noclip.Connection then
        Noclip.Connection:Disconnect()
        Noclip.Connection = nil
    end
end
local AntiRagdoll = {
    Enabled = false,
    Connections = {}
}
function AntiRagdoll.isInPlayerHitbox(part)
    if not part or not part.Parent then return false end
    if part.Name == "__HITBOX" then return true end
    local char = getCharacter()
    if char and part:IsDescendantOf(char) then
        local hitbox = char:FindFirstChild("__HITBOX")
        if hitbox and part:IsDescendantOf(hitbox) then
            return true
        end
    end
    return false
end
function AntiRagdoll.attachWatcher(part)
    if not part or part.Name == "HumanoidRootPart" then return end
    if AntiRagdoll.isInPlayerHitbox(part) then return end
    local function resetTransparency()
        if not part or not part.Parent then return end
        if AntiRagdoll.isInPlayerHitbox(part) then return end
        if part.Transparency ~= 0 then
            part.Transparency = 0
        end
        if part.LocalTransparencyModifier ~= 0 then
            part.LocalTransparencyModifier = 0
        end
    end
    resetTransparency()
    local conn1 = part:GetPropertyChangedSignal("Transparency"):Connect(resetTransparency)
    local conn2 = part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(resetTransparency)
    table.insert(AntiRagdoll.Connections, conn1)
    table.insert(AntiRagdoll.Connections, conn2)
end
function AntiRagdoll.start()
    AntiRagdoll.Enabled = true
    local char = getCharacter()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            AntiRagdoll.attachWatcher(part)
        end
    end
end
function AntiRagdoll.stop()
    AntiRagdoll.Enabled = false
    for _, conn in ipairs(AntiRagdoll.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    AntiRagdoll.Connections = {}
end
local FlyToBest = {
    Enabled = false,
    TargetSpawn = nil,
    TargetPlot = nil,
    Connection = nil
}
function FlyToBest.getNearestPlotToPos(position)
    local plots = getAllPlots()
    local nearest = nil
    local nearestDist = math.huge
    for _, plot in ipairs(plots) do
        local plotSign = plot:FindFirstChild("PlotSign")
        if plotSign and plotSign:IsA("BasePart") then
            local dist = (plotSign.Position - position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = plot
            end
        end
    end
    return nearest
end
function FlyToBest.getPlotFromSpawn(spawn)
    if not spawn then return nil end
    local current = spawn
    for _ = 1, 5 do
        current = current.Parent
        if not current then break end
        if current:IsA("Model") and current.Parent == workspace:FindFirstChild("Plots") then
            return current
        end
    end
    if spawn:IsA("BasePart") then
        return FlyToBest.getNearestPlotToPos(spawn.Position)
    elseif spawn:IsA("Model") then
        local pivot = spawn:GetPivot()
        return FlyToBest.getNearestPlotToPos(pivot.Position)
    end
    return nil
end
function FlyToBest.getPlotSign(plot)
    if not plot or not plot:IsA("Model") then return nil end
    local sign = plot:FindFirstChild("PlotSign", true)
    if sign and sign:IsA("BasePart") then
        return sign
    end
    return nil
end
function FlyToBest.computeTarget()
    local spawn, value, name, plot = findHighestValueBrainrot()
    if spawn then
        FlyToBest.TargetSpawn = spawn
        FlyToBest.TargetPlot = plot or FlyToBest.getPlotFromSpawn(spawn)
        return spawn, value, name
    end
    return nil, 0, ""
end
function FlyToBest.start()
    local spawn = FlyToBest.computeTarget()
    if not spawn then
        warn("[Chilli Hub] No brainrot found to fly to!")
        return
    end
    local targetPos = spawn:IsA("BasePart") and spawn.Position or spawn:GetPivot().Position
    targetPos = targetPos + Vector3.new(0, 5, 0)
    Fly.start()
    FlyToBest.Enabled = true
    FlyToBest.Connection = RunService.RenderStepped:Connect(function()
        if not FlyToBest.Enabled then return end
        local hrp = getHRP()
        if not hrp then return end
        local direction = (targetPos - hrp.Position).Unit
        if Fly.BodyVelocity then
            Fly.BodyVelocity.velocity = direction * Fly.Speed
        end
        if (hrp.Position - targetPos).Magnitude < 5 then
            FlyToBest.stop()
        end
    end)
end
function FlyToBest.stop()
    FlyToBest.Enabled = false
    if FlyToBest.Connection then
        FlyToBest.Connection:Disconnect()
        FlyToBest.Connection = nil
    end
    Fly.stop()
end
function FlyToBest.teleportToBest()
    local spawn = FlyToBest.computeTarget()
    if not spawn then
        warn("[Chilli Hub] No brainrot found to teleport to!")
        return
    end
    local hrp = getHRP()
    if not hrp then return end
    local targetPos = spawn:IsA("BasePart") and spawn.Position or spawn:GetPivot().Position
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
end
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.C then
        if FlyToBest.Enabled then
            FlyToBest.stop()
        else
            FlyToBest.start()
        end
    end
end)
local Pathfinder = {
    CurrentPath = nil,
    Following = false
}
function Pathfinder.pathfindTo(targetPosition)
    local hrp = getHRP()
    local humanoid = getHumanoid()
    if not hrp or not humanoid then return false end
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 7,
        AgentMaxSlope = 45
    })
    local success, err = pcall(function()
        path:ComputeAsync(hrp.Position, targetPosition)
    end)
    if not success then return false end
    if path.Status ~= Enum.PathStatus.Success then return false end
    Pathfinder.CurrentPath = path
    local waypoints = path:GetWaypoints()
    for _, waypoint in ipairs(waypoints) do
        if not Pathfinder.Following then break end
        humanoid:MoveTo(waypoint.Position)
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        humanoid.MoveToFinished:Wait()
    end
    return true
end
function Pathfinder.followTarget(target)
    Pathfinder.Following = true
    task.spawn(function()
        while Pathfinder.Following and target and target.Parent do
            local targetPos = target:IsA("BasePart") and target.Position or target:GetPivot().Position
            Pathfinder.pathfindTo(targetPos)
            task.wait(0.5)
        end
    end)
end
function Pathfinder.stopFollowing()
    Pathfinder.Following = false
    Pathfinder.CurrentPath = nil
end
function Pathfinder.findCandidate()
    local spawn, value, name = findHighestValueBrainrot()
    return spawn
end
local AutoCollect = {
    Enabled = false,
    Connection = nil,
    Delay = 0.1
}
function AutoCollect.start()
    if AutoCollect.Connection then return end
    AutoCollect.Enabled = true
    AutoCollect.Connection = RunService.Heartbeat:Connect(function()
        if not AutoCollect.Enabled then return end
        local hrp = getHRP()
        if not hrp then return end
        local debris = workspace:FindFirstChild("Debris")
        if debris then
            for _, item in ipairs(debris:GetChildren()) do
                if item:IsA("BasePart") or item:IsA("Model") then
                    local pos = item:IsA("BasePart") and item.Position or item:GetPivot().Position
                    if (pos - hrp.Position).Magnitude < 15 then
                        if item:IsA("BasePart") then
                            firetouchinterest(hrp, item, 0)
                            task.wait()
                            firetouchinterest(hrp, item, 1)
                        end
                    end
                end
            end
        end
        task.wait(AutoCollect.Delay)
    end)
end
function AutoCollect.stop()
    AutoCollect.Enabled = false
    if AutoCollect.Connection then
        AutoCollect.Connection:Disconnect()
        AutoCollect.Connection = nil
    end
end
local AutoSell = {
    Enabled = false,
    Connection = nil,
    Threshold = 1000000
}
function AutoSell.parseThreshold(text)
    return parsePrice(text)
end
function AutoSell.start()
    if AutoSell.Connection then return end
    AutoSell.Enabled = true
    AutoSell.Threshold = AutoSell.parseThreshold(Config.SellThresholdText or "1M")
    AutoSell.Connection = RunService.Heartbeat:Connect(function()
        if not AutoSell.Enabled then return end
        local sellRemote = getRESell()
        if not sellRemote then return end
        local plots = getAllPlots()
        for _, plot in ipairs(plots) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local gui = sign:FindFirstChild("SurfaceGui")
                if gui then
                    local frame = gui:FindFirstChild("Frame")
                    if frame then
                        local label = frame:FindFirstChildOfClass("TextLabel")
                        if label and label.Text == LocalPlayer.Name then
                            local podiums = getAnimalPodiums(plot)
                            if podiums then
                                for i = 1, 40 do
                                    local spawn = getPodiumSpawn(podiums, i)
                                    if spawn and spawn.Parent then
                                        for _, child in ipairs(spawn.Parent:GetDescendants()) do
                                            if child:IsA("TextLabel") then
                                                local value = parsePrice(child.Text)
                                                if value > 0 and value < AutoSell.Threshold then
                                                    pcall(function()
                                                        sellRemote:FireServer(i)
                                                    end)
                                                end
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(1)
    end)
end
function AutoSell.stop()
    AutoSell.Enabled = false
    if AutoSell.Connection then
        AutoSell.Connection:Disconnect()
        AutoSell.Connection = nil
    end
end
local PlayerESP = {
    Enabled = false,
    Highlights = {},
    Billboards = {},
    Connections = {}
}
local ESP_COLOR = Color3.fromRGB(85, 170, 255)
function PlayerESP.createHighlight(character)
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerESP_Char"
    highlight.Adornee = character
    highlight.FillColor = ESP_COLOR
    highlight.FillTransparency = 0.22
    highlight.OutlineColor = ESP_COLOR
    highlight.OutlineTransparency = 0.08
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = gethui()
    return highlight
end
function PlayerESP.createBillboard(character, player)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerESP_DisplayName"
    billboard.Adornee = hrp
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 600
    billboard.StudsOffsetWorldSpace = Vector3.new(0, (character:GetExtentsSize().Y / 2) + 0.9, 0)
    billboard.Size = UDim2.new(0, 96, 0, 18)
    billboard.Parent = gethui()
    local bg = Instance.new("Frame")
    bg.Name = "BG"
    bg.Parent = billboard
    bg.AnchorPoint = Vector2.new(0.5, 0.5)
    bg.Position = UDim2.fromScale(0.5, 0.5)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.45
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)
    local padding = Instance.new("UIPadding", bg)
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = bg
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.Text = player.DisplayName
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.12
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    return billboard
end
function PlayerESP.attachToPlayer(player)
    if player == LocalPlayer then return end
    local function setupESP(character)
        if not character then return end
        character:WaitForChild("HumanoidRootPart", 5)
        if PlayerESP.Highlights[player] then
            PlayerESP.Highlights[player]:Destroy()
        end
        if PlayerESP.Billboards[player] then
            PlayerESP.Billboards[player]:Destroy()
        end
        PlayerESP.Highlights[player] = PlayerESP.createHighlight(character)
        PlayerESP.Billboards[player] = PlayerESP.createBillboard(character, player)
    end
    if player.Character then
        setupESP(player.Character)
    end
    local conn = player.CharacterAdded:Connect(setupESP)
    table.insert(PlayerESP.Connections, conn)
end
function PlayerESP.start()
    PlayerESP.Enabled = true
    for _, player in ipairs(Players:GetPlayers()) do
        PlayerESP.attachToPlayer(player)
    end
    local conn = Players.PlayerAdded:Connect(function(player)
        PlayerESP.attachToPlayer(player)
    end)
    table.insert(PlayerESP.Connections, conn)
end
function PlayerESP.stop()
    PlayerESP.Enabled = false
    for _, highlight in pairs(PlayerESP.Highlights) do
        pcall(function() highlight:Destroy() end)
    end
    PlayerESP.Highlights = {}
    for _, billboard in pairs(PlayerESP.Billboards) do
        pcall(function() billboard:Destroy() end)
    end
    PlayerESP.Billboards = {}
    for _, conn in ipairs(PlayerESP.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    PlayerESP.Connections = {}
end
local HighestNPCESP = {
    Enabled = false,
    Beam = nil,
    Attachment0 = nil,
    Attachment1 = nil,
    Connection = nil,
    Hue = 0
}
function HighestNPCESP.createBeam(targetPart)
    HighestNPCESP.cleanup()
    local hrp = getHRP()
    if not hrp or not targetPart then return end
    HighestNPCESP.Attachment0 = Instance.new("Attachment")
    HighestNPCESP.Attachment0.Parent = hrp
    HighestNPCESP.Attachment1 = Instance.new("Attachment")
    HighestNPCESP.Attachment1.Parent = targetPart
    HighestNPCESP.Beam = Instance.new("Beam")
    HighestNPCESP.Beam.Attachment0 = HighestNPCESP.Attachment0
    HighestNPCESP.Beam.Attachment1 = HighestNPCESP.Attachment1
    HighestNPCESP.Beam.Width0 = 0.3
    HighestNPCESP.Beam.Width1 = 0.3
    HighestNPCESP.Beam.FaceCamera = true
    HighestNPCESP.Beam.Brightness = 2
    HighestNPCESP.Beam.LightEmission = 1
    HighestNPCESP.Beam.LightInfluence = 0
    HighestNPCESP.Beam.Parent = gethui()
end
function HighestNPCESP.start()
    HighestNPCESP.Enabled = true
    HighestNPCESP.Connection = RunService.RenderStepped:Connect(function(dt)
        if not HighestNPCESP.Enabled then return end
        HighestNPCESP.Hue = (HighestNPCESP.Hue + dt * 0.5) % 1
        local rainbowColor = Color3.fromHSV(HighestNPCESP.Hue, 1, 1)
        local spawn, value, name = findHighestValueBrainrot()
        if spawn then
            local targetPart = spawn:IsA("BasePart") and spawn or spawn:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                if not HighestNPCESP.Beam or HighestNPCESP.Attachment1.Parent ~= targetPart then
                    HighestNPCESP.createBeam(targetPart)
                end
                if HighestNPCESP.Beam then
                    HighestNPCESP.Beam.Color = ColorSequence.new(rainbowColor)
                end
            end
        else
            HighestNPCESP.cleanup()
        end
    end)
end
function HighestNPCESP.stop()
    HighestNPCESP.Enabled = false
    if HighestNPCESP.Connection then
        HighestNPCESP.Connection:Disconnect()
        HighestNPCESP.Connection = nil
    end
    HighestNPCESP.cleanup()
end
function HighestNPCESP.cleanup()
    if HighestNPCESP.Beam then
        HighestNPCESP.Beam:Destroy()
        HighestNPCESP.Beam = nil
    end
    if HighestNPCESP.Attachment0 then
        HighestNPCESP.Attachment0:Destroy()
        HighestNPCESP.Attachment0 = nil
    end
    if HighestNPCESP.Attachment1 then
        HighestNPCESP.Attachment1:Destroy()
        HighestNPCESP.Attachment1 = nil
    end
end
local XRayPlots = {
    Enabled = false,
    OriginalTransparencies = {}
}
function XRayPlots.start()
    XRayPlots.Enabled = true
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do
        for _, part in ipairs(plot:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "Spawn" then
                XRayPlots.OriginalTransparencies[part] = part.Transparency
                part.Transparency = 0.7
            end
        end
    end
end
function XRayPlots.stop()
    XRayPlots.Enabled = false
    for part, transparency in pairs(XRayPlots.OriginalTransparencies) do
        if part and part.Parent then
            part.Transparency = transparency
        end
    end
    XRayPlots.OriginalTransparencies = {}
end
local ReduceGraphics = {
    Enabled = false,
    OriginalSettings = {}
}
function ReduceGraphics.start()
    ReduceGraphics.Enabled = true
    ReduceGraphics.OriginalSettings.GlobalShadows = Lighting.GlobalShadows
    ReduceGraphics.OriginalSettings.FogEnd = Lighting.FogEnd
    ReduceGraphics.OriginalSettings.Brightness = Lighting.Brightness
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            ReduceGraphics.OriginalSettings[effect] = effect.Enabled
            effect.Enabled = false
        end
    end
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end
function ReduceGraphics.stop()
    ReduceGraphics.Enabled = false
    if ReduceGraphics.OriginalSettings.GlobalShadows ~= nil then
        Lighting.GlobalShadows = ReduceGraphics.OriginalSettings.GlobalShadows
    end
    if ReduceGraphics.OriginalSettings.FogEnd ~= nil then
        Lighting.FogEnd = ReduceGraphics.OriginalSettings.FogEnd
    end
    for effect, enabled in pairs(ReduceGraphics.OriginalSettings) do
        if typeof(effect) == "Instance" and effect:IsA("PostEffect") then
            effect.Enabled = enabled
        end
    end
    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
end
local Aimbot = {
    Enabled = false,
    Connection = nil
}
function Aimbot.findNearestPlayer()
    local hrp = getHRP()
    if not hrp then return nil end
    local nearest = nil
    local nearestDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local enemyHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if enemyHRP then
                local dist = (enemyHRP.Position - hrp.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = enemyHRP
                end
            end
        end
    end
    return nearest
end
function Aimbot.start()
    Aimbot.Enabled = true
    Aimbot.Connection = RunService.RenderStepped:Connect(function()
        if not Aimbot.Enabled then return end
        local target = Aimbot.findNearestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end)
end
function Aimbot.stop()
    Aimbot.Enabled = false
    if Aimbot.Connection then
        Aimbot.Connection:Disconnect()
        Aimbot.Connection = nil
    end
end
local ChilliBoosterUI = {
    ScreenGui = nil,
    MainFrame = nil,
    Visible = true
}
function ChilliBoosterUI.create()
    if ChilliBoosterUI.ScreenGui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "Chilli Booster"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = gethui()
    ChilliBoosterUI.ScreenGui = gui
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 200, 0, 180)
    main.Position = UDim2.new(0, Config.SpeedBoostUI_PosX or 30, 0, Config.SpeedBoostUI_PosY or 90)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    main.BorderSizePixel = 0
    main.Parent = gui
    ChilliBoosterUI.MainFrame = main
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(255, 100, 100)
    stroke.Thickness = 2
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    header.BorderSizePixel = 0
    header.Parent = main
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "🌶️ Chilli Booster"
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -27, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    closeBtn.MouseButton1Click:Connect(function()
        ChilliBoosterUI.toggle(false)
    end)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -40)
    content.Position = UDim2.new(0, 10, 0, 35)
    content.BackgroundTransparency = 1
    content.Parent = main
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = content
    ChilliBoosterUI.createSlider(content, "Speed", 16, 200, tonumber(Config.CB_Speed) or 16, function(value)
        Config.CB_Speed = tostring(value)
        saveConfig()
    end)
    ChilliBoosterUI.createSlider(content, "Jump", 50, 200, tonumber(Config.CB_JumpBoost) or 50, function(value)
        Config.CB_JumpBoost = tostring(value)
        JumpBoost.apply()
        saveConfig()
    end)
    ChilliBoosterUI.createDropdown(content, "Gravity", FALL_OPTIONS, Config.CB_FallIndex or 1, function(index)
        Config.CB_FallIndex = index
        FalldownController.FallIndex = index
        saveConfig()
    end)
    local enableBtn = Instance.new("TextButton")
    enableBtn.Name = "EnableToggle"
    enableBtn.Text = Config.CB_Enabled and "✓ ENABLED" or "○ DISABLED"
    enableBtn.Size = UDim2.new(1, 0, 0, 30)
    enableBtn.BackgroundColor3 = Config.CB_Enabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(80, 80, 85)
    enableBtn.BorderSizePixel = 0
    enableBtn.Font = Enum.Font.GothamBold
    enableBtn.TextSize = 12
    enableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enableBtn.Parent = content
    Instance.new("UICorner", enableBtn).CornerRadius = UDim.new(0, 6)
    enableBtn.MouseButton1Click:Connect(function()
        Config.CB_Enabled = not Config.CB_Enabled
        enableBtn.Text = Config.CB_Enabled and "✓ ENABLED" or "○ DISABLED"
        enableBtn.BackgroundColor3 = Config.CB_Enabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(80, 80, 85)
        if Config.CB_Enabled then
            JumpBoost.apply()
            FalldownController.start()
        else
            JumpBoost.reset()
            FalldownController.stop()
        end
        saveConfig()
    end)
    ChilliBoosterUI.makeDraggable(main, header)
end
function ChilliBoosterUI.createSlider(parent, name, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 0, 15)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name .. ":"
    label.Parent = container
    local valueBox = Instance.new("TextBox")
    valueBox.Name = "ValueBox"
    valueBox.Size = UDim2.new(0.3, 0, 0, 20)
    valueBox.Position = UDim2.new(0.65, 0, 0, 0)
    valueBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    valueBox.BorderSizePixel = 0
    valueBox.Font = Enum.Font.GothamSemibold
    valueBox.TextSize = 12
    valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueBox.Text = tostring(default)
    valueBox.Parent = container
    Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 4)
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 22)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 4)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 4)
    local dragging = false
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
            pos = math.clamp(pos, 0, 1)
            local value = math.floor(min + (max - min) * pos)
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            valueBox.Text = tostring(value)
            callback(value)
        end
    end)
    valueBox.FocusLost:Connect(function()
        local value = tonumber(valueBox.Text)
        if value then
            value = math.clamp(value, min, max)
            valueBox.Text = tostring(value)
            sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            callback(value)
        else
            valueBox.Text = tostring(default)
        end
    end)
end
function ChilliBoosterUI.createDropdown(parent, name, options, default, callback)
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = UDim2.new(1, 0, 0, 25)
    container.BackgroundTransparency = 1
    container.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name .. ":"
    label.Parent = container
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.55, 0, 1, 0)
    btn.Position = UDim2.new(0.45, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = options[default].name
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local currentIndex = default
    btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        btn.Text = options[currentIndex].name
        callback(currentIndex)
    end)
end
function ChilliBoosterUI.makeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            Config.SpeedBoostUI_PosX = frame.Position.X.Offset
            Config.SpeedBoostUI_PosY = frame.Position.Y.Offset
            saveConfig()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end
function ChilliBoosterUI.toggle(visible)
    ChilliBoosterUI.Visible = visible
    if ChilliBoosterUI.ScreenGui then
        ChilliBoosterUI.ScreenGui.Enabled = visible
    end
end
function ChilliBoosterUI.destroy()
    if ChilliBoosterUI.ScreenGui then
        ChilliBoosterUI.ScreenGui:Destroy()
        ChilliBoosterUI.ScreenGui = nil
    end
end
local FloatingToggle = {
    Button = nil
}
function FloatingToggle.create()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OpenButtonGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = gethui()
    local btn = Instance.new("ImageButton")
    btn.Name = "FloatingToggle"
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0, 10, 0.5, -25)
    btn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    btn.BorderSizePixel = 0
    btn.Image = "rbxassetid://6031071053"
    btn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = screenGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.5, 0)
    FloatingToggle.Button = btn
    btn.MouseButton1Click:Connect(function()
        ChilliBoosterUI.toggle(not ChilliBoosterUI.Visible)
    end)
    local dragging = false
    local dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end
local function notify(title, description, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Chilli Hub",
            Text = description or "",
            Duration = duration or 3
        })
    end)
end
local Webhook = {
    URL = nil,
    MinValue = 500000
}
function Webhook.send(spawn, value)
    if not Webhook.URL or value < Webhook.MinValue then return end
    if getPlayerCount() ~= 8 then return end
    local name = getBrainrotDisplayName(spawn)
    local location = getLocationDescription(spawn)
    local embed = {
        title = "🌶️ High Value Brainrot Found!",
        description = "**" .. name .. "**\nValue: **$" .. tostring(value) .. "**",
        color = value >= 10000000 and 16711680 or (value >= 1000000 and 16744448 or 65280),
        fields = {
            {name = "Player", value = LocalPlayer.Name .. " (" .. LocalPlayer.UserId .. ")", inline = true},
            {name = "Location", value = location, inline = true},
            {name = "Server", value = getPlayerCount() .. "/8", inline = true}
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    if request or http_request then
        local req = request or http_request
        pcall(function()
            req({
                Url = Webhook.URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({embeds = {embed}})
            })
        end)
    end
end
local BatchChecker = {
    LastCheck = 0,
    Interval = 0.5
}
function BatchChecker.check()
    local now = tick()
    if now - BatchChecker.LastCheck < BatchChecker.Interval then return end
    BatchChecker.LastCheck = now
    local map = workspace:FindFirstChild("Map")
    if map then
        local codes = map:FindFirstChild("Codes")
        if codes then
            local progressText = codes:FindFirstChild("Main")
            if progressText then
                local gui = progressText:FindFirstChild("SurfaceGui")
                if gui then
                    local frame = gui:FindFirstChild("MainFrame")
                    if frame then
                        local bar = frame:FindFirstChild("ProgressBar")
                        if bar and bar:FindFirstChild("Bar") then
                            local text = bar.Bar:FindFirstChild("ProgressText")
                            if text and text.Text == "50/250" then
                            end
                        end
                    end
                end
            end
        end
    end
    local spawn, value, name = findHighestValueBrainrot()
    if spawn and value >= Webhook.MinValue then
        Webhook.send(spawn, value)
    end
end
local ChilliBooster = {}
function ChilliBooster.enable()
    Config.CB_Enabled = true
    saveConfig({CB_Enabled = true})
    JumpBoost.apply()
    FalldownController.start()
    notify("Chilli Booster", "Enabled!", 2)
end
function ChilliBooster.disable()
    Config.CB_Enabled = false
    saveConfig({CB_Enabled = false})
    JumpBoost.reset()
    FalldownController.stop()
    notify("Chilli Booster", "Disabled!", 2)
end
function ChilliBooster.reconcileModes()
    local isStealing = LocalPlayer:GetAttribute("Stealing")
    if Config.InfinityJump and not isStealing then
        InfinityJump.start()
    end
    if Config.CB_Enabled then
        JumpBoost.apply()
        FalldownController.start()
    end
end
function ChilliBooster.coldStart()
    if Config.CB_Enabled then
        ChilliBooster.enable()
    end
    if Config.SpeedBoost then
        SpeedBoost.start()
    end
    if Config.InfinityJump then
        InfinityJump.start()
    end
    if Config.ESPHighestNPC_All then
        HighestNPCESP.start()
    end
    if Config.PlayerBox then
        PlayerESP.start()
    end
    if Config.XRayPlots then
        XRayPlots.start()
    end
    if Config.ReduceGraphics then
        ReduceGraphics.start()
    end
    if Config.AutoAimbotTaser then
        Aimbot.start()
    end
    if Config.AutoCollect then
        AutoCollect.start()
    end
    if Config.SellBrainrots then
        AutoSell.start()
    end
end
LocalPlayer.CharacterRemoving:Connect(function()
    FalldownController.stop()
end)
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    task.defer(function()
        ChilliBooster.reconcileModes()
    end)
end)
LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
    if not LocalPlayer:GetAttribute("Stealing") then
        ChilliBooster.reconcileModes()
    end
end)
local function loadMainUI()
    local success, Window = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/dtkhanh1/CHL2/refs/heads/main/SCRSAB"))()
    end)
    if not success then
        warn("[Chilli Hub] Failed to load UI library, using fallback")
        ChilliBoosterUI.create()
        FloatingToggle.create()
        return
    end
    local MainWindow = Window:Window({
        Title = "Chilli Hub - Steal a Brainrot",
        Subtitle = "v3.0 Complete",
        Size = UDim2.new(0, 500, 0, 400),
        Opened = true
    })
    local TabGroup = MainWindow:TabGroup()
    local StealerTab = TabGroup:Tab({Title = "Stealer", Image = ""})
    local StealerSection = StealerTab:Section({Title = "Auto Farm", Opened = true})
    StealerSection:Toggle({
        Title = "Auto Collect",
        Default = Config.AutoCollect,
        Callback = function(value)
            Config.AutoCollect = value
            if value then AutoCollect.start() else AutoCollect.stop() end
            saveConfig()
        end
    })
    StealerSection:Toggle({
        Title = "Auto Sell Pets",
        Default = Config.SellBrainrots,
        Callback = function(value)
            Config.SellBrainrots = value
            if value then AutoSell.start() else AutoSell.stop() end
            saveConfig()
        end
    })
    StealerSection:Input({
        Title = "Sell Threshold",
        Default = Config.SellThresholdText,
        Callback = function(value)
            Config.SellThresholdText = value
            AutoSell.Threshold = AutoSell.parseThreshold(value)
            saveConfig()
        end
    })
    local HelperTab = TabGroup:Tab({Title = "Helper", Image = ""})
    local UtilitySection = HelperTab:Section({Title = "Utility", Opened = true})
    UtilitySection:Toggle({
        Title = "Aimbot",
        Default = Config.AutoAimbotTaser,
        Callback = function(value)
            Config.AutoAimbotTaser = value
            if value then Aimbot.start() else Aimbot.stop() end
            saveConfig()
        end
    })
    UtilitySection:Toggle({
        Title = "Speed Boost",
        Default = Config.SpeedBoost,
        Callback = function(value)
            Config.SpeedBoost = value
            if value then SpeedBoost.start() else SpeedBoost.stop() end
            saveConfig()
        end
    })
    UtilitySection:Slider({
        Title = "Speed Value",
        Min = 16,
        Max = 200,
        Default = Config.SpeedBoost_Speed,
        Callback = function(value)
            Config.SpeedBoost_Speed = value
            saveConfig()
        end
    })
    UtilitySection:Toggle({
        Title = "Infinity Jump",
        Default = Config.InfinityJump,
        Callback = function(value)
            Config.InfinityJump = value
            if value then InfinityJump.start() else InfinityJump.stop() end
            saveConfig()
        end
    })
    UtilitySection:Toggle({
        Title = "Anti Ragdoll",
        Default = Config.AntiRagdollConditional,
        Callback = function(value)
            Config.AntiRagdollConditional = value
            if value then AntiRagdoll.start() else AntiRagdoll.stop() end
            saveConfig()
        end
    })
    UtilitySection:Toggle({
        Title = "Reduce Graphics",
        Default = Config.ReduceGraphics,
        Callback = function(value)
            Config.ReduceGraphics = value
            if value then ReduceGraphics.start() else ReduceGraphics.stop() end
            saveConfig()
        end
    })
    local FinderTab = TabGroup:Tab({Title = "Finder", Image = ""})
    local ESPSection = FinderTab:Section({Title = "ESP", Opened = true})
    ESPSection:Toggle({
        Title = "Highest Value Brainrot ESP",
        Default = Config.ESPHighestNPC_All,
        Callback = function(value)
            Config.ESPHighestNPC_All = value
            if value then HighestNPCESP.start() else HighestNPCESP.stop() end
            saveConfig()
        end
    })
    ESPSection:Toggle({
        Title = "Player ESP",
        Default = Config.PlayerBox,
        Callback = function(value)
            Config.PlayerBox = value
            if value then PlayerESP.start() else PlayerESP.stop() end
            saveConfig()
        end
    })
    ESPSection:Toggle({
        Title = "XRay Plots",
        Default = Config.XRayPlots,
        Callback = function(value)
            Config.XRayPlots = value
            if value then XRayPlots.start() else XRayPlots.stop() end
            saveConfig()
        end
    })
    local TeleportSection = FinderTab:Section({Title = "Teleport", Opened = true})
    TeleportSection:Button({
        Title = "Fly to Best Brainrot (C)",
        Callback = function()
            if FlyToBest.Enabled then
                FlyToBest.stop()
            else
                FlyToBest.start()
            end
        end
    })
    TeleportSection:Button({
        Title = "TP to Best Brainrot",
        Callback = function()
            FlyToBest.teleportToBest()
        end
    })
    local ServerTab = TabGroup:Tab({Title = "Server", Image = ""})
    local ServerSection = ServerTab:Section({Title = "Server Info", Opened = true})
    ServerSection:Paragraph({
        Title = "Player Count",
        Desc = getPlayerCount() .. "/8"
    })
    ServerSection:Button({
        Title = "Rejoin Server",
        Callback = function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    })
    local DiscordTab = TabGroup:Tab({Title = "Discord", Image = ""})
    local NotesSection = DiscordTab:Section({Title = "Discord / Notes", Opened = true})
    NotesSection:Paragraph({
        Title = "",
        Desc = "Works best on low-ping servers (<120)"
    })
    NotesSection:Button({
        Title = "Discord Link (Click to copy)",
        Callback = function()
            if setclipboard then
                setclipboard("https://discord.gg/chillihub")
                notify("Copied", "Discord link copied to clipboard.")
            end
        end
    })
    ChilliBoosterUI.create()
    FloatingToggle.create()
end
local function initialize()
    print("[Chilli Hub] Starting...")
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    waitForCharacter()
    loadConfig()
    ChilliBooster.coldStart()
    task.spawn(loadMainUI)
    RunService.Heartbeat:Connect(function()
        BatchChecker.check()
    end)
    print("[Chilli Hub] Loaded successfully!")
    notify("Chilli Hub", "Loaded! Press C to fly to best brainrot.", 5)
end
task.spawn(initialize)
_G.ChilliHub = {
    Config = Config,
    SpeedBoost = SpeedBoost,
    JumpBoost = JumpBoost,
    InfinityJump = InfinityJump,
    Fly = Fly,
    Noclip = Noclip,
    GrappleSpam = GrappleSpam,
    FalldownController = FalldownController,
    FlyToBest = FlyToBest,
    Pathfinder = Pathfinder,
    PlayerESP = PlayerESP,
    HighestNPCESP = HighestNPCESP,
    XRayPlots = XRayPlots,
    AutoCollect = AutoCollect,
    AutoSell = AutoSell,
    Aimbot = Aimbot,
    AntiRagdoll = AntiRagdoll,
    ReduceGraphics = ReduceGraphics,
    ChilliBoosterUI = ChilliBoosterUI,
    FloatingToggle = FloatingToggle,
    findHighestValueBrainrot = findHighestValueBrainrot,
    parsePrice = parsePrice,
    notify = notify,
    saveConfig = saveConfig,
    loadConfig = loadConfig
}
return _G.ChilliHub
