-- [ INIT + DELAY FIX ]
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
local Players, RunService, Camera = game:GetService("Players"), game:GetService("RunService"), workspace.CurrentCamera
local Player, Mouse, StarterGui = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), game:GetService("StarterGui")

task.wait(1) -- ⏳ fix tombol tidak bisa dipencet saat game load cepat

-- [ CREATE ORION UI ]
local Window = OrionLib:MakeWindow({
    Name = "YoxanXHub | Arsenal V1",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = false
})

-- [ UI TABS ]
local TabAimbot = Window:MakeTab({Name="Aimbot", Icon="⚙️", PremiumOnly=false})
local TabESP = Window:MakeTab({Name="ESP", Icon="🧿", PremiumOnly=false})
local TabMisc = Window:MakeTab({Name="Misc", Icon="🧰", PremiumOnly=false})

-- [ TOGGLE STATE VARS ]
Aimbot, Smooth, Wall, ESP, ESPTeam, ShowName, SafeMode, KillAll, AutoFire = false, false, false, false, false, false, false, false, false
TargetPart, parts, partIdx = "Head", {"Head", "UpperTorso", "Torso"}, 1
ESPMode, ESPColor, Rainbow, PositionMode = "Highlight", Color3.new(1,1,1), false, "Front"
safemodew, KillAllIndex = 10, 1

-- [ NOTIFY HELPER ]
function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "YoxanXHub",
            Text = text,
            Duration = 3
        })
    end)
end

-- [ AIMBOT TAB ]
TabAimbot:AddToggle({Name="Aimbot", Default=false, Callback=function(v) Aimbot = v end})
TabAimbot:AddToggle({Name="Smooth Aimbot", Default=false, Callback=function(v) Smooth = v end})
TabAimbot:AddToggle({Name="Wall Aimbot", Default=false, Callback=function(v) Wall = v end})
TabAimbot:AddToggle({Name="Safe Mode", Default=false, Callback=function(v) SafeMode = v end})
TabAimbot:AddButton({Name="Switch Target Part", Callback=function()
    partIdx = partIdx % #parts + 1
    TargetPart = parts[partIdx]
    notify("Target Lock: " .. TargetPart)
end})

-- [ ESP TAB ]
TabESP:AddToggle({Name="Enable ESP", Default=false, Callback=function(v) ESP = v end})
TabESP:AddToggle({Name="Team Check", Default=false, Callback=function(v) ESPTeam = v end})
TabESP:AddToggle({Name="Show Name", Default=false, Callback=function(v) ShowName = v end})
TabESP:AddButton({Name="Switch ESP Mode", Callback=function()
    ESPMode = (ESPMode == "Highlight") and "Box" or "Highlight"
    notify("ESP Mode: " .. ESPMode)
end})
TabESP:AddTextbox({
    Name = "ESP Color (e.g. red, blue, rainbow)", Default = "", TextDisappear = true,
    Callback = function(v)
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
    end
})

-- [ MISC TAB ]
TabMisc:AddToggle({Name="Kill All", Default=false, Callback=function(v) KillAll = v KillAllIndex = 1 end})
TabMisc:AddToggle({Name="Auto Fire", Default=false, Callback=function(v) AutoFire = v end})
TabMisc:AddButton({Name="Toggle TP Position", Callback=function()
    PositionMode = (PositionMode == "Front") and "Behind" or "Front"
    notify("Position: " .. PositionMode)
end})

-- Valid target check
local function valid(p)
    return p and p.Character
        and p.Character:FindFirstChild(TargetPart)
        and p.Character:FindFirstChild("Humanoid")
        and p.Character.Humanoid.Health > 0
end

-- Raycast: apakah musuh tertutup?
local function isBehind(p)
    local origin = Camera.CFrame.Position
    local direction = (p.Character[TargetPart].Position - origin)
    local ray = Ray.new(origin, direction)
    local hit = workspace:FindPartOnRay(ray, Player.Character)
    return hit and not p.Character:IsAncestorOf(hit)
end

-- Cari musuh terdekat di layar
local function getClosest()
    local best, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and valid(p) and p.Team ~= Player.Team then
            if not Wall and isBehind(p) then continue end
            local pos, visible = Camera:WorldToViewportPoint(p.Character[TargetPart].Position)
            if visible then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < dist then
                    dist = mag
                    best = p
                end
            end
        end
    end
    return best
