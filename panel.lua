--[[
    ⚡ ZERO PANEL v20 — สมบูรณ์แบบครบทุกฟังก์ชัน
    รหัสปลดล็อค: SiSi
]]

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")
local SoundService      = game:GetService("SoundService")
local Lighting          = game:GetService("Lighting")
local RunService        = game:GetService("RunService")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local VirtualUser       = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ════════════════════════ ตั้งค่า ════════════════════════
local CLICK_SOUND = "rbxassetid://876939830"
local THEME = {
    bgDark = Color3.fromRGB(18, 18, 20), bgPanel = Color3.fromRGB(24, 24, 27),
    bgCard = Color3.fromRGB(32, 32, 36), bgHover = Color3.fromRGB(45, 45, 50),
    text = Color3.fromRGB(255, 255, 255), subtext = Color3.fromRGB(150, 150, 160),
    accent = Color3.fromRGB(255, 255, 255), border = Color3.fromRGB(50, 50, 55),
    on = Color3.fromRGB(70, 220, 120), danger = Color3.fromRGB(255, 80, 80)
}

-- ⭐ ระบบจำค่า (Persist Config)
local CONFIG_FILE = "ZeroPanel_Config.json"
local config = { speedOn = false, autoLoopOn = false, antiAfkOn = false }
local function saveConfig() pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(config)) end) end
local function loadConfig()
    local ok, data = pcall(function() return readfile(CONFIG_FILE) end)
    if ok and data and data ~= "" then
        local ok2, parsed = pcall(function() return HttpService:JSONDecode(data) end)
        if ok2 and parsed then for k, v in pairs(parsed) do config[k] = v end end
    end
end
loadConfig()

-- ⭐ ระบบภาษา
local currentLang = "th"
local Trans = {
    ["th"] = { Main="Main", Mic="Mic", Setting="Setting", Farm="ฟาร์ม", FarmDesc="วาร์ปไปจุดฟาร์ม", Win="วิน", WinDesc="วาร์ปไปจุดวิน", Loop="Auto Loop", LoopDesc="สแปม Speed + Scare 0.1 วิ", Sell="Sell All", SellDesc="ขายของทั้งหมด", Speed="Speed Boost", SpeedDesc="ความเร็ว 900", Noclip="Noclip", NoclipDesc="เดินทะลุกำแพง", Jump="Inf Jump", JumpDesc="กระโดดไม่จำกัด", Hop="Server Hop", HopDesc="สุ่มเซิร์ฟเวอร์ใหม่", Rejoin="Rejoin", RejoinDesc="กลับเซิร์ฟเวอร์เดิม", Shadow="Shadow", ShadowDesc="เปิด/ปิด เงา", Bloom="Bloom", BloomDesc="เปิด/ปิด แสงฟุ้ง", Afk="Anti-AFK", AfkDesc="กันเตะตอนยืนนิ่ง", Lang="ภาษา / Language", LangDesc="เปลี่ยนภาษาของเมนู" },
    ["en"] = { Main="Main", Mic="Mic", Setting="Setting", Farm="Farm", FarmDesc="Warp to Farm", Win="Win", WinDesc="Warp to Win", Loop="Auto Loop", LoopDesc="Spam Speed + Scare 0.1s", Sell="Sell All", SellDesc="Sell all items", Speed="Speed Boost", SpeedDesc="Speed 900", Noclip="Noclip", NoclipDesc="Walk through walls", Jump="Inf Jump", JumpDesc="Infinite jump", Hop="Server Hop", HopDesc="Find new server", Rejoin="Rejoin", RejoinDesc="Back to same server", Shadow="Shadow", ShadowDesc="Toggle shadows", Bloom="Bloom", BloomDesc="Toggle bloom", Afk="Anti-AFK", AfkDesc="Prevent idle kick", Lang="Language / ภาษา", LangDesc="Change menu language" }
}
local L = function(key) return Trans[currentLang][key] or key end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local VALID_KEYS = { ["SiSi"] = true }

