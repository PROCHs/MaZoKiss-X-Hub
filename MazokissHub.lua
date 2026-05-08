local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

local req = syn and syn.request or http_request or request

local ConfigName = "MazokissConfig.json"

local Config = {
    AutoSkip = false,
    AutoQueue = false,
    AutoSummon = false,
    WhiteScreen = false,
    Webhook = ""
}

pcall(function()
    if readfile and isfile and isfile(ConfigName) then
        Config = HttpService:JSONDecode(readfile(ConfigName))
    end
end)

local function SaveConfig()
    pcall(function()
        if writefile then
            writefile(ConfigName, HttpService:JSONEncode(Config))
        end
    end)
end

--========================
-- WHITE SCREEN
--========================

local function ApplyWhiteScreen()
    pcall(function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
            end
            if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
            if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") then
                v.Enabled = false
            end
        end

        Lighting.GlobalShadows = false
        Lighting.FogEnd = 999999999
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 10
        Lighting.ClockTime = 12
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

        local old = player.PlayerGui:FindFirstChild("WhiteScreenGui")
        if old then old:Destroy() end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "WhiteScreenGui"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = player.PlayerGui

        local bg = Instance.new("Frame")
        bg.Size = UDim2.fromScale(1, 1)
        bg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        bg.BackgroundTransparency = 0
        bg.BorderSizePixel = 0
        bg.ZIndex = 1
        bg.Parent = screenGui

        local card = Instance.new("Frame")
        card.Size = UDim2.fromOffset(600, 200)
        card.Position = UDim2.new(0.5, -300, 0.5, -100)
        card.BackgroundTransparency = 1
        card.BorderSizePixel = 0
        card.ZIndex = 2
        card.Parent = screenGui

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0.55, 0)
        title.Position = UDim2.fromScale(0, 0)
        title.BackgroundTransparency = 1
        title.Text = "MaZoKiss Hub"
        title.TextColor3 = Color3.fromRGB(0, 0, 0)
        title.TextScaled = true
        title.Font = Enum.Font.FredokaOne
        title.ZIndex = 3
        title.Parent = card

        local line = Instance.new("Frame")
        line.Size = UDim2.new(0.85, 0, 0, 3)
        line.Position = UDim2.new(0.075, 0, 0.58, 0)
        line.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
        line.BorderSizePixel = 0
        line.ZIndex = 3
        line.Parent = card

        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, 0, 0.38, 0)
        status.Position = UDim2.new(0, 0, 0.62, 0)
        status.BackgroundTransparency = 1
        status.Text = "🌾 Now Farming..."
        status.TextColor3 = Color3.fromRGB(0, 0, 0)
        status.TextScaled = true
        status.Font = Enum.Font.FredokaOne
        status.ZIndex = 3
        status.Parent = card
    end)
end

local function RemoveWhiteScreen()
    pcall(function()
        local gui = player.PlayerGui:FindFirstChild("WhiteScreenGui")
        if gui then gui:Destroy() end
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = true
    end)
end

--========================
-- FLUENT UI
--========================

local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()
local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
))()
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

