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

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

local selectedScriptName = "Script"

local uiParent = nil
pcall(function() uiParent = CoreGui end)
if not uiParent then
    uiParent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Helper para animaciones rápidas
local function TweenObj(obj, props, time, style, dir)
    time = time or 0.3
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    local tween = TweenService:Create(obj, TweenInfo.new(time, style, dir), props)
    tween:Play()
    return tween
end

task.spawn(function()
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local Matchmaking = PlayerGui:WaitForChild("Matchmaking", 10)
    if not Matchmaking then return end 
    
    local Bottom = Matchmaking:WaitForChild("Bottom", 5)
    local Main = Bottom and Bottom:WaitForChild("Main", 5)
    local ActionButton = Main and Main:WaitForChild("Action", 5)

    if ActionButton then
        local Blocker = Instance.new("TextButton")
        Blocker.Name = "DUELSHUB_Blocker"
        Blocker.Size = UDim2.new(1, 0, 1, 0)
        Blocker.Position = UDim2.new(0, 0, 0, 0)
        Blocker.BackgroundTransparency = 1 
        Blocker.Text = ""
        Blocker.ZIndex = 99999 
        Blocker.Parent = ActionButton

        local tiempoListo = false
        local clickCount = 0 

        Blocker.MouseButton1Click:Connect(function()
            if not tiempoListo then
                clickCount = clickCount + 1 
                
                if clickCount > 3 then
                    pcall(function()
                        StarterGui:SetCore("SendNotification", {
                            Title = "[ SYSTEM ]",
                            Text = "Bypass initialization takes 30s - 1m.",
                            Duration = 4
                        })
                    end)
                else
                    pcall(function()
                        StarterGui:SetCore("SendNotification", {
                            Title = "[ STATUS ]",
                            Text = "Awaiting bypass completion...",
                            Duration = 3
                        })
                    end)
                end
            end
        end)

        task.wait(45)
        tiempoListo = true
        
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "[ READY ]",
                Text = selectedScriptName .. " injected successfully.",
                Duration = 5
            })
        end)
        
        Blocker:Destroy()
    end
end)

local function startLoadingScreenAndExecute(scriptFunction, hubName)
    local BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Size = 0
    BlurEffect.Parent = Lighting

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PremiumLoadingScreen"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = uiParent

    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    Background.BackgroundTransparency = 1
    Background.BorderSizePixel = 0
    Background.Parent = ScreenGui

    local MainPanel = Instance.new("Frame")
    MainPanel.Size = UDim2.new(0, 360, 0, 180) 
    MainPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
    MainPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainPanel.BackgroundTransparency = 1
    MainPanel.BorderSizePixel = 0
    MainPanel.ClipsDescendants = true
    MainPanel.Parent = Background

    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 6)
    PanelCorner.Parent = MainPanel

    local PanelStroke = Instance.new("UIStroke")
    PanelStroke.Color = Color3.fromRGB(100, 110, 120)
    PanelStroke.Thickness = 1
    PanelStroke.Transparency = 1
    PanelStroke.Parent = MainPanel

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.TextTransparency = 1
    Title.Text = "INITIALIZING " .. hubName:upper()
    Title.Parent = MainPanel

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, -40, 0, 20)
    StatusText.Position = UDim2.new(0, 20, 0, 60)
    StatusText.BackgroundTransparency = 1
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextSize = 12
    StatusText.TextColor3 = Color3.fromRGB(160, 160, 160)
    StatusText.TextTransparency = 1
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Text = "Establishing connection..."
    StatusText.Parent = MainPanel

    local PercentageText = Instance.new("TextLabel")
    PercentageText.Size = UDim2.new(0, 50, 0, 20)
    PercentageText.Position = UDim2.new(1, -70, 0, 60)
    PercentageText.BackgroundTransparency = 1
    PercentageText.Font = Enum.Font.GothamBold
    PercentageText.TextSize = 12
    PercentageText.TextColor3 = Color3.fromRGB(220, 220, 220)
    PercentageText.TextTransparency = 1
    PercentageText.TextXAlignment = Enum.TextXAlignment.Right
    PercentageText.Text = "0%"
    PercentageText.Parent = MainPanel

    local ProgressBarBG = Instance.new("Frame")
    ProgressBarBG.Size = UDim2.new(1, -40, 0, 4)
    ProgressBarBG.Position = UDim2.new(0, 20, 0, 90)
    ProgressBarBG.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ProgressBarBG.BackgroundTransparency = 1
    ProgressBarBG.BorderSizePixel = 0
    ProgressBarBG.Parent = MainPanel

    local BGCorner = Instance.new("UICorner")
    BGCorner.CornerRadius = UDim.new(1, 0)
    BGCorner.Parent = ProgressBarBG

    local ProgressBarFill = Instance.new("Frame")
    ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressBarFill.BackgroundColor3 = Color3.fromRGB(100, 110, 120)
    ProgressBarFill.BorderSizePixel = 0
    ProgressBarFill.Parent = ProgressBarBG

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = ProgressBarFill

    local CreditsText = Instance.new("TextLabel")
    CreditsText.Size = UDim2.new(1, 0, 0, 20)
    CreditsText.Position = UDim2.new(0, 0, 0, 115)
    CreditsText.BackgroundTransparency = 1
    CreditsText.Font = Enum.Font.Gotham
    CreditsText.TextSize = 11
    CreditsText.TextColor3 = Color3.fromRGB(100, 100, 100)
    CreditsText.TextTransparency = 1
    CreditsText.Text = "Securing framework endpoints"
    CreditsText.Parent = MainPanel

    local fadeInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(BlurEffect, fadeInfo, {Size = 15}):Play()
    TweenService:Create(Background, fadeInfo, {BackgroundTransparency = 0.4}):Play()
    TweenService:Create(MainPanel, fadeInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(PanelStroke, fadeInfo, {Transparency = 0}):Play()
    TweenService:Create(Title, fadeInfo, {TextTransparency = 0}):Play()
    TweenService:Create(StatusText, fadeInfo, {TextTransparency = 0}):Play()
    TweenService:Create(PercentageText, fadeInfo, {TextTransparency = 0}):Play()
    TweenService:Create(ProgressBarBG, fadeInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(CreditsText, fadeInfo, {TextTransparency = 0}):Play()

    task.wait(0.8)

    local duration = 20
    local messages = {
        "Loading core architecture...",
        "Bypassing security protocols...",
        "Downloading remote environment...",
        "Applying formal UI wrapper...",
        "Finalizing script execution..."
    }

    task.spawn(function()
        local fillTween = TweenService:Create(ProgressBarFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)})
        fillTween:Play()
        
        local startTime = tick()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local elapsed = tick() - startTime
            local progress = math.clamp(elapsed / duration, 0, 1)
            PercentageText.Text = math.floor(progress * 100) .. "%"
            
            if progress >= 1 then
                connection:Disconnect()
            end
        end)
        
        local timePerMessage = duration / #messages
        for _, msg in ipairs(messages) do
            StatusText.Text = msg
            task.wait(timePerMessage)
        end
        
        StatusText.Text = "Execution Ready."
        task.wait(0.4)
        
        local fadeOutInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        TweenService:Create(BlurEffect, fadeOutInfo, {Size = 0}):Play()
        TweenService:Create(Background, fadeOutInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(MainPanel, fadeOutInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(PanelStroke, fadeOutInfo, {Transparency = 1}):Play()
        TweenService:Create(Title, fadeOutInfo, {TextTransparency = 1}):Play()
        TweenService:Create(StatusText, fadeOutInfo, {TextTransparency = 1}):Play()
        TweenService:Create(PercentageText, fadeOutInfo, {TextTransparency = 1}):Play()
        TweenService:Create(ProgressBarBG, fadeOutInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(ProgressBarFill, fadeOutInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(CreditsText, fadeOutInfo, {TextTransparency = 1}):Play()
        
        task.wait(0.6)
        ScreenGui:Destroy()
        BlurEffect:Destroy()
        
        pcall(scriptFunction)
    end)
end

local function openMiniHub()
    local ThemeColor = Color3.fromRGB(100, 110, 120) -- Tono Steel por defecto (Formal)

    local HubGui = Instance.new("ScreenGui")
    HubGui.Name = "DuelsHub_Dashboard"
    HubGui.ResetOnSpawn = false
    HubGui.Parent = uiParent

    local MinButton = Instance.new("TextButton")
    MinButton.Size = UDim2.new(0, 45, 0, 45)
    MinButton.Position = UDim2.new(0.5, -22, 0, 20) 
    MinButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MinButton.Text = "H"
    MinButton.TextColor3 = ThemeColor
    MinButton.Font = Enum.Font.GothamBold
    MinButton.TextSize = 20
    MinButton.Visible = false 
    MinButton.Parent = HubGui

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6) 
    MinCorner.Parent = MinButton

    local MinStroke = Instance.new("UIStroke")
    MinStroke.Color = ThemeColor
    MinStroke.Thickness = 1
    MinStroke.Parent = MinButton

    -- Animación hover para MinButton
    MinButton.MouseEnter:Connect(function() TweenObj(MinButton, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}, 0.2) end)
    MinButton.MouseLeave:Connect(function() TweenObj(MinButton, {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}, 0.2) end)

    local minDragging, minDragInput, minMousePos, minFramePos
    MinButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            minDragging = true
            minMousePos = input.Position
            minFramePos = MinButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then minDragging = false end
            end)
        end
    end)
    MinButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            minDragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == minDragInput and minDragging then
            local delta = input.Position - minMousePos
            MinButton.Position = UDim2.new(minFramePos.X.Scale, minFramePos.X.Offset + delta.X, minFramePos.Y.Scale, minFramePos.Y.Offset + delta.Y)
        end
    end)

    local HubMain = Instance.new("Frame")
    HubMain.Size = UDim2.new(0, 440, 0, 450)
    HubMain.Position = UDim2.new(0.5, 0, 0.5, 0)
    HubMain.AnchorPoint = Vector2.new(0.5, 0.5)
    HubMain.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    HubMain.BorderSizePixel = 0
    HubMain.ClipsDescendants = true
    HubMain.Parent = HubGui

    local dragging = false
    local dragInput, mousePos, framePos

    HubMain.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = HubMain.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    HubMain.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            HubMain.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)

    local HubCorner = Instance.new("UICorner")
    HubCorner.CornerRadius = UDim.new(0, 6)
    HubCorner.Parent = HubMain

    local HubStroke = Instance.new("UIStroke")
    HubStroke.Color = ThemeColor
    HubStroke.Thickness = 1
    HubStroke.Parent = HubMain

    local HubTitle = Instance.new("TextLabel")
    HubTitle.Size = UDim2.new(1, 0, 0, 40)
    HubTitle.Position = UDim2.new(0, 0, 0, 10)
    HubTitle.BackgroundTransparency = 1
    HubTitle.Font = Enum.Font.GothamBold
    HubTitle.TextSize = 18
    HubTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
    HubTitle.Text = "DUELS HUB DASHBOARD"
    HubTitle.Parent = HubMain

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -40, 0, 10) 
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Font = Enum.Font.GothamMedium
    MinimizeBtn.TextSize = 16
    MinimizeBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    MinimizeBtn.Text = "—"
    MinimizeBtn.Parent = HubMain

    MinimizeBtn.MouseEnter:Connect(function() TweenObj(MinimizeBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2) end)
    MinimizeBtn.MouseLeave:Connect(function() TweenObj(MinimizeBtn, {TextColor3 = Color3.fromRGB(140, 140, 140)}, 0.2) end)

    local function ToggleHub(show)
        if show then
            MinButton.Visible = false
            HubMain.Visible = true
            HubMain.Size = UDim2.new(0, 400, 0, 410)
            TweenObj(HubMain, {Size = UDim2.new(0, 440, 0, 450)}, 0.4)
            TweenObj(HubMain, {BackgroundTransparency = 0}, 0.3)
            TweenObj(HubStroke, {Transparency = 0}, 0.3)
        else
            local t = TweenObj(HubMain, {Size = UDim2.new(0, 400, 0, 410), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            TweenObj(HubStroke, {Transparency = 1}, 0.3)
            t.Completed:Wait()
            HubMain.Visible = false
            MinButton.Visible = true
        end
    end

    MinimizeBtn.MouseButton1Click:Connect(function() ToggleHub(false) end)
    MinButton.MouseButton1Click:Connect(function() ToggleHub(true) end)

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -24, 0, 30)
    TabContainer.Position = UDim2.new(0, 12, 0, 55)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = HubMain

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = TabContainer

    local ContentArea = Instance.new("CanvasGroup")
    ContentArea.Size = UDim2.new(1, -24, 1, -135)
    ContentArea.Position = UDim2.new(0, 12, 0, 95)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = HubMain

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, 0, 1, 0) 
    ScrollFrame.Position = UDim2.new(0, 0, 0, 0)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 2
    ScrollFrame.ScrollBarImageColor3 = ThemeColor
    ScrollFrame.Parent = ContentArea

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ScrollFrame