local function playSound(id, vol, pitch)
    local s = Instance.new("Sound")
    s.SoundId = id; s.Volume = vol or 0.4; s.PlaybackSpeed = pitch or 1
    s.Parent = SoundService; s:Play()
    task.delay(3, function() if s then s:Destroy() end end)
end

-- ⭐ ระบบ Anti-AFK
local antiAfkActive = false
local antiAfkThread = nil
local function startAntiAfk()
    if antiAfkThread then return end
    antiAfkActive = true
    antiAfkThread = task.spawn(function()
        while antiAfkActive do
            pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
            task.wait(60)
        end
        antiAfkThread = nil
    end)
end
local function stopAntiAfk() antiAfkActive = false; antiAfkThread = nil end
pcall(function()
    player.Idled:Connect(function()
        if antiAfkActive then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end
    end)
end)

-- ══════════ 1. หน้า Login ══════════
for _, parent in ipairs({playerGui, CoreGui}) do
    local ok, old = pcall(function() return parent:FindFirstChild("ZeroPanel") end)
    if ok and old then old:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "ZeroPanel"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
local okCore = pcall(function() gui.Parent = CoreGui end)
if not okCore then gui.Parent = playerGui end

local loginFrame = Instance.new("Frame")
loginFrame.Size = UDim2.fromOffset(280, 180)
loginFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
loginFrame.BackgroundColor3 = THEME.bgDark
loginFrame.Parent = gui
Instance.new("UICorner", loginFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", loginFrame).Color = THEME.border

local loginTitle = Instance.new("TextLabel")
loginTitle.Size = UDim2.new(1, 0, 0, 40)
loginTitle.BackgroundTransparency = 1
loginTitle.Font = Enum.Font.GothamBold
loginTitle.TextSize = 16
loginTitle.TextColor3 = THEME.text
loginTitle.Text = "🔑 กรุณาใส่คีย์เพื่อใช้งาน"
loginTitle.Parent = loginFrame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -40, 0, 35)
keyBox.Position = UDim2.fromOffset(20, 50)
keyBox.BackgroundColor3 = THEME.bgCard
keyBox.TextColor3 = THEME.text
keyBox.PlaceholderText = "ใส่คีย์ที่นี่..."
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 13
keyBox.Parent = loginFrame
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 6)

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -40, 0, 20)
statusLbl.Position = UDim2.fromOffset(20, 90)
statusLbl.BackgroundTransparency = 1
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 11
statusLbl.TextColor3 = THEME.danger
statusLbl.Text = ""
statusLbl.Parent = loginFrame

local confirmBtn = Instance.new("TextButton")
confirmBtn.Size = UDim2.new(1, -40, 0, 35)
confirmBtn.Position = UDim2.fromOffset(20, 120)
confirmBtn.BackgroundColor3 = THEME.accent
confirmBtn.Text = "ยืนยันคีย์"
confirmBtn.TextColor3 = Color3.fromRGB(0,0,0)
confirmBtn.Font = Enum.Font.GothamBold
confirmBtn.TextSize = 14
confirmBtn.Parent = loginFrame
Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 6)

local mainUI_Open = nil

confirmBtn.MouseButton1Click:Connect(function()
    local key = keyBox.Text
    if key == "" then statusLbl.Text = "❌ กรุณาใส่คีย์"; return end
    
    statusLbl.Text = "⏳ กำลังตรวจสอบ..."
    statusLbl.TextColor3 = THEME.subtext
    task.wait(0.5)
    
    if VALID_KEYS[key] then
        statusLbl.Text = "✅ ยืนยันสำเร็จ!"
        statusLbl.TextColor3 = THEME.on
        playSound(CLICK_SOUND, 0.6, 1.2)
        task.wait(0.5)
        loginFrame.Visible = false
        if mainUI_Open then mainUI_Open() end
    else
        statusLbl.Text = "❌ ไม่มีคีย์นี้ในระบบ"
        statusLbl.TextColor3 = THEME.danger
    end
end)

