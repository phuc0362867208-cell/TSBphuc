local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

local AutoFarm = false
local Distance = 3
local Mode = "Trên đầu"

local Target = nil
local SavedPos = nil

local FollowConnection
local NoclipConnection

local function getHRP(char)
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
end

local function getTarget()

    local myChar = lp.Character
    local myHRP = getHRP(myChar)
    if not myHRP then return nil end

    local nearest = nil
    local dist = math.huge

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= lp then

            local char = plr.Character
            local hrp = getHRP(char)
            local hum = char and char:FindFirstChild("Humanoid")

            if hrp and hum and hum.Health > 0 then

                local d = (myHRP.Position - hrp.Position).Magnitude

                if d < dist then
                    dist = d
                    nearest = plr
                end

            end
        end
    end

    return nearest
end

local function getOffset()

    if Mode == "Trên đầu" then
        return CFrame.new(0, Distance, 0)

    elseif Mode == "Sau lưng" then
        return CFrame.new(0, 0, Distance)

    elseif Mode == "Trước mặt" then
        return CFrame.new(0, 0, -Distance)

    elseif Mode == "Dưới chân" then
        return CFrame.new(0, -Distance, 0)
    end

end

local function startFarm()

    local char = lp.Character
    local hrp = getHRP(char)
    if not hrp then return end

    SavedPos = hrp.CFrame

    NoclipConnection = RunService.Stepped:Connect(function()

        if lp.Character then
            for _,v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end

    end)

    FollowConnection = task.spawn(function()

        while AutoFarm do

            local char = lp.Character
            local hrp = getHRP(char)
            if not hrp then task.wait() continue end

            if not Target
            or not Target.Character
            or not Target.Character:FindFirstChild("Humanoid")
            or Target.Character.Humanoid.Health <= 0 then

                Target = getTarget()
            end

            if Target and Target.Character then

                local thrp = getHRP(Target.Character)

                if thrp then

                    -- offset phía sau target
                    local pos = thrp.CFrame * CFrame.new(0,0,Distance)

                    hrp.AssemblyLinearVelocity = Vector3.zero

                    hrp.CFrame = CFrame.lookAt(
                        pos.Position,
                        thrp.Position
                    )

                end

            end

            task.wait(0.12) -- delay giúp hit register

        end

    end)

end

local function stopFarm()

    local char = lp.Character
    local hrp = getHRP(char)

    if FollowConnection then
        FollowConnection:Disconnect()
        FollowConnection = nil
    end

    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end

    if hrp then
        hrp.Anchored = false

        if SavedPos then
            hrp.CFrame = SavedPos
        end
    end

end


-- SPEED FIX SYSTEM

local SpeedEnabled = false
local SpeedValue = 50

RunService.Heartbeat:Connect(function()

    if SpeedEnabled then

        local char = lp.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        if hum.WalkSpeed ~= SpeedValue then
            hum.WalkSpeed = SpeedValue
        end

    end

end)

-- JUMP FIX

local JumpEnabled = false
local JumpValue = 20

RunService.Heartbeat:Connect(function()

    if JumpEnabled then

        local char = lp.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        hum.UseJumpPower = false
        hum.JumpHeight = JumpValue

    end

end)


-- ORBIT TELE SYSTEM

local OrbitEnabled = false
local OrbitDistance = 5
local OrbitSpeed = 1

local OrbitTarget = nil
local OrbitConnection
local OrbitAngle = 0
local OrbitSavedPos = nil

local function getNearestTarget()

    local closest = nil
    local dist = math.huge

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= lp then

            local char = plr.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hum and hrp and hum.Health > 0 then

                local d = (lp.Character.HumanoidRootPart.Position - hrp.Position).Magnitude

                if d < dist then
                    dist = d
                    closest = plr
                end

            end
        end
    end

    return closest
end


local function startOrbit()

    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    OrbitSavedPos = hrp.CFrame
    hrp.Anchored = true

    OrbitTarget = getNearestTarget()

    OrbitConnection = RunService.Heartbeat:Connect(function()

        if not OrbitEnabled then return end

        if not OrbitTarget
        or not OrbitTarget.Character
        or not OrbitTarget.Character:FindFirstChild("Humanoid")
        or OrbitTarget.Character.Humanoid.Health <= 0 then

            OrbitTarget = getNearestTarget()
        end

        local thrp = OrbitTarget and OrbitTarget.Character and OrbitTarget.Character:FindFirstChild("HumanoidRootPart")

        if thrp then

            OrbitAngle = OrbitAngle + OrbitSpeed

            local x = math.cos(OrbitAngle) * OrbitDistance
            local z = math.sin(OrbitAngle) * OrbitDistance

            local pos = thrp.Position + Vector3.new(x,0,z)

            local look = CFrame.lookAt(pos, thrp.Position)

hrp.CFrame = CFrame.new(look.Position, thrp.Position)

        end

    end)

