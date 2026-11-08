--[[
    ╔═══════════════════════════════════════════════════════╗
    ║       NARAKU HUB - BLOX FRUITS v5.0 PREMIUM           ║
    ║                                                       ║
    ║   ✓ Auto Farm (Smart)                                 ║
    ║   ✓ Auto Equip Fruit                                  ║
    ║   ✓ Auto Quest                                        ║
    ║   ✓ Auto Stats                                        ║
    ║   ✓ Teleport Islands                                  ║
    ║   ✓ Speed Boost                                       ║
    ║   ✓ Infinite Jump                                     ║
    ║   ✓ ESP Players                                       ║
    ╚═══════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════
--                        SERVICES
-- ═══════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════
--                        CLEANUP
-- ═══════════════════════════════════════════════════════════
for _, name in pairs({"NarakuBF", "NarakuBFV5", "NarakuBFV4", "NarakuBFV3"}) do
    local old = game.CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ═══════════════════════════════════════════════════════════
--                        CONFIG
-- ═══════════════════════════════════════════════════════════
local Config = {
    AutoFarm = false,
    AutoEquipFruit = false,
    SelectedFruit = "Dragon",
    AutoQuest = false,
    AutoStats = false,
    StatToUpgrade = "Melee",
    SpeedBoost = false,
    SpeedValue = 150,
    InfiniteJump = false,
    FlyHeight = 15,
    FarmRange = 800,
    ESP = false,
}

-- ═══════════════════════════════════════════════════════════
--                        THEME
-- ═══════════════════════════════════════════════════════════
local Theme = {
    Bg = Color3.fromRGB(10, 8, 18),
    Sec = Color3.fromRGB(20, 15, 32),
    Ter = Color3.fromRGB(32, 24, 50),
    Acc = Color3.fromRGB(255, 120, 60),
    Acc2 = Color3.fromRGB(255, 200, 80),
    Acc3 = Color3.fromRGB(80, 180, 255),
    Success = Color3.fromRGB(80, 230, 130),
    Danger = Color3.fromRGB(255, 60, 90),
    Text = Color3.fromRGB(240, 235, 255),
    Sub = Color3.fromRGB(150, 140, 180),
}

-- ═══════════════════════════════════════════════════════════
--                        REMOTES
-- ═══════════════════════════════════════════════════════════
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local CommF = Remotes and Remotes:FindFirstChild("CommF_")
local CommE = Remotes and Remotes:FindFirstChild("CommE_")

local function FireCommF(cmd)
    if CommF then pcall(function() CommF:InvokeServer(cmd) end) end
end

local function FireCommE(cmd, ...)
    if CommE then pcall(function() CommE:FireServer(cmd, ...) end) end
end

-- ═══════════════════════════════════════════════════════════
--                        ISLANDS
-- ═══════════════════════════════════════════════════════════
local Islands = {
    {name = "Starter Island", pos = Vector3.new(0, 15, 0), level = 1},
    {name = "Marine Fort", pos = Vector3.new(-2840, 30, 4000), level = 15},
    {name = "Middle Town", pos = Vector3.new(-655, 15, 1500), level = 30},
    {name = "Jungle", pos = Vector3.new(-1400, 15, 200), level = 50},
    {name = "Pirate Village", pos = Vector3.new(-1100, 15, 3400), level = 75},
    {name = "Desert", pos = Vector3.new(1050, 15, 2900), level = 100},
    {name = "Frozen Village", pos = Vector3.new(1275, 15, -1140), level = 120},
    {name = "Colosseum", pos = Vector3.new(-1830, 15, -3250), level = 150},
    {name = "Prison", pos = Vector3.new(5300, 15, 480), level = 190},
    {name = "Magma Village", pos = Vector3.new(-5300, 15, 8400), level = 250},
    {name = "Underwater City", pos = Vector3.new(6100, -25, -1950), level = 350},
    {name = "Fishman Island", pos = Vector3.new(61500, 200, -7150), level = 500},
    {name = "Skylands", pos = Vector3.new(-4850, 850, -2200), level = 750},
    {name = "Kingdom of Rose", pos = Vector3.new(-390, 15, 6110), level = 1000},
    {name = "Cursed Ship", pos = Vector3.new(915, 130, 32700), level = 1200},
    {name = "Ice Castle", pos = Vector3.new(5600, 30, -2000), level = 1500},
    {name = "Forgotten Island", pos = Vector3.new(-3050, 350, -10000), level = 1750},
    {name = "Haunted Castle", pos = Vector3.new(-9500, 200, -6500), level = 2000},
}

-- ═══════════════════════════════════════════════════════════
--                        UTILITIES
-- ═══════════════════════════════════════════════════════════
local function getChar() return LocalPlayer.Character end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getMyLevel()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if stats then
        local lvl = stats:FindFirstChild("Level")
        if lvl then return lvl.Value end
    end
    return 1
end

-- ═══════════════════════════════════════════════════════════
--                        UI
-- ═══════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NarakuBFV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- Floating Button
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -30)
OpenBtn.BackgroundColor3 = Theme.Acc
OpenBtn.Text = "🍎"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 26
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.AutoButtonColor = false
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui

local OBC = Instance.new("UICorner")
OBC.CornerRadius = UDim.new(1, 0)
OBC.Parent = OpenBtn

local OBS = Instance.new("UIStroke")
OBS.Color = Color3.fromRGB(255, 255, 255)
OBS.Thickness = 2
OBS.Parent = OpenBtn

-- Main
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 640, 0, 600)
Main.Position = UDim2.new(0.5, -320, 0.5, -300)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MC = Instance.new("UICorner")
MC.CornerRadius = UDim.new(0, 16)
MC.Parent = Main