-- ══════════ 2. หน้า Panel หลัก ══════════
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(420, 320)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
mainFrame.BackgroundColor3 = THEME.bgDark
mainFrame.Parent = gui
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", mainFrame).Color = THEME.border

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.fromOffset(12, 0)
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextColor3 = THEME.text
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Text = "⚡ Zero Panel v20"
titleText.Parent = titleBar

local creditLbl = Instance.new("TextLabel")
creditLbl.Size = UDim2.new(1, 0, 0, 20)
creditLbl.Position = UDim2.new(0, 0, 0, 36)
creditLbl.BackgroundTransparency = 1
creditLbl.Font = Enum.Font.Gotham
creditLbl.TextSize = 11
creditLbl.TextColor3 = THEME.subtext
creditLbl.Text = "Create By: SiSi_88929"
creditLbl.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(24, 24)
closeBtn.Position = UDim2.new(1, -36, 0.5, -12)
closeBtn.BackgroundColor3 = THEME.bgCard
closeBtn.Text = "✕"; closeBtn.TextColor3 = THEME.text; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 12
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

local function makeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end
makeDraggable(mainFrame, titleBar)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 110, 1, -66)
sidebar.Position = UDim2.fromOffset(8, 60)
sidebar.BackgroundTransparency = 1
sidebar.Parent = mainFrame
Instance.new("UIListLayout", sidebar).Padding = UDim.new(0, 6)

local actionArea = Instance.new("Frame")
actionArea.Size = UDim2.new(1, -126, 1, -66)
actionArea.Position = UDim2.fromOffset(118, 60)
actionArea.BackgroundColor3 = THEME.bgPanel
actionArea.BackgroundTransparency = 0.3
actionArea.Parent = mainFrame
Instance.new("UICorner", actionArea).CornerRadius = UDim.new(0, 8)

local actionScroll = Instance.new("ScrollingFrame")
actionScroll.Size = UDim2.new(1, -10, 1, -10)
actionScroll.Position = UDim2.fromOffset(5, 5)
actionScroll.BackgroundTransparency = 1
actionScroll.ScrollBarThickness = 3
actionScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
actionScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
actionScroll.Parent = actionArea
Instance.new("UIListLayout", actionScroll).Padding = UDim.new(0, 6)

local tabs = {}
local function createActionBtn(title, desc, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 0, 0, 45)
    btn.BackgroundColor3 = THEME.bgCard
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.LayoutOrder = order
    btn.Parent = actionScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -10, 0, 18); lbl.Position = UDim2.fromOffset(10, 5)
    lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
    lbl.TextColor3 = THEME.text; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text = title

    local sub = Instance.new("TextLabel", btn)
    sub.Size = UDim2.new(1, -10, 0, 14); sub.Position = UDim2.new(0, 10, 1, -18)
    sub.BackgroundTransparency = 1; sub.Font = Enum.Font.Gotham; sub.TextSize = 10
    sub.TextColor3 = THEME.subtext; sub.TextXAlignment = Enum.TextXAlignment.Left; sub.Text = desc

    task.delay((order or 0) * 0.05, function()
        TweenService:Create(btn, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 0}):Play()
    end)
    btn.MouseButton1Down:Connect(function() TweenService:Create(btn, TweenInfo.new(0.08), {Size = UDim2.new(0.95, 0, 0, 43), BackgroundColor3 = THEME.bgHover}):Play() end)
    btn.MouseButton1Up:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = btn:GetAttribute("ToggleColor") or THEME.bgCard}):Play() end)
    btn.MouseButton1Click:Connect(function() playSound(CLICK_SOUND, 0.5, 1); if callback then callback(btn) end end)
    return btn, lbl
end

