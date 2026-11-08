--[[
    ╔═══════════════════════════════════════════════╗
    ║          ███╗   ██╗ █████╗ ██████╗            ║
    ║          ████╗  ██║██╔══██╗██╔══██╗           ║
    ║          ██╔██╗ ██║███████║██████╔╝           ║
    ║          ██║╚██╗██║██╔══██║██╔══██╗           ║
    ║          ██║ ╚████║██║  ██║██║  ██║           ║
    ║          ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝           ║
    ║                                                ║
    ║      NARAKU - BLOX FRUITS AUTO v1.0           ║
    ║                                                ║
    ║   ✓ Auto Farm Level                           ║
    ║   ✓ Auto Equip Fruit                          ║
    ║   ✓ Auto Farm NPCs (Level-based)              ║
    ║   ✓ Auto Quest                                ║
    ║   ✓ Auto Chest                                ║
    ║   ✓ Teleport to Island                        ║
    ╚═══════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════
--                    SERVICES
-- ═══════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════
--                    CLEANUP
-- ═══════════════════════════════════════════════════════
for _, name in pairs({"NarakuBF", "NarakuBFV1", "NarakuBloxFruits"}) do
    local old = game.CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ═══════════════════════════════════════════════════════
--                    CONFIG
-- ═══════════════════════════════════════════════════════
local Config = {
    -- AUTO FARM
    AutoFarm = false,
    FarmRange = 1000,
    FlyHeight = 20,
    AutoEquipFruit = false,
    FruitName = "Dragon",
    
    -- AUTO QUEST
    AutoQuest = false,
    
    -- AUTO CHEST
    AutoChest = false,
    
    -- AUTO STATS
    AutoStats = false,
    StatToUpgrade = "Melee",
    
    -- MOVEMENT
    SpeedBoost = false,
    SpeedValue = 120,
    InfiniteJump = false,
    
    -- TELEPORT
    TeleportSelect = "Starter Island",
}

-- ═══════════════════════════════════════════════════════
--                    THEME
-- ═══════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════
--                    UTILITIES
-- ═══════════════════════════════════════════════════════
local function getChar() return LocalPlayer.Character end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Naraku BF",
            Text = text,
            Duration = 3,
        })
    end)
end

-- ═══════════════════════════════════════════════════════
--                    ISLANDS DATABASE
-- ═══════════════════════════════════════════════════════
-- You need to update these coordinates if Blox Fruits updates!
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

-- ═══════════════════════════════════════════════════════
--                    UI CREATION
-- ═══════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NarakuBF"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
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
OBS.Transparency = 0.3
OBS.Parent = OpenBtn

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, -320, 0.5, -300)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MC = Instance.new("UICorner")
MC.CornerRadius = UDim.new(0, 16)
MC.Parent = Main

local MS = Instance.new("UIStroke")
MS.Color = Theme.Acc
MS.Thickness = 2
MS.Transparency = 0.2
MS.Parent = Main

local MG = Instance.new("UIGradient")
MG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Acc),
    ColorSequenceKeypoint.new(0.5, Theme.Acc2),
    ColorSequenceKeypoint.new(1, Theme.Acc3),
})
MG.Rotation = 45
MG.Parent = MS

Main:TweenSize(UDim2.new(0, 640, 0, 600), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)

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
HO.BackgroundTransparency = 0.35
HO.BorderSizePixel = 0
HO.Parent = Header

local HOC = Instance.new("UICorner")
HOC.CornerRadius = UDim.new(0, 16)
HOC.Parent = HO

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -180, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🍎 NARAKU - BLOX FRUITS 🍎"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(0, 280, 0, 20)
Sub.Position = UDim2.new(0, 22, 1, -22)
Sub.BackgroundTransparency = 1
Sub.Text = "Auto Farm • Auto Quest • Auto Everything"
Sub.TextColor3 = Theme.Success
Sub.TextSize = 11
Sub.Font = Enum.Font.GothamBold
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.Parent = Header

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 34, 0, 34)
MinBtn.Position = UDim2.new(1, -88, 0, 18)
MinBtn.BackgroundColor3 = Theme.Ter
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.AutoButtonColor = false
MinBtn.Parent = Header

local MNC = Instance.new("UICorner")
MNC.CornerRadius = UDim.new(0, 8)
MNC.Parent = MinBtn

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -48, 0, 18)
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.Text = "✖"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

