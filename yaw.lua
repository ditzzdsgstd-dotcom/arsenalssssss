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

-- Ready!
print("✅ YoxanXHub Arsenal V1.5 UI Loaded (1/9)")
