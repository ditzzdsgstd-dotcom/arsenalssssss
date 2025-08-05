-- YoxanXHub Arsenal V1.5 | 1/9 - UI Dasar + Intro Loading
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

pcall(function() if CoreGui:FindFirstChild("YoxanXHub") then CoreGui.YoxanXHub:Destroy() end end)

-- Intro Loading
local intro = Instance.new("ScreenGui", CoreGui)
intro.Name = "YoxanXHub"
intro.ResetOnSpawn = false

local frame = Instance.new("Frame", intro)
frame.Size = UDim2.new(0, 260, 0, 60)
frame.Position = UDim2.new(0.5, -130, 0.5, -30)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame)

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "🧠 YoxanXHub | Arsenal Loading..."
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 14

wait(2)
intro:Destroy()

-- UI Base
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "YoxanXHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 420, 0, 300)
main.Position = UDim2.new(0.5, -210, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 90, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar)

local tabList = {"Aimbot", "ESP", "Misc"}
local buttons = {}
local contentFrames = {}

for i, tabName in ipairs(tabList) do
	local btn = Instance.new("TextButton", sidebar)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, 10 + (i-1)*40)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Text = tabName
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn)
	buttons[tabName] = btn
	
	local content = Instance.new("ScrollingFrame", main)
	content.Size = UDim2.new(1, -100, 1, -20)
	content.Position = UDim2.new(0, 95, 0, 10)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.Visible = (i == 1)
	content.CanvasSize = UDim2.new(0, 0, 0, 500)
	content.ScrollBarThickness = 4
	contentFrames[tabName] = content
	
	btn.MouseButton1Click:Connect(function()
		for _, frame in pairs(contentFrames) do frame.Visible = false end
		for _, b in pairs(buttons) do b.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end
		content.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end)
end

-- == Aimbot System ==
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local AimbotEnabled = false

local function createToggle(parent, text, default, callback)
	local toggle = Instance.new("TextButton", parent)
	toggle.Size = UDim2.new(0, 180, 0, 30)
	toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggle.Font = Enum.Font.Gotham
	toggle.TextSize = 13
	toggle.Text = text .. ": " .. (default and "ON" or "OFF")
	toggle.BorderSizePixel = 0
	Instance.new("UICorner", toggle)
	
	local state = default
	toggle.MouseButton1Click:Connect(function()
		state = not state
		toggle.Text = text .. ": " .. (state and "ON" or "OFF")
		callback(state)
	end)
end

-- Aimbot toggle
createToggle(contentFrames["Aimbot"], "Enable Aimbot", false, function(state)
	AimbotEnabled = state
end)

-- Aimbot logic
RunService.RenderStepped:Connect(function()
	if not AimbotEnabled then return end
	
	local closest, shortest = nil, math.huge
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
			local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
				if dist < shortest then
					shortest = dist
					closest = plr
				end
			end
		end
	end
	
	if closest and closest.Character and closest.Character:FindFirstChild("Head") then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position)
	end
end)

-- == Kill All & Auto Fire ==
local KillAllEnabled = false
local AutoFireEnabled = false

-- Create toggles
createToggle(contentFrames["Misc"], "Enable Kill All", false, function(state)
	KillAllEnabled = state
	local char = LocalPlayer.Character
	if char then
		for _, p in ipairs(char:GetChildren()) do
			if p:IsA("BasePart") then
				p.LocalTransparencyModifier = state and 1 or 0 -- Invisible toggle
			end
		end
	end
end)

createToggle(contentFrames["Misc"], "Enable Auto Fire", false, function(state)
	AutoFireEnabled = state
end)

-- Kill All + Auto Fire Logic
RunService.RenderStepped:Connect(function()
	if not KillAllEnabled and not AutoFireEnabled then return end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
			local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
			if tool and AutoFireEnabled then
				tool:Activate()
			end
			if KillAllEnabled then
				LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.Head.CFrame * CFrame.new(0, 0, 1)
			end
		end
	end
end)

-- == ESP System ==
local ESPEnabled = false
local ESPFolder = Instance.new("Folder", CoreGui)
ESPFolder.Name = "YoxanXHub_ESP"