local CC = Instance.new("UICorner")
CC.CornerRadius = UDim.new(0, 8)
CC.Parent = CloseBtn

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 36)
TabBar.Position = UDim2.new(0, 10, 0, 78)
TabBar.BackgroundColor3 = Theme.Sec
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local TBC = Instance.new("UICorner")
TBC.CornerRadius = UDim.new(0, 10)
TBC.Parent = TabBar

local TBP = Instance.new("UIPadding")
TBP.PaddingLeft = UDim.new(0, 5)
TBP.PaddingRight = UDim.new(0, 5)
TBP.PaddingTop = UDim.new(0, 4)
TBP.PaddingBottom = UDim.new(0, 4)
TBP.Parent = TabBar

local TBL = Instance.new("UIListLayout")
TBL.FillDirection = Enum.FillDirection.Horizontal
TBL.Padding = UDim.new(0, 4)
TBL.Parent = TabBar

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -130)
Content.Position = UDim2.new(0, 10, 0, 122)
Content.BackgroundColor3 = Theme.Sec
Content.BorderSizePixel = 0
Content.Parent = Main

local ConC = Instance.new("UICorner")
ConC.CornerRadius = UDim.new(0, 12)
ConC.Parent = Content

-- Tabs
local Tabs = {}

local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 118, 1, 0)
    TabBtn.BackgroundColor3 = Theme.Ter
    TabBtn.Text = icon .. " " .. name
    TabBtn.TextColor3 = Theme.Sub
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = TabBar
    
    local TabC = Instance.new("UICorner")
    TabC.CornerRadius = UDim.new(0, 8)
    TabC.Parent = TabBtn
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 6
    Scroll.ScrollBarImageColor3 = Theme.Acc
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.Visible = false
    Scroll.Parent = Content
    
    local ScrollPad = Instance.new("UIPadding")
    ScrollPad.PaddingTop = UDim.new(0, 10)
    ScrollPad.PaddingLeft = UDim.new(0, 10)
    ScrollPad.PaddingRight = UDim.new(0, 10)
    ScrollPad.PaddingBottom = UDim.new(0, 10)
    ScrollPad.Parent = Scroll
    
    local ScrollL = Instance.new("UIListLayout")
    ScrollL.Padding = UDim.new(0, 8)
    ScrollL.SortOrder = Enum.SortOrder.LayoutOrder
    ScrollL.Parent = Scroll
    
    Tabs[name] = {Button = TabBtn, Scroll = Scroll}
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Scroll.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Ter, TextColor3 = Theme.Sub}):Play()
        end
        Scroll.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Acc, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    
    return Scroll
end

-- Helper UI
local function CreateSection(parent, text)
    local S = Instance.new("Frame")
    S.Size = UDim2.new(1, 0, 0, 32)
    S.BackgroundColor3 = Theme.Bg
    S.BackgroundTransparency = 0.5
    S.BorderSizePixel = 0
    S.Parent = parent
    
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

local function CreateToggle(parent, name, icon, default, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 46)
    B.BackgroundColor3 = Theme.Ter
    B.Text = ""
    B.AutoButtonColor = false
    B.Parent = parent
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 10)
    BC.Parent = B
    
    local BS = Instance.new("UIStroke")
    BS.Color = Color3.fromRGB(60, 50, 90)
    BS.Thickness = 1
    BS.Parent = B
    
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
    Sw.BorderSizePixel = 0
    Sw.Parent = B
    
    local SwC = Instance.new("UICorner")
    SwC.CornerRadius = UDim.new(1, 0)
    SwC.Parent = Sw
    
    local K = Instance.new("Frame")
    K.Size = UDim2.new(0, 20, 0, 20)
    K.Position = UDim2.new(0, 3, 0.5, -10)
    K.BackgroundColor3 = Color3.fromRGB(220, 215, 240)
    K.BorderSizePixel = 0
    K.Parent = Sw
    
    local KC = Instance.new("UICorner")
    KC.CornerRadius = UDim.new(1, 0)
    KC.Parent = K
    
    local state = default or false
    
    local function updateVisual()
        if state then
            TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Acc}):Play()
            TweenService:Create(K, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -23, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            TweenService:Create(BS, TweenInfo.new(0.2), {Color = Theme.Acc}):Play()
        else
            TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 45, 70)}):Play()
            TweenService:Create(K, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 3, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(220, 215, 240)
            }):Play()
            TweenService:Create(BS, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 50, 90)}):Play()
        end
    end
    
    updateVisual()
    
    B.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if callback then pcall(callback, state) end
    end)
