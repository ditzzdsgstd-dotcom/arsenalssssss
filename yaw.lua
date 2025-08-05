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
