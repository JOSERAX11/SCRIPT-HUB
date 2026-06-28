
local key = ... 

-- VERIFICAR LA CLAVE
if key ~= "DUELS_HUB_SECRETO" then
    warn("❌ ACCESO DENEGADO: Por favor, ejecuta este script usando el DUELS-HUB oficial.")
    return -- El "return" hace que el resto del script no se ejecute
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local AimbotEnabled = false 
local AutoShootEnabled = false 
local ESPEnabled = false 
local ShowFOV = false 
local FOV_RADIUS = 500 

local SilentAimEnabled = false
local currentSilentTarget = nil

local SilentAutoShootEnabled = false
local SilentFOV = 150
local ShowSilentFOV = false

local ShowHitboxFOV = false
local HITBOX_FOV_RADIUS = 200

local SMOOTHNESS = 0.4 
local shotCooldown = 0.02
local autoshootDelay = 0.150

local lastShot = 0
local currentTarget = nil
local triggerBotTimer = 0

local hitboxEnabled = false
local hitbox_original_properties = {}
local activeHitboxes = {} 
local hitboxSize = 150 
local MAX_ACTIVE_HITBOXES = 5 
local MAX_HITBOX_DISTANCE = 250 

local FOVCircle = nil
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Thickness = 1.5
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Filled = false
    FOVCircle.Radius = FOV_RADIUS
end

local SilentFOVCircle = nil
if Drawing then
    SilentFOVCircle = Drawing.new("Circle")
    SilentFOVCircle.Visible = false
    SilentFOVCircle.Thickness = 1.5
    SilentFOVCircle.Color = Color3.fromRGB(0, 255, 0)
    SilentFOVCircle.Filled = false
    SilentFOVCircle.Radius = SilentFOV
end

local HitboxFOVCircle = nil
if Drawing then
    HitboxFOVCircle = Drawing.new("Circle")
    HitboxFOVCircle.Visible = false
    HitboxFOVCircle.Thickness = 1.5
    HitboxFOVCircle.Color = Color3.fromRGB(255, 50, 50)
    HitboxFOVCircle.Filled = false
    HitboxFOVCircle.Radius = HITBOX_FOV_RADIUS
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🎯 External Aimbot Menu",
   LoadingTitle = "Cargando Script...",
   LoadingSubtitle = "por ti",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false
})

local TabCombat = Window:CreateTab("🔫 Combate", 4483362458)
local TabVisuals = Window:CreateTab("👁️ Visuales", 4483362458)
local TabSettings = Window:CreateTab("⚙️ Ajustes", 4483362458)

local StatusLabel = TabCombat:CreateLabel("Objetivo: Ninguno")
local currentStatusText = ""

local function UpdateStatus(text)
    if text ~= currentStatusText then
        currentStatusText = text
        StatusLabel:Set(text)
    end
end

TabCombat:CreateSection("AutoShoot")

TabCombat:CreateToggle({
   Name = "AutoShoot",
   CurrentValue = false,
   Flag = "AutoShootToggle",
   Callback = function(Value)
       AutoShootEnabled = Value
       triggerBotTimer = 0
       if not AutoShootEnabled and not SilentAimEnabled then
           currentSilentTarget = nil
       end
   end,
})

TabCombat:CreateSection("Silent Aim")

TabCombat:CreateToggle({
   Name = "Silent Aim",
   CurrentValue = false,
   Flag = "SilentAimToggle",
   Callback = function(Value)
       SilentAimEnabled = Value
       if not SilentAimEnabled and not AutoShootEnabled then
           currentSilentTarget = nil
       end
   end,
})

TabCombat:CreateToggle({
    Name = "Silent AutoShoot",
    CurrentValue = false,
    Flag = "SilentAutoShootToggle",
    Callback = function(Value)
        SilentAutoShootEnabled = Value
    end,
})

TabCombat:CreateToggle({
    Name = "Mostrar FOV Silent Aim",
    CurrentValue = false,
    Flag = "SilentFOVToggle",
    Callback = function(Value)
        ShowSilentFOV = Value
        if SilentFOVCircle then SilentFOVCircle.Visible = ShowSilentFOV end
    end,
})

