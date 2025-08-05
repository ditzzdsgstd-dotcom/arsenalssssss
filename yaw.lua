-- YoxanXHub | Arsenal V1.5 UI - 1/10 (UI Dasar Style Rayfield/Delta)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
pcall(function() CoreGui:FindFirstChild("YoxanXHubUI"):Destroy() end)
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "YoxanXHubUI"
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false

-- Frame Utama
local main = Instance.new("Frame", gui)
main.Name = "MainFrame"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, 480, 0, 320)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.BackgroundTransparency = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- Sidebar kiri
local sidebar = Instance.new("Frame", main)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 100, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar)

-- Title Text
local title = Instance.new("TextLabel", sidebar)
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "YoxanXHub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Placeholder Tab Buttons
for i, name in ipairs({"Aimbot", "ESP", "Misc"}) do
	local tab = Instance.new("TextButton", sidebar)
	tab.Size = UDim2.new(1, -10, 0, 30)
	tab.Position = UDim2.new(0, 5, 0, 50 + (i - 1) * 35)
	tab.Text = name
	tab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	tab.TextColor3 = Color3.fromRGB(255, 255, 255)
	tab.Font = Enum.Font.Gotham
	tab.TextSize = 14
	tab.BorderSizePixel = 0
	Instance.new("UICorner", tab)
end

-- Konten Area
local content = Instance.new("Frame", main)
content.Name = "ContentArea"
content.Position = UDim2.new(0, 100, 0, 0)
content.Size = UDim2.new(1, -100, 1, 0)
content.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
content.BorderSizePixel = 0
Instance.new("UICorner", content)

-- == Buat Konten Frame untuk Tiap Tab ==
local tabNames = {"Aimbot", "ESP", "Misc"}
local tabIcons = {"🔫", "👁️", "⚙️"}
local contentFrames = {}

for i, name in ipairs(tabNames) do
	local frame = Instance.new("Frame", content)
	frame.Name = name .. "Frame"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = (i == 1) -- hanya tab pertama yg aktif awal
	contentFrames[name] = frame
end

-- == Tambah logika pada sidebar button ==
local sidebarButtons = {}
for i, btn in ipairs(sidebar:GetChildren()) do
	if btn:IsA("TextButton") then
		local tabName = btn.Text
		local icon = tabIcons[i] or ""
		btn.Text = icon .. " " .. tabName
		sidebarButtons[tabName] = btn

		btn.MouseButton1Click:Connect(function()
			-- Hide all tabs
			for _, frame in pairs(contentFrames) do
				frame.Visible = false
			end
			-- Show selected
			if contentFrames[tabName] then
				contentFrames[tabName].Visible = true
			end
		end)
	end
end

-- == Library ==
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- == Aimbot State ==
local AimbotEnabled = false