end

local function CreateSlider(parent, name, min, max, default, callback)
    local C = Instance.new("Frame")
    C.Size = UDim2.new(1, 0, 0, 60)
    C.BackgroundColor3 = Theme.Ter
    C.BorderSizePixel = 0
    C.Parent = parent
    
    local CC = Instance.new("UICorner")
    CC.CornerRadius = UDim.new(0, 10)
    CC.Parent = C
    
    local CS = Instance.new("UIStroke")
    CS.Color = Color3.fromRGB(60, 50, 90)
    CS.Thickness = 1
    CS.Parent = C
    
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
    Bar.BorderSizePixel = 0
    Bar.Parent = C
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(1, 0)
    BC.Parent = Bar
    
    local F = Instance.new("Frame")
    F.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    F.BackgroundColor3 = Theme.Acc
    F.BorderSizePixel = 0
    F.Parent = Bar
    
    local FC = Instance.new("UICorner")
    FC.CornerRadius = UDim.new(1, 0)
    FC.Parent = F
    
    local val = default
    local drag = false
    
    local function upd(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        val = math.floor(min + (max - min) * pos)
        F.Size = UDim2.new(pos, 0, 1, 0)
        L.Text = name .. ": " .. val
        if callback then pcall(callback, val) end
    end
    
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            upd(input)
        end
    end)
    
    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            upd(input)
        end
    end)
end

local function CreateDropdown(parent, name, options, default, callback)
    local C = Instance.new("Frame")
    C.Size = UDim2.new(1, 0, 0, 45)
    C.BackgroundColor3 = Theme.Ter
    C.BorderSizePixel = 0
    C.Parent = parent
    
    local CC = Instance.new("UICorner")
    CC.CornerRadius = UDim.new(0, 10)
    CC.Parent = C
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0.5, 0, 1, 0)
    L.Position = UDim2.new(0, 10, 0, 0)
    L.BackgroundTransparency = 1
    L.Text = name
    L.TextColor3 = Theme.Text
    L.TextSize = 13
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = C
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.45, 0, 0, 32)
    Btn.Position = UDim2.new(0.53, 0, 0.5, -16)
    Btn.BackgroundColor3 = Theme.Acc
    Btn.Text = default
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.AutoButtonColor = false
    Btn.Parent = C
    
    local BtnC = Instance.new("UICorner")
    BtnC.CornerRadius = UDim.new(0, 6)
    BtnC.Parent = Btn
    
    local index = 1
    for i, v in ipairs(options) do
        if v == default then index = i break end
    end
    
    Btn.MouseButton1Click:Connect(function()
        index = index + 1
        if index > #options then index = 1 end
        local currentVal = options[index]
        Btn.Text = currentVal
        if callback then pcall(callback, currentVal) end
    end)
end

-- ═══════════════════════════════════════════════════════
--                    CREATE TABS
-- ═══════════════════════════════════════════════════════
local FarmTab = CreateTab("Auto Farm", "⚔️")
local FruitTab = CreateTab("Fruit", "🍎")
local QuestTab = CreateTab("Quest", "📜")
local TeleportTab = CreateTab("Teleport", "🌍")
local MoveTab = CreateTab("Move", "💨")
local MiscTab = CreateTab("Misc", "🛠️")