local MS = Instance.new("UIStroke")
MS.Color = Theme.Acc
MS.Thickness = 2
MS.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundColor3 = Theme.Sec
Header.BorderSizePixel = 0
Header.Parent = Main

local HC = Instance.new("UICorner")
HC.CornerRadius = UDim.new(0, 16)
HC.Parent = Header

local HG = Instance.new("UIGradient")
HG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Acc),
    ColorSequenceKeypoint.new(0.5, Theme.Acc2),
    ColorSequenceKeypoint.new(1, Theme.Acc3),
})
HG.Rotation = 45
HG.Parent = Header

local HO = Instance.new("Frame")
HO.Size = UDim2.new(1, 0, 1, 0)
HO.BackgroundColor3 = Theme.Bg
HO.BackgroundTransparency = 0.3
HO.BorderSizePixel = 0
HO.Parent = Header

local HOC = Instance.new("UICorner")
HOC.CornerRadius = UDim.new(0, 16)
HOC.Parent = HO

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -180, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🍎 NARAKU - BLOX FRUITS v5.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(0, 280, 0, 20)
Sub.Position = UDim2.new(0, 22, 1, -22)
Sub.BackgroundTransparency = 1
Sub.Text = "Premium Edition • Auto Everything"
Sub.TextColor3 = Theme.Success
Sub.TextSize = 11
Sub.Font = Enum.Font.GothamBold
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.Parent = Header

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -48, 0, 18)
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.Text = "✖"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CC = Instance.new("UICorner")
CC.CornerRadius = UDim.new(0, 8)
CC.Parent = CloseBtn

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 34, 0, 34)
MinBtn.Position = UDim2.new(1, -88, 0, 18)
MinBtn.BackgroundColor3 = Theme.Ter
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = Header

local MNC = Instance.new("UICorner")
MNC.CornerRadius = UDim.new(0, 8)
MNC.Parent = MinBtn

-- Info bar
local InfoBar = Instance.new("Frame")
InfoBar.Size = UDim2.new(1, -20, 0, 30)
InfoBar.Position = UDim2.new(0, 10, 0, 80)
InfoBar.BackgroundColor3 = Theme.Ter
InfoBar.BorderSizePixel = 0
InfoBar.Parent = Main

local IBC = Instance.new("UICorner")
IBC.CornerRadius = UDim.new(0, 8)
IBC.Parent = InfoBar

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 1, 0)
InfoLabel.Position = UDim2.new(0, 10, 0, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Level: ... | Island: ..."
InfoLabel.TextColor3 = Theme.Text
InfoLabel.TextSize = 13
InfoLabel.Font = Enum.Font.GothamBold
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Parent = InfoBar

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local level = getMyLevel()
            local island = "Unknown"
            for _, isl in pairs(Islands) do
                if level >= isl.level then island = isl.name end
            end
            InfoLabel.Text = "Level: " .. level .. " | Island: " .. island
        end)
    end
end)

-- Content
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -170)
Content.Position = UDim2.new(0, 10, 0, 115)
Content.BackgroundColor3 = Theme.Sec
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 6
Content.ScrollBarImageColor3 = Theme.Acc
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main

local ConC = Instance.new("UICorner")
ConC.CornerRadius = UDim.new(0, 12)
ConC.Parent = Content

