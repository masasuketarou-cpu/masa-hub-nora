-- スヌーピー フラッシュ TP（黒いヘッダー、青いタイトル、白黒の操作ボタン）
-- 機能: フラッシュTP、自動巨大ポーション、自動グラブ、トリガースライダー、即時離脱

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
ローカル RunService = ゲーム:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local HttpService = game:GetService("HttpService")
ローカルプレイヤー = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===================== 設定 ====================
local configFile = "Snoopy_FlashTP_Config.json"
ローカル設定 = {
    flashEnabled = true、
    giantEnabled = false、
    autoGrabEnabled = false、
    triggerPercent = 0.91、
}

isfile かつ isfile(configFile) の場合、
    ローカル成功、デコード済み = pcall(function()
        return HttpService:JSONDecode(readfile(configFile))
    終わり）
    成功して解読された場合
        設定 = デコード済み
    終わり
終わり

ローカル関数 saveConfig()
    書き込みファイルの場合
        pcall(function()
            writefile(configFile, HttpService:JSONEncode(Config))
        終わり）
    終わり
終わり

-- ===================== 色 ====================
local BLUE_TITLE = Color3.fromRGB(0, 191, 255) -- цвет 🩵
local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.fromRGB(0, 0, 0)
local DARK_GRAY = Color3.fromRGB(40, 40, 40)
local GRAY = Color3.fromRGB(70, 70, 70)
local LIGHT_GRAY = Color3.fromRGB(120, 120, 120)

-- [[ ScreenGui ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "101_Flash"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

-- [[ メインフレーム ]]
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 200, 0, 240)
Main.Position = UDim2.new(0.5, -100, 0.5, -120)
メインの背景色3 = 黒
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
メインストロークの厚さ = 2
メインストロークの色 = グレー
MainStroke.Parent = Main

-- タイトルバー（黒一色）
local TitleBar = Instance.new("Frame")
TitleBar.Name = "タイトルバー"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = BLACK -- чисто чёрный
タイトルバーの枠線サイズピクセル = 0
TitleBar.Active = true
TitleBar.ZIndex = 2
タイトルバーの親 = メイン

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- タイトル：「101 Flash TP」青色
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "タイトル"
TitleLabel.Size = UDim2.new(1, 0, 0, 20)
TitleLabel.Position = UDim2.new(0, 0, 0, 8)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "101 Flash TP"
TitleLabel.TextColor3 = BLUE_TITLE -- 表示されます
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 2
TitleLabel.Parent = TitleBar

-- (リッチテキストを使用して、テキストを使用して、цвет всему тексту)

-- ドラッグロジック
ローカルドラッグ = false
local dragStart = nil
local startPos = nil
local oldMouseBehavior = nil

TitleBar.InputBegan:Connect(function(input)
    input.UserInputType が Enum.UserInputType.MouseButton1 または input.UserInputType が Enum.UserInputType.Touch の場合、
        ドラッグ中 = true
        oldMouseBehavior = UserInputService.MouseBehavior
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        dragStart = input.Position
        startPos = Main.Position
    終わり
終わり）

UserInputService.InputChanged:Connect(function(input)
    ドラッグ中で、かつ (input.UserInputType == Enum.UserInputType.MouseMovement または input.UserInputType == Enum.UserInputType.Touch) の場合、
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    終わり
終わり）

UserInputService.InputEnded:Connect(function(input)
    input.UserInputType が Enum.UserInputType.MouseButton1 または input.UserInputType が Enum.UserInputType.Touch の場合、
        ドラッグ = false
        oldMouseBehavior の場合
            UserInputService.MouseBehavior = oldMouseBehavior
            oldMouseBehavior = nil
        終わり
    終わり
終わり）

-  コンテンツ
local Content = Instance.new("Frame")
Content.Name = "コンテンツ"
Content.Size = UDim2.new(1, -14, 1, -44)
Content.Position = UDim2.new(0, 7, 0, 40)
コンテンツの背景透明度 = 1
Content.BorderSizePixel = 0
コンテンツ.ZIndex = 2
コンテンツの親 = メイン

-- ==================== トグルボタン作成ツール ====================
ローカル関数 createToggleButton(yOffset, label, configKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.Position = UDim2.new(0, 0, 0, yOffset)
    btn.BackgroundColor3 = ダークグレー
    btn.TextColor3 = 白
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.ZIndex = 2
    btn.Parent = コンテンツ

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    ストロークの太さ = 1
    ストロークの色 = グレー
    ストローク.親 = btn

    ローカル状態 = Config[configKey] または false
    btn.Text = label .. ": " .. (状態と「ON」または「OFF」)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = GRAY}):Play()
    終わり）
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = DARK_GRAY}):Play()
    終わり）

    btn.MouseButton1Click:Connect(function()
        Config[configKey] = Config[configKey] ではない
        btn.Text = label .. ": " .. (Config[configKey] かつ "ON" または "OFF")
        saveConfig()
        _G[configKey] = Config[configKey]
    終わり）

    ボタンを返す
終わり

-- FLASH TPボタン（1つ目）
createToggleButton(0, "FLASH TP", "flashEnabled")

-- ==================== トリガースライダー ====================
local sliderValue = Config.triggerPercent または 0.91
local sliderDragging = false

local TriggerLabel = Instance.new("TextLabel")
TriggerLabel.Size = UDim2.new(1, 0, 0, 14)
TriggerLabel.Position = UDim2.new(0, 0, 0, 32)
TriggerLabel.BackgroundTransparency = 1
TriggerLabel.Text = "トリガー: " .. math.floor(sliderValue * 100) .. "%"
TriggerLabel.TextColor3 = 白
TriggerLabel.Font = Enum.Font.GothamBold
TriggerLabel.TextSize = 11
TriggerLabel.TextXAlignment = Enum.TextXAlignment.Left
TriggerLabel.ZIndex = 2
TriggerLabel.Parent = コンテンツ

local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(1, 0, 0, 6)
SliderTrack.Position = UDim2.new(0, 0, 0, 48)
SliderTrack.BackgroundColor3 = DARK_GRAY
SliderTrack.BorderSizePixel = 0
SliderTrack.ZIndex = 2
SliderTrack.Parent = コンテンツ

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(1, 0)
TrackCorner.Parent = SliderTrack

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(sliderValue, 0, 1, 0)
SliderFill.BackgroundColor3 = ライトグレー
SliderFill.BorderSizePixel = 0
SliderFill.ZIndex = 2
SliderFill.Parent = SliderTrack

local SliderKnob = Instance.new("TextButton")
SliderKnob.Size = UDim2.new(0, 14, 0, 14)
SliderKnob.Position = UDim2.new(sliderValue, 0, 0.5, 0)
SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
SliderKnob.BackgroundColor3 = WHITE
SliderKnob.BorderSizePixel = 0
SliderKnob.Text = ""
SliderKnob.ZIndex = 3
SliderKnob.Parent = SliderTrack

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = SliderKnob

local knobStroke = Instance.new("UIStroke")
ノブストロークの太さ = 2
ノブストロークの色 = グレー
knobStroke.Parent = SliderKnob

ローカル関数 updateSlider(x)
    local trackPos = SliderTrack.AbsolutePosition.X
    local trackSize = SliderTrack.AbsoluteSize.X
    trackSize <= 0 の場合、終了を返す
    local percent = math.clamp((x - trackPos) / trackSize, 0, 1)
    パーセント = math.floor(パーセント * 200 + 0.5) / 200
    percent = math.clamp(percent, 0, 1)
    スライダー値 = パーセント
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
    TriggerLabel.Text = "トリガー: " .. math.floor(percent * 100) .. "%"
    Config.triggerPercent = パーセント
    _G.triggerPercent = パーセント
    saveConfig()
終わり

SliderKnob.MouseButton1Down:Connect(function() sliderDragging = true end)
SliderTrack.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
        updateSlider(inp.Position.X)
    終わり
終わり）

UserInputService.InputChanged:Connect(function(inp)
    sliderDragging かつ (inp.UserInputType == Enum.UserInputType.MouseMovement または inp.UserInputType == Enum.UserInputType.Touch) の場合、
        updateSlider(inp.Position.X)
    終わり
終わり）

UserInputService.InputEnded:Connect(function(inp)
    inp.UserInputType == Enum.UserInputType.MouseButton1 または inp.UserInputType == Enum.UserInputType.Touch の場合、
        sliderDragging = false
    終わり
終わり）

-- ==================== 残りのボタン ====================
createToggleButton(62, "AUTO GIANT POTION", "giantEnabled")
createToggleButton(94, "AUTO GRAB", "autoGrabEnabled")

-- ==================== インスタリーリーブ ====================
local LeaveButton = Instance.new("TextButton")
LeaveButton.Size = UDim2.new(1, 0, 0, 28)
LeaveButton.Position = UDim2.new(0, 0, 0, 128)
LeaveButton.BackgroundColor3 = DARK_GRAY
LeaveButton.Text = "即時退出"
LeaveButton.TextColor3 = 白
LeaveButton.Font = Enum.Font.GothamBold
LeaveButton.TextSize = 12
LeaveButton.BorderSizePixel = 0
LeaveButton.ZIndex = 2
LeaveButton.Parent = コンテンツ

local LeaveCorner = Instance.new("UICorner")
LeaveCorner.CornerRadius = UDim.new(0, 6)
LeaveCorner.Parent = LeaveButton

local LeaveStroke = Instance.new("UIStroke")
LeaveStroke.Thickness = 1
LeaveStroke.Color = GRAY
LeaveStroke.Parent = LeaveButton

LeaveButton.MouseEnter:Connect(function()
    TweenService:Create(LeaveButton, TweenInfo.new(0.15), {BackgroundColor3 = GRAY}):Play()
終わり）
LeaveButton.MouseLeave:Connect(function()
    TweenService:Create(LeaveButton, TweenInfo.new(0.15), {BackgroundColor3 = DARK_GRAY}):Play()
終わり）

LeaveButton.MouseButton1Click:Connect(function()
    プレイヤー:キック("インスタントリーブで退出しました")
終わり）

-- ==================== グローバル変数 ====================
_G.flashEnabled = Config.flashEnabled
_G.giantEnabled = Config.giantEnabled
_G.autoGrabEnabled = Config.autoGrabEnabled
_G.triggerPercent = Config.triggerPercent

-- ==================== 自動使用ロジック ====================
local activeTriggers = {}

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    _G.flashEnabled も _G.giantEnabled も _G.autoGrabEnabled も無効の場合、終了する
    activeTriggers[prompt] が真の場合、end を返します。
    activeTriggers[prompt] = true
    local startTime = os.clock()
    ローカルで発生した = false

    ローカル接続
    connection = RunService.PreRender:Connect(function()
        プロンプトがない場合、またはプロンプトがない場合。親は次のようになります。
            接続:切断()
            activeTriggers[prompt] = nil
            戻る
        終わり
        local progress = math.clamp((os.clock() - startTime) / prompt.HoldDuration, 0, 1)

        発火しておらず、進行状況が _G.triggerPercent 以上の場合
            発火 = true
            接続:切断()
            activeTriggers[prompt] = nil

            local char = player.Character
            文字でない場合は、終了を返します。
            local backpack = player:FindFirstChild("Backpack")

            _G.flashEnabled の場合
                local flash = char:FindFirstChild("Flash Teleport") or (backpack and backpack:FindFirstChild("Flash Teleport"))
                フラッシュの場合
                    flash.Parent = char
                    task.spawn(function() flash:Activate() task.wait(0.08) end)
                終わり
            終わり
            _G.giantEnabled の場合
                local giant = char:FindFirstChild("Giant Potion") or (backpack and backpack:FindFirstChild("Giant Potion"))
                巨大であれば
                    giant.Parent = char
                    task.spawn(function() giant:Activate() end)
                終わり
            終わり
            _G.autoGrabEnabled の場合
                local grab = char:FindFirstChild("Grab") or (backpack and backpack:FindFirstChild("Grab"))
                掴むなら
                    grab.Parent = char
                    task.spawn(function() grab:Activate() end)
                終わり
            終わり
        終わり
    終わり）

    prompt.PromptonHoldEnded:Connect(function()
        解雇されなければ
            接続:切断()
            activeTriggers[prompt] = nil
        終わり
    終わり）
終わり）

print("101個のFlash TPがロードされました！")