TabCombat:CreateSlider({
    Name = "Tamaño FOV Silent",
    Range = {10, 1500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = SilentFOV,
    Flag = "SilentFOVSlider",
    Callback = function(Value)
        SilentFOV = Value
        if SilentFOVCircle then SilentFOVCircle.Radius = SilentFOV end
    end,
})

TabCombat:CreateSection("Aimbot")

TabCombat:CreateToggle({
   Name = "Aimbot (Cámara)",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
       AimbotEnabled = Value
       if not AimbotEnabled then 
           UpdateStatus("Objetivo: Ninguno") 
           currentTarget = nil
       end
   end,
})

TabCombat:CreateToggle({
   Name = "Mostrar FOV Aimbot",
   CurrentValue = false,
   Flag = "AimbotFOVToggle",
   Callback = function(Value)
       ShowFOV = Value
       if FOVCircle then FOVCircle.Visible = ShowFOV end
   end,
})

TabCombat:CreateSlider({
   Name = "Tamaño FOV Aimbot",
   Range = {10, 1500},
   Increment = 10,
   Suffix = "px",
   CurrentValue = FOV_RADIUS,
   Flag = "AimbotFOVSlider",
   Callback = function(Value)
       FOV_RADIUS = Value
       if FOVCircle then FOVCircle.Radius = FOV_RADIUS end
   end,
})

TabCombat:CreateSection("Hitbox Dinámica")

TabCombat:CreateToggle({
   Name = "Expandir Hitbox (Silent Visual)",
   CurrentValue = false,
   Flag = "HitboxToggle",
   Callback = function(Value)
       hitboxEnabled = Value
       if hitboxEnabled then
           coroutine.wrap(function()
               while hitboxEnabled do
                   updateHitboxes()
                   checkForDeadPlayers()
                   task.wait(0.2) 
               end
           end)()
       else
           for _, player in ipairs(Players:GetPlayers()) do
               restoredPart(player)
           end
           hitbox_original_properties = {}
           activeHitboxes = {}
       end
   end,
})

TabCombat:CreateSlider({
   Name = "Tamaño Máx Hitbox",
   Range = {10, 500},
   Increment = 5,
   Suffix = "studs",
   CurrentValue = hitboxSize,
   Flag = "HitboxSize",
   Callback = function(Value)
       hitboxSize = Value
   end,
})

TabCombat:CreateToggle({
   Name = "Mostrar FOV Hitbox",
   CurrentValue = false,
   Flag = "HitboxFOVToggle",
   Callback = function(Value)
       ShowHitboxFOV = Value
       if HitboxFOVCircle then HitboxFOVCircle.Visible = ShowHitboxFOV end
   end,
})

TabCombat:CreateSlider({
   Name = "Tamaño Hitbox FOV",
   Range = {10, 1000},
   Increment = 10,
   Suffix = "px",
   CurrentValue = HITBOX_FOV_RADIUS,
   Flag = "HitboxFOVSlider",
   Callback = function(Value)
       HITBOX_FOV_RADIUS = Value
       if HitboxFOVCircle then HitboxFOVCircle.Radius = HITBOX_FOV_RADIUS end
   end,
})

TabVisuals:CreateToggle({
   Name = "Activar ESP (Jugadores)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       ESPEnabled = Value
       UpdateESP()
   end,
})

TabSettings:CreateSlider({
   Name = "Aimbot Smoothness (Suavidad)",
   Range = {1, 100},
   Increment = 1,
   Suffix = "%",
   CurrentValue = SMOOTHNESS * 100,
   Flag = "SmoothSlider",
   Callback = function(Value)
       SMOOTHNESS = Value / 100
   end,
})

TabSettings:CreateInput({
   Name = "AutoShoot Delay",
   PlaceholderText = tostring(autoshootDelay),
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local val = tonumber(Text)
       if val then autoshootDelay = val end
   end,
})

TabSettings:CreateInput({
   Name = "Click Cooldown",
   PlaceholderText = tostring(shotCooldown),
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local val = tonumber(Text)
       if val then shotCooldown = val end
   end,
})

local cachedSafeZones = {}

local function calculateAABB(instance)
    if not instance then return nil end
    
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
    local found = false

    for _, part in ipairs(instance:GetDescendants()) do
        if part:IsA("BasePart") then
            found = true
            local pos = part.Position
            local size = part.Size / 2
            
            minX = math.min(minX, pos.X - size.X)
            minY = math.min(minY, pos.Y - size.Y)
            minZ = math.min(minZ, pos.Z - size.Z)
            
            maxX = math.max(maxX, pos.X + size.X)
            maxY = math.max(maxY, pos.Y + size.Y)
            maxZ = math.max(maxZ, pos.Z + size.Z)
        end
    end

    if found then
        return {
            min = Vector3.new(minX - 15, minY - 15, minZ - 15),
            max = Vector3.new(maxX + 15, maxY + 100, maxZ + 15)
        }
    end
    return nil
end

local function updateSafeZonesCache()
    table.clear(cachedSafeZones)
    
    local lobby = Workspace:FindFirstChild("Lobby")
    if lobby then
        local box = calculateAABB(lobby)
        if box then table.insert(cachedSafeZones, box) end
    end

    local votingMap = Workspace:FindFirstChild("VotingMap")
    if votingMap then
        local votingLobby = votingMap:FindFirstChild("VotingLobby")
        if votingLobby then
            local box = calculateAABB(votingLobby)
            if box then table.insert(cachedSafeZones, box) end
        end
    end
end

task.spawn(function()
    while true do
        updateSafeZonesCache()
        task.wait(5)
    end
end)

local function isInSafeZone(player)
    if #cachedSafeZones == 0 then return false end
    
    local char = player.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
    if not root then return false end

    local pos = root.Position

    for _, zone in ipairs(cachedSafeZones) do
        if pos.X >= zone.min.X and pos.X <= zone.max.X and
           pos.Y >= zone.min.Y and pos.Y <= zone.max.Y and
           pos.Z >= zone.min.Z and pos.Z <= zone.max.Z then
            return true
        end
    end
    return false
end

local function IsTeammate(player)
    local myTeam = LocalPlayer:GetAttribute("Team")
    local targetTeam = player:GetAttribute("Team")
    if myTeam and targetTeam then return myTeam == targetTeam end
    return false
end

local function IsPartVisible(targetPart, targetCharacter)
    local myCharacter = LocalPlayer.Character
    local myOriginPart = myCharacter and (myCharacter:FindFirstChild("Head") or myCharacter:FindFirstChild("HumanoidRootPart"))
    
    if not myOriginPart or not targetPart then return false end
    
    local origin = myOriginPart.Position
    local direction = targetPart.Position - origin
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {myCharacter, targetCharacter, Camera}
    rayParams.IgnoreWater = true
    
    local rayResult = Workspace:Raycast(origin, direction, rayParams)
    return not rayResult 
end

local function savedPart(player, part)
    if not hitbox_original_properties[player] then hitbox_original_properties[player] = {} end
    if not hitbox_original_properties[player][part.Name] then
        hitbox_original_properties[player][part.Name] = {
            CanCollide = part.CanCollide,
            Transparency = part.Transparency,
            Size = part.Size,
            Massless = part.Massless,
            Color = part.Color,
            Material = part.Material
        }
    end
end

function restoredPart(player)
    if activeHitboxes[player] and hitbox_original_properties[player] then
        for partName, properties in pairs(hitbox_original_properties[player]) do
            local part = player.Character and player.Character:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                if part.Size ~= properties.Size then part.Size = properties.Size end
                if part.CanCollide ~= properties.CanCollide then part.CanCollide = properties.CanCollide end
                if part.Transparency ~= properties.Transparency then part.Transparency = properties.Transparency end
                if properties.Massless ~= nil and part.Massless ~= properties.Massless then part.Massless = properties.Massless end
                if properties.Color and part.Color ~= properties.Color then part.Color = properties.Color end
                if properties.Material and part.Material ~= properties.Material then part.Material = properties.Material end
            end
        end
        activeHitboxes[player] = false 
    end
end

local function extendHitbox(player)
    local headPart = player.Character and player.Character:FindFirstChild("Head")
    local myRoot = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head"))
    
    if headPart and myRoot then
        savedPart(player, headPart)
        local distance = (myRoot.Position - headPart.Position).Magnitude
        
        local dynamicSize = math.clamp(distance * 1.5, 12, hitboxSize)
        local targetSize = Vector3.new(dynamicSize, dynamicSize, dynamicSize)
        
        if (headPart.Size - targetSize).Magnitude > 2 then
            headPart.Size = targetSize
        end
        
        if headPart.CanCollide ~= false then headPart.CanCollide = false end
        if headPart.Transparency ~= 1 then headPart.Transparency = 1 end
        if headPart.Massless ~= true then headPart.Massless = true end
        
        activeHitboxes[player] = true
    end
end

function updateHitboxes()
    local myCharacter = LocalPlayer.Character
    local myRoot = myCharacter and (myCharacter:FindFirstChild("HumanoidRootPart") or myCharacter:FindFirstChild("Head"))
    local mousePos = UserInputService:GetMouseLocation()
    
    if not myRoot then return end

    if isInSafeZone(LocalPlayer) then
        for _, player in ipairs(Players:GetPlayers()) do restoredPart(player) end
        return
    end

    local validEnemies = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 and not IsTeammate(player) and not isInSafeZone(player) then
                local targetHead = player.Character:FindFirstChild("Head")
                if targetHead then
                    local dist = (myRoot.Position - targetHead.Position).Magnitude
                    if dist <= MAX_HITBOX_DISTANCE then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetHead.Position)
                        if onScreen then
                            local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if distToMouse <= HITBOX_FOV_RADIUS then
                                table.insert(validEnemies, {player = player, head = targetHead, distance = dist})
                            else
                                restoredPart(player) 
                            end
                        else
                            restoredPart(player) 
                        end
                    else
                        restoredPart(player) 
                    end
                end
            else
                restoredPart(player) 
            end
        else
            restoredPart(player)
        end
    end

    table.sort(validEnemies, function(a, b) return a.distance < b.distance end)

    for i, enemyData in ipairs(validEnemies) do
        local player = enemyData.player
        if i <= MAX_ACTIVE_HITBOXES then
            if IsPartVisible(enemyData.head, player.Character) then
                extendHitbox(player)
            else
                restoredPart(player)
            end
        else
            restoredPart(player)
        end
    end
