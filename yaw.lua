-- YoxanXHub | Arsenal UI V2 - 1/5
local CoreGui = game:GetService("CoreGui")
pcall(function() CoreGui:FindFirstChild("YoxanXHubUI"):Destroy() end)

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "YoxanXHubUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- == Floating Open Button ==
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 40, 0, 40)
openBtn.Position = UDim2.new(0, 10, 0.5, -20)
openBtn.Text = "📂"
openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 20
Instance.new("UICorner", openBtn)

-- == Main Window ==
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 520, 0, 320)
main.Position = UDim2.new(0.5, -260, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Visible = false
Instance.new("UICorner", main)

-- == Draggable ==
local dragToggle, dragInput, dragStart, startPos
main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragToggle = true
		dragStart = input.Position
		startPos = main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
		end)
	end
end)
main.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragToggle then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- == Title Bar ==
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "YoxanXHub | Arsenal"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left

-- == Close Button ==
local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "❌"
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
Instance.new("UICorner", closeBtn)

-- == Sidebar Tabs ==
local tabNames = {"Aimbot", "ESP", "Misc"}
local tabButtons = {}
local contentFrames = {}

for i, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton", main)
	btn.Size = UDim2.new(0, 100, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, 50 + (i - 1) * 35)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	Instance.new("UICorner", btn)
	tabButtons[name] = btn

	local content = Instance.new("Frame", main)
	content.Size = UDim2.new(1, -130, 1, -60)
	content.Position = UDim2.new(0, 120, 0, 50)
	content.BackgroundTransparency = 1
	content.Visible = false
	contentFrames[name] = content

	local placeholder = Instance.new("TextLabel", content)
	placeholder.Size = UDim2.new(1, -20, 0, 24)
	placeholder.Position = UDim2.new(0, 10, 0, 10)
	placeholder.BackgroundTransparency = 1
	placeholder.Text = name.." features coming soon..."
	placeholder.TextColor3 = Color3.fromRGB(200,200,200)
	placeholder.Font = Enum.Font.Gotham
	placeholder.TextSize = 14
	placeholder.TextXAlignment = Enum.TextXAlignment.Left
end

-- == Tab Switching ==
for name, btn in pairs(tabButtons) do
	btn.MouseButton1Click:Connect(function()
		for n, f in pairs(contentFrames) do
			f.Visible = (n == name)
		end
	end)
end

-- == Show/Hide Logic ==
openBtn.MouseButton1Click:Connect(function()
	main.Visible = true
	openBtn.Visible = false
	contentFrames["Aimbot"].Visible = true
end)

closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	openBtn.Visible = true
end)

-- == Aimbot State ==
local Aimbot = false

-- == Create Toggle Utility ==
local function createToggle(tab, labelText, default, callback)
	local button = Instance.new("TextButton", tab)
	button.Size = UDim2.new(0, 160, 0, 30)
	button.Position = UDim2.new(0, 10, 0, 45 + #tab:GetChildren()*35)
	button.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(120, 0, 0)
	button.Text = (default and "✔️ " or "❌ ") .. labelText
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	Instance.new("UICorner", button)

	local toggled = default
	button.MouseButton1Click:Connect(function()
		toggled = not toggled
		button.Text = (toggled and "✔️ " or "❌ ") .. labelText
		button.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(120, 0, 0)
		if callback then callback(toggled) end
	end)
end

-- == Apply to Aimbot Tab ==
createToggle(contentFrames["Aimbot"], "Enable Aimbot", false, function(state)
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
			local pos, visible = Camera:WorldToViewportPoint(plr.Character.Head.Position)
			if visible then
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
			local head = target.Character.Head.Position
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, head)
		end
	end
end)

-- == ESP State ==
local ESPEnabled = false
local ESPObjects = {}

-- == ESP Toggle in Tab ==
createToggle(contentFrames["ESP"], "Enable ESP", false, function(state)
	ESPEnabled = state
end)

-- == Create Highlight per Player ==
local function createESP(plr)
	if ESPObjects[plr] or not plr.Character then return end
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Adornee = plr.Character
	highlight.Parent = plr.Character
	ESPObjects[plr] = highlight
end

-- == Remove ESP ==
local function removeESP(plr)
	if ESPObjects[plr] then
		ESPObjects[plr]:Destroy()
		ESPObjects[plr] = nil
	end
end

-- == Main ESP Render Loop ==
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
	if not ESPEnabled then
		for _, h in pairs(ESPObjects) do h:Destroy() end
		ESPObjects = {}
		return
	end

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Team ~= LP.Team then
			if plr.Character and not ESPObjects[plr] then
				createESP(plr)
			elseif not plr.Character and ESPObjects[plr] then
				removeESP(plr)
			end
		elseif ESPObjects[plr] then
			removeESP(plr)
		end
	end
end)

-- == KillAll State ==
local KillAll = false

-- == Toggle Button in Misc Tab ==
createToggle(contentFrames["Misc"], "Enable KillAll", false, function(state)
	KillAll = state
end)

-- == KillAll Logic ==
local function teleportTo(position)
	local char = LP.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	char:MoveTo(position + Vector3.new(0, 3, 0))
end

task.spawn(function()
	while task.wait(0.4) do
		if KillAll then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LP and plr.Team ~= LP.Team and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local targetPos = plr.Character.HumanoidRootPart.Position
					teleportTo(targetPos)
					break
				end
			end
		end
	end
end)

-- == AutoFire State ==
local AutoFire = false

-- == Auto Fire Toggle in Misc Tab ==
createToggle(contentFrames["Misc"], "Enable AutoFire", false, function(state)
	AutoFire = state
end)

-- == AutoFire Logic ==
RunService.RenderStepped:Connect(function()
	if AutoFire and LP.Character then
		local tool = LP.Character:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			tool:Activate()
		end
	end
end)

-- == Final Notification UI ==
local function finalNotify()
	local notif = Instance.new("TextLabel", gui)
	notif.Size = UDim2.new(0, 300, 0, 30)
	notif.Position = UDim2.new(0.5, -150, 1, -40)
	notif.BackgroundColor3 = Color3.fromRGB(35, 150, 60)
	notif.Text = "✅ YoxanXHub Arsenal Fully Loaded!"
	notif.TextColor3 = Color3.new(1, 1, 1)
	notif.Font = Enum.Font.GothamBold
	notif.TextSize = 14
	notif.BackgroundTransparency = 0
	notif.ZIndex = 5
	Instance.new("UICorner", notif)

	task.spawn(function()
		for i = 1, 50 do
			notif.TextTransparency = i / 50
			notif.BackgroundTransparency = i / 50
			task.wait(0.02)
		end
		notif:Destroy()
	end)
end

task.delay(1.5, finalNotify)