local ConPad = Instance.new("UIPadding")
ConPad.PaddingTop = UDim.new(0, 10)
ConPad.PaddingLeft = UDim.new(0, 10)
ConPad.PaddingRight = UDim.new(0, 10)
ConPad.PaddingBottom = UDim.new(0, 10)
ConPad.Parent = Content

local ConLayout = Instance.new("UIListLayout")
ConLayout.Padding = UDim.new(0, 8)
ConLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConLayout.Parent = Content

-- Helper functions
local function CreateSection(text)
    local S = Instance.new("Frame")
    S.Size = UDim2.new(1, 0, 0, 32)
    S.BackgroundColor3 = Theme.Bg
    S.BackgroundTransparency = 0.5
    S.BorderSizePixel = 0
    S.Parent = Content
    
    local SC = Instance.new("UICorner")
    SC.CornerRadius = UDim.new(0, 8)
    SC.Parent = S
    
    local L = Instance.new("Frame")
    L.Size = UDim2.new(0, 4, 0, 18)
    L.Position = UDim2.new(0, 10, 0.5, -9)
    L.BackgroundColor3 = Theme.Acc
    L.BorderSizePixel = 0
    L.Parent = S
    
    local LC = Instance.new("UICorner")
    LC.CornerRadius = UDim.new(1, 0)
    LC.Parent = L
    
    local T = Instance.new("TextLabel")
    T.Size = UDim2.new(1, -30, 1, 0)
    T.Position = UDim2.new(0, 22, 0, 0)
    T.BackgroundTransparency = 1
    T.Text = text
    T.TextColor3 = Theme.Text
    T.TextSize = 13
    T.Font = Enum.Font.GothamBlack
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.Parent = S
end

local function CreateToggle(name, icon, default, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 46)
    B.BackgroundColor3 = Theme.Ter
    B.Text = ""
    B.AutoButtonColor = false
    B.Parent = Content
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 10)
    BC.Parent = B
    
    local I = Instance.new("TextLabel")
    I.Size = UDim2.new(0, 40, 1, 0)
    I.Position = UDim2.new(0, 5, 0, 0)
    I.BackgroundTransparency = 1
    I.Text = icon
    I.TextSize = 22
    I.Font = Enum.Font.GothamBold
    I.Parent = B
    
    local N = Instance.new("TextLabel")
    N.Size = UDim2.new(1, -120, 1, 0)
    N.Position = UDim2.new(0, 45, 0, 0)
    N.BackgroundTransparency = 1
    N.Text = name
    N.TextColor3 = Theme.Text
    N.TextSize = 14
    N.Font = Enum.Font.GothamBold
    N.TextXAlignment = Enum.TextXAlignment.Left
    N.Parent = B
    
    local Sw = Instance.new("Frame")
    Sw.Size = UDim2.new(0, 48, 0, 26)
    Sw.Position = UDim2.new(1, -58, 0.5, -13)
    Sw.BackgroundColor3 = Color3.fromRGB(50, 45, 70)
    Sw.Parent = B
    
    local SwC = Instance.new("UICorner")
    SwC.CornerRadius = UDim.new(1, 0)
    SwC.Parent = Sw
    
    local K = Instance.new("Frame")
    K.Size = UDim2.new(0, 20, 0, 20)
    K.Position = UDim2.new(0, 3, 0.5, -10)
    K.BackgroundColor3 = Color3.fromRGB(220, 215, 240)
    K.Parent = Sw
    
    local KC = Instance.new("UICorner")
    KC.CornerRadius = UDim.new(1, 0)
    KC.Parent = K
    
    local state = default or false
    local function update()
        if state then
            TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Acc}):Play()
            TweenService:Create(K, TweenInfo.new(0.2), {Position = UDim2.new(1, -23, 0.5, -10)}):Play()
        else
            TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 45, 70)}):Play()
            TweenService:Create(K, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -10)}):Play()
        end
    end
    update()
    
    B.MouseButton1Click:Connect(function()
        state = not state
        update()
        if callback then pcall(callback, state) end
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local C = Instance.new("Frame")
    C.Size = UDim2.new(1, 0, 0, 60)
    C.BackgroundColor3 = Theme.Ter
    C.Parent = Content
    
    local CC = Instance.new("UICorner")
    CC.CornerRadius = UDim.new(0, 10)
    CC.Parent = C
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -20, 0, 22)
    L.Position = UDim2.new(0, 10, 0, 5)
    L.BackgroundTransparency = 1
    L.Text = name .. ": " .. default
    L.TextColor3 = Theme.Text
    L.TextSize = 13
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = C
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 10)
    Bar.Position = UDim2.new(0, 10, 1, -20)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
    Bar.Parent = C
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(1, 0)
    BC.Parent = Bar
    
    local F = Instance.new("Frame")
    F.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    F.BackgroundColor3 = Theme.Acc
    F.Parent = Bar
    
    local FC = Instance.new("UICorner")
    FC.CornerRadius = UDim.new(1, 0)
    FC.Parent = F
    
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        F.Size = UDim2.new(pos, 0, 1, 0)
        L.Text = name .. ": " .. val
        if callback then pcall(callback, val) end
    end
    
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
end