end

-- Semua musuh
local function getEnemies()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and valid(p) and p.Team ~= Player.Team then
            table.insert(list, p)
        end
    end
    return list
end

-- Musuh paling aman (terdekat)
local function getSafeTarget()
    local safest, dist = nil, safemodew
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and valid(p) and p.Team ~= Player.Team then
            local d = (p.Character.PrimaryPart.Position - Player.Character.PrimaryPart.Position).Magnitude
            if d <= dist then
                dist = d
                safest = p
            end
        end
    end
    return safest
end

-- Dapatkan posisi teleport (di depan/di belakang musuh)
local function getPositionCFrame(target)
    local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local offset = (PositionMode == "Front") and hrp.CFrame.LookVector * 3 or -hrp.CFrame.LookVector * 3
    return CFrame.new(hrp.Position + offset, hrp.Position)
end

-- Logic runtime
local CurrentTarget = nil
local lastTeleportTime = 0
local TELEPORT_DELAY = 1.5

RunService.RenderStepped:Connect(function()
    -- Reset target jika semuanya mati/nonaktif
    if not Aimbot and not KillAll then
        CurrentTarget = nil
    end

    -- 🔪 Kill All logic
    if KillAll then
        local enemies = getEnemies()
        if #enemies > 0 and tick() - lastTeleportTime >= TELEPORT_DELAY then
            KillAllIndex = (KillAllIndex % #enemies) + 1
            CurrentTarget = enemies[KillAllIndex]
            lastTeleportTime = tick()
        end

        if CurrentTarget and valid(CurrentTarget) and Player.Character:FindFirstChild("HumanoidRootPart") then
            local cf = getPositionCFrame(CurrentTarget)
            if cf then
                Player.Character.HumanoidRootPart.CFrame = cf
            end
            local goal = CFrame.new(Camera.CFrame.Position, CurrentTarget.Character[TargetPart].Position)
            Camera.CFrame = Smooth and Camera.CFrame:Lerp(goal, 0.2) or goal
        end
    end

    -- 🎯 Aimbot logic
    if Aimbot and not KillAll then
        CurrentTarget = SafeMode and getSafeTarget() or getClosest()
        if CurrentTarget and valid(CurrentTarget) and CurrentTarget.Team ~= Player.Team then
            local goal = CFrame.new(Camera.CFrame.Position, CurrentTarget.Character[TargetPart].Position)
            Camera.CFrame = Smooth and Camera.CFrame:Lerp(goal, 0.2) or goal
        else
            CurrentTarget = nil
        end
    end
end)

local highlights, boxes, names = {}

-- Fungsi rainbow
local function getRainbow(t)
    local f = 2
    return Color3.fromRGB(
        math.floor(math.sin(f*t+0)*127+128),
        math.floor(math.sin(f*t+2)*127+128),
        math.floor(math.sin(f*t+4)*127+128)
    )
end

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p == Player then continue end

        local isValid = valid(p) and (not ESPTeam or p.Team ~= Player.Team)
        local color = Rainbow and getRainbow(tick()) or ESPColor

        if ESP and isValid then
            -- HIGHLIGHT ESP
            if ESPMode == "Highlight" then
                if not highlights[p] then
                    local h = Instance.new("Highlight")
                    h.Adornee = p.Character
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 1
                    h.Parent = p.Character
                    highlights[p] = h
                    if boxes[p] then boxes[p]:Destroy() boxes[p] = nil end
                end
                highlights[p].FillColor = color

            -- BOX ESP
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

            -- Show Name
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
            -- Clean jika ESP mati atau player invalid
            if highlights[p] then highlights[p]:Destroy() highlights[p] = nil end
            if boxes[p] then boxes[p]:Destroy() boxes[p] = nil end
            if names[p] then names[p]:Destroy() names[p] = nil end
        end
    end
end)

-- 🔫 Auto Fire Handler
RunService.RenderStepped:Connect(function()
    if AutoFire and Player and Player.Character then
        local tool = Player.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            tool:Activate()
        end
    end
end)

-- 🟢 Notify when all loaded
notify("✅ YoxanXHub | Arsenal Loaded Successfully!")
