-- ═══════════════════════════════════════════════════════════════
-- NARAKU HUB - SMART AUTO FARM (Level-Based)
-- Features:
-- 1. Reads your Level
-- 2. Teleports to the correct Island
-- 3. Kills NPCs in that Island
-- 4. Auto Equips Fruit/Melee
-- 5. Speed Boost + Infinite Jump
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════
-- 1. إعدادات الجزائر (الاسم، الإحداثيات، الليفل المطلوب)
-- ═══════════════════════════════════════════════════════
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
}

-- ═══════════════════════════════════════════════════════
-- 2. الإعدادات
-- ═══════════════════════════════════════════════════════
local Config = {
    AutoFarm = false,
    AutoEquipFruit = false,
    SelectedFruit = "Dragon", -- اسم الفاكهة اللي تبيها
    SpeedBoost = false,
    SpeedValue = 150,
    InfiniteJump = false,
    FlyHeight = 15,
}

-- ═══════════════════════════════════════════════════════
-- 3. دالة الحصول على ليفل اللاعب
-- ═══════════════════════════════════════════════════════
local function getMyLevel()
    local level = 1
    -- Blox Fruits تحط الليفل في leaderstats
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if stats then
        local lvl = stats:FindFirstChild("Level")
        if lvl then level = lvl.Value end
    end
    return level
end

-- ═══════════════════════════════════════════════════════
-- 4. الواجهة
-- ═══════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NarakuBF"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 450, 0, 450)
Main.Position = UDim2.new(0.5, -225, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MC = Instance.new("UICorner")
MC.CornerRadius = UDim.new(0, 12)
MC.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
Title.Text = "🍎 NARAKU - SMART AUTO FARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 12)
TC.Parent = Title

-- إطار المعلومات
local InfoFrame = Instance.new("Frame")
InfoFrame.Size = UDim2.new(1, -20, 0, 50)
InfoFrame.Position = UDim2.new(0, 10, 0, 60)
InfoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
InfoFrame.Parent = Main

local IFC = Instance.new("UICorner")
IFC.CornerRadius = UDim.new(0, 8)
IFC.Parent = InfoFrame

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 1, 0)
InfoLabel.Position = UDim2.new(0, 10, 0, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Level: Loading... | Island: Loading..."
InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoLabel.TextSize = 14
InfoLabel.Font = Enum.Font.GothamBold
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Parent = InfoFrame

-- دالة تحديث المعلومات
local function updateInfo()
    local level = getMyLevel()
    local island = "Unknown"
    for _, isl in pairs(Islands) do
        if level >= isl.level then
            island = isl.name
        end
    end
    InfoLabel.Text = "Level: " .. level .. " | Island: " .. island
end

task.spawn(function()
    while task.wait(2) do
        pcall(updateInfo)
    end
end)

-- دالة إنشاء زر
local function CreateButton(name, callback, color)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 40)
    Btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 60)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = Main
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 8)
    BC.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)
    
    return Btn
end

-- الأزرار
local FarmBtn = CreateButton("⚔️ Auto Farm (Smart) : OFF", function()
    Config.AutoFarm = not Config.AutoFarm
    FarmBtn.Text = "⚔️ Auto Farm (Smart) : " .. (Config.AutoFarm and "ON" or "OFF")
    FarmBtn.BackgroundColor3 = Config.AutoFarm and Color3.fromRGB(80, 230, 130) or Color3.fromRGB(40, 40, 60)
end, Color3.fromRGB(40, 40, 60))
FarmBtn.Position = UDim2.new(0, 10, 0, 120)

local EquipBtn = CreateButton("🍎 Auto Equip Fruit : OFF", function()
    Config.AutoEquipFruit = not Config.AutoEquipFruit
    EquipBtn.Text = "🍎 Auto Equip Fruit : " .. (Config.AutoEquipFruit and "ON" or "OFF")
    EquipBtn.BackgroundColor3 = Config.AutoEquipFruit and Color3.fromRGB(80, 230, 130) or Color3.fromRGB(40, 40, 60)
end, Color3.fromRGB(40, 40, 60))
EquipBtn.Position = UDim2.new(0, 10, 0, 170)