createToggle(contentFrames["ESP"], "Enable ESP", false, function(state)
	ESPEnabled = state
	if not state then
		for _, v in pairs(ESPFolder:GetChildren()) do
			v:Destroy()
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not ESPEnabled then return end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			if not ESPFolder:FindFirstChild(plr.Name) then
				local hl = Instance.new("Highlight", ESPFolder)
				hl.Name = plr.Name
				hl.Adornee = plr.Character
				hl.FillTransparency = 0.5
				hl.OutlineTransparency = 0.1
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				if plr.Team == LocalPlayer.Team then
					hl.FillColor = Color3.fromRGB(0, 150, 255) -- Biru
				else
					hl.FillColor = Color3.fromRGB(255, 0, 0) -- Merah
				end
			else
				-- Update adornee if character respawn
				local current = ESPFolder:FindFirstChild(plr.Name)
				if current and current:IsA("Highlight") then
					current.Adornee = plr.Character
				end
			end
		end
	end
	-- Hapus ESP yang sudah tidak valid
	for _, esp in pairs(ESPFolder:GetChildren()) do
		if not Players:FindFirstChild(esp.Name) then
			esp:Destroy()
		end
	end
end)

-- == WalkSpeed Slider ==
local WalkSpeed = 16

local function createSlider(parent, labelText, min, max, default, callback)
	local slider = Instance.new("TextButton", parent)
	slider.Size = UDim2.new(0, 180, 0, 30)
	slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	slider.TextColor3 = Color3.fromRGB(255, 255, 255)
	slider.Font = Enum.Font.Gotham
	slider.TextSize = 13
	slider.BorderSizePixel = 0
	local val = default
	slider.Text = labelText .. ": " .. tostring(val)
	Instance.new("UICorner", slider)
	slider.MouseButton1Click:Connect(function()
		val = val + 2
		if val > max then val = min end
		slider.Text = labelText .. ": " .. tostring(val)
		callback(val)
	end)
end

createSlider(contentFrames["Misc"], "WalkSpeed", 16, 50, 16, function(value)
	WalkSpeed = value
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.WalkSpeed = value
	end
end)

-- == Teleport ke Base Button ==
local teleportButton = Instance.new("TextButton", contentFrames["Misc"])
teleportButton.Size = UDim2.new(0, 180, 0, 30)
teleportButton.Position = UDim2.new(0, 0, 0, 120)
teleportButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
teleportButton.Text = "📍 Teleport to Base"
teleportButton.TextColor3 = Color3.new(1,1,1)
teleportButton.Font = Enum.Font.Gotham
teleportButton.TextSize = 13
teleportButton.BorderSizePixel = 0
Instance.new("UICorner", teleportButton)

teleportButton.MouseButton1Click:Connect(function()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root and workspace:FindFirstChild("SpawnLocation") then
		root.CFrame = workspace.SpawnLocation.CFrame + Vector3.new(0, 5, 0)
	end
end)

-- == Anti-Void Safety ==
RunService.Stepped:Connect(function()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root and root.Position.Y < -20 then
		if workspace:FindFirstChild("SpawnLocation") then
			root.CFrame = workspace.SpawnLocation.CFrame + Vector3.new(0, 5, 0)
		else
			root.CFrame = CFrame.new(0, 20, 0)
		end
	end
end)

-- == FPS & Target Info Overlay ==
local overlay = Instance.new("TextLabel", gui)
overlay.Size = UDim2.new(0, 300, 0, 20)
overlay.Position = UDim2.new(1, -310, 0, 10)
overlay.BackgroundTransparency = 1
overlay.TextColor3 = Color3.fromRGB(255, 255, 255)
overlay.Font = Enum.Font.Gotham
overlay.TextSize = 13
overlay.TextXAlignment = Enum.TextXAlignment.Right
overlay.Text = "FPS: ... | Target: None"
overlay.ZIndex = 10

-- FPS Tracker
local fps = 0
local counter = 0
local last = tick()

-- Aimbot Target Debug Tracker
RunService.RenderStepped:Connect(function()
	-- FPS
	counter += 1
	if tick() - last >= 1 then
		fps = counter
		counter = 0
		last = tick()
	end
	
	local targetName = "None"
	if AimbotEnabled then
		local closest, shortest = nil, math.huge
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
				local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
					if dist < shortest then
						shortest = dist
						closest = plr
					end
				end
			end
		end
		if closest then
			local health = math.floor(closest.Character.Humanoid.Health)
			local distance = math.floor((Camera.CFrame.Position - closest.Character.Head.Position).Magnitude)
			targetName = closest.Name .. " | HP: " .. health .. " | " .. distance .. " studs"
		end
	end
	overlay.Text = "FPS: " .. tostring(fps) .. " | Target: " .. targetName
end)

