local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Rayfield.lua"))()

local Window = Rayfield:CreateWindow({
	Name = "YoxanXHub | Arsenal V1.5",
	LoadingTitle = "YoxanXHub Arsenal",
	LoadingSubtitle = "by yoxanx",
	ConfigurationSaving = {
		Enabled = false
	},
        Discord = {
            Enabled = false,
        },
        KeySystem = false
})

-- Tabs
local Tab_Aimbot = Window:CreateTab("🎯 Aimbot", 4483362458)
local Tab_Combat = Window:CreateTab("⚔️ Combat", 4483363089)
local Tab_ESP = Window:CreateTab("👁️ ESP", 4483362660)
local Tab_Misc = Window:CreateTab("🛠️ Misc", 4483361986)

-- Sample Toggle (nanti kita aktifkan di 2/5)
Tab_Aimbot:CreateToggle({
	Name = "Enable Aimbot",
	CurrentValue = false,
	Flag = "AimbotEnabled",
	Callback = function(Value)
		-- diisi di 2/5
	end,
})

-- Sample Combat Toggle
Tab_Combat:CreateToggle({
	Name = "Auto Fire",
	CurrentValue = false,
	Flag = "AutoFire",
	Callback = function(Value)
		-- diisi di 3/5
	end,
})

-- Sample ESP Toggle
Tab_ESP:CreateToggle({
	Name = "ESP Enabled",
	CurrentValue = false,
	Flag = "ESPEnabled",
	Callback = function(Value)
		-- diisi di 4/5
	end,
})

-- Sample Misc Buttons
Tab_Misc:CreateButton({
	Name = "Teleport to Base",
	Callback = function()
		-- diisi di 5/5
	end,
})