end

function checkForDeadPlayers()
    for player in pairs(hitbox_original_properties) do
        if not player.Parent or not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
            restoredPart(player)
            hitbox_original_properties[player] = nil
            activeHitboxes[player] = nil
        end
    end
end

function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local highlight = char:FindFirstChild("ESPHighlight")
                if ESPEnabled then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "ESPHighlight"
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.Parent = char
                    end
                    if IsTeammate(player) then
                        highlight.FillColor = Color3.fromRGB(0, 0, 255)
                    else
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    end
                else
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end
end

local function SetupPlayerESP(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5) 
        if ESPEnabled then UpdateESP() end
    end)
    player.AttributeChanged:Connect(function(attribute)
        if attribute == "Team" and ESPEnabled then UpdateESP() end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then SetupPlayerESP(player) end
end
Players.PlayerAdded:Connect(function(player) SetupPlayerESP(player) end)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if ESPEnabled then UpdateESP() end
end)
LocalPlayer.AttributeChanged:Connect(function(attribute)
    if attribute == "Team" and ESPEnabled then UpdateESP() end
end)

local function GetBestTarget(fovLimit)
    local fovToUse = fovLimit or FOV_RADIUS
    local mousePos = UserInputService:GetMouseLocation()
    local bestPlayer = nil
    local bestDist = fovToUse
    local MAX_DISTANCE = 1500

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeammate(player) and not isInSafeZone(player) and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local partsToCheck = {"Head", "UpperTorso"} 
            for _, partName in ipairs(partsToCheck) do
                local part = player.Character:FindFirstChild(partName)
                if part then
                    local distanceToPlayer = (Camera.CFrame.Position - part.Position).Magnitude
                    if distanceToPlayer <= MAX_DISTANCE then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if distToMouse < bestDist then
                                bestDist = distToMouse
                                bestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end

    if not bestPlayer then return nil, nil, false end

    local char = bestPlayer.Character
    local priorityParts = {"Head", "UpperTorso"} 

    for _, partName in ipairs(priorityParts) do
        local part = char:FindFirstChild(partName)
        if part and IsPartVisible(part, char) then return bestPlayer, part, true end
    end

    local defaultTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if defaultTorso then return bestPlayer, defaultTorso, false end

    return nil, nil, false
