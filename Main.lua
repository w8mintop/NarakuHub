--[[
    NARAKU HUB - BLOX FRUITS (Remote Edition)
    Features:
    - Auto Farm (Fly + Kill NPCs)
    - Auto Equip Fruit
    - Auto Quest
    - Teleport Islands
    - Speed Boost (Working)
    - Infinite Jump
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════
-- الإعدادات
-- ═══════════════════════════════════════════════════════
local Config = {
    AutoFarm = false,
    AutoEquipFruit = false,
    SelectedFruit = "Dragon",
    AutoQuest = false,
    SpeedBoost = false,
    SpeedValue = 150,
    InfiniteJump = false,
    FlyHeight = 15,
    FarmRange = 800,
}

-- ═══════════════════════════════════════════════════════
-- الـ Remotes الخاصة بـ Blox Fruits (مهم جداً)
-- ═══════════════════════════════════════════════════════
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local CommF = Remotes and Remotes:FindFirstChild("CommF_")
local CommE = Remotes and Remotes:FindFirstChild("CommE_")

-- دالة إرسال الأمر للعبة (الطريقة الصحيحة)
local function FireCommF(cmd)
    if CommF then
        pcall(function() CommF:InvokeServer(cmd) end)
    end
end

local function FireCommE(cmd, ...)
    if CommE then
        pcall(function() CommE:FireServer(cmd, ...) end)
    end
end

-- ═══════════════════════════════════════════════════════
-- الواجهة
-- ═══════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NarakuBF"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 520)
Main.Position = UDim2.new(0.5, -250, 0.5, -260)
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
Title.BackgroundColor3 = Color3.fromRGB(255, 120, 60)
Title.Text = "🍎 NARAKU - BLOX FRUITS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 12)
TC.Parent = Title

-- Tab System (بسيط)
local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(1, -20, 1, -110)
Tabs.Position = UDim2.new(0, 10, 0, 60)
Tabs.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Tabs.Parent = Main

local TC2 = Instance.new("UICorner")
TC2.CornerRadius = UDim.new(0, 10)
TC2.Parent = Tabs

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Tabs

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 10)
Padding.PaddingLeft = UDim.new(0, 10)
Padding.PaddingRight = UDim.new(0, 10)
Padding.Parent = Tabs

-- دالة إنشاء زر تبديل
local function CreateToggle(name, default, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Btn.Text = name .. " : OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = Tabs
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 8)
    BC.Parent = Btn
    
    local state = default or false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = name .. " : " .. (state and "ON" or "OFF")
        Btn.TextColor3 = state and Color3.fromRGB(80, 230, 130) or Color3.fromRGB(255, 100, 100)
        if callback then pcall(callback, state) end
    end)
end

-- دالة إنشاء زر عادي
local function CreateButton(name, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 120, 60)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = Tabs
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 8)
    BC.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)
end

-- دالة إنشاء شريط تمرير
local function CreateSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 55)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Frame.Parent = Tabs
    
    local FC = Instance.new("UICorner")
    FC.CornerRadius = UDim.new(0, 8)
    FC.Parent = Frame
    
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -20, 0, 20)
    Lbl.Position = UDim2.new(0, 10, 0, 5)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = name .. ": " .. default
    Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Frame
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 8)
    Bar.Position = UDim2.new(0, 10, 1, -18)
    Bar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    Bar.Parent = Frame
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(1, 0)
    BC.Parent = Bar
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 120, 60)
    Fill.Parent = Bar
    
    local FC2 = Instance.new("UICorner")
    FC2.CornerRadius = UDim.new(1, 0)
    FC2.Parent = Fill
    
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Lbl.Text = name .. ": " .. val
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

-- ═══════════════════════════════════════════════════════
-- الميزات
-- ═══════════════════════════════════════════════════════

CreateButton("⚔️ Auto Farm NPCs", function()
    Config.AutoFarm = not Config.AutoFarm
    StarterGui:SetCore("SendNotification", {Title = "Naraku", Text = "Auto Farm: " .. (Config.AutoFarm and "ON" or "OFF")})
end)

CreateButton("🍎 Auto Equip Fruit (" .. Config.SelectedFruit .. ")", function()
    Config.AutoEquipFruit = not Config.AutoEquipFruit
    StarterGui:SetCore("SendNotification", {Title = "Naraku", Text = "Auto Equip Fruit: " .. (Config.AutoEquipFruit and "ON" or "OFF")})
end)

CreateButton("📜 Auto Quest", function()
    Config.AutoQuest = not Config.AutoQuest
    StarterGui:SetCore("SendNotification", {Title = "Naraku", Text = "Auto Quest: " .. (Config.AutoQuest and "ON" or "OFF")})
end)

CreateToggle("💨 Speed Boost", false, function(v) Config.SpeedBoost = v end)
CreateSlider("Speed Value", 16, 300, 150, function(v) Config.SpeedValue = v end)
CreateToggle("🦘 Infinite Jump", false, function(v) Config.InfiniteJump = v end)

CreateButton("🏝️ Teleport to Starter Island", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 15, 0)
    end
end)

-- زر إغلاق
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -20, 0, 40)
CloseBtn.Position = UDim2.new(0, 10, 1, -50)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 90)
CloseBtn.Text = "✖ CLOSE"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Main

local CC = Instance.new("UICorner")
CC.CornerRadius = UDim.new(0, 8)
CC.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ═══════════════════════════════════════════════════════
-- المنطق (يعمل فعلياً)
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

-- Auto Farm (باستخدام Remotes)
task.spawn(function()
    while task.wait(0.1) do
        if Config.AutoFarm then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                
                -- البحث عن NPC
                local nearest = nil
                local minDist = Config.FarmRange
                
                for _, obj in pairs(Workspace:GetChildren()) do
                    pcall(function()
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                            local hum = obj.Humanoid
                            if hum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                                local dist = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    nearest = obj
                                end
                            end
                        end
                    end)
                end
                
                if nearest then
                    local targetPos = nearest.HumanoidRootPart.Position + Vector3.new(0, Config.FlyHeight, 0)
                    hrp.CFrame = CFrame.new(targetPos, nearest.HumanoidRootPart.Position)
                    
                    -- ضرب
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        pcall(function() tool:Activate() end)
                    end
                    
                    -- محاولة إرسال أمر للعبة (إذا فيه Remote للقتال)
                    FireCommE("Attack", nearest)
                end
            end
        end
    end
end)

-- Auto Quest (باستخدام Remotes)
task.spawn(function()
    while task.wait(2) do
        if Config.AutoQuest then
            -- البحث عن NPC المهام
            for _, obj in pairs(Workspace:GetChildren()) do
                pcall(function()
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                        local npcName = obj.Name:lower()
                        if npcName:find("quest") or npcName:find("teacher") or npcName:find("master") then
                            local char = LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.HumanoidRootPart.CFrame = CFrame.new(obj.HumanoidRootPart.Position + Vector3.new(0, 3, 3))
                                task.wait(1)
                                -- محاولة قبول المهمة
                                FireCommE("StartQuest", obj.Name)
                            end
                        end
                    end
                end)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════
-- Console
-- ═══════════════════════════════════════════════════════
print("✅ Naraku Blox Fruits Loaded!")
print("📌 CommF Found:", CommF ~= nil)
print("📌 CommE Found:", CommE ~= nil)