Tabs["Auto Farm"].Scroll.Visible = true
TweenService:Create(Tabs["Auto Farm"].Button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Acc, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()

-- ═══════════════════════════════════════════════════════
--                    ⚔️ AUTO FARM TAB
-- ═══════════════════════════════════════════════════════
CreateSection(FarmTab, "⚔️ AUTO FARM")

CreateToggle(FarmTab, "Auto Farm (Kill NPCs)", "⚔️", false, function(v)
    Config.AutoFarm = v
end)

CreateToggle(FarmTab, "Auto Farm Level (Auto TP to island)", "📈", false, function(v)
    Config.AutoFarmLevel = v
end)

CreateSlider(FarmTab, "Farm Range", 100, 2000, 1000, function(v)
    Config.FarmRange = v
end)

CreateSlider(FarmTab, "Fly Height", 5, 60, 20, function(v)
    Config.FlyHeight = v
end)

-- ═══════════════════════════════════════════════════════
--                    🍎 FRUIT TAB
-- ═══════════════════════════════════════════════════════
CreateSection(FruitTab, "🍎 FRUIT SETTINGS")

CreateToggle(FruitTab, "Auto Equip Fruit", "🍎", false, function(v)
    Config.AutoEquipFruit = v
end)

CreateDropdown(FruitTab, "Select Fruit", {
    "Dragon", "Kitsune", "Leopard", "Dough", "Venom",
    "Shadow", "Buddha", "Portal", "Rumble", "Gravity",
    "Control", "Spirit", "Mammoth", "Gas", "T-Rex",
    "Blizzard", "Pain", "Love", "Spider", "Sound",
    "Phoenix", "Magma", "Quake", "Light", "Ice",
    "Sand", "Dark", "Flame", "Bomb", "Spring", "Chop", "Rocket",
}, "Dragon", function(v)
    Config.FruitName = v
    notify("Selected Fruit: " .. v)
end)

-- ═══════════════════════════════════════════════════════
--                    📜 QUEST TAB
-- ═══════════════════════════════════════════════════════
CreateSection(QuestTab, "📜 AUTO QUEST")

CreateToggle(QuestTab, "Auto Quest", "📜", false, function(v)
    Config.AutoQuest = v
end)

CreateToggle(QuestTab, "Auto Accept Quest", "✅", false, function(v)
    Config.AutoAcceptQuest = v
end)

CreateToggle(QuestTab, "Auto Complete Quest", "🏁", false, function(v)
    Config.AutoCompleteQuest = v
end)

-- ═══════════════════════════════════════════════════════
--                    🌍 TELEPORT TAB
-- ═══════════════════════════════════════════════════════
CreateSection(TeleportTab, "🌍 ISLANDS")

for _, island in pairs(Islands) do
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 40)
    B.BackgroundColor3 = Theme.Ter
    B.Text = "🌍 " .. island.name .. " (Lv. " .. island.level .. ")"
    B.TextColor3 = Theme.Text
    B.TextSize = 13
    B.Font = Enum.Font.GothamBold
    B.AutoButtonColor = false
    B.Parent = TeleportTab
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 8)
    BC.Parent = B
    
    B.MouseButton1Click:Connect(function()
        local char = getChar()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(island.pos + Vector3.new(0, 5, 0))
            notify("Teleported to " .. island.name)
        end
    end)
end

-- ═══════════════════════════════════════════════════════
--                    💨 MOVEMENT TAB
-- ═══════════════════════════════════════════════════════
CreateSection(MoveTab, "💨 SPEED")

CreateToggle(MoveTab, "Speed Boost", "💨", false, function(v)
    Config.SpeedBoost = v
end)

CreateSlider(MoveTab, "Speed Value", 16, 300, 120, function(v)
    Config.SpeedValue = v
end)

CreateSection(MoveTab, "🦘 JUMP")

CreateToggle(MoveTab, "Infinite Jump", "🦘", false, function(v)
    Config.InfiniteJump = v
end)

-- ═══════════════════════════════════════════════════════
--                    🛠️ MISC TAB
-- ═══════════════════════════════════════════════════════
CreateSection(MiscTab, "🛠️ UTILITIES")

CreateToggle(MiscTab, "Auto Chest", "💰", false, function(v)
    Config.AutoChest = v
end)

CreateToggle(MiscTab, "Auto Stats", "📊", false, function(v)
    Config.AutoStats = v
end)

CreateDropdown(MiscTab, "Stat to Upgrade", {
    "Melee", "Defense", "Sword", "Gun", "Demon Fruit",
}, "Melee", function(v)
    Config.StatToUpgrade = v
end)

-- ═══════════════════════════════════════════════════════
--                    ⚙️ CORE LOGIC
-- ═══════════════════════════════════════════════════════

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