local Window = Fluent:CreateWindow({
    Title = "MaZoKiss X Hub",
    SubTitle = "Toilet Tower Defense",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "sword" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "monitor" }),
    Webhook = Window:AddTab({ Title = "Webhook", Icon = "webhook" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

--========================
-- MAIN TAB
--========================

Tabs.Main:AddParagraph({
    Title = "MaZoKiss X Hub",
    Content = "Toilet Tower Defense Farm Script"
})

Tabs.Main:AddParagraph({
    Title = "Toggle UI",
    Content = "กด LeftCtrl เพื่อเปิด/ปิด UI"
})

--========================
-- FARM TAB
--========================

Tabs.Farm:AddParagraph({
    Title = "Farm",
    Content = "ฟังชั่นสำหรับ Farm อัตโนมัติ"
})

local AutoSkipToggle = Tabs.Farm:AddToggle("AutoSkip", {
    Title = "Auto Skip",
    Description = "Skip Wave อัตโนมัติ",
    Default = Config.AutoSkip
})

AutoSkipToggle:OnChanged(function()
    Config.AutoSkip = Options.AutoSkip.Value
    SaveConfig()
end)

local AutoQueueToggle = Tabs.Farm:AddToggle("AutoQueue", {
    Title = "Auto Queue",
    Description = "วาปเข้า Lift อัตโนมัติ",
    Default = Config.AutoQueue
})

AutoQueueToggle:OnChanged(function()
    Config.AutoQueue = Options.AutoQueue.Value
    SaveConfig()
end)

-- ✅ เพิ่ม Auto Summon
local AutoSummonToggle = Tabs.Farm:AddToggle("AutoSummon", {
    Title = "Auto Summon",
    Description = "Summon อัตโนมัติ",
    Default = Config.AutoSummon
})

AutoSummonToggle:OnChanged(function()
    Config.AutoSummon = Options.AutoSummon.Value
    SaveConfig()
end)

--========================
-- VISUAL TAB
--========================

Tabs.Visual:AddParagraph({
    Title = "Visual / FPS",
    Content = "ปรับกราฟฟิคเพื่อเพิ่ม FPS"
})

local WhiteScreenToggle = Tabs.Visual:AddToggle("WhiteScreen", {
    Title = "White Screen / FPS Boost",
    Description = "ลด Graphic และทำให้จอขาวเพิ่ม FPS",
    Default = Config.WhiteScreen
})

WhiteScreenToggle:OnChanged(function()
    Config.WhiteScreen = Options.WhiteScreen.Value
    SaveConfig()
    if Config.WhiteScreen then
        ApplyWhiteScreen()
    else
        RemoveWhiteScreen()
    end
end)

--========================
-- WEBHOOK TAB
--========================

Tabs.Webhook:AddInput("WebhookURL", {
    Title = "Webhook URL",
    Default = Config.Webhook,
    Placeholder = "https://discord.com/api/webhooks/...",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        Config.Webhook = Value
        SaveConfig()
    end
})

Tabs.Webhook:AddButton({
    Title = "Test Webhook",
    Description = "ส่งข้อความทดสอบไปยัง Discord",
    Callback = function()
        if Config.Webhook == "" then
            Fluent:Notify({
                Title = "Error",
                Content = "กรุณาใส่ Webhook URL ก่อนครับ",
                Duration = 3
            })
            return
        end
        pcall(function()
            req({
                Url = Config.Webhook,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({
                    ["content"] = "✅ Webhook Connected : " .. player.Name
                })
            })
        end)
        Fluent:Notify({
            Title = "Webhook",
            Content = "ส่ง Test สำเร็จครับ ✅",
            Duration = 3
        })
    end
})

--========================
-- SETTINGS TAB
--========================

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("MaZoKissHub")
SaveManager:SetFolder("MaZoKissHub/TTD")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

--========================
-- LOOPS
--========================

local sentLobby = false

spawn(function()
    while true do
        wait(5)
        if Options.AutoSkip.Value then
            if not workspace:FindFirstChild("Lifts") then
                local args = {
                    [1] = {
                        [1] = {
                            [1] = "\226\129\130("
                        }
                    }
                }
                ReplicatedStorage
                    .NetworkingContainer
                    .DataRemote
                    :FireServer(unpack(args))
            end
        end
    end
end)

spawn(function()
    while true do
        wait(2)
        if Options.AutoQueue.Value then
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:WaitForChild("Humanoid")

            if workspace:FindFirstChild("Lifts") then
                if not sentLobby then
                    sentLobby = true
                    pcall(function()
                        if Config.Webhook ~= "" then
                            local coins = player.leaderstats.Coins.Value
                            local data = {
                                ["embeds"] = {
                                    {
                                        ["title"] = "MaZoKiss X Hub | Toilet Tower Defense",
                                        ["color"] = 16711680,
                                        ["description"] =
                                            "**-> Profile :**\n" ..
                                            "┃ Username : `" .. player.Name .. "`\n\n" ..
                                            "**-> Coins Collected Result :**\n" ..
                                            "┃ Coins : `" .. tostring(coins) .. "`",
                                        ["footer"] = {
                                            ["text"] = "Status: กลับสู่ลอบบี้เรียบร้อย"
                                        }
                                    }
                                }
                            }
                            req({
                                Url = Config.Webhook,
                                Method = "POST",
                                Headers = { ["Content-Type"] = "application/json" },
                                Body = HttpService:JSONEncode(data)
                            })
                        end
                    end)
                end

                hrp.CFrame = workspace.Lifts.ToiletHQ.Base.CFrame + Vector3.new(0, 3, 0)
                wait(30)

                if workspace:FindFirstChild("Lifts") then
                    humanoid.Health = 0
                    wait(8)
                end
            else
                sentLobby = false
            end
        end
    end
end)

-- ✅ Loop Auto Summon
spawn(function()
    while true do
        wait(1)
        if Options.AutoSummon.Value then
            pcall(function()
                local args = {
                    [1] = {
                        [1] = {
                            [1] = "\226\129\130J"
                        }
                    }
                }
                ReplicatedStorage
                    .NetworkingContainer
                    .DataRemote
                    :FireServer(unpack(args))
            end)
        end
    end
end)

--========================
-- AUTO LOAD
--========================

if Config.WhiteScreen then
    ApplyWhiteScreen()
end

Window:SelectTab(1)

Fluent:Notify({
    Title = "MaZoKiss Hub",
    Content = "โหลด Config สำเร็จครับ ✅ | กด LeftCtrl เพื่อซ่อน/แสดง UI",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
