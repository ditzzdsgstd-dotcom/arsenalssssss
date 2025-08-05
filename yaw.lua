-- YoxanXHub Arsenal V1.5 – 1/5 (Custom UI + Tabs + Toggles + Intro)
local CoreGui, Players, TweenService = game:GetService("CoreGui"), game:GetService("Players"), game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("YoxanXHub_UI") then CoreGui.YoxanXHub_UI:Destroy() end
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "YoxanXHub_UI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 480, 0, 300)
main.Position = UDim2.new(0.5, -240, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Visible = false
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local topbar = Instance.new("TextLabel", main)
topbar.Size = UDim2.new(1, 0, 0, 30)
topbar.Text = "🔹 YoxanXHub | Arsenal V1.5"
topbar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topbar.TextColor3 = Color3.new(1, 1, 1)
topbar.Font = Enum.Font.GothamBold
topbar.TextSize = 14
topbar.BorderSizePixel = 0

local closeBtn = Instance.new("TextButton", topbar)
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.new(1, 0.3, 0.3)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instance.new("UICorner", closeBtn)

closeBtn.MouseButton1Click:Connect(function()
	gui.Enabled = false
end)

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 100, 1, -30)
sidebar.Position = UDim2.new(0, 0, 0, 30)
sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", sidebar)

local contentFrames = {}
local tabs = {"Aimbot", "ESP", "Misc"}

for i, name in ipairs(tabs) do
	local btn = Instance.new("TextButton", sidebar)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, (i - 1) * 35 + 10)
	btn.Text = name
	btn.Font = Enum.Font.Gotham
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
	Instance.new("UICorner", btn)

	local content = Instance.new("Frame", main)
	content.Size = UDim2.new(1, -110, 1, -40)
	content.Position = UDim2.new(0, 110, 0, 35)
	content.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	content.Visible = (i == 1)
	Instance.new("UICorner", content)
	contentFrames[name] = content

	btn.MouseButton1Click:Connect(function()
		for _, frame in pairs(contentFrames) do frame.Visible = false end
		content.Visible = true
	end)

	-- Add dummy toggle button for each tab
	local toggle = Instance.new("TextButton", content)
	toggle.Size = UDim2.new(0, 150, 0, 30)
	toggle.Position = UDim2.new(0, 20, 0, 20)
	toggle.Text = "Toggle " .. name
	toggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
	toggle.Font = Enum.Font.Gotham
	toggle.TextColor3 = Color3.fromRGB(255,255,255)
	Instance.new("UICorner", toggle)
end

-- Reopen Button (floating)
local reopen = Instance.new("TextButton", gui)
reopen.Size = UDim2.new(0, 80, 0, 30)
reopen.Position = UDim2.new(0, 10, 1, -40)
reopen.Text = "Open Hub"
reopen.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
reopen.TextColor3 = Color3.new(1,1,1)
reopen.Font = Enum.Font.GothamBold
Instance.new("UICorner", reopen)

reopen.MouseButton1Click:Connect(function()
	gui.Enabled = true
end)

-- Intro animation
local intro = Instance.new("TextLabel", gui)
intro.Size = UDim2.new(0, 300, 0, 50)
intro.Position = UDim2.new(0.5, -150, 0.5, -25)
intro.Text = "🚀 Loading YoxanXHub Arsenal V1.5..."
intro.BackgroundTransparency = 1
intro.TextColor3 = Color3.new(1, 1, 1)
intro.Font = Enum.Font.GothamBold
intro.TextSize = 18

task.wait(2.5)
intro:Destroy()
main.Visible = true

-- YoxanXHub Arsenal V1.5 – 2/5 (Aimbot Logic + UI Toggle Integration)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- === Aimbot Settings ===
local AimbotEnabled = false
local StickyLock = true
local TeamCheck = true
local TargetPart = "Head"
local MaxDistance = 999

local CurrentTarget = nil

-- === Get Closest Target ===
local function GetClosest()
	local closest, dist = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild(TargetPart) then
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

-- === Aimbot Core ===
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

-- === UI Toggle Integration ===
local gui = game:GetService("CoreGui"):FindFirstChild("YoxanXHub_UI")
if gui then
	local main = gui:FindFirstChildOfClass("Frame")
	if main then
		local aimbotFrame = nil
		for _, v in pairs(main:GetDescendants()) do
			if v:IsA("TextButton") and v.Text:lower():find("aimbot") then
				aimbotFrame = v
				break
			end
		end
		if aimbotFrame then
			aimbotFrame.MouseButton1Click:Connect(function()
				AimbotEnabled = not AimbotEnabled
				aimbotFrame.Text = AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
			end)
		end
	end
end

-- YoxanXHub Arsenal V1.5 – 3/5 (Auto Fire + Kill All + UI Toggle)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AutoFire = false
local KillAll = false
local Target = nil
local Gun = nil