end


local function stopOrbit()

    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if OrbitConnection then
        OrbitConnection:Disconnect()
        OrbitConnection = nil
    end

    if hrp then
        hrp.Anchored = false

        if OrbitSavedPos then
            hrp.CFrame = OrbitSavedPos
        end
    end

end

local AutoSkillEnabled = false
local SkillDelay = 0.35

local Hold1 = 0
local Hold2 = 0
local Hold3 = 0
local Hold4 = 0

local VIM = game:GetService("VirtualInputManager")

local function pressKeyHold(key, hold)

    -- nhấn phím
    VIM:SendKeyEvent(true, key, false, game)

    -- giữ phím
    if hold > 0 then
        task.wait(hold)
    else
        task.wait(0.05)
    end

    -- nhả phím
    VIM:SendKeyEvent(false, key, false, game)

end


task.spawn(function()

    while true do

        if not AutoSkillEnabled then
            task.wait(0.2)
            continue
        end

        pressKeyHold(Enum.KeyCode.One, Hold1)
        task.wait(SkillDelay)

        pressKeyHold(Enum.KeyCode.Two, Hold2)
        task.wait(SkillDelay)

        pressKeyHold(Enum.KeyCode.Three, Hold3)
        task.wait(SkillDelay)

        pressKeyHold(Enum.KeyCode.Four, Hold4)
        task.wait(SkillDelay)

    end

end)

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local AutoAttack = false
local AttackThread = nil

local function startAutoAttack()
    if AttackThread then return end -- tránh tạo nhiều thread

    AttackThread = task.spawn(function()
        while AutoAttack do
            local char = lp.Character
            local remote = char and char:FindFirstChild("Communicate")

            if remote then
                remote:FireServer({
                    Mobile = true,
                    Goal = "LeftClick"
                })
            end

            task.wait(0.08) -- tốc độ đánh (có thể chỉnh 0.06–0.1)
        end

        AttackThread = nil
    end)
end

local function stopAutoAttack()
    AutoAttack = false
end

-- AUTO ESCAPE SKY SYSTEM

local EscapeEnabled = false
local EscapeHP = 10
local ReturnHP = 80

local Escaping = false
local SavedFightPos = nil

local EscapeConnection
local NoclipConnection


