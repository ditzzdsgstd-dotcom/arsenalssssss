local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
local Players, RunService, Camera = game:GetService("Players"), game:GetService("RunService"), workspace.CurrentCamera
local Player, Mouse, StarterGui = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), game:GetService("StarterGui")

local Window = OrionLib:MakeWindow({
    Name = "YoxanXHub | Arsenal",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = false
})

-- Tabs
local tabAimbot = Window:MakeTab({Name="Aimbot", Icon="⚙️", PremiumOnly=false})
local tabESP = Window:MakeTab({Name="ESP", Icon="🧿", PremiumOnly=false})
local tabMisc = Window:MakeTab({Name="Misc", Icon="🧰", PremiumOnly=false})

-- Vars (same as original, logic in part 2/3)
Aimbot, Smooth, Wall, ESP, ESPTeam, ShowName, SafeMode, KillAll, AutoFire = false, false, false, false, false, false, false, false, false
TargetPart, parts, partIdx = "Head", {"Head", "UpperTorso", "Torso"}, 1
ESPMode, ESPColor, Rainbow, PositionMode = "Highlight", Color3.new(1,1,1), false, "Front"
safemodew, KillAllIndex = 10, 1

-- Notify
function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title="YoxanXHub", Text=text, Duration=3})
    end)
end

-- Aimbot Tab
tabAimbot:AddToggle({Name="Aimbot", Default=false, Callback=function(v) Aimbot = v end})
tabAimbot:AddToggle({Name="Smooth Aimbot", Default=false, Callback=function(v) Smooth = v end})
tabAimbot:AddToggle({Name="Wall Aimbot", Default=false, Callback=function(v) Wall = v end})
tabAimbot:AddToggle({Name="Safe Mode", Default=false, Callback=function(v) SafeMode = v end})
tabAimbot:AddButton({Name="Switch Target Part", Callback=function()
    partIdx = partIdx % #parts + 1
    TargetPart = parts[partIdx]
    notify("Target Lock: " .. TargetPart)
end})

-- ESP Tab
tabESP:AddToggle({Name="Enable ESP", Default=false, Callback=function(v) ESP = v end})
tabESP:AddToggle({Name="Team Check", Default=false, Callback=function(v) ESPTeam = v end})
tabESP:AddToggle({Name="Show Name", Default=false, Callback=function(v) ShowName = v end})
tabESP:AddButton({Name="Switch ESP Mode", Callback=function()
    ESPMode = (ESPMode == "Highlight") and "Box" or "Highlight"
    notify("ESP Mode: " .. ESPMode)
end})
tabESP:AddTextbox({Name="ESP Color (e.g. red, blue, rainbow)", Default="", TextDisappear=true, Callback=function(v)
    local c = v:lower()
    Rainbow = false
    local colorList = {
        red=Color3.fromRGB(255,0,0), blue=Color3.fromRGB(0,0,255), green=Color3.fromRGB(0,255,0),
        yellow=Color3.fromRGB(255,255,0), black=Color3.fromRGB(0,0,0), white=Color3.fromRGB(255,255,255),
        pink=Color3.fromRGB(255,105,180), purple=Color3.fromRGB(128,0,128), orange=Color3.fromRGB(255,165,0),
        cyan=Color3.fromRGB(0,255,255)
    }
    ESPColor = colorList[c] or Color3.new(1,1,1)
    if c == "rainbow" then Rainbow = true end
    notify("ESP Color: " .. c)
end})

-- Misc Tab
tabMisc:AddToggle({Name="Kill All", Default=false, Callback=function(v) KillAll = v KillAllIndex = 1 end})
tabMisc:AddToggle({Name="Auto Fire", Default=false, Callback=function(v) AutoFire = v end})
tabMisc:AddButton({Name="Toggle Teleport Position", Callback=function()
    PositionMode = PositionMode == "Front" and "Behind" or "Front"
    notify("Position: " .. PositionMode)
end})

-- Helper Functions
local function getRainbow(t)
    local f = 2
    return Color3.fromRGB(
        math.floor(math.sin(f*t+0)*127+128),
        math.floor(math.sin(f*t+2)*127+128),
        math.floor(math.sin(f*t+4)*127+128)
    )
end

local function valid(p)
    return p and p.Character
        and p.Character:FindFirstChild(TargetPart)
        and p.Character:FindFirstChild("Humanoid")
        and p.Character.Humanoid.Health > 0
end

local function isBehind(p)
    local o = Camera.CFrame.Position
    local d = (p.Character[TargetPart].Position - o)
    local ray = Ray.new(o, d)
    local hit = workspace:FindPartOnRay(ray, Player.Character)
    return hit and not p.Character:IsAncestorOf(hit)
end

local function getClosest()
    local best, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and valid(p) and p.Team ~= Player.Team then
            if not Wall and isBehind(p) then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character[TargetPart].Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < dist then dist, best = mag, p end
            end
        end
    end
    return best
end

local function getEnemies()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and valid(p) and p.Team ~= Player.Team then
            table.insert(list, p)
        end
    end
    return list
end