local function CreateButton(name, icon, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 45)
    B.BackgroundColor3 = Theme.Acc
    B.Text = ""
    B.AutoButtonColor = false
    B.Parent = Content
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 10)
    BC.Parent = B
    
    local I = Instance.new("TextLabel")
    I.Size = UDim2.new(0, 45, 1, 0)
    I.BackgroundTransparency = 1
    I.Text = icon
    I.TextSize = 22
    I.Font = Enum.Font.GothamBold
    I.Parent = B
    
    local N = Instance.new("TextLabel")
    N.Size = UDim2.new(1, -55, 1, 0)
    N.Position = UDim2.new(0, 50, 0, 0)
    N.BackgroundTransparency = 1
    N.Text = name
    N.TextColor3 = Color3.fromRGB(255, 255, 255)
    N.TextSize = 14
    N.Font = Enum.Font.GothamBold
    N.TextXAlignment = Enum.TextXAlignment.Left
    N.Parent = B
    
    B.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)
end

-- ═══════════════════════════════════════════════════════════
--                    UI CONTENT
-- ═══════════════════════════════════════════════════════════

CreateSection("⚔️ AUTO FARM")
CreateToggle("Auto Farm (Smart)", "⚔️", false, function(v) Config.AutoFarm = v end)
CreateSlider("Farm Range", 100, 2000, 800, function(v) Config.FarmRange = v end)
CreateSlider("Fly Height", 5, 60, 15, function(v) Config.FlyHeight = v end)

CreateSection("🍎 FRUIT")
CreateToggle("Auto Equip Fruit", "🍎", false, function(v) Config.AutoEquipFruit = v end)
local fruits = {"Dragon", "Kitsune", "Leopard", "Dough", "Venom", "Shadow", "Buddha", "Portal", "Rumble", "Gravity", "Control", "Spirit", "Mammoth", "Gas", "T-Rex", "Blizzard", "Pain", "Love", "Spider", "Sound", "Phoenix", "Magma", "Quake", "Light", "Ice", "Sand", "Dark", "Flame", "Bomb", "Spring", "Chop", "Rocket"}
local fruitIndex = 1
local fruitBtn = Instance.new("TextButton")
fruitBtn.Size = UDim2.new(1, 0, 0, 40)
fruitBtn.BackgroundColor3 = Theme.Ter
fruitBtn.Text = "Fruit: " .. fruits[fruitIndex]
fruitBtn.TextColor3 = Theme.Text
fruitBtn.TextSize = 13
fruitBtn.Font = Enum.Font.GothamBold
fruitBtn.Parent = Content

local FBC = Instance.new("UICorner")
FBC.CornerRadius = UDim.new(0, 8)
FBC.Parent = fruitBtn

fruitBtn.MouseButton1Click:Connect(function()
    fruitIndex = fruitIndex + 1
    if fruitIndex > #fruits then fruitIndex = 1 end
    Config.SelectedFruit = fruits[fruitIndex]
    fruitBtn.Text = "Fruit: " .. fruits[fruitIndex]
end)

CreateSection("📜 QUEST")
CreateToggle("Auto Quest", "📜", false, function(v) Config.AutoQuest = v end)

CreateSection("💨 MOVEMENT")
CreateToggle("Speed Boost", "💨", false, function(v) Config.SpeedBoost = v end)
CreateSlider("Speed Value", 16, 300, 150, function(v) Config.SpeedValue = v end)
CreateToggle("Infinite Jump", "🦘", false, function(v) Config.InfiniteJump = v end)

CreateSection("🗺️ TELEPORT")
for _, isl in pairs(Islands) do
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 40)
    B.BackgroundColor3 = Theme.Ter
    B.Text = "🏝️ " .. isl.name .. " (Lv. " .. isl.level .. ")"
    B.TextColor3 = Theme.Text
    B.TextSize = 12
    B.Font = Enum.Font.GothamBold
    B.AutoButtonColor = false
    B.Parent = Content
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 8)
    BC.Parent = B
    
    B.MouseButton1Click:Connect(function()
        local char = getChar()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(isl.pos + Vector3.new(0, 5, 0))
            StarterGui:SetCore("SendNotification", {Title = "Naraku", Text = "Teleported to " .. isl.name})
        end
    end)
