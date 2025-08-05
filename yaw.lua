local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

local Window = OrionLib:MakeWindow({
	Name = "YoxanXHub | Arsenal V1.5",
	HidePremium = false,
	SaveConfig = false,
	IntroText = "YoxanXHub Arsenal",
	ConfigFolder = "YoxanXHub"
})

-- 🎯 Aimbot Tab
local AimbotTab = Window:MakeTab({
	Name = "🎯 Aimbot",
	Icon = "rbxassetid://4483362458", -- sidik jari style
	PremiumOnly = false
})

-- ⚔️ Combat Tab
local CombatTab = Window:MakeTab({
	Name = "⚔️ Combat",
	Icon = "rbxassetid://4483363089", -- fingerprint-like
	PremiumOnly = false
})

-- 👁️ ESP Tab
local ESPTab = Window:MakeTab({
	Name = "👁️ ESP",
	Icon = "rbxassetid://4483362660", -- eye
	PremiumOnly = false
})

-- 🛠️ Misc Tab
local MiscTab = Window:MakeTab({
	Name = "🛠️ Misc",
	Icon = "rbxassetid://4483361986", -- gear
	PremiumOnly = false
})

-- 🎯 Aimbot Toggle
AimbotTab:AddToggle({
	Name = "Enable Aimbot",
	Default = false,
	Callback = function(Value)
		getgenv().AimbotEnabled = Value
	end    
})

-- ⚔️ Combat Toggles
CombatTab:AddToggle({
	Name = "Auto Fire",
	Default = false,
	Callback = function(Value)
		getgenv().AutoFire = Value
	end    
})

CombatTab:AddToggle({
	Name = "Kill All",
	Default = false,
	Callback = function(Value)
		getgenv().KillAll = Value
	end    
})

-- 👁️ ESP Toggle
ESPTab:AddToggle({
	Name = "ESP Enabled",
	Default = false,
	Callback = function(Value)
		getgenv().ESPEnabled = Value
	end    
})

-- 🛠️ Misc Buttons
MiscTab:AddButton({
	Name = "Teleport to Base",
	Callback = function()
		local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then root.CFrame = CFrame.new(0, 50, 0) end -- bisa diganti lokasi
	end    
})

MiscTab:AddButton({
	Name = "Exit UI",
	Callback = function()
		if game.CoreGui:FindFirstChild("Orion") then
			game.CoreGui.Orion:Destroy()
		end
	end    
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Setting
local AimbotEnabled = false
local StickyLock = true
local TargetPart = "Head"
local CurrentTarget = nil
local MaxDistance = 999

-- Dapatkan musuh terdekat
local function GetClosest()
	local closest, shortest = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(TargetPart) then
			if player.Team == LocalPlayer.Team then continue end
			local part = player.Character[TargetPart]
			local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
				if dist < shortest and (Camera.CFrame.Position - part.Position).Magnitude <= MaxDistance then
					closest = player
					shortest = dist
				end
			end
		end
	end
	return closest
end

-- Aimbot logic
RunService.RenderStepped:Connect(function()
	AimbotEnabled = getgenv().AimbotEnabled
	if not AimbotEnabled then CurrentTarget = nil return end

	local target = StickyLock and CurrentTarget or GetClosest()
	if target and target.Character and target.Character:FindFirstChild(TargetPart) then
		local part = target.Character[TargetPart]
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
		CurrentTarget = target
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local TargetPart = "Head"
local Gun = nil

-- Auto Gun detection
LocalPlayer.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") and tool:FindFirstChildOfClass("RemoteEvent") then
			Gun = tool
		end
	end)
end)

-- Get closest enemy
local function GetClosest()
	local closest, dist = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild(TargetPart) then
			local part = player.Character[TargetPart]
			local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
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

-- Auto Fire Logic
RunService.RenderStepped:Connect(function()
	if not getgenv().AutoFire or not Gun then return end
	local target = GetClosest()
	if target and target.Character and target.Character:FindFirstChild(TargetPart) then
		local fire = Gun:FindFirstChildWhichIsA("RemoteEvent", true)
		if fire then
			fire:FireServer({Position = target.Character[TargetPart].Position})
		end
	end
end)

-- Kill All Logic
RunService.RenderStepped:Connect(function()
	if not getgenv().KillAll or not Gun then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild(TargetPart) then
			local fire = Gun:FindFirstChildWhichIsA("RemoteEvent", true)
			if fire then
				fire:FireServer({Position = player.Character[TargetPart].Position})
				wait(0.05)
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

-- WallCheck
local function CanSee(part)
	if not part then return false end
	local origin = Camera.CFrame.Position
	local direction = (part.Position - origin).Unit * 500
	local ray = workspace:Raycast(origin, direction, RaycastParams.new())
	return ray and ray.Instance and ray.Instance:IsDescendantOf(part.Parent)
end

-- Create ESP
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
	label.TextColor3 = Color3.new(1, 1, 1)
end

-- Update Loop
RunService.RenderStepped:Connect(function()
	if not getgenv().ESPEnabled then return end
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

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local WalkSpeed = 16
local FastWalk = false
local AntiVoidEnabled = true
local BasePosition = Vector3.new(0, 50, 0)

-- Auto Character Update
LocalPlayer.CharacterAdded:Connect(function(char)
	Character = char
end)

-- WalkSpeed logic
RunService.RenderStepped:Connect(function()
	local human = Character and Character:FindFirstChild("Humanoid")
	if human then
		human.WalkSpeed = FastWalk and 30 or 16
	end
end)

-- AntiVoid logic
RunService.Stepped:Connect(function()
	if not AntiVoidEnabled then return end
	local root = Character and Character:FindFirstChild("HumanoidRootPart")
	if root and root.Position.Y < -10 then
		root.CFrame = CFrame.new(BasePosition)
	end
end)

-- Sync Flags from OrionLib
task.spawn(function()
	while task.wait(0.2) do
		local flags = getgenv().OrionFlags or {}
		FastWalk = flags["WalkSpeedFast"] or false
	end
end)

OrionLib:Init()