local function getSafeTarget()
    local safeTarget = nil
    local safeDist = safemodew
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and valid(p) and p.Team ~= Player.Team then
            local dist = (p.Character.PrimaryPart.Position - Player.Character.PrimaryPart.Position).Magnitude
            if dist <= safeDist then
                safeDist = dist
                safeTarget = p
            end
        end
    end
    return safeTarget
end

local function getPositionCFrame(target)
    local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local offset = PositionMode == "Front" and hrp.CFrame.LookVector * 3 or -hrp.CFrame.LookVector * 3
    return CFrame.new(hrp.Position + offset, hrp.Position)
end

-- ESP Containers
local highlights, boxes, names = {}, {}, {}

-- Runtime Logic
local CurrentTarget = nil
local lastTeleportTime = 0
local TELEPORT_DELAY = 1.5

RunService.RenderStepped:Connect(function()
    -- Handle Aimbot & Kill All
    if not Aimbot and not KillAll then
        CurrentTarget = nil
    end

    if KillAll then
        local enemies = getEnemies()
        if #enemies > 0 and tick() - lastTeleportTime >= TELEPORT_DELAY then
            KillAllIndex = (KillAllIndex % #enemies) + 1
            CurrentTarget = enemies[KillAllIndex]
            lastTeleportTime = tick()
        end

        if CurrentTarget and valid(CurrentTarget) and Player.Character:FindFirstChild("HumanoidRootPart") then
            local pos = getPositionCFrame(CurrentTarget)
            if pos then
                Player.Character.HumanoidRootPart.CFrame = pos
            end

            local goal = CFrame.new(Camera.CFrame.Position, CurrentTarget.Character[TargetPart].Position)
            Camera.CFrame = Smooth and Camera.CFrame:Lerp(goal, 0.2) or goal
        end
    elseif Aimbot then
        CurrentTarget = SafeMode and getSafeTarget() or getClosest()
        if CurrentTarget and valid(CurrentTarget) and CurrentTarget.Team ~= Player.Team then
            local goal = CFrame.new(Camera.CFrame.Position, CurrentTarget.Character[TargetPart].Position)
            Camera.CFrame = Smooth and Camera.CFrame:Lerp(goal, 0.2) or goal
        end
    end

    -- ESP Logic
    for _, p in pairs(Players:GetPlayers()) do
        if p == Player then continue end
        local isValid = valid(p) and (not ESPTeam or p.Team ~= Player.Team)
        local color = Rainbow and getRainbow(tick()) or ESPColor

        if ESP and isValid then
            if ESPMode == "Highlight" then
                if not highlights[p] then
                    local h = Instance.new("Highlight")
                    h.Adornee = p.Character
                    h.FillTransparency = 0.5
                    h.Parent = p.Character
                    highlights[p] = h
                    if boxes[p] then boxes[p]:Destroy() boxes[p] = nil end
                end
                highlights[p].FillColor = color
            elseif ESPMode == "Box" then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    if not boxes[p] then
                        local b = Instance.new("BoxHandleAdornment")
                        b.Adornee = root
                        b.Size = Vector3.new(4,6,2)
                        b.AlwaysOnTop = true
                        b.ZIndex = 5
                        b.Transparency = 0.5
                        b.Color3 = color
                        b.Parent = root
                        boxes[p] = b
                        if highlights[p] then highlights[p]:Destroy() highlights[p] = nil end
                    else
                        boxes[p].Color3 = color
                    end
                end
            end

            if ShowName and not names[p] then
                local bb = Instance.new("BillboardGui", p.Character)
                bb.Adornee = p.Character:FindFirstChild("Head")
                bb.Size = UDim2.new(0, 150, 0, 30)
                bb.AlwaysOnTop = true
                local lbl = Instance.new("TextLabel", bb)
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.Text = p.DisplayName.."(@"..p.Name..")"
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.new(1,1,1)
                lbl.Font = Enum.Font.Gotham
                lbl.TextScaled = true
                names[p] = bb
            elseif not ShowName and names[p] then
                names[p]:Destroy()
                names[p] = nil
            end
        else
            if highlights[p] then highlights[p]:Destroy() highlights[p] = nil end
            if boxes[p] then boxes[p]:Destroy() boxes[p] = nil end
            if names[p] then names[p]:Destroy() names[p] = nil end
        end
    end
end)

-- Auto Fire System
local autoFireConnection = nil

-- Auto Fire Toggle Handler
RunService.RenderStepped:Connect(function()
    if AutoFire and Player and Player.Character and Player.Character:FindFirstChildOfClass("Tool") then
        local tool = Player.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            tool:Activate()
        end
    end
end)

-- Optional: Rainbow Visuals (Optional Effect)
-- Akan warnai teks (jika kamu ingin menambahkan efek ini ke judul/label, panggil getRainbow(tick()))
-- Kamu bisa gunakan ini jika ingin gaya visual seperti UI asli DYHub
-- Contoh: someLabel.TextColor3 = getRainbow(tick())
-- Namun untuk OrionLib, efek rainbow tidak otomatis animasi kecuali manual melalui loop

--[[ Contoh Manual Rainbow UI (jika kamu tambahkan OrionLib custom label):
RunService.RenderStepped:Connect(function()
    someLabel.TextColor3 = getRainbow(tick())
end)
]]

-- ✅ SELESAI ✅
notify("✅ YoxanXHub Arsenal Loaded Successfully!")