end

local function TriggerClick()
    if tick() - lastShot > shotCooldown then
        lastShot = tick()
        if mouse1click then
            mouse1click()
        else
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.delay(0.02, function() vim:SendMouseButtonEvent(0, 0, 0, false, game, 0) end)
        end
    end
end

local function GetRandomBodyPart(char)
    if not char then return nil end
    
    local possibleParts = {
        "Head", "UpperTorso", "LowerTorso", 
        "RightUpperArm", "RightLowerArm", "RightHand",
        "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperLeg", "RightLowerLeg", "RightFoot",
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
        "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"
    }
    
    local availableParts = {}
    
    for _, partName in ipairs(possibleParts) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            if IsPartVisible(part, char) then
                table.insert(availableParts, part)
            end
        end
    end
    
    if #availableParts > 0 then
        local randomIndex = math.random(1, #availableParts)
        return availableParts[randomIndex]
    end
    
    return nil
end

RunService:BindToRenderStep("AimbotCameraLock", Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
    local mousePos = UserInputService:GetMouseLocation()

    if FOVCircle and ShowFOV then
        FOVCircle.Position = mousePos
    end
    
    if HitboxFOVCircle and ShowHitboxFOV then
        HitboxFOVCircle.Position = mousePos
    end
    
    if SilentFOVCircle and ShowSilentFOV then
        SilentFOVCircle.Position = mousePos
    end
    
    local activeTarget = nil

    if AutoShootEnabled and not isInSafeZone(LocalPlayer) then
        local targetPlayer, defaultPart, isVisible = GetBestTarget(10000)
        
        if targetPlayer and isVisible then
            activeTarget = GetRandomBodyPart(targetPlayer.Character) or defaultPart
            
            triggerBotTimer = triggerBotTimer + deltaTime
            if triggerBotTimer >= autoshootDelay then
                TriggerClick()
                triggerBotTimer = 0
            end
        else
            triggerBotTimer = 0 
        end

    elseif SilentAimEnabled and not isInSafeZone(LocalPlayer) then
        local targetPlayer, defaultPart, isVisible = GetBestTarget(SilentFOV)
        if targetPlayer and isVisible then
            activeTarget = GetRandomBodyPart(targetPlayer.Character) or defaultPart
            
            if SilentAutoShootEnabled then
                triggerBotTimer = triggerBotTimer + deltaTime
                if triggerBotTimer >= autoshootDelay then
                    TriggerClick()
                    triggerBotTimer = 0
                end
            else
                triggerBotTimer = 0
            end
        else
            if SilentAutoShootEnabled then triggerBotTimer = 0 end
        end
    end

    currentSilentTarget = activeTarget

    if AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        
        if isInSafeZone(LocalPlayer) then
            UpdateStatus("En Zona Segura (Bloqueado)")
            currentTarget = nil
            return
        end

        local targetPlayer, targetPart, isVisible = GetBestTarget(FOV_RADIUS)
        
        if targetPlayer then
            local estado = isVisible and " (Visible)" or " (Oculto)"
            UpdateStatus("Objetivo: " .. targetPlayer.Name .. estado)
            currentTarget = targetPlayer
            
            local targetPosition = targetPart.Position
            local distanceToTarget = (Camera.CFrame.Position - targetPosition).Magnitude

            if distanceToTarget > 2 then
                local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPosition)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, SMOOTHNESS)
            end
        else
            UpdateStatus("Buscando objetivo...")
            currentTarget = nil
        end
    else
        if AimbotEnabled then
            UpdateStatus("Mantén Clic Derecho")
            currentTarget = nil
        end
    end
end)

local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__index = newcclosure(function(self, index)
    local isSilentActive = SilentAimEnabled or AutoShootEnabled

    if isSilentActive and currentSilentTarget and self == Mouse and (index == "Hit" or index == "Target") then
        if index == "Hit" then
            return currentSilentTarget.CFrame
        elseif index == "Target" then
            return currentSilentTarget
        end
    end
    
    return oldIndex(self, index)
end)

setreadonly(mt, true)
