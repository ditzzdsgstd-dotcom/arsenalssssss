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