-- AUTO EQUIP FRUIT
local function equipFruit()
    if not Config.AutoEquipFruit then return end
    
    local char = getChar()
    if not char then return end
    
    -- Check if already equipped
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then return end
    
    -- Find fruit in backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    
    local fruitToFind = Config.FruitName:lower()
    
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find(fruitToFind) or toolName:find("fruit") then
                -- Equip
                pcall(function()
                    tool.Parent = char
                end)
                notify("Equipped: " .. tool.Name)
                return
            end
        end
    end
end

-- AUTO FARM (Simplified for Blox Fruits)
local function findNearestEnemy()
    local char = getChar()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = char.HumanoidRootPart.Position
    local nearest = nil
    local minDist = Config.FarmRange
    
    for _, obj in pairs(Workspace:GetChildren()) do
        pcall(function()
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                local hum = obj.Humanoid
                if hum.Health > 0 and obj.Name ~= LocalPlayer.Name then
                    -- Skip players
                    local isPlayer = Players:GetPlayerFromCharacter(obj)
                    if not isPlayer then
                        local dist = (obj.HumanoidRootPart.Position - myPos).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearest = obj
                        end
                    end
                end
            end
        end)
    end
    
    return nearest
end

-- Auto Farm Main Loop
task.spawn(function()
    while task.wait(0.1) do
        if Config.AutoFarm then
            equipFruit()
            
            local char = getChar()
            if char and char:FindFirstChild("HumanoidRootPart") then
                local enemy = findNearestEnemy()
                if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                    local eHrp = enemy.HumanoidRootPart
                    local hrp = char.HumanoidRootPart
                    local dist = (eHrp.Position - hrp.Position).Magnitude
                    
                    if dist > 5 then
                        -- Fly to enemy
                        local targetPos = eHrp.Position + Vector3.new(0, Config.FlyHeight, 0)
                        hrp.CFrame = CFrame.new(targetPos, eHrp.Position)
                    else
                        -- Attack
                        hrp.CFrame = CFrame.new(hrp.Position, eHrp.Position)
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            pcall(function() tool:Activate() end)
                        end
                        pcall(function()
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        end)
                    end
                end
            end
        end
    end
end)

-- AUTO FARM LEVEL (Teleport to islands based on level)
task.spawn(function()
    while task.wait(5) do
        if Config.AutoFarmLevel then
            local char = getChar()
            if not char then continue end
            
            -- Get player level (Blox Fruits uses a stat system)
            local stats = LocalPlayer:FindFirstChild("leaderstats")
            if not stats then continue end
            
            local level = 1
            pcall(function()
                local lvlStat = stats:FindFirstChild("Level")
                if lvlStat then level = lvlStat.Value end
            end)
            
            -- Find closest island to level
            for _, island in pairs(Islands) do
                if level >= island.level - 10 and level <= island.level + 50 then
                    char.HumanoidRootPart.CFrame = CFrame.new(island.pos + Vector3.new(0, 5, 0))
                    notify("Auto TP: " .. island.name)
                    break
                end
            end
        end
    end
end)

-- AUTO QUEST
task.spawn(function()
    while task.wait(2) do
        if Config.AutoQuest or Config.AutoAcceptQuest then
            local char = getChar()
            if not char then continue end
            
            -- Find quest giver NPCs
            for _, npc in pairs(Workspace:GetChildren()) do
                pcall(function()
                    if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
                        local npcName = npc.Name:lower()
                        if npcName:find("quest") or npcName:find("teacher") or npcName:find("master") then
                            local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                            if npcRoot then
                                local dist = (npcRoot.Position - char.HumanoidRootPart.Position).Magnitude
                                if dist < 300 then
                                    -- Teleport to NPC
                                    char.HumanoidRootPart.CFrame = CFrame.new(npcRoot.Position + Vector3.new(0, 3, 3))
                                    task.wait(1)
                                    
                                    -- Try E key
                                    pcall(function()
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                        task.wait(0.1)
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                    end)
                                end
                            end
                        end
                    end
                end)
            end
        end
    end
end)

-- AUTO CHEST
task.spawn(function()
    while task.wait(1) do
        if Config.AutoChest then
            local char = getChar()
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            
            for _, obj in pairs(Workspace:GetChildren()) do
                pcall(function()
                    if obj:IsA("Model") and (obj.Name:lower():find("chest") or obj.Name:lower():find("crate")) then
                        local part = obj:FindFirstChildWhichIsA("BasePart") or obj:FindFirstChild("Handle")
                        if part then
                            local dist = (part.Position - char.HumanoidRootPart.Position).Magnitude
                            if dist < 500 then
                                char.HumanoidRootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                                task.wait(0.3)
                            end
                        end
                    end
                end)
            end
        end
    end
end)