local scriptsList = {
        { Name = "RysHub", Credits = "@Rysted & @Rey", Category = "HUB's", Discord = "https://discord.gg/Hx7SmBEP8t", Status = "Operational", Exec = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Rysted/scripts/main/MurderersVSSheriffs.lua"))() end },
        { Name = "Dark Hub", Credits = "@Dark Hub", Category = "HUB's", Discord = "https://discord.gg/NZ8SWCW62k", Status = "Operational", Exec = function() loadstring(game:HttpGet("https://encrypt-x.pages.dev/Scripts?Id=0245794645232"))("0245794645232") end },
        { Name = "DXV1D", Credits = "@DXV1D", Category = "HUB's", Discord = "N/A", Status = "Operational", Exec = function() loadstring(game:HttpGet("https://encrypt-x.pages.dev/Scripts?Id=9387482195239"))("9387482195239") end },
        { Name = "Triangulare", Credits = "@Moligrafi, @baranqqs", Category = "HUB's", Discord = "https://discord.gg/Md2PTdMh23", Status = "Operational", Exec = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Steal-a-Labubu-Triangulare-Auto-Collect-Auto-Lock-and-Auto-Deliver-42566"))() end },

        { Name = "Danhub", Credits = "@danhub", Category = "Farm", Discord = "https://discord.gg/xhpg89mRZ", Status = "Operational", Exec = function() loadstring(game:HttpGet("https://encrypt-x.pages.dev/Scripts?Id=Danhub"))("Danhub") end },
        { Name = "Fernando Hub", Credits = "@Fernando", Category = "Farm", Discord = "https://discord.gg/SgTngraUmP", Status = "Operational", Exec = function() loadstring(game:HttpGet("https://pastebin.com/raw/hqNqZ8CM"))() end },

        { Name = "AUTO-SHOOT (solo-pc)", Credits = "@DUELS-HUB", Category = "Aim", Discord = "https://discord.gg/MfD8u9MpcW", Status = "Operational", Exec = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/JOSERAX11/SCRIPT-HUB/refs/heads/main/Utils.lua"))("DUELS_HUB_SECRETO") end },
        { Name = "SILENT-AIM(Mobile-beta)", Credits = "@DUELS-HUB", Category = "Aim", Discord = "https://discord.gg/MfD8u9MpcW", Status = "Operational", Exec = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/JOSERAX11/SCRIPT-HUB/refs/heads/main/Utils1.lua"))("DUELS_HUB_SECRETO") end },
        { Name = "Hitbox-expander", Credits = "@DanHub", Category = "Aim", Discord = "https://discord.gg/K2f3727px8", Status = "Operational", Exec = function() loadstring(game:HttpGet("https://encrypt-x.pages.dev/Scripts?Id=BIMOLEGION"))("BIMOLEGION") end },

        { Name = "EMOTES/ANIMATIONS", Credits = "@7yd7", Category = "Misc", Discord = "N/A", Status = "Operational", Exec = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))() end },
        { Name = "ZyroXploit", Credits = "@ZyroXploit", Category = "Misc", Discord = "N/A", Status = "Operational", Exec = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ZyroOnTop/CopyMimicScript/refs/heads/main/byZyro"))() end },        
        { Name = "HEADLESS (key)", Credits = "@Zorvixa.", Category = "Misc", Discord = "https://discord.gg/HfMBj367jT", Status = "Operational", Exec = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/thebabydashminecraft-stack/Headless-zorvixa/refs/heads/main/Headless.lua"))() end },        
        { Name = "ROBLOX-USERNAME", Credits = "@???", Category = "Misc", Discord = "N/A", Status = "Operational", Exec = function() loadstring(game:HttpGet("https://pastebin.com/raw/VQg93ehe"))() end },        
    }
    local TabNames = {"HUB's", "Aim", "Farm", "Misc", "Settings"}
    local TabButtons = {}

    local function LoadTab(selectedTabName)
        TweenObj(ContentArea, {GroupTransparency = 1}, 0.15).Completed:Wait()

        for name, btn in pairs(TabButtons) do
            if name == selectedTabName then
                TweenObj(btn, {BackgroundColor3 = ThemeColor, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            else
                TweenObj(btn, {BackgroundColor3 = Color3.fromRGB(20, 20, 20), TextColor3 = Color3.fromRGB(120, 120, 120)}, 0.2)
            end
        end

        for _, child in ipairs(ScrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        if selectedTabName == "Settings" then
            local totalSettingsHeight = 0

            local ThemeCard = Instance.new("Frame")
            ThemeCard.Size = UDim2.new(0, 390, 0, 95)
            ThemeCard.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            ThemeCard.Parent = ScrollFrame

            local ThemeCorner = Instance.new("UICorner")
            ThemeCorner.CornerRadius = UDim.new(0, 4)
            ThemeCorner.Parent = ThemeCard

            local ThemeStroke = Instance.new("UIStroke")
            ThemeStroke.Color = Color3.fromRGB(35, 35, 35)
            ThemeStroke.Thickness = 1
            ThemeStroke.Parent = ThemeCard

            local ThemeTitle = Instance.new("TextLabel")
            ThemeTitle.Size = UDim2.new(1, 0, 0, 20)
            ThemeTitle.Position = UDim2.new(0, 15, 0, 10)
            ThemeTitle.BackgroundTransparency = 1
            ThemeTitle.Font = Enum.Font.GothamBold
            ThemeTitle.TextSize = 13
            ThemeTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
            ThemeTitle.TextXAlignment = Enum.TextXAlignment.Left
            ThemeTitle.Text = "INTERFACE THEME"
            ThemeTitle.Parent = ThemeCard

            local Palette = {
                {Name = "Steel", Color = Color3.fromRGB(100, 110, 120)},
                {Name = "Crimson", Color = Color3.fromRGB(160, 50, 50)},
                {Name = "Midnight", Color = Color3.fromRGB(50, 70, 110)},
                {Name = "Forest", Color = Color3.fromRGB(40, 100, 70)},
                {Name = "Gold", Color = Color3.fromRGB(170, 140, 60)},
                {Name = "Monochrome", Color = Color3.fromRGB(210, 210, 210)}
            }

            local xOffset = 15
            for _, theme in ipairs(Palette) do
                local ColorBtn = Instance.new("TextButton")
                ColorBtn.Size = UDim2.new(0, 35, 0, 35)
                ColorBtn.Position = UDim2.new(0, xOffset, 0, 42)
                ColorBtn.BackgroundColor3 = theme.Color
                ColorBtn.Text = ""
                ColorBtn.Parent = ThemeCard
                
                local ColorCorner = Instance.new("UICorner")
                ColorCorner.CornerRadius = UDim.new(1, 0)
                ColorCorner.Parent = ColorBtn

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Color3.fromRGB(10, 10, 10)
                BtnStroke.Thickness = 1
                BtnStroke.Parent = ColorBtn
                
                ColorBtn.MouseEnter:Connect(function() TweenObj(ColorBtn, {Size = UDim2.new(0, 38, 0, 38)}, 0.2) end)
                ColorBtn.MouseLeave:Connect(function() TweenObj(ColorBtn, {Size = UDim2.new(0, 35, 0, 35)}, 0.2) end)

                ColorBtn.MouseButton1Click:Connect(function()
                    ThemeColor = theme.Color
                    TweenObj(HubStroke, {Color = ThemeColor}, 0.3)
                    TweenObj(MinStroke, {Color = ThemeColor}, 0.3)
                    TweenObj(MinButton, {TextColor3 = ThemeColor}, 0.3)
                    ScrollFrame.ScrollBarImageColor3 = ThemeColor
                    
                    for name, btn in pairs(TabButtons) do
                        if name == "Settings" then 
                            TweenObj(btn, {BackgroundColor3 = ThemeColor}, 0.3)
                        end
                    end
                end)
                xOffset = xOffset + 50
            end

            totalSettingsHeight = totalSettingsHeight + 95 + 8

            local ConfigCard = Instance.new("Frame")
            ConfigCard.Size = UDim2.new(0, 390, 0, 110)
            ConfigCard.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            ConfigCard.Parent = ScrollFrame

            local ConfigCorner = Instance.new("UICorner")
            ConfigCorner.CornerRadius = UDim.new(0, 4)
            ConfigCorner.Parent = ConfigCard

            local ConfigStroke = Instance.new("UIStroke")
            ConfigStroke.Color = Color3.fromRGB(35, 35, 35)
            ConfigStroke.Thickness = 1
            ConfigStroke.Parent = ConfigCard

            local ConfigTitle = Instance.new("TextLabel")
            ConfigTitle.Size = UDim2.new(1, 0, 0, 20)
            ConfigTitle.Position = UDim2.new(0, 15, 0, 10)
            ConfigTitle.BackgroundTransparency = 1
            ConfigTitle.Font = Enum.Font.GothamBold
            ConfigTitle.TextSize = 13
            ConfigTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
            ConfigTitle.TextXAlignment = Enum.TextXAlignment.Left
            ConfigTitle.Text = "SYSTEM CONTROLS"
            ConfigTitle.Parent = ConfigCard

            local DestroyBtn = Instance.new("TextButton")
            DestroyBtn.Size = UDim2.new(0, 170, 0, 30)
            DestroyBtn.Position = UDim2.new(0, 15, 0, 45)
            DestroyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            DestroyBtn.Font = Enum.Font.GothamMedium
            DestroyBtn.TextSize = 12
            DestroyBtn.TextColor3 = Color3.fromRGB(200, 70, 70)
            DestroyBtn.Text = "Terminate Interface"
            DestroyBtn.Parent = ConfigCard

            local DestroyCorner = Instance.new("UICorner")
            DestroyCorner.CornerRadius = UDim.new(0, 4)
            DestroyCorner.Parent = DestroyBtn
            
            local DestroyStroke = Instance.new("UIStroke")
            DestroyStroke.Color = Color3.fromRGB(40, 20, 20)
            DestroyStroke.Parent = DestroyBtn

            DestroyBtn.MouseEnter:Connect(function() TweenObj(DestroyBtn, {BackgroundColor3 = Color3.fromRGB(200, 70, 70), TextColor3 = Color3.fromRGB(255,255,255)}, 0.2) end)
            DestroyBtn.MouseLeave:Connect(function() TweenObj(DestroyBtn, {BackgroundColor3 = Color3.fromRGB(25, 25, 25), TextColor3 = Color3.fromRGB(200, 70, 70)}, 0.2) end)

            DestroyBtn.MouseButton1Click:Connect(function()
                HubGui:Destroy()
            end)

            local RejoinBtn = Instance.new("TextButton")
            RejoinBtn.Size = UDim2.new(0, 170, 0, 30)
            RejoinBtn.Position = UDim2.new(1, -185, 0, 45)
            RejoinBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            RejoinBtn.Font = Enum.Font.GothamMedium
            RejoinBtn.TextSize = 12
            RejoinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            RejoinBtn.Text = "Reconnect Instance"
            RejoinBtn.Parent = ConfigCard

            local RejoinCorner = Instance.new("UICorner")
            RejoinCorner.CornerRadius = UDim.new(0, 4)
            RejoinCorner.Parent = RejoinBtn
            
            local RejoinStroke = Instance.new("UIStroke")
            RejoinStroke.Color = Color3.fromRGB(35, 35, 35)
            RejoinStroke.Parent = RejoinBtn

            RejoinBtn.MouseEnter:Connect(function() TweenObj(RejoinBtn, {BackgroundColor3 = ThemeColor, TextColor3 = Color3.fromRGB(255,255,255)}, 0.2); TweenObj(RejoinStroke, {Color = ThemeColor}, 0.2) end)
            RejoinBtn.MouseLeave:Connect(function() TweenObj(RejoinBtn, {BackgroundColor3 = Color3.fromRGB(25, 25, 25), TextColor3 = Color3.fromRGB(200,200,200)}, 0.2); TweenObj(RejoinStroke, {Color = Color3.fromRGB(35,35,35)}, 0.2) end)

            RejoinBtn.MouseButton1Click:Connect(function()
                if #Players:GetPlayers() <= 1 then
                    Players.LocalPlayer:Kick("\nReconnecting...")
                    task.wait()
                    TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
                end
            end)

            totalSettingsHeight = totalSettingsHeight + 110 + 8
            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalSettingsHeight + 10)
            TweenObj(ContentArea, {GroupTransparency = 0}, 0.2)
            return
        end

        local totalElementsHeight = 0

        for _, scriptData in ipairs(scriptsList) do
            if scriptData.Category == selectedTabName then
                local Card = Instance.new("Frame")
                Card.Size = UDim2.new(0, 390, 0, 50)
                Card.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                Card.Parent = ScrollFrame

                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 4)
                CardCorner.Parent = Card

                local CardStroke = Instance.new("UIStroke")
                CardStroke.Color = Color3.fromRGB(30, 30, 30)
                CardStroke.Thickness = 1
                CardStroke.Parent = Card

                local NameLabel = Instance.new("TextLabel")
                NameLabel.Size = UDim2.new(0, 160, 0, 20)
                NameLabel.Position = UDim2.new(0, 15, 0, 7)
                NameLabel.BackgroundTransparency = 1
                NameLabel.Font = Enum.Font.GothamMedium
                NameLabel.TextSize = 13
                NameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
                NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                NameLabel.Text = scriptData.Name
                NameLabel.Parent = Card

                local CreditsLabel = Instance.new("TextLabel")
                CreditsLabel.Size = UDim2.new(0, 160, 0, 15)
                CreditsLabel.Position = UDim2.new(0, 15, 0, 26)
                CreditsLabel.BackgroundTransparency = 1
                CreditsLabel.Font = Enum.Font.Gotham
                CreditsLabel.TextSize = 10
                CreditsLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
                CreditsLabel.TextXAlignment = Enum.TextXAlignment.Left
                CreditsLabel.Text = "Author: " .. scriptData.Credits
                CreditsLabel.Parent = Card

                local StatusLabel = Instance.new("TextLabel")
                StatusLabel.Size = UDim2.new(0, 80, 0, 20)
                StatusLabel.Position = UDim2.new(0, 200, 0.5, -10)
                StatusLabel.BackgroundTransparency = 1
                StatusLabel.Font = Enum.Font.GothamMedium
                StatusLabel.TextSize = 10
                StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                if scriptData.Status == "Operational" then
                    StatusLabel.Text = "Operational"
                    StatusLabel.TextColor3 = Color3.fromRGB(100, 180, 120)
                else
                    StatusLabel.Text = "Maintenance"
                    StatusLabel.TextColor3 = Color3.fromRGB(180, 80, 80)
                end
                StatusLabel.Parent = Card

                local DiscordBtn = Instance.new("TextButton")
                DiscordBtn.Size = UDim2.new(0, 80, 0, 26)
                DiscordBtn.Position = UDim2.new(1, -95, 0.5, -13)
                DiscordBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                DiscordBtn.Font = Enum.Font.GothamMedium
                DiscordBtn.TextSize = 10
                DiscordBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
                DiscordBtn.Text = "Copy discord"
                DiscordBtn.ZIndex = 5 
                DiscordBtn.Parent = Card

                local DiscCorner = Instance.new("UICorner")
                DiscCorner.CornerRadius = UDim.new(0, 3)
                DiscCorner.Parent = DiscordBtn
                
                local DiscStroke = Instance.new("UIStroke")
                DiscStroke.Color = Color3.fromRGB(35, 35, 35)
                DiscStroke.Parent = DiscordBtn

                if scriptData.Discord == "N/A" then
                    DiscordBtn.Text = "Unavailable"
                    DiscordBtn.AutoButtonColor = false
                else
                    DiscordBtn.MouseEnter:Connect(function() TweenObj(DiscordBtn, {BackgroundColor3 = Color3.fromRGB(40, 40, 40), TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2) end)
                    DiscordBtn.MouseLeave:Connect(function() TweenObj(DiscordBtn, {BackgroundColor3 = Color3.fromRGB(25, 25, 25), TextColor3 = Color3.fromRGB(180, 180, 180)}, 0.2) end)

                    DiscordBtn.MouseButton1Click:Connect(function()
                        pcall(function() setclipboard(scriptData.Discord) end)
                        pcall(function()
                            StarterGui:SetCore("SendNotification", {
                                Title = "[ PORTAPAPELES ]",
                                Text = scriptData.Name .. " Discord copied.",
                                Duration = 3
                            })
                        end)
                    end)
                end

                local ExecTrigger = Instance.new("TextButton")
                ExecTrigger.Size = UDim2.new(1, -110, 1, 0)
                ExecTrigger.Position = UDim2.new(0, 0, 0, 0)
                ExecTrigger.BackgroundTransparency = 1
                ExecTrigger.Text = ""
                ExecTrigger.ZIndex = 2
                ExecTrigger.Parent = Card

                ExecTrigger.MouseEnter:Connect(function()
                    TweenObj(Card, {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}, 0.2)
                    TweenObj(CardStroke, {Color = ThemeColor}, 0.2)
                end)
                ExecTrigger.MouseLeave:Connect(function()
                    TweenObj(Card, {BackgroundColor3 = Color3.fromRGB(18, 18, 18)}, 0.2)
                    TweenObj(CardStroke, {Color = Color3.fromRGB(30, 30, 30)}, 0.2)
                end)

                ExecTrigger.MouseButton1Click:Connect(function()
                    if scriptData.Status ~= "Operational" then
                        pcall(function()
                            StarterGui:SetCore("SendNotification", {
                                Title = "[ ACCESS DENIED ]",
                                Text = scriptData.Name .. " is currently offline.",
                                Duration = 3
                            })
                        end)
                        return 
                    end

                    ToggleHub(false)
                    selectedScriptName = scriptData.Name
                    startLoadingScreenAndExecute(scriptData.Exec, scriptData.Name)
                end)
                
                totalElementsHeight = totalElementsHeight + 50 + 8
            end
        end
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalElementsHeight + 10)
        TweenObj(ContentArea, {GroupTransparency = 0}, 0.2)
    end

    for _, tabName in ipairs(TabNames) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.2, -5, 1, 0)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 11
        TabBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
        TabBtn.Text = tabName:upper()
        TabBtn.Parent = TabContainer

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 4)
        TabBtnCorner.Parent = TabBtn
        
        local TabBtnStroke = Instance.new("UIStroke")
        TabBtnStroke.Color = Color3.fromRGB(30, 30, 30)
        TabBtnStroke.Parent = TabBtn

        TabButtons[tabName] = TabBtn

        TabBtn.MouseButton1Click:Connect(function()
            LoadTab(tabName)
        end)
    end

    LoadTab("HUB's")

    local DisclaimerLabel = Instance.new("TextLabel")
    DisclaimerLabel.Size = UDim2.new(1, 0, 0, 20)
    DisclaimerLabel.Position = UDim2.new(0, 0, 1, -25) 
    DisclaimerLabel.BackgroundTransparency = 1
    DisclaimerLabel.Font = Enum.Font.Gotham
    DisclaimerLabel.TextSize = 10
    DisclaimerLabel.TextColor3 = Color3.fromRGB(90, 90, 90)
    DisclaimerLabel.Text = "💎 Desarrollado por @DuelsHub | Discord: discord.gg/JTYZ7YMhh6"
    DisclaimerLabel.Parent = HubMain
end

-- ==============================================
-- SISTEMA DE INVITACIÓN AL DISCORD (POP-UP ANIMADO)
-- ==============================================
local function showDiscordInvite()
    local BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Size = 0
    BlurEffect.Parent = Lighting

    local InviteGui = Instance.new("ScreenGui")
    InviteGui.Name = "DuelsHub_DiscordInvite"
    InviteGui.IgnoreGuiInset = true
    InviteGui.ResetOnSpawn = false
    InviteGui.Parent = uiParent

    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BackgroundTransparency = 1
    Background.Parent = InviteGui

    local MainPanel = Instance.new("Frame")
    MainPanel.Size = UDim2.new(0, 0, 0, 0) -- Comienza en 0 para la animación "Pop"
    MainPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
    MainPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainPanel.ClipsDescendants = true
    MainPanel.Parent = Background

    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 8)
    PanelCorner.Parent = MainPanel

    local PanelStroke = Instance.new("UIStroke")
    PanelStroke.Color = Color3.fromRGB(100, 110, 120) -- Theme Color
    PanelStroke.Thickness = 1.5
    PanelStroke.Parent = MainPanel

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 20)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Text = "DUEL'S HUB"
    Title.Parent = MainPanel

    local SubTitle = Instance.new("TextLabel")
    SubTitle.Size = UDim2.new(1, -40, 0, 40)
    SubTitle.Position = UDim2.new(0, 20, 0, 60)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Font = Enum.Font.GothamMedium
    SubTitle.TextSize = 14
    SubTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    SubTitle.TextWrapped = true
    SubTitle.Text = "¡Bienvenido! Únete a nuestra comunidad de Discord para obtener soporte y actualizaciones."
    SubTitle.Parent = MainPanel

    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(0, 240, 0, 40)
    CopyBtn.Position = UDim2.new(0.5, -120, 0, 115)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Blurple oficial de Discord
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.TextSize = 14
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.Text = "Copiar Enlace de Discord"
    CopyBtn.Parent = MainPanel

    local CopyCorner = Instance.new("UICorner")
    CopyCorner.CornerRadius = UDim.new(0, 6)
    CopyCorner.Parent = CopyBtn

    local ContinueBtn = Instance.new("TextButton")
    ContinueBtn.Size = UDim2.new(0, 240, 0, 35)
    ContinueBtn.Position = UDim2.new(0.5, -120, 0, 165)
    ContinueBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ContinueBtn.Font = Enum.Font.GothamMedium
    ContinueBtn.TextSize = 13
    ContinueBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    ContinueBtn.Text = "Continuar al Hub"
    ContinueBtn.Parent = MainPanel

    local ContinueCorner = Instance.new("UICorner")
    ContinueCorner.CornerRadius = UDim.new(0, 6)
    ContinueCorner.Parent = ContinueBtn
    
    local ContinueStroke = Instance.new("UIStroke")
    ContinueStroke.Color = Color3.fromRGB(40, 40, 40)
    ContinueStroke.Parent = ContinueBtn

    -- Hover animations
    CopyBtn.MouseEnter:Connect(function() TweenObj(CopyBtn, {BackgroundColor3 = Color3.fromRGB(105, 116, 245)}, 0.2) end)
    CopyBtn.MouseLeave:Connect(function() TweenObj(CopyBtn, {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}, 0.2) end)
    ContinueBtn.MouseEnter:Connect(function() TweenObj(ContinueBtn, {BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2) end)
    ContinueBtn.MouseLeave:Connect(function() TweenObj(ContinueBtn, {BackgroundColor3 = Color3.fromRGB(25, 25, 25), TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.2) end)

    -- Animación de ENTRADA (Aparición fluida con rebote)
    TweenObj(BlurEffect, {Size = 20}, 0.6)
    TweenObj(Background, {BackgroundTransparency = 0.4}, 0.6)
    local popIn = TweenService:Create(MainPanel, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 340, 0, 225)})
    popIn:Play()

    -- Funcionalidad de Botones
    CopyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/JTYZ7YMhh6") end)
        CopyBtn.Text = "¡Enlace Copiado!"
        CopyBtn.BackgroundColor3 = Color3.fromRGB(67, 181, 129) -- Color Verde Éxito de Discord
        
        task.wait(2)
        CopyBtn.Text = "Copiar Enlace de Discord"
        CopyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    end)

    ContinueBtn.MouseButton1Click:Connect(function()
        -- Animación de SALIDA (Cierre)
        TweenObj(BlurEffect, {Size = 0}, 0.4)
        TweenObj(Background, {BackgroundTransparency = 1}, 0.4)
        local popOut = TweenService:Create(MainPanel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
        popOut:Play()
        popOut.Completed:Wait()

        InviteGui:Destroy()
        BlurEffect:Destroy()

        -- Iniciar el Hub Principal
        openMiniHub()
    end)
end

-- Ejecutamos la pantalla de Discord PRIMERO
showDiscordInvite()