-- == Toggle Aimbot UI ==
local function createToggle(parent, text, default, callback)
	local toggle = Instance.new("TextButton", parent)
	toggle.Size = UDim2.new(0, 140, 0, 30)
	toggle.Position = UDim2.new(0, 10, 0, 10 + (#parent:GetChildren()-1)*35)
	toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggle.Font = Enum.Font.Gotham
	toggle.TextSize = 14
	toggle.Text = "[OFF] " .. text
	toggle.BorderSizePixel = 0
	Instance.new("UICorner", toggle)

	local state = default
	toggle.MouseButton1Click:Connect(function()
		state = not state
		toggle.Text = (state and "[ON] " or "[OFF] ") .. text
		callback(state)
	end)
end

-- == Toggle on UI ==
createToggle(contentFrames["Aimbot"], "Enable Aimbot", false, function(state)
	AimbotEnabled = state
end)

-- == Aimbot Function ==
RunService.RenderStepped:Connect(function()
	if not AimbotEnabled then return end

	local closest, distance = nil, math.huge
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
			local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
				if dist < distance then
					distance = dist
					closest = plr
				end
			end
		end
	end

	if closest and closest.Character and closest.Character:FindFirstChild("Head") then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position)
	end
end)

-- == KillAll Logic ==
local KillAll = false

createToggle(contentFrames["Misc"], "Enable KillAll", false, function(state)
	KillAll = state
	local char = LocalPlayer.Character
	if char then
		for _, part in pairs(char:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.Transparency = state and 1 or 0
				if part:FindFirstChildOfClass("Decal") then
					for _, d in pairs(part:GetChildren()) do
						if d:IsA("Decal") then
							d.Transparency = state and 1 or 0
						end
					end
				end
			end
		end
	end
end)

-- == Teleport ke musuh aktif ==
task.spawn(function()
	while task.wait(0.5) do
		if KillAll and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			for _, enemy in pairs(Players:GetPlayers()) do
				if enemy ~= LocalPlayer and enemy.Team ~= LocalPlayer.Team and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
					if enemy.Character:FindFirstChild("Humanoid") and enemy.Character.Humanoid.Health > 0 then
						LocalPlayer.Character:MoveTo(enemy.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
						break
					end
				end
			end
		end
	end
end)

-- == AutoFire Logic ==
local AutoFire = false
local VirtualInput = game:GetService("VirtualInputManager")
local UserInput = game:GetService("UserInputService")

createToggle(contentFrames["Misc"], "Enable AutoFire", false, function(state)
	AutoFire = state
end)

RunService.RenderStepped:Connect(function()
	if AutoFire and LocalPlayer.Character then
		local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			VirtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
			VirtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
		end
	end
end)

-- == Notifikasi UI Loaded ==
local function showNotify(text)
	local notif = Instance.new("TextLabel", gui)
	notif.Size = UDim2.new(0, 280, 0, 32)
	notif.Position = UDim2.new(0.5, -140, 1, -40)
	notif.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
	notif.Text = "✅ " .. text
	notif.TextColor3 = Color3.new(1, 1, 1)
	notif.Font = Enum.Font.GothamBold
	notif.TextSize = 14
	notif.BackgroundTransparency = 0
	notif.ZIndex = 999
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

task.delay(1.2, function()
	showNotify("YoxanXHub Arsenal Loaded!")
end)

-- == ESP Logic ==
local ESPEnabled = false
local HighlightFolder = Instance.new("Folder", CoreGui)
HighlightFolder.Name = "YoxanXESP"

createToggle(contentFrames["ESP"], "Enable ESP", false, function(state)
	ESPEnabled = state
	if not state then
		for _, v in pairs(HighlightFolder:GetChildren()) do
			v:Destroy()
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not ESPEnabled then return end

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local already = HighlightFolder:FindFirstChild(plr.Name)
			if not already then
				local hl = Instance.new("Highlight")
				hl.Name = plr.Name
				hl.Adornee = plr.Character
				hl.FillColor = Color3.fromRGB(255, 0, 0)
				hl.OutlineColor = Color3.fromRGB(0, 0, 0)
				hl.FillTransparency = 0.5
				hl.OutlineTransparency = 0.1
				hl.Parent = HighlightFolder
			end
		end
	end

	-- Clean up dead/invalid
	for _, v in pairs(HighlightFolder:GetChildren()) do
		if not Players:FindFirstChild(v.Name) or not Players[v.Name].Character or Players[v.Name].Team == LocalPlayer.Team then
			v:Destroy()
		end
	end
end)

-- == WalkSpeed & JumpPower ==
local SpeedBoost = false
local JumpPower = 50

createToggle(contentFrames["Misc"], "Enable Speed Boost", false, function(state)
	SpeedBoost = state
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.WalkSpeed = state and 40 or 16
	end
end)

-- Auto apply speed if respawned
LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid")
	if SpeedBoost then
		char.Humanoid.WalkSpeed = 40
	end
	char.Humanoid.JumpPower = JumpPower
end)

-- == Auto Respawn ==
local AutoRespawn = false

createToggle(contentFrames["Misc"], "Enable Auto Respawn", false, function(state)
	AutoRespawn = state
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	if AutoRespawn then
		task.wait(1)
		game:GetService("ReplicatedStorage").Events:FindFirstChild("SpawnMe"):FireServer()
	end
end)

-- == Teleport to Base ==
local teleportButton = Instance.new("TextButton", contentFrames["Misc"])
teleportButton.Size = UDim2.new(0, 140, 0, 30)
teleportButton.Position = UDim2.new(0, 10, 0, 130)
teleportButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.Font = Enum.Font.Gotham
teleportButton.TextSize = 14
teleportButton.Text = "📍 Teleport to Base"
teleportButton.BorderSizePixel = 0
Instance.new("UICorner", teleportButton)

teleportButton.MouseButton1Click:Connect(function()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character:MoveTo(Vector3.new(0, 10, 0)) -- Ganti pos sesuai kebutuhan
	end
end)

-- == FPS Tracker ==
local fpsLabel = Instance.new("TextLabel", gui)
fpsLabel.Size = UDim2.new(0, 100, 0, 20)
fpsLabel.Position = UDim2.new(0, 10, 0, 10)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextSize = 14
fpsLabel.Text = "FPS: ..."
fpsLabel.ZIndex = 9999

local frameCount, lastTick = 0, tick()
RunService.RenderStepped:Connect(function()
	frameCount += 1
	local now = tick()
	if now - lastTick >= 1 then
		fpsLabel.Text = "FPS: " .. frameCount
		frameCount = 0
		lastTick = now
	end
end)

-- == Target Lock Info ==
local lockInfo = Instance.new("TextLabel", gui)
lockInfo.Size = UDim2.new(0, 200, 0, 20)
lockInfo.Position = UDim2.new(0, 10, 0, 30)
lockInfo.BackgroundTransparency = 1
lockInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
lockInfo.Font = Enum.Font.GothamSemibold
lockInfo.TextSize = 14
lockInfo.Text = "Target: None"
lockInfo.ZIndex = 9999

-- Update dari aimbot
RunService.RenderStepped:Connect(function()
	if not AimbotEnabled then
		lockInfo.Text = "Target: None"
		return
	end

	local closest, distance = nil, math.huge
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
			local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
				if dist < distance then
					distance = dist
					closest = plr
				end
			end
		end
	end

	if closest then
		lockInfo.Text = "Target: " .. closest.Name
	else
		lockInfo.Text = "Target: None"
	end
end)

-- == Optional Blur saat UI aktif ==
local Lighting = game:GetService("Lighting")
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0

-- == Floating Open Button ==
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 100, 0, 35)
openBtn.Position = UDim2.new(0, 10, 1, -50)
openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Text = "📂 Open Hub"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.Visible = false
openBtn.ZIndex = 10000
Instance.new("UICorner", openBtn)

-- == Toggle Hide/Show UI ==
local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(0, 30, 0, 30)
toggleBtn.Position = UDim2.new(1, -35, 0, 5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggleBtn.Text = "-"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.TextSize = 16
Instance.new("UICorner", toggleBtn)

toggleBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	openBtn.Visible = true
	blur.Size = 0
end)

openBtn.MouseButton1Click:Connect(function()
	main.Visible = true
	openBtn.Visible = false
	blur.Size = 8
end)

-- Aktifkan blur saat UI terbuka
task.delay(0.5, function()
	blur.Size = 8
end)