-- === Auto-detect Weapon ===
LocalPlayer.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") and tool:FindFirstChildOfClass("RemoteEvent") then
			Gun = tool
		end
	end)
end)

-- === Auto Fire Logic ===
RunService.RenderStepped:Connect(function()
	if not AutoFire or not Target or not Gun then return end
	if Target.Character and Target.Character:FindFirstChild("Head") then
		local head = Target.Character.Head
		local shoot = Gun:FindFirstChildWhichIsA("RemoteEvent", true)
		if shoot then
			shoot:FireServer({Position = head.Position})
		end
	end
end)

-- === Kill All Logic ===
RunService.RenderStepped:Connect(function()
	if not KillAll or not Gun then return end
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			if player.Team ~= LocalPlayer.Team and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
				local shoot = Gun:FindFirstChildWhichIsA("RemoteEvent", true)
				if shoot then
					shoot:FireServer({Position = player.Character.Head.Position})
					wait(0.03)
				end
			end
		end
	end
end)

-- === UI Integration ===
local gui = game:GetService("CoreGui"):FindFirstChild("YoxanXHub_UI")
if gui then
	local main = gui:FindFirstChildOfClass("Frame")
	if main then
		for _, btn in pairs(main:GetDescendants()) do
			if btn:IsA("TextButton") then
				if btn.Text:lower():find("autofire") then
					btn.MouseButton1Click:Connect(function()
						AutoFire = not AutoFire
						btn.Text = AutoFire and "AutoFire: ON" or "AutoFire: OFF"
					end)
				elseif btn.Text:lower():find("killall") then
					btn.MouseButton1Click:Connect(function()
						KillAll = not KillAll
						btn.Text = KillAll and "KillAll: ON" or "KillAll: OFF"
					end)
				end
			end
		end
	end
end

-- YoxanXHub Arsenal V1.5 – 4/5 (ESP + Team Check + UI Integration)
local Players, RunService = game:GetService("Players"), game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = true
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "YoxanXHub_ESP"

-- WallCheck Function
local function CanSee(part)
	if not part then return false end
	local origin = Camera.CFrame.Position
	local direction = (part.Position - origin).Unit * 500
	local ray = workspace:Raycast(origin, direction, RaycastParams.new())
	return ray and ray.Instance and ray.Instance:IsDescendantOf(part.Parent)
end

-- Create ESP for Player
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

-- ESP Update
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

-- UI Integration
local gui = game:GetService("CoreGui"):FindFirstChild("YoxanXHub_UI")
if gui then
	local main = gui:FindFirstChildOfClass("Frame")
	if main then
		for _, btn in pairs(main:GetDescendants()) do
			if btn:IsA("TextButton") and btn.Text:lower():find("esp") then
				btn.MouseButton1Click:Connect(function()
					ESPEnabled = not ESPEnabled
					btn.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
				end)
			end
		end
	end
end

-- YoxanXHub Arsenal V1.5 – 5/5 (WalkSpeed + Teleport + AntiVoid + Exit UI)
local Players, RunService = game:GetService("Players"), game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local WalkSpeed = 16
local AntiVoidEnabled = true

-- WalkSpeed Control
RunService.RenderStepped:Connect(function()
	if Humanoid and Humanoid.Parent and Humanoid.Health > 0 then
		Humanoid.WalkSpeed = WalkSpeed
	end
end)

-- Teleport to Base
local function TeleportToBase()
	local root = Character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(0, 50, 0) -- Ganti sesuai posisi base
	end
end

-- Anti Void Logic
RunService.Stepped:Connect(function()
	local root = Character:FindFirstChild("HumanoidRootPart")
	if root and root.Position.Y < -10 and AntiVoidEnabled then
		TeleportToBase()
	end
end)

-- Exit UI
local function ExitHub()
	local gui = game:GetService("CoreGui"):FindFirstChild("YoxanXHub_UI")
	local esp = game:GetService("CoreGui"):FindFirstChild("YoxanXHub_ESP")
	if gui then gui:Destroy() end
	if esp then esp:Destroy() end
end

-- UI Integration
local gui = game:GetService("CoreGui"):FindFirstChild("YoxanXHub_UI")
if gui then
	local main = gui:FindFirstChildOfClass("Frame")
	if main then
		for _, btn in pairs(main:GetDescendants()) do
			if btn:IsA("TextButton") then
				if btn.Text:lower():find("walkspeed") then
					btn.MouseButton1Click:Connect(function()
						WalkSpeed = WalkSpeed == 16 and 30 or 16
						btn.Text = "WalkSpeed: " .. WalkSpeed
					end)
				elseif btn.Text:lower():find("teleport") then
					btn.MouseButton1Click:Connect(function()
						TeleportToBase()
					end)
				elseif btn.Text:lower():find("exit") then
					btn.MouseButton1Click:Connect(function()
						ExitHub()
					end)
				end
			end
		end
	end
end
