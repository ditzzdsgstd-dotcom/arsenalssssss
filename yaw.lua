-- YoxanXHub Arsenal V1.5 – Part 1/10: Custom UI Base (NO OrionLib)
local Players, TweenService, CoreGui = game:GetService("Players"), game:GetService("TweenService"), game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Destroy previous UI
if CoreGui:FindFirstChild("YoxanXHub_UI") then
	CoreGui.YoxanXHub_UI:Destroy()
end

-- UI Container
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "YoxanXHub_UI"
ScreenGui.ResetOnSpawn = false

-- Main Frame
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 480, 0, 320)
Main.Position = UDim2.new(0.5, -240, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

-- Topbar
local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "YoxanXHub | Arsenal V1.5"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 14

-- Close Button
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.new(1,0.3,0.3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Sidebar
local SideBar = Instance.new("Frame", Main)
SideBar.Size = UDim2.new(0, 100, 1, -30)
SideBar.Position = UDim2.new(0, 0, 0, 30)
SideBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
SideBar.BorderSizePixel = 0
Instance.new("UICorner", SideBar)

-- Tab Buttons
local tabs = {"Aimbot", "ESP", "Misc"}
local contentFrames = {}

for i, tabName in pairs(tabs) do
	local btn = Instance.new("TextButton", SideBar)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, (i-1)*35 + 10)
	btn.Text = tabName
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn)

	-- Content frame
	local content = Instance.new("Frame", Main)
	content.Size = UDim2.new(1, -110, 1, -40)
	content.Position = UDim2.new(0, 110, 0, 35)
	content.BackgroundColor3 = Color3.fromRGB(35,35,35)
	content.Visible = (i == 1) -- default to first tab
	content.BorderSizePixel = 0
	Instance.new("UICorner", content)

	contentFrames[tabName] = content

	btn.MouseButton1Click:Connect(function()
		for _, frame in pairs(contentFrames) do
			frame.Visible = false
		end
		content.Visible = true
	end)
end

-- YoxanXHub Arsenal V1.5 – Part 2/10 (Aimbot)
local Players, RunService = game:GetService("Players"), game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local AimbotEnabled = true
local TeamCheck = true
local StickyLock = true
local HitPart = "Head" -- fallback to "HumanoidRootPart" if missing

local CurrentTarget = nil

-- Smart Get Closest Player
local function GetClosest()
	local closest, dist = nil, math.huge
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild(HitPart) then
			if TeamCheck and player.Team == LocalPlayer.Team then continue end
			local part = player.Character[HitPart]
			local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
			if not onScreen then continue end
			local magnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
			if magnitude < dist then
				closest = player
				dist = magnitude
			end
		end
	end
	return closest
end

-- Update lock
RunService.RenderStepped:Connect(function()
	if AimbotEnabled then
		local target = StickyLock and CurrentTarget or GetClosest()
		if target and target.Character and target.Character:FindFirstChild(HitPart) then
			local part = target.Character[HitPart]
			if part and part:IsA("BasePart") then
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
				CurrentTarget = target
			end
		else
			CurrentTarget = nil
		end
	end
end)

-- YoxanXHub Arsenal V1.5 – Part 3/10 (Auto Fire + Kill All)
local Players, RunService, ReplicatedStorage = game:GetService("Players"), game:GetService("RunService"), game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local AutoFireEnabled = true
local KillAllEnabled = false
local AntiOverkill = true

local CurrentGun = nil
local Target = nil

-- Tool detection
LocalPlayer.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child:FindFirstChild("GunScript") then
			CurrentGun = child
		end
	end)
end)

-- Auto Fire Logic
RunService.RenderStepped:Connect(function()
	if not AutoFireEnabled or not Target then return end
	if not CurrentGun then return end
	if not Target.Character or not Target.Character:FindFirstChild("Humanoid") then return end
	if Target.Character.Humanoid.Health <= 0 then return end

	local Head = Target.Character:FindFirstChild("Head")
	if not Head then return end

	local shootEvent = CurrentGun:FindFirstChild("ShootEvent") or CurrentGun:FindFirstChildWhichIsA("RemoteEvent", true)
	if shootEvent then
		shootEvent:FireServer({Position = Head.Position})
	end
end)

-- Kill All Logic
RunService.RenderStepped:Connect(function()
	if not KillAllEnabled then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			if player.Team ~= LocalPlayer.Team and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
				local head = player.Character.Head
				local gun = CurrentGun
				if gun and gun:FindFirstChildWhichIsA("RemoteEvent", true) then
					gun:FindFirstChildWhichIsA("RemoteEvent", true):FireServer({Position = head.Position})
					if AntiOverkill then
						wait(0.05)
					end
					-- Optional: teleport after kill
					if player.Character:FindFirstChild("HumanoidRootPart") then
						LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 15, 0)
					end
				end
			end
		end
	end
end)

-- YoxanXHub Arsenal V1.5 – Part 4/10 (ESP System)
local Players, RunService = game:GetService("Players"), game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = true
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "YoxanXHub_ESP"

local function WallCheck(part)
	if not part then return false end
	local origin = Camera.CFrame.Position
	local direction = (part.Position - origin).Unit * 500
	local result = workspace:Raycast(origin, direction, RaycastParams.new())
	return result and result.Instance and result.Instance:IsDescendantOf(part.Parent)
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
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
end

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
				if not WallCheck(head) then
					visible = false
				end
				tag.Enabled = visible
			end
		end
	end
end)

-- YoxanXHub Arsenal V1.5 – Part 5/10 (Misc System)
local Players, RunService = game:GetService("Players"), game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local WalkSpeedValue = 16
local TeleportEnabled = true
local AntiVoidEnabled = true

-- WalkSpeed controller
RunService.RenderStepped:Connect(function()
	if Humanoid and Humanoid.Parent and Humanoid.Health > 0 then
		Humanoid.WalkSpeed = WalkSpeedValue
	end
end)

-- Teleport to base
local function TeleportToBase()
	if Character and Character:FindFirstChild("HumanoidRootPart") then
		Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0) -- Ganti ke koordinat base map
	end
end

-- Anti-Void protection
RunService.Stepped:Connect(function()
	if not AntiVoidEnabled then return end
	if Character and Character:FindFirstChild("HumanoidRootPart") then
		if Character.HumanoidRootPart.Position.Y < -10 then
			TeleportToBase()
		end
	end
end)

-- Exit UI (destroy entire hub)
local function ExitHub()
	local gui = game.CoreGui:FindFirstChild("YoxanXHub_UI")
	if gui then gui:Destroy() end
	local esp = game.CoreGui:FindFirstChild("YoxanXHub_ESP")
	if esp then esp:Destroy() end
end