end

CreateSection("📊 STATS")
CreateToggle("Auto Stats", "📊", false, function(v) Config.AutoStats = v end)

-- ═══════════════════════════════════════════════════════════
--                    CONTROLS
-- ═══════════════════════════════════════════════════════════

CloseBtn.MouseButton1Click:Connect(function()
    for k, v in pairs(Config) do
        if type(v) == "boolean" then Config[k] = false end
    end
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main:TweenSize(UDim2.new(0, 640, 0, 70), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    else
        Main:TweenSize(UDim2.new(0, 640, 0, 600), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

-- ═══════════════════════════════════════════════════════════
--                    LOGIC
-- ═══════════════════════════════════════════════════════════

-- Speed Boost
task.spawn(function()
    while task.wait(0.1) do
        if Config.SpeedBoost then
            local hum = getHum()
            if hum and hum.WalkSpeed ~= Config.SpeedValue then
                hum.WalkSpeed = Config.SpeedValue
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Auto Equip Fruit
task.spawn(function()
    while task.wait(1) do
        if Config.AutoEquipFruit then
            local char = getChar()
            if char and not char:FindFirstChildOfClass("Tool") then
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in pairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            local name = tool.Name:lower()
                            if name:find("fruit") or name:find(Config.SelectedFruit:lower()) then
                                tool.Parent = char
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Farm
task.spawn(function()
    local currentIsland = nil
    while task.wait(0.1) do
        if Config.AutoFarm then
            local char = getChar()
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local myLevel = getMyLevel()
                
                -- Target island
                local targetIsland = Islands[1]
                for _, isl in pairs(Islands) do
                    if myLevel >= isl.level then targetIsland = isl end
                end
                
                -- If changed, teleport
                if currentIsland ~= targetIsland.name then
                    currentIsland = targetIsland.name
                    hrp.CFrame = CFrame.new(targetIsland.pos + Vector3.new(0, 10, 0))
                    task.wait(1)
                end
                
                -- Find nearest NPC
                local nearestNPC = nil
                local minDist = Config.FarmRange
                for _, obj in pairs(Workspace:GetChildren()) do
                    pcall(function()
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                            if obj.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                                local dist = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    nearestNPC = obj
                                end
                            end
                        end
                    end)
                end
                
                if nearestNPC then
                    local targetPos = nearestNPC.HumanoidRootPart.Position + Vector3.new(0, Config.FlyHeight, 0)
                    hrp.CFrame = CFrame.new(targetPos, nearestNPC.HumanoidRootPart.Position)
                    
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then pcall(function() tool:Activate() end) end
                    
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end)
                end
            end
        end
    end
end)

-- Auto Quest
task.spawn(function()
    while task.wait(2) do
        if Config.AutoQuest then
            for _, obj in pairs(Workspace:GetChildren()) do
                pcall(function()
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                        local n = obj.Name:lower()
                        if n:find("quest") or n:find("master") or n:find("teacher") then
                            local char = getChar()
                            if char and obj:FindFirstChild("HumanoidRootPart") then
                                char.HumanoidRootPart.CFrame = CFrame.new(obj.HumanoidRootPart.Position + Vector3.new(0, 3, 3))
                                task.wait(0.5)
                                FireCommE("StartQuest", obj.Name)
                            end
                        end
                    end
                end)
            end
        end
    end
end)

-- Auto Stats
task.spawn(function()
    while task.wait(2) do
        if Config.AutoStats then
            pcall(function()
                FireCommF("Buy" .. Config.StatToUpgrade)
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--                    CONSOLE
-- ═══════════════════════════════════════════════════════════
print("╔════════════════════════════════════════════════╗")
print("║   NARAKU - BLOX FRUITS v5.0 PREMIUM LOADED     ║")
print("║                                                ║")
print("║   ✓ Auto Farm                                  ║")
print("║   ✓ Auto Equip Fruit                           ║")
print("║   ✓ Auto Quest                                 ║")
print("║   ✓ Auto Stats                                 ║")
print("║   ✓ Teleport Islands                           ║")
print("║   ✓ Speed Boost                                ║")
print("║   ✓ Infinite Jump                              ║")
print("║                                                ║")
print("║   📌 RightShift = Toggle UI                    ║")
print("╚════════════════════════════════════════════════╝")