RunService.Heartbeat:Connect(function()

    if not EscapeEnabled then return end

    local char = lp.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not hum or not hrp then return end

    local hpPercent = (hum.Health / hum.MaxHealth) * 100


    -- TELE LÊN TRỜI
    if hpPercent <= EscapeHP and not Escaping then

        SavedFightPos = hrp.CFrame

        local skyPos = hrp.Position + Vector3.new(0,300,0)

        Escaping = true

        -- GIỮ VỊ TRÍ TRÊN TRỜI
        EscapeConnection = RunService.Heartbeat:Connect(function()

            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then

                local hrp = lp.Character.HumanoidRootPart

                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.CFrame = CFrame.new(skyPos)

            end

        end)


        -- NOCLIP
        NoclipConnection = RunService.Stepped:Connect(function()

            if lp.Character then
                for _,v in pairs(lp.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end

        end)


        -- TẮT TELE KHÁC
        AutoFarm = false
        OrbitEnabled = false

    end


    -- QUAY LẠI
    if Escaping and hpPercent >= ReturnHP then

        if EscapeConnection then
            EscapeConnection:Disconnect()
            EscapeConnection = nil
        end

        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end

        if SavedFightPos then
            hrp.CFrame = SavedFightPos
        end

        Escaping = false

    end

end)


-- LEVEL 1 (giảm nhẹ)
local function FixLag1()

    settings().Rendering.QualityLevel = Enum.QualityLevel.Level06

end


-- LEVEL 2 (tắt shadow)
local function FixLag2()

    settings().Rendering.QualityLevel = Enum.QualityLevel.Level04

    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = false

end


-- LEVEL 3 (xóa hiệu ứng)
local function FixLag3()

    settings().Rendering.QualityLevel = Enum.QualityLevel.Level02

    for _,v in pairs(game:GetDescendants()) do
        if v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Smoke")
        or v:IsA("Fire")
        or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end

end


-- LEVEL 4 (đổi material nhẹ)
local function FixLag4()

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        end
    end

end


-- LEVEL 5 (FIX LAG CỰC MAX)
local function FixLag5()

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then

            if v.Position.Y > 5 then
                v.Transparency = 1
                v.CanCollide = false
            else
                v.Color = Color3.fromRGB(120,120,120)
                v.Material = Enum.Material.SmoothPlastic
            end

        end
    end

end


-- LEVEL 6 (MAXX HƠN NỮA)
local function FixLag6()

    for _,v in pairs(workspace:GetDescendants()) do

        if v:IsA("BasePart") then
            v.Transparency = 1
            v.CanCollide = false
        end

        if v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Smoke")
        or v:IsA("Fire")
        or v:IsA("Sparkles") then
            v.Enabled = false
        end

        if v:IsA("Decal")
        or v:IsA("Texture") then
            v:Destroy()
        end

    end

    local Lighting = game:GetService("Lighting")

    Lighting.Brightness = 0
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000

    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

end

local StatsEnabled = false
local StatsGui

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")

local function createStatsUI()

    if StatsGui then return end

    StatsGui = Instance.new("ScreenGui")
    StatsGui.Name = "StatsUI"
    StatsGui.Parent = game.CoreGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0,170,0,70)
    Frame.Position = UDim2.new(0,10,0,10)
    Frame.BackgroundColor3 = Color3.fromRGB(10,10,20)
    Frame.Parent = StatsGui

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0,170,255)
    Stroke.Thickness = 2
    Stroke.Parent = Frame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,10)
    Corner.Parent = Frame


    local FPS = Instance.new("TextLabel")
    FPS.Size = UDim2.new(1,0,0.5,0)
    FPS.BackgroundTransparency = 1
    FPS.TextColor3 = Color3.fromRGB(0,170,255)
    FPS.Font = Enum.Font.GothamBold
    FPS.TextSize = 18
    FPS.Text = "FPS : ..."
    FPS.Parent = Frame


    local Ping = Instance.new("TextLabel")
    Ping.Size = UDim2.new(1,0,0.5,0)
    Ping.Position = UDim2.new(0,0,0.5,0)
    Ping.BackgroundTransparency = 1
    Ping.TextColor3 = Color3.fromRGB(0,170,255)
    Ping.Font = Enum.Font.GothamBold
    Ping.TextSize = 18
    Ping.Text = "Ping : ..."
    Ping.Parent = Frame


    -- UPDATE FPS + PING
    RunService.RenderStepped:Connect(function()

        if not StatsEnabled then return end

        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())

        FPS.Text = "FPS : "..fps
        Ping.Text = "Ping : "..ping.." ms"

    end)


    -- DRAG UI
    local dragging = false
    local dragStart
    local startPos

    Frame.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = true
            dragStart = input.Position
            startPos = Frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)

        end

    end)


    Frame.InputChanged:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end

    end)


    UIS.InputChanged:Connect(function(input)

        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

            local delta = input.Position - dragStart

            Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )

        end

    end)

end

-- WINDOW
local Window = WindUI:CreateWindow({
Title = "PHUCMAX",
Icon = "rbxassetid://103302974191559",
Author = "by PHUCMAX",
Folder = "TSB",
Size = UDim2.fromOffset(580, 340),
Transparent = true,
Theme = "Dark",
Resizable = true,
SideBarWidth = 150,
Background = "rbxassetid://103302974191559",
BackgroundImageTransparency = 0.42,
HideSearchBar = false,
ScrollBarEnabled = false,
User = { Enabled = true, Anonymous = false },
})

Window:EditOpenButton({
Title = "Open Example UI",
Icon = "rbxassetid://111450164466537",
CornerRadius = UDim.new(0,16),
StrokeThickness = 2,
Color = ColorSequence.new(
Color3.fromHex("007BFF"),
Color3.fromHex("00D4FF")
),
Draggable = true,
})


local Tabs = {
Info = Window:Tab({ Title = "Info", Icon = "ghost" }),
Main = Window:Tab({ Title = "Main", Icon = "gem" }),
Fixlag = Window:Tab({ Title = "Fixlag", Icon = "cog" }),


local InfoTab = Tabs.Info

InfoTab:Section({
    Title = "Thông Tin"
})

InfoTab:Button({
    Title = "Copy Link Discord",
    Desc = " copy link Discord",
    Callback = function()

        local link = "https://discord.gg/yourserver"

        if setclipboard then
            setclipboard(link)
        elseif toclipboard then
            toclipboard(link)
        end

        print("Đã copy link Discord:", link)

    end
})



local MainTab = Tabs.Main

MainTab:Button({
    Title = "Run Camlock ",
    Desc = "camlock",
    Callback = function()

        loadstring(game:HttpGet("https://raw.githubusercontent.com/phuc0362867208-cell/TSBphuc/main/camlock.lua"))()

    end
})


MainTab:Section({
Title = "Auto Farm Player"
})

MainTab:Toggle({
Title = "Auto Farm Player",
Desc = "Bám player gần nhất",
Default = false,
Callback = function(state)

AutoFarm = state

if state then
Target = getTarget()
startFarm()
else
stopFarm()
end

end
})


MainTab:Dropdown({
    Title = "Khoảng cách bám",
    Desc = "Chọn khoảng cách bám",
    Values = {
        "0",
        "1",
        "2",
        "3",
        "5",
        "7",
        "10",
        "15",
        "20"
    },
    Default = "3",
    Multi = false,
    Callback = function(v)

        Distance = tonumber(v)

    end
})


MainTab:Section({
    Title = "Auto Skill"
})


MainTab:Toggle({
    Title = "Auto Skill",
    Desc = "Tự động dùng skill 1-4",
    Default = false,
    Callback = function(state)

        AutoSkillEnabled = state

    end
})

MainTab:Section({
    Title = "Auto Combat"
})


MainTab:Toggle({
    Title = "Auto Attack",
    Default = false,
    Callback = function(state)
        AutoAttack = state

        if state then
            startAutoAttack()
        else
            stopAutoAttack()
        end
    end
})



MainTab:Section({
    Title = "Auto Escape"
})


MainTab:Dropdown({
    Title = "Escape HP %",
    Values = {
        "10","20","30","40","50","60","70","80"
    },
    Default = "10",
    Multi = false,
    Callback = function(v)

        EscapeHP = tonumber(v)

    end
})


MainTab:Dropdown({
    Title = "Return HP %",
    Values = {
        "20","30","40","50","60","70","80","90","100"
    },
    Default = "80",
    Multi = false,
    Callback = function(v)

        ReturnHP = tonumber(v)

    end
})


MainTab:Toggle({
    Title = "Auto Escape Teleport",
    Desc = "Máu thấp sẽ tự động trốn",
    Default = false,
    Callback = function(state)

        EscapeEnabled = state

    end
})



MainTab:Section({
    Title = "Movement"
})


MainTab:Dropdown({
    Title = "Speed Select",
    Values = {"50","150","300","600","999"},
    Default = "50",
    Callback = function(v)

        SpeedValue = tonumber(v)

    end
})


MainTab:Toggle({
    Title = "Enable Speed",
    Default = false,
    Callback = function(state)

        SpeedEnabled = state

        if not state then
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
            end
        end

    end
})

MainTab:Dropdown({
    Title = "Jump Select",
    Values = {"10","20","40","60","100"},
    Default = "20",
    Callback = function(v)

        JumpValue = tonumber(v)

    end
})


MainTab:Toggle({
    Title = "Enable Jump",
    Default = false,
    Callback = function(state)

        JumpEnabled = state

    end
})


MainTab:Section({
    Title = "Orbit Tele"
})


MainTab:Dropdown({
    Title = "Orbit Distance",
    Values = {
        "0","5","10","20","30","40","50","60","70","80","90","99"
    },
    Default = "5",
    Multi = false,
    Callback = function(v)

        OrbitDistance = tonumber(v)

    end
})


MainTab:Dropdown({
    Title = "Orbit Speed",
    Values = {
        "Chậm",
        "Trung Bình",
        "Nhanh",
        "Siêu Nhanh"
    },
    Default = "Trung Bình",
    Multi = false,
    Callback = function(v)

        if v == "Chậm" then
            OrbitSpeed = 0.05
        elseif v == "Trung Bình" then
            OrbitSpeed = 0.15
        elseif v == "Nhanh" then
            OrbitSpeed = 0.35
        elseif v == "Siêu Nhanh" then
            OrbitSpeed = 0.8
        end

    end
})


MainTab:Toggle({
    Title = "Orbit Player",
    Default = false,
    Callback = function(state)

        OrbitEnabled = state

        if state then
            startOrbit()
        else
            stopOrbit()
        end

    end
})

Fixlag:Toggle({
    Title = "Show FPS & Ping",
    Default = false,
    Callback = function(state)

        StatsEnabled = state

        if state then
            createStatsUI()
        elseif StatsGui then
            StatsGui:Destroy()
            StatsGui = nil
        end

    end
})

Fixlag:Button({Title="FixLag Level 1", Callback=function() FixLag1() end})
Fixlag:Button({Title="FixLag Level 2", Callback=function() FixLag2() end})
Fixlag:Button({Title="FixLag Level 3", Callback=function() FixLag3() end})
Fixlag:Button({Title="FixLag Level 4", Callback=function() FixLag4() end})
Fixlag:Button({Title="FixLag Level 5 ", Callback=function() FixLag5() end})
Fixlag:Button({Title="FixLag Level 6 ", Callback=function() FixLag6() end})


