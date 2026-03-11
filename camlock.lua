-- CAMLOCK MODULE (BLUE UI VERSION)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CamlockEnabled = false
local CurrentTarget = nil
local HighlightESP


local function getNearest()

    local closest = nil
    local dist = math.huge

    local myChar = lp.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= lp then

            local char = plr.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hum and hrp and hum.Health > 0 then

                local mag = (hrp.Position - myHRP.Position).Magnitude

                if mag < dist then
                    dist = mag
                    closest = plr
                end

            end
        end
    end

    return closest
end


local function highlight(char)

    if HighlightESP then
        HighlightESP:Destroy()
    end

    HighlightESP = Instance.new("Highlight")
    HighlightESP.FillTransparency = 1
    HighlightESP.OutlineColor = Color3.fromRGB(0,170,255)
    HighlightESP.OutlineTransparency = 0
    HighlightESP.Parent = char

end


RunService.RenderStepped:Connect(function()

    if not CamlockEnabled then return end

    if not CurrentTarget
    or not CurrentTarget.Character
    or CurrentTarget.Character.Humanoid.Health <= 0 then

        CurrentTarget = getNearest()

        if CurrentTarget and CurrentTarget.Character then
            highlight(CurrentTarget.Character)
        end

    end

    if CurrentTarget and CurrentTarget.Character then

        local hrp = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")

        if hrp then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position)
        end

    end

end)



-- UI

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CamlockUI"
ScreenGui.Parent = lp:WaitForChild("PlayerGui")


local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,180,0,95)
Frame.Position = UDim2.new(0.6,0,0.5,0)
Frame.BackgroundColor3 = Color3.fromRGB(15,15,25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui


local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0,170,255)
Stroke.Thickness = 2
Stroke.Parent = Frame


local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,10)
Corner.Parent = Frame


local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,25)
Title.Text = "Camlock"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0,170,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame


local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1,-10,0,40)
Button.Position = UDim2.new(0,5,0,40)
Button.Text = "OFF"
Button.BackgroundColor3 = Color3.fromRGB(0,120,255)
Button.TextColor3 = Color3.new(1,1,1)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 16
Button.Parent = Frame


local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0,8)
ButtonCorner.Parent = Button


Button.MouseButton1Click:Connect(function()

    CamlockEnabled = not CamlockEnabled

    if CamlockEnabled then
        Button.Text = "ON"
        Button.BackgroundColor3 = Color3.fromRGB(0,170,255)
    else
        Button.Text = "OFF"
        Button.BackgroundColor3 = Color3.fromRGB(0,120,255)
        CurrentTarget = nil

        if HighlightESP then
            HighlightESP:Destroy()
        end
    end

end)



-- DRAG UI

local dragging = false
local dragInput
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

    if input == dragInput and dragging then

        local delta = input.Position - dragStart

        Frame.Position =
        UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

    end

end)