local SpeedBtn = CreateButton("💨 Speed Boost : OFF", function()
    Config.SpeedBoost = not Config.SpeedBoost
    SpeedBtn.Text = "💨 Speed Boost : " .. (Config.SpeedBoost and "ON" or "OFF")
    SpeedBtn.BackgroundColor3 = Config.SpeedBoost and Color3.fromRGB(80, 230, 130) or Color3.fromRGB(40, 40, 60)
end, Color3.fromRGB(40, 40, 60))
SpeedBtn.Position = UDim2.new(0, 10, 0, 220)

local JumpBtn = CreateButton("🦘 Infinite Jump : OFF", function()
    Config.InfiniteJump = not Config.InfiniteJump
    JumpBtn.Text = "🦘 Infinite Jump : " .. (Config.InfiniteJump and "ON" or "OFF")
    JumpBtn.BackgroundColor3 = Config.InfiniteJump and Color3.fromRGB(80, 230, 130) or Color3.fromRGB(40, 40, 60)
end, Color3.fromRGB(40, 40, 60))
JumpBtn.Position = UDim2.new(0, 10, 0, 270)

local CloseBtn = CreateButton("✖ CLOSE", function()
    ScreenGui:Destroy()
end, Color3.fromRGB(255, 60, 90))
CloseBtn.Position = UDim2.new(0, 10, 1, -50)

-- ═══════════════════════════════════════════════════════
-- 5. المنطق (الذكاء)
-- ═══════════════════════════════════════════════════════

-- Speed Boost
task.spawn(function()
    while task.wait(0.1) do
        if Config.SpeedBoost then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= Config.SpeedValue then
                    hum.WalkSpeed = Config.SpeedValue
                end
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- Auto Equip Fruit
task.spawn(function()
    while task.wait(1) do
        if Config.AutoEquipFruit then
            local char = LocalPlayer.Character
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

-- ═══════════════════════════════════════════════════════
-- 6. Auto Farm (الجزء الذكي)
-- ═══════════════════════════════════════════════════════
task.spawn(function()
    local currentIsland = nil
    while task.wait(0.1) do
        if Config.AutoFarm then
            local char = LocalPlayer.Character
            if not char then continue end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then continue end
            
            local myLevel = getMyLevel()
            
            -- 1. إيجاد الجزيرة المناسبة حسب الليفل
            local targetIsland = Islands[1]
            for _, isl in pairs(Islands) do
                if myLevel >= isl.level then
                    targetIsland = isl
                end
            end
            
            -- 2. إذا تغيرت الجزيرة، نطير لها
            if currentIsland ~= targetIsland.name then
                currentIsland = targetIsland.name
                hrp.CFrame = CFrame.new(targetIsland.pos + Vector3.new(0, 10, 0))
                task.wait(1)
            end
            
            -- 3. البحث عن أقرب NPC في الجزيرة
            local nearestNPC = nil
            local minDist = 800
            
            for _, obj in pairs(Workspace:GetChildren()) do
                pcall(function()
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                        local npcHum = obj.Humanoid
                        if npcHum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                            -- نتأكد أن الـ NPC قريب من الجزيرة
                            local distToIsland = (obj.HumanoidRootPart.Position - targetIsland.pos).Magnitude
                            local distToMe = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
                            
                            if distToIsland < 500 and distToMe < minDist then
                                minDist = distToMe
                                nearestNPC = obj
                            end
                        end
                    end
                end)
            end
            
            -- 4. إذا لقينا NPC، نطير فوقه ونضربه
            if nearestNPC then
                local npcHrp = nearestNPC.HumanoidRootPart
                local targetPos = npcHrp.Position + Vector3.new(0, Config.FlyHeight, 0)
                
                -- طيران سلس فوق الـ NPC
                hrp.CFrame = CFrame.new(targetPos, npcHrp.Position)
                
                -- ضرب
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function() tool:Activate() end)
                end
                
                -- ضرب بالماوس
                pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════
-- 7. Console
-- ═══════════════════════════════════════════════════════
print("✅ Naraku Smart Auto Farm Loaded!")
print("📌 Level:", getMyLevel())