local function switchTab(tabName)
    for name, btn in pairs(tabs) do
        TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundColor3 = name == tabName and THEME.text or Color3.fromRGB(0,0,0), BackgroundTransparency = name == tabName and 0 or 1, TextColor3 = name == tabName and Color3.fromRGB(0,0,0) or THEME.subtext}):Play()
    end
    for _, child in ipairs(actionScroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end
    end

    -- ═══════════ หน้า MAIN ═══════════
    if tabName == "Main" then
        createActionBtn("🌾 "..L("Farm"), L("FarmDesc"), 1, function() 
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(2648, 0, 71.59) 
            end
        end)
        createActionBtn("🏆 "..L("Win"), L("WinDesc"), 2, function() 
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(57.46, 3.16, -3.45) 
            end
        end)
        
        createActionBtn("💰 "..L("Sell"), L("SellDesc"), 3, function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local sellRemote = remotes and remotes:FindFirstChild("SellAll")
            if sellRemote then pcall(function() sellRemote:InvokeServer() end) end
        end)

        local loopOn = config.autoLoopOn or false
        local loopBtn = createActionBtn("🔁 "..L("Loop"), L("LoopDesc"), 4, function(btn)
            loopOn = not loopOn
            config.autoLoopOn = loopOn; saveConfig()
            btn:SetAttribute("ToggleColor", loopOn and THEME.on or THEME.bgCard)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = loopOn and THEME.on or THEME.bgCard}):Play()
            
            if loopOn then
                task.spawn(function()
                    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                    local trainStep = remotes and remotes:FindFirstChild("TrainStep")
                    while loopOn do
                        if trainStep then pcall(function() trainStep:FireServer("Speed"); trainStep:FireServer("Scare") end) end
                        task.wait(0.1)
                    end
                end)
            end
        end)
        if loopOn then loopBtn:SetAttribute("ToggleColor", THEME.on); loopBtn.BackgroundColor3 = THEME.on end

    -- ═══════════ หน้า MIC ═══════════
    elseif tabName == "Mic" then
        local speedOn = config.speedOn or false
        local speedBtn = createActionBtn("⚡ "..L("Speed"), L("SpeedDesc"), 1, function(btn)
            speedOn = not speedOn
            config.speedOn = speedOn; saveConfig()
            btn:SetAttribute("ToggleColor", speedOn and THEME.on or THEME.bgCard)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = speedOn and THEME.on or THEME.bgCard}):Play()
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = speedOn and 900 or 16 end
        end)
        if speedOn then speedBtn:SetAttribute("ToggleColor", THEME.on); speedBtn.BackgroundColor3 = THEME.on end

        local noclipOn = false
        createActionBtn("👻 "..L("Noclip"), L("NoclipDesc"), 2, function(btn)
            noclipOn = not noclipOn
            btn:SetAttribute("ToggleColor", noclipOn and THEME.on or THEME.bgCard)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = noclipOn and THEME.on or THEME.bgCard}):Play()
            if noclipOn then
                task.spawn(function()
                    while noclipOn do
                        if player.Character then
                            for _, v in pairs(player.Character:GetDescendants()) do
                                if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                            end
                        end
                        RunService.Stepped:Wait()
                    end
                end)
            end
        end)

        local jumpOn = false
        createActionBtn("🦘 "..L("Jump"), L("JumpDesc"), 3, function(btn)
            jumpOn = not jumpOn
            btn:SetAttribute("ToggleColor", jumpOn and THEME.on or THEME.bgCard)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = jumpOn and THEME.on or THEME.bgCard}):Play()
        end)
        UserInputService.JumpRequest:Connect(function()
            if jumpOn and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)

    -- ═══════════ หน้า SETTING ═══════════
    elseif tabName == "Setting" then
        createActionBtn("🌐 "..L("Lang"), L("LangDesc").." (TH/EN)", 1, function(btn)
            currentLang = currentLang == "th" and "en" or "th"
            switchTab("Setting")
        end)

        createActionBtn("🌐 "..L("Hop"), L("HopDesc"), 2, function()
            pcall(function()
                local res = HttpService:JSONDecode(game:HttpGet(string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=100", game.PlaceId)))
                for _, s in ipairs(res.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player); break
                    end
                end
            end)
        end)
        
        createActionBtn("🔄 "..L("Rejoin"), L("RejoinDesc"), 3, function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end)

        local shadowOn = true
        createActionBtn("🌑 "..L("Shadow"), L("ShadowDesc"), 4, function(btn)
            shadowOn = not shadowOn
            btn:SetAttribute("ToggleColor", shadowOn and THEME.on or THEME.bgCard)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = shadowOn and THEME.on or THEME.bgCard}):Play()
            Lighting.GlobalShadows = shadowOn
        end)

        local bloomOn = true
        createActionBtn("✨ "..L("Bloom"), L("BloomDesc"), 5, function(btn)
            bloomOn = not bloomOn
            btn:SetAttribute("ToggleColor", bloomOn and THEME.on or THEME.bgCard)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = bloomOn and THEME.on or THEME.bgCard}):Play()
            local b = Lighting:FindFirstChildOfClass("BloomEffect")
            if not b and bloomOn then b = Instance.new("BloomEffect", Lighting) end
            if b then b.Enabled = bloomOn end
        end)

        local afkOn = config.antiAfkOn or false
        local afkBtn = createActionBtn("🛡️ "..L("Afk"), L("AfkDesc"), 6, function(btn)
            afkOn = not afkOn
            config.antiAfkOn = afkOn; saveConfig()
            btn:SetAttribute("ToggleColor", afkOn and THEME.on or THEME.bgCard)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = afkOn and THEME.on or THEME.bgCard}):Play()
            if afkOn then startAntiAfk() else stopAntiAfk() end
        end)
        if afkOn then afkBtn:SetAttribute("ToggleColor", THEME.on); afkBtn.BackgroundColor3 = THEME.on end
    end