-- == Silent Mode + WallCheck + Wallbang ==
local SilentMode = false
local WallCheck = false
local Wallbang = false

createToggle(contentFrames["Aimbot"], "Silent Mode", false, function(state)
	SilentMode = state
end)

createToggle(contentFrames["Aimbot"], "Wall Check", true, function(state)
	WallCheck = state
end)

createToggle(contentFrames["Aimbot"], "Wallbang", false, function(state)
	Wallbang = state
end)

-- Override Aimbot logic (improve with WallCheck + Wallbang)
RunService.RenderStepped:Connect(function()
	if not AimbotEnabled then return end
	local closest, shortest = nil, math.huge
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
			local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
				if dist < shortest then
					if WallCheck then
						local ray = workspace:Raycast(Camera.CFrame.Position, (plr.Character.Head.Position - Camera.CFrame.Position).Unit * 500, RaycastParams.new())
						if ray and ray.Instance and not plr.Character:IsAncestorOf(ray.Instance) and not Wallbang then
							continue -- blocked & wallbang off
						end
					end
					shortest = dist
					closest = plr
				end
			end
		end
	end

	-- Set camera & mute audio
	if closest and closest.Character and closest.Character:FindFirstChild("Head") then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position)
		if SilentMode then
			local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
			if tool and tool:FindFirstChild("Handle") then
				for _, s in pairs(tool.Handle:GetChildren()) do
					if s:IsA("Sound") then
						s.Volume = 0
					end
				end
			end
		end
	end
end)

-- == Sticky Lock-On ==
local StickyLock = false
local CurrentTarget = nil

createToggle(contentFrames["Aimbot"], "Sticky Lock", false, function(state)
	StickyLock = state
	if not state then
		CurrentTarget = nil
	end
end)

RunService.RenderStepped:Connect(function()
	if not AimbotEnabled then return end
	
	local function isValidTarget(plr)
		if plr == LocalPlayer then return false end
		if plr.Team == LocalPlayer.Team then return false end
		if not plr.Character then return false end
		local hum = plr.Character:FindFirstChild("Humanoid")
		local head = plr.Character:FindFirstChild("Head")
		if not hum or not head then return false end
		if hum.Health <= 0 then return false end
		return true
	end
	
	local function getClosestTarget()
		local closest, shortest = nil, math.huge
		for _, plr in pairs(Players:GetPlayers()) do
			if isValidTarget(plr) then
				local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
					if dist < shortest then
						-- Bypass frozen: still shootable
						shortest = dist
						closest = plr
					end
				end
			end
		end
		return closest
	end
	
	if StickyLock and CurrentTarget and isValidTarget(CurrentTarget) then
		-- keep locked
	elseif StickyLock then
		CurrentTarget = getClosestTarget()
	else
		CurrentTarget = getClosestTarget()
	end
	
	if CurrentTarget and CurrentTarget.Character:FindFirstChild("Head") then
		local head = CurrentTarget.Character.Head
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
	end
end)

-- == Final Cleanup Buttons ==
local function createButton(parent, text, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0, 180, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.Text = text
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn)
	btn.MouseButton1Click:Connect(callback)
end

createButton(contentFrames["Misc"], "🧼 Clear ESP", function()
	for _, v in pairs(CoreGui:GetChildren()) do
		if v.Name == "YoxanXHub_ESP" then
			v:Destroy()
		end
	end
end)

createButton(contentFrames["Misc"], "🧹 Reset Toggles", function()
	AimbotEnabled = false
	AutoFireEnabled = false
	KillAllEnabled = false
	SilentMode = false
	StickyLock = false
	ESPEnabled = false
	WallCheck = true
	Wallbang = false
	WalkSpeed = 16
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeed
	end
end)

createButton(contentFrames["Misc"], "🚪 Exit UI", function()
	if CoreGui:FindFirstChild("YoxanXHub") then
		CoreGui.YoxanXHub:Destroy()
	end
	if CoreGui:FindFirstChild("YoxanXLoading") then
		CoreGui.YoxanXLoading:Destroy()
	end
end)

-- Ready!
print("✅ YoxanXHub Arsenal V1.5 UI Loaded ")
