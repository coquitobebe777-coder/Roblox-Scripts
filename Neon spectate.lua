
-- NEON RGB SPECTATE v2.0
-- StarterPlayerScripts / LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local gui = Instance.new("ScreenGui")
gui.Name = "NeonSpectate"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local selectedPlayer = nil
local hue = 0

-- BOTON FLOTANTE
local floating = Instance.new("TextButton")
floating.Size = UDim2.fromOffset(55, 55)
floating.Position = UDim2.new(0, 20, 0.5, 0)
floating.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
floating.Text = "RGB"
floating.TextColor3 = Color3.new(1,1,1)
floating.TextSize = 15
floating.Font = Enum.Font.GothamBold
floating.Parent = gui

Instance.new("UICorner", floating).CornerRadius =
    UDim.new(1, 0)

local floatStroke = Instance.new("UIStroke")
floatStroke.Thickness = 3
floatStroke.Parent = floating

-- MENU PRINCIPAL
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(260, 300)
main.Position = UDim2.new(0.5, -130, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
main.Visible = false
main.Parent = gui

Instance.new("UICorner", main).CornerRadius =
    UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Parent = main

-- TITULO
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "NEON SPECTATE"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = main

-- LISTA
local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(10, 50)
list.Size = UDim2.new(1, -20, 0, 190)
list.BackgroundColor3 = Color3.fromRGB(20,20,35)
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = list

local function stopSpectate()
    selectedPlayer = nil

    local character = player.Character
    local humanoid = character and
        character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        camera.CameraSubject = humanoid
    end
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
            button.Size = UDim2.new(1, -8, 0, 34)
            button.BackgroundColor3 =
                Color3.fromRGB(35, 25, 55)
            button.TextColor3 = Color3.new(1,1,1)
            button.Text = target.DisplayName
            button.Font = Enum.Font.Gotham
            button.TextSize = 12
            button.Parent = list

            Instance.new("UICorner", button).CornerRadius =
                UDim.new(0, 7)

            button.MouseButton1Click:Connect(function()
                local character = target.Character
                local humanoid = character and
                    character:FindFirstChildOfClass("Humanoid")

                if humanoid then
                    selectedPlayer = target
                    camera.CameraSubject = humanoid
                end
            end)
        end
    end

    task.wait()
    list.CanvasSize = UDim2.fromOffset(
        0, layout.AbsoluteContentSize.Y + 5
    )
end

-- STOP
local stop = Instance.new("TextButton")
stop.Position = UDim2.new(0, 10, 1, -48)
stop.Size = UDim2.new(1, -20, 0, 38)
stop.BackgroundColor3 = Color3.fromRGB(170, 25, 60)
stop.Text = "STOP SPECTATE"
stop.TextColor3 = Color3.new(1,1,1)
stop.Font = Enum.Font.GothamBold
stop.TextSize = 13
stop.Parent = main

Instance.new("UICorner", stop).CornerRadius =
    UDim.new(0, 8)

stop.MouseButton1Click:Connect(stopSpectate)

-- MOSTRAR / OCULTAR
floating.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- ARRASTRAR BOTON FLOTANTE
local dragging = false
local dragStart
local startPosition
local dragInput

floating.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = floating.Position

        input.Changed:Connect(function()
            if input.UserInputState ==
                Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        floating.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

-- RGB
RunService.RenderStepped:Connect(function(dt)
    hue = (hue + dt * 0.4) % 1

    local color = Color3.fromHSV(hue, 1, 1)
    stroke.Color = color
    floatStroke.Color = color

    if selectedPlayer then
        local character = selectedPlayer.Character
        local humanoid = character and
            character:FindFirstChildOfClass("Humanoid")

        if humanoid and camera.CameraSubject ~= humanoid then
            camera.CameraSubject = humanoid
        end
    end
end)

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

refreshPlayers()