end

local function createSidebarBtn(name, display, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. icon .. "  " .. display
    btn.TextColor3 = THEME.subtext; btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() playSound(CLICK_SOUND, 0.4, 1.1); switchTab(name) end)
    tabs[name] = btn
end
createSidebarBtn("Main", "Main", "⌂")
createSidebarBtn("Mic", "Mic", "⚡")
createSidebarBtn("Setting", "Setting", "⚙")

mainUI_Open = function()
    mainFrame.Visible = true
    mainFrame.Size = UDim2.fromOffset(0, 0)
    TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(420, 320)}):Play()
    switchTab("Main")
    
    -- ⭐ เช็คค่า Config ตอนเปิด UI ครั้งแรก
    task.defer(function()
        task.wait(0.5)
        if config.antiAfkOn then startAntiAfk() end
        if config.speedOn then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 900 end
        end
    end)
end

local showBtn = Instance.new("TextButton")
showBtn.Size = UDim2.fromOffset(50, 50)
showBtn.Position = UDim2.new(0, 20, 0.5, -25)
showBtn.BackgroundColor3 = THEME.bgDark
showBtn.Text = "⚡"; showBtn.TextColor3 = THEME.text; showBtn.Font = Enum.Font.GothamBold; showBtn.TextSize = 24
showBtn.Visible = false
showBtn.Parent = gui
Instance.new("UICorner", showBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", showBtn).Color = THEME.border
makeDraggable(showBtn, showBtn)

closeBtn.MouseButton1Click:Connect(function()
    playSound(CLICK_SOUND, 0.6, 0.9)
    local tw = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(0, 0)})
    tw:Play(); tw.Completed:Connect(function() mainFrame.Visible = false; showBtn.Visible = true end)
end)
showBtn.MouseButton1Click:Connect(function()
    playSound(CLICK_SOUND, 0.6, 1.1)
    showBtn.Visible = false; mainUI_Open()
end)

print("[⚡ Zero Panel v20] โหลดสำเร็จ! ใส่คีย์ SiSi")