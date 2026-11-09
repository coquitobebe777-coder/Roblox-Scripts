
-- NEON RGB SPECTATE v1.0
-- LocalScript - StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local selectedPlayer = nil
local rainbowHue = 0

local gui = Instance.new("ScreenGui")
gui.Name = "NeonSpectate"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(300, 370)
main.Position = UDim2.new(0.5, -150, 0.5, -185)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Thickness = 3
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "NEON SPECTATE"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 23
title.Font = Enum.Font.GothamBold
title.Parent = main

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(15, 65)
list.Size = UDim2.new(1, -30, 0, 220)
list.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.new()
list.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.Parent = list

local function stopSpectate()
    selectedPlayer = nil
    camera.CameraSubject = player.Character
        and player.Character:FindFirstChildOfClass("Humanoid")
end

local function refreshPlayers()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player then
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -10, 0, 38)
            button.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
            button.TextColor3 = Color3.new(1, 1, 1)
            button.Text = "  " .. target.DisplayName
                .. "  (@" .. target.Name .. ")"
            button.Font = Enum.Font.GothamMedium
            button.TextSize = 13
            button.Parent = list

            Instance.new("UICorner", button).CornerRadius =
                UDim.new(0, 8)

            button.MouseButton1Click:Connect(function()
                local character = target.Character
                local humanoid = character
                    and character:FindFirstChildOfClass("Humanoid")

                if humanoid then
                    selectedPlayer = target
                    camera.CameraSubject = humanoid
                end
            end)
        end
    end

    task.wait()
    list.CanvasSize = UDim2.fromOffset(
        0, layout.AbsoluteContentSize.Y + 10
    )
end

local stop = Instance.new("TextButton")
stop.Position = UDim2.fromOffset(15, 300)
stop.Size = UDim2.new(1, -30, 0, 42)
stop.BackgroundColor3 = Color3.fromRGB(180, 20, 55)
stop.Text = "STOP SPECTATE"
stop.TextColor3 = Color3.new(1, 1, 1)
stop.Font = Enum.Font.GothamBold
stop.TextSize = 15
stop.Parent = main

Instance.new("UICorner", stop).CornerRadius = UDim.new(0, 9)
stop.MouseButton1Click:Connect(stopSpectate)

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(function(target)
    if selectedPlayer == target then
        stopSpectate()
    end
    refreshPlayers()
end)

player.CharacterAdded:Connect(function(character)
    if not selectedPlayer then
        camera.CameraSubject =
            character:WaitForChild("Humanoid")
    end
end)

RunService.RenderStepped:Connect(function(dt)
    rainbowHue = (rainbowHue + dt * 0.35) % 1
    stroke.Color = Color3.fromHSV(rainbowHue, 1, 1)

    if selectedPlayer then
        local character = selectedPlayer.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")

        if humanoid and camera.CameraSubject ~= humanoid then
            camera.CameraSubject = humanoid
        end
    end
end)

refreshPlayers()
