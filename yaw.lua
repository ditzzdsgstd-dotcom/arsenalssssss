local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

local Window = OrionLib:MakeWindow({
	Name = "YoxanXHub | Arsenal V1.6",
	HidePremium = false,
	SaveConfig = false,
	IntroText = "YoxanXHub V1.6 Loaded",
	ConfigFolder = "YoxanXHub"
})

-- 🎯 Aimbot Tab
local AimbotTab = Window:MakeTab({
	Name = "🎯 Aimbot",
	Icon = "rbxassetid://4483362458", -- fingerprint icon
	PremiumOnly = false
})

-- ⚔️ Combat Tab
local CombatTab = Window:MakeTab({
	Name = "⚔️ Combat",
	Icon = "rbxassetid://4483363089",
	PremiumOnly = false
})

-- 👁️ ESP Tab
local ESPTab = Window:MakeTab({
	Name = "👁️ ESP",
	Icon = "rbxassetid://4483362660",
	PremiumOnly = false
})

-- 🛠️ Misc Tab
local MiscTab = Window:MakeTab({
	Name = "🛠️ Misc",
	Icon = "rbxassetid://4483361986",
	PremiumOnly = false
})

-- 🎯 Aimbot Toggles
AimbotTab:AddToggle({
	Name = "Enable Aimbot",
	Default = true,
	Flag = "EnableAimbot"
})

AimbotTab:AddToggle({
	Name = "Sticky Lock",
	Default = true,
	Flag = "StickyLock"
})

-- ⚔️ Combat Toggles
CombatTab:AddToggle({
	Name = "Auto Fire",
	Default = true,
	Flag = "AutoFire"
})

CombatTab:AddToggle({
	Name = "Kill All (Invisible)",
	Default = false,
	Flag = "KillAll"
})

-- 👁️ ESP Toggle
ESPTab:AddToggle({
	Name = "ESP Enabled",
	Default = true,
	Flag = "ESP"
})

-- 🛠️ Misc Toggles
MiscTab:AddToggle({
	Name = "WalkSpeed Fast",
	Default = false,
	Flag = "FastWalk"
})

MiscTab:AddButton({
	Name = "Teleport to Base",
	Callback = function()
		local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = CFrame.new(0, 50, 0)
		end
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

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function GetClosestEnemy()
	local closest = nil
	local shortest = math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
				if dist < shortest then
					shortest = dist
					closest = player
				end
			end
		end
	end
	return closest
end

local CurrentTarget = nil

RunService.RenderStepped:Connect(function()
	local flags = getgenv().OrionFlags or {}
	local aimbotEnabled = flags["EnableAimbot"]
	local sticky = flags["StickyLock"]

	if not aimbotEnabled then
		CurrentTarget = nil
		return
	end

	if not sticky or not CurrentTarget or not CurrentTarget.Character or not CurrentTarget.Character:FindFirstChild("Head") then
		CurrentTarget = GetClosestEnemy()
	end

	if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
		local head = CurrentTarget.Character.Head
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function GetClosestEnemy()
	local closest, shortest = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
				if dist < shortest then
					shortest = dist
					closest = player
				end
			end
		end
	end
	return closest
end

local function GetGun()
	local char = LocalPlayer.Character
	if not char then return nil end
	for _, v in ipairs(char:GetChildren()) do
		if v:IsA("Tool") and v:FindFirstChildWhichIsA("RemoteEvent", true) then
			return v
		end
	end
	return nil
end

local function SetInvisible(state)
	local char = LocalPlayer.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = state and 1 or 0
			part.CanCollide = not state
		elseif part:IsA("Decal") then
			part.Transparency = state and 1 or 0
		end
	end
end

RunService.RenderStepped:Connect(function()
	local flags = getgenv().OrionFlags or {}
	local autoFire = flags["AutoFire"]
	local killAll = flags["KillAll"]
	local gun = GetGun()
	if not gun then return end

	local fireRemote = gun:FindFirstChildWhichIsA("RemoteEvent", true)
	if not fireRemote then return end

	-- Auto Fire Logic
	if autoFire then
		local target = GetClosestEnemy()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			fireRemote:FireServer({Position = target.Character.Head.Position})
		end
	end

	-- Kill All Logic
	if killAll then
		SetInvisible(true)
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
				fireRemote:FireServer({Position = player.Character.Head.Position})
				task.wait(0.05)
			end
		end
	else
		SetInvisible(false)
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "YoxanXHub_ESP"

local function CanSee(part)
	if not part then return false end
	local origin = Camera.CFrame.Position
	local direction = (part.Position - origin).Unit * 1000
	local ray = workspace:Raycast(origin, direction, RaycastParams.new())
	return ray and ray.Instance and ray.Instance:IsDescendantOf(part.Parent)
end

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

RunService.RenderStepped:Connect(function()
	if not getgenv().OrionFlags or not getgenv().OrionFlags["ESP"] then return end
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

local FastWalk = false
local AntiVoidEnabled = true
local BasePosition = Vector3.new(0, 50, 0)

-- Update Character Reference
LocalPlayer.CharacterAdded:Connect(function(char)
	Character = char
end)

-- WalkSpeed Logic
RunService.RenderStepped:Connect(function()
	if not Character then return end
	local human = Character:FindFirstChildOfClass("Humanoid")
	if human then
		human.WalkSpeed = FastWalk and 30 or 16
	end
end)

-- Anti Void Logic
RunService.Stepped:Connect(function()
	if not AntiVoidEnabled then return end
	local root = Character and Character:FindFirstChild("HumanoidRootPart")
	if root and root.Position.Y < -10 then
		root.CFrame = CFrame.new(BasePosition)
	end
end)

-- Orion Flag Check
task.spawn(function()
	while task.wait(0.2) do
		local flags = getgenv().OrionFlags or {}
		FastWalk = flags["FastWalk"] or false
	end
end)

OrionLib:Init()
