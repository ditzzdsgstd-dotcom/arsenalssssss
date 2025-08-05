-- YoxanXHub | Arsenal UI (1/5) - With Intro + OrionLib Style
local CoreGui = game:GetService("CoreGui")
pcall(function() CoreGui:FindFirstChild("YoxanXHubUI"):Destroy() end)

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "YoxanXHubUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Intro Frame
local intro = Instance.new("TextLabel", gui)
intro.Size = UDim2.new(0, 300, 0, 60)
intro.Position = UDim2.new(0.5, -150, 0.5, -30)
intro.BackgroundColor3 = Color3.fromRGB(20,20,20)
intro.Text = "Loading YoxanXHub Arsenal..."
intro.TextColor3 = Color3.new(1,1,1)
intro.Font = Enum.Font.GothamBold
intro.TextSize = 18
intro.BorderSizePixel = 0
Instance.new("UICorner", intro)

-- Fade out intro
task.spawn(function()
	for i = 1, 30 do
		intro.TextTransparency = i/30
		intro.BackgroundTransparency = i/30
		task.wait(0.02)
	end
	intro:Destroy()
end)

-- Main UI Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 500, 0, 320)
main.Position = UDim2.new(0.5, -250, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Name = "MainUI"
main.Visible = false
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(60,60,60)
stroke.Thickness = 2

-- Title Bar
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "YoxanXHub | Arsenal"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Tabs
local tabNames = {"Aimbot", "ESP", "Misc"}
local tabButtons = {}
local contentFrames = {}
local currentTab = nil

for i, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton", main)
	btn.Size = UDim2.new(0, 100, 0, 30)
	btn.Position = UDim2.new(0, 10 + (i-1)*110, 0, 45)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	tabButtons[name] = btn

	local content = Instance.new("Frame", main)
	content.Size = UDim2.new(1, -20, 1, -90)
	content.Position = UDim2.new(0, 10, 0, 85)
	content.BackgroundTransparency = 1
	content.Visible = false
	contentFrames[name] = content

	local placeholder = Instance.new("TextLabel", content)
	placeholder.Size = UDim2.new(1, -20, 0, 24)
	placeholder.Position = UDim2.new(0, 10, 0, 10)
	placeholder.BackgroundTransparency = 1
	placeholder.Text = name.." features will appear here."
	placeholder.TextColor3 = Color3.fromRGB(200,200,200)
	placeholder.Font = Enum.Font.Gotham
	placeholder.TextSize = 14
	placeholder.TextXAlignment = Enum.TextXAlignment.Left
end

-- Tab switching
for name, btn in pairs(tabButtons) do
	btn.MouseButton1Click:Connect(function()
		for n, frame in pairs(contentFrames) do
			frame.Visible = (n == name)
		end
	end)
end

-- Show main UI after intro fades
task.delay(0.8, function()
	main.Visible = true
	contentFrames["Aimbot"].Visible = true
end)

-- == Aimbot Toggle System ==
local Aimbot = false

-- Buat toggle di tab Aimbot
local function createToggle(tab, labelText, callback)
	local btn = Instance.new("TextButton", tab)
	btn.Size = UDim2.new(0, 140, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, 45)
	btn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
	btn.Text = "❌ " .. labelText
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	Instance.new("UICorner", btn)

	local toggled = false
	btn.MouseButton1Click:Connect(function()
		toggled = not toggled
		btn.Text = (toggled and "✔️ " or "❌ ") .. labelText
		btn.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(120, 0, 0)
		callback(toggled)
	end)
end

createToggle(contentFrames["Aimbot"], "Enable Aimbot", function(state)
	Aimbot = state
end)

-- == Aimbot Logic ==
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = workspace.CurrentCamera

local function getClosestEnemy()
	local closest, dist = nil, math.huge
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Team ~= LP.Team and plr.Character and plr.Character:FindFirstChild("Head") then
			local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
			if onScreen then
				local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
				if mag < dist then
					closest = plr
					dist = mag
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	if Aimbot then
		local target = getClosestEnemy()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			local headPos = target.Character.Head.Position
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPos)
		end
	end
end)

-- == ESP Toggle ==
local ESPEnabled = false
local ESPObjects = {}

createToggle(contentFrames["ESP"], "Enable ESP", function(state)
	ESPEnabled = state
end)

-- == ESP Logic ==
local function createESP(player)
	if ESPObjects[player] then return end
	if not player.Character then return end
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Adornee = player.Character
	highlight.Parent = player.Character
	ESPObjects[player] = highlight
end

local function removeESP(player)
	if ESPObjects[player] then
		ESPObjects[player]:Destroy()
		ESPObjects[player] = nil
	end
end

-- Cleanup jika player mati/respawn/leave
Players.PlayerRemoving:Connect(removeESP)
RunService.RenderStepped:Connect(function()
	if not ESPEnabled then
		for _, h in pairs(ESPObjects) do h:Destroy() end
		ESPObjects = {}
		return
	end

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LP and p.Team ~= LP.Team then
			if p.Character and not ESPObjects[p] then
				createESP(p)
			elseif not p.Character and ESPObjects[p] then
				removeESP(p)
			end
		elseif ESPObjects[p] then
			removeESP(p)
		end
	end
end)

-- == Kill All Toggle ==
local KillAll = false

createToggle(contentFrames["Misc"], "Enable KillAll", function(state)
	KillAll = state
end)

-- == Kill All Logic ==
local function teleportTo(pos)
	local char = LP.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	char:MoveTo(pos + Vector3.new(0, 3, 0))
end

task.spawn(function()
	while task.wait(0.4) do
		if KillAll then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LP and plr.Team ~= LP.Team and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local hrp = plr.Character.HumanoidRootPart
					teleportTo(hrp.Position)
					break
				end
			end
		end
	end
end)

-- == Auto Fire Toggle ==
local AutoFire = false

createToggle(contentFrames["Misc"], "Enable Auto Fire", function(state)
	AutoFire = state
end)

-- == Auto Fire Logic ==
RunService.RenderStepped:Connect(function()
	if AutoFire and LP.Character then
		local tool = LP.Character:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			tool:Activate()
		end
	end
end)

-- ✅ Final Notification
local function finalNotify()
	local note = Instance.new("TextLabel", gui)
	note.Size = UDim2.new(0, 280, 0, 30)
	note.Position = UDim2.new(0.5, -140, 1, -40)
	note.BackgroundColor3 = Color3.fromRGB(30, 180, 60)
	note.Text = "✅ YoxanXHub Arsenal Fully Loaded!"
	note.TextColor3 = Color3.new(1,1,1)
	note.Font = Enum.Font.GothamBold
	note.TextSize = 14
	note.BackgroundTransparency = 0
	Instance.new("UICorner", note)

	task.spawn(function()
		for i = 1, 50 do
			note.TextTransparency = i/50
			note.BackgroundTransparency = i/50
			task.wait(0.02)
		end
		note:Destroy()
	end)
end

-- Show notification after UI is ready
task.delay(1.5, finalNotify)