-- AUTO STATS
task.spawn(function()
    while task.wait(2) do
        if Config.AutoStats then
            pcall(function()
                -- Blox Fruits has a specific remote for stat points
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes then
                    local statRemote = remotes:FindFirstChild("CommF_") or remotes:FindFirstChild("Stats")
                    if statRemote then
                        -- Try to level up stats
                        -- This is complex and may not work
                    end
                end
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════
--                    CONTROLS
-- ═══════════════════════════════════════════════════════

CloseBtn.MouseButton1Click:Connect(function()
    for k, v in pairs(Config) do
        if type(v) == "boolean" then Config[k] = false end
    end
    Main:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3, true)
    task.wait(0.4)
    ScreenGui:Destroy()
    print("🔒 Naraku Blox Fruits Closed")
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

OpenBtn.MouseButton1Click:Connect(function()
    OpenBtn.Visible = false
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main:TweenSize(UDim2.new(0, 640, 0, 600), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then
            Main.Visible = false
            OpenBtn.Visible = true
        else
            Main.Visible = true
            OpenBtn.Visible = false
        end
    end
end)

-- ═══════════════════════════════════════════════════════
--                    WELCOME
-- ═══════════════════════════════════════════════════════
local Notify = Instance.new("Frame")
Notify.Size = UDim2.new(0, 400, 0, 100)
Notify.Position = UDim2.new(0.5, -200, 0, -130)
Notify.BackgroundColor3 = Theme.Sec
Notify.BorderSizePixel = 0
Notify.Parent = ScreenGui

local NC = Instance.new("UICorner")
NC.CornerRadius = UDim.new(0, 14)
NC.Parent = Notify

local NS = Instance.new("UIStroke")
NS.Color = Theme.Acc
NS.Thickness = 2
NS.Parent = Notify

local NI = Instance.new("TextLabel")
NI.Size = UDim2.new(0, 65, 1, 0)
NI.BackgroundTransparency = 1
NI.Text = "🍎"
NI.TextColor3 = Theme.Acc
NI.TextSize = 34
NI.Font = Enum.Font.GothamBlack
NI.Parent = Notify

local NT = Instance.new("TextLabel")
NT.Size = UDim2.new(1, -75, 0, 32)
NT.Position = UDim2.new(0, 70, 0, 15)
NT.BackgroundTransparency = 1
NT.Text = "NARAKU - BLOX FRUITS v1.0"
NT.TextColor3 = Theme.Text
NT.TextSize = 16
NT.Font = Enum.Font.GothamBlack
NT.TextXAlignment = Enum.TextXAlignment.Left
NT.Parent = Notify

local NM = Instance.new("TextLabel")
NM.Size = UDim2.new(1, -75, 0, 25)
NM.Position = UDim2.new(0, 70, 0, 50)
NM.BackgroundTransparency = 1
NM.Text = "Auto Farm • Fruit • Quest • Chest"
NM.TextColor3 = Theme.Success
NM.TextSize = 12
NM.Font = Enum.Font.GothamBold
NM.TextXAlignment = Enum.TextXAlignment.Left
NM.Parent = Notify

TweenService:Create(Notify, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -200, 0, 20)}):Play()
task.wait(5)
TweenService:Create(Notify, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -200, 0, -130)}):Play()
task.wait(0.5)
Notify:Destroy()

-- ═══════════════════════════════════════════════════════
--                    CONSOLE
-- ═══════════════════════════════════════════════════════
print("╔════════════════════════════════════════════╗")
print("║   NARAKU - BLOX FRUITS v1.0 LOADED         ║")
print("║                                            ║")
print("║   ✓ Auto Farm (Kill NPCs)                  ║")
print("║   ✓ Auto Equip Fruit                       ║")
print("║   ✓ Auto Quest                             ║")
print("║   ✓ Auto Chest                             ║")
print("║   ✓ Teleport to Islands                    ║")
print("║   ✓ Speed Boost                            ║")
print("║                                            ║")
print("║   📌 RightShift = Toggle UI                ║")
print("╚════════════════════════════════════════════╝")