Tab_Misc:CreateButton({
	Name = "Exit UI",
	Callback = function()
		game.CoreGui:FindFirstChild("Rayfield")?.:Destroy()
	end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local AimbotEnabled = false
local StickyLock = true
local TeamCheck = true
local TargetPart = "Head"
local MaxDistance = 999
local CurrentTarget = nil

-- Function Get Closest Enemy
local function GetClosest()
	local closest, dist = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(TargetPart) and player.Character:FindFirstChild("Humanoid") then
			if TeamCheck and player.Team == LocalPlayer.Team then continue end
			if player.Character.Humanoid.Health <= 0 then continue end

			local part = player.Character[TargetPart]
			local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
			if not onScreen then continue end

			local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
			local distToCam = (Camera.CFrame.Position - part.Position).Magnitude
			if mag < dist and distToCam <= MaxDistance then
				closest = player
				dist = mag
			end
		end
	end
	return closest
end

-- Aimbot Core Logic
RunService.RenderStepped:Connect(function()
	if not AimbotEnabled then return end
	local target = StickyLock and CurrentTarget or GetClosest()
	if target and target.Character and target.Character:FindFirstChild(TargetPart) then
		local part = target.Character[TargetPart]
		if part and part:IsA("BasePart") then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
			CurrentTarget = target
		end
	else
		CurrentTarget = nil
	end
end)

-- UI Connection (Rayfield Flag System)
task.spawn(function()
	while task.wait(0.2) do
		local Flag = getgenv().RayfieldFlags
		if Flag and Flag["AimbotEnabled"] ~= nil then
			AimbotEnabled = Flag["AimbotEnabled"]
		end
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local AutoFire = false
local KillAll = false
local TargetPart = "Head"
local Gun = nil

-- Gun Detection
LocalPlayer.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") and tool:FindFirstChildOfClass("RemoteEvent") then
			Gun = tool
		end
	end)
end)

-- Update Flags
task.spawn(function()
	while task.wait(0.2) do
		local Flag = getgenv().RayfieldFlags
		if Flag then
			AutoFire = Flag["AutoFire"] or false
			KillAll = Flag["KillAll"] or false
		end
	end
end)

-- Closest Enemy
local function GetClosest()
	local closest, dist = nil, math.huge
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(TargetPart) then
			if player.Team == LocalPlayer.Team then continue end
			local head = player.Character[TargetPart]
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
				if mag < dist then
					closest = player
					dist = mag
				end
			end
		end
	end
	return closest
end

-- AutoFire Logic
RunService.RenderStepped:Connect(function()
	if AutoFire and Gun then
		local target = GetClosest()
		if target and target.Character and target.Character:FindFirstChild(TargetPart) then
			local shoot = Gun:FindFirstChildWhichIsA("RemoteEvent", true)
			if shoot then
				shoot:FireServer({Position = target.Character[TargetPart].Position})
			end
		end
	end
end)

-- KillAll Logic
RunService.RenderStepped:Connect(function()
	if KillAll and Gun then
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(TargetPart) then
				if player.Team ~= LocalPlayer.Team then
					local shoot = Gun:FindFirstChildWhichIsA("RemoteEvent", true)
					if shoot then
						shoot:FireServer({Position = player.Character[TargetPart].Position})
						wait(0.03)
					end
				end
			end
		end
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "YoxanXHub_ESP"

local ESPEnabled = false

-- WallCheck
local function CanSee(part)
	if not part then return false end
	local origin = Camera.CFrame.Position
	local direction = (part.Position - origin).Unit * 500
	local ray = workspace:Raycast(origin, direction, RaycastParams.new())
	return ray and ray.Instance and ray.Instance:IsDescendantOf(part.Parent)
end

-- Create ESP Label
local function CreateESP(player)
	if ESPFolder:FindFirstChild(player.Name) then return end
	local esp = Instance.new("BillboardGui", ESPFolder)
	esp.Name = player.Name
	esp.Adornee = nil
	esp.Size = UDim2.new(0, 100, 0, 20)
	esp.StudsOffset = Vector3.new(0, 2, 0)
	esp.AlwaysOnTop = true

	local label = Instance.new("TextLabel", esp)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = player.Name
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
	if not ESPEnabled then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local tag = ESPFolder:FindFirstChild(player.Name)
			if not tag then
				CreateESP(player)
				tag = ESPFolder:FindFirstChild(player.Name)
			end
			if tag and head then
				tag.Adornee = head
				local label = tag:FindFirstChildOfClass("TextLabel")
				local visible = true
				if player.Team == LocalPlayer.Team then
					label.TextColor3 = Color3.fromRGB(0, 200, 255)
					visible = false
				else
					label.TextColor3 = Color3.fromRGB(255, 80, 80)
				end
				if not CanSee(head) then
					visible = false
				end
				tag.Enabled = visible
			end
		end
	end
end)

-- Sync with Rayfield Flag
task.spawn(function()
	while task.wait(0.2) do
		local Flag = getgenv().RayfieldFlags
		if Flag and Flag["ESPEnabled"] ~= nil then
			ESPEnabled = Flag["ESPEnabled"]
		end
	end
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local WalkSpeed = 16
local AntiVoid = true
local TPPosition = Vector3.new(0, 50, 0) -- ganti sesuai base

-- WalkSpeed toggle logic
RunService.RenderStepped:Connect(function()
	local human = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
	if human then
		human.WalkSpeed = WalkSpeed
	end
end)

-- AntiVoid Logic
RunService.Stepped:Connect(function()
	local root = Character:FindFirstChild("HumanoidRootPart")
	if root and root.Position.Y < -10 and AntiVoid then
		root.CFrame = CFrame.new(TPPosition)
	end
end)

-- Rayfield Button Hooks
task.spawn(function()
	local gui = game:GetService("CoreGui"):FindFirstChild("Rayfield")
	if gui then
		local flags = getgenv().RayfieldFlags
		while task.wait(0.3) do
			if flags then
				if flags["WalkSpeedFast"] then
					WalkSpeed = 30
				else
					WalkSpeed = 16
				end
			end
		end
	end
end)

-- Teleport to Base (Manual)
local function TeleportToBase()
	local root = Character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(TPPosition)
	end
end

-- Connect UI Buttons (Rayfield Manual Link)
local miscTab = game:GetService("CoreGui"):FindFirstChild("Rayfield")
if miscTab then
	local folder = getgenv().RayfieldFlags
	if folder then
		-- Button actions ditangani langsung di 1/5:
		-- "Teleport to Base" button calls TeleportToBase
		-- "Exit UI" button: game.CoreGui:FindFirstChild("Rayfield")?.:Destroy()
	end
end
