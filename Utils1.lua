local ProtectionConfig = {
    SecretKey = "Joserax_MVS_Secret_2026",
    HubName = "DASHBOARD-HUB"
}

if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return 
end
-- Verifica si el ServiceId es el tuyo
if not Config or Config.ServiceId ~= 27041 then
    error("Acceso denegado: Este script no está autorizado para este ServiceId.")
    return -- Detiene la ejecución
end 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Variables ESP
local ESPEnabled = false 

-- Variables FOV Visual Hitbox (Silent)
local ShowHitboxFOV = false
local HITBOX_FOV_RADIUS = 200

-- Variables de Hitbox y Optimización
local hitboxEnabled = false
local hitbox_original_properties = {}
local activeHitboxes = {} 
local hitboxSize = 150 
local MAX_ACTIVE_HITBOXES = 5 
local MAX_HITBOX_DISTANCE = 250 

-- Configuración del Círculo FOV Hitbox (Rojo)
local HitboxFOVCircle = nil
if Drawing then
    HitboxFOVCircle = Drawing.new("Circle")
    HitboxFOVCircle.Visible = false
    HitboxFOVCircle.Thickness = 1.5
    HitboxFOVCircle.Color = Color3.fromRGB(255, 50, 50)
    HitboxFOVCircle.Filled = false
    HitboxFOVCircle.Radius = HITBOX_FOV_RADIUS
end

-- ==========================================
-- CARGAR RAYFIELD UI
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🎯 Silent & ESP Menu",
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

-- ==========================================
-- PESTAÑAS
-- ==========================================
local TabCombat = Window:CreateTab("🔫 Combate", 4483362458)
local TabVisuals = Window:CreateTab("👁️ Visuales", 4483362458)

-- ==========================================
-- ELEMENTOS DE RAYFIELD (COMBATE - SILENT)
-- ==========================================
TabCombat:CreateSection("Silent (Hitbox Dinámica)")

TabCombat:CreateToggle({
   Name = "Silent",
   CurrentValue = false,
   Flag = "HitboxToggle",
   Callback = function(Value)
       hitboxEnabled = Value
       if hitboxEnabled then
           coroutine.wrap(function()
               while hitboxEnabled do
                   updateHitboxes()
                   checkForDeadPlayers()
                   task.wait(0.15) -- OPTIMIZACIÓN ANTI-LAG: Reducida la carga en la CPU
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
   Name = "Tamaño Máx Hitbox (mejor 150)",
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
   Name = "FOV silent",
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

-- ==========================================
-- ELEMENTOS DE RAYFIELD (VISUALES)
-- ==========================================
TabVisuals:CreateSection("ESP")

TabVisuals:CreateToggle({
   Name = "Activar ESP (Jugadores)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       ESPEnabled = Value
       UpdateESP()
   end,
})

-- ==========================================
-- LÓGICA ZONAS SEGURAS (AABB)
-- ==========================================
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
    rayParams.FilterDescendantsInstances = {myCharacter, targetCharacter}
    rayParams.IgnoreWater = true
    
    local rayResult = Workspace:Raycast(origin, direction, rayParams)
    return not rayResult 
end

-- ==========================================
-- LÓGICA DE HITBOX (SILENT) CON ANTI-LAG
-- ==========================================
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
                -- OPTIMIZACIÓN ANTI-LAG: Solo aplicar si es necesario
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
        
        -- OPTIMIZACIÓN ANTI-LAG: Solo modificar tamaño si la diferencia es mayor a 2 studs
        if (headPart.Size - targetSize).Magnitude > 2 then
            headPart.Size = targetSize
        end
        
        -- OPTIMIZACIÓN ANTI-LAG: Solo reescribir propiedades si no tienen el valor deseado
        if headPart.CanCollide ~= false then headPart.CanCollide = false end
        if headPart.Transparency ~= 1 then headPart.Transparency = 1 end 
        if headPart.Massless ~= true then headPart.Massless = true end
        
        activeHitboxes[player] = true
    end
end

function updateHitboxes()
    local myCharacter = LocalPlayer.Character
    local myRoot = myCharacter and (myCharacter:FindFirstChild("HumanoidRootPart") or myCharacter:FindFirstChild("Head"))
    
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    
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
                            local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if distToCenter <= HITBOX_FOV_RADIUS then
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

-- ==========================================
-- LÓGICA ESP
-- ==========================================
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

-- ==========================================
-- BUCLE RENDER STEP PARA FOV VISUAL (CENTRO DE PANTALLA)
-- ==========================================
RunService:BindToRenderStep("SilentFOVRender", Enum.RenderPriority.Camera.Value + 1, function()
    if HitboxFOVCircle and ShowHitboxFOV then
        local viewportSize = Camera.ViewportSize
        HitboxFOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    end
end)
