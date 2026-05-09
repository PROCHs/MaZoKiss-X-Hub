local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

local req = syn and syn.request or http_request or request

local TargetPlaceID = 93712201161812

local ConfigName = "MazokissConfig.json"

local Config = {
    AutoSkip = false,
    AutoQueue = false,
    AutoSummon = false,
    WhiteScreen = false,
    Webhook = "",
    SellBasic = false,
    SellUncommon = false,
    SellRare = false,
    SellEpic = false,
    SellLegendary = false
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
-- RARITY DETECTION
--========================

local function GetRarity(unit)
    local tf = unit:FindFirstChild("TroopsFrame")
    if not tf then return nil end
    local rg = tf:FindFirstChild("RarityGradient")
    if not rg then return nil end
    local colorStr = tostring(rg.Color)

    if colorStr:find("0.890196") then
        return "Basic"
    elseif colorStr:find("0.615686") then
        return "Legendary"
    elseif colorStr:find("0 0.85098 0") then
        return "Epic"
    elseif colorStr:find("0 0 0.85098") then
        return "Rare"
    elseif colorStr:find("0 0 1 0 0 1 0 0.694118 0 0") then
        return "Uncommon"
    end
    return nil
end

local function SellUnits()
    local lobby = player.PlayerGui:FindFirstChild("Lobby")
    if not lobby then
        Fluent:Notify({
            Title = "Sell",
            Content = "ไม่เจอ Lobby UI กรุณาอยู่ในล็อบบี้ก่อนครับ",
            Duration = 3
        })
        return
    end

    local unitFrame = lobby:FindFirstChild("UnitFrame")
    if not unitFrame then return end
    local unitList = unitFrame:FindFirstChild("UnitList")
    if not unitList then return end

    local totalSold = 0

    while true do
        local soldCount = 0

        for _, row in pairs(unitList:GetChildren()) do
            if row.Name:find("Row") then
                for _, unit in pairs(row:GetChildren()) do
                    if unit:IsA("Frame") then
                        local rarity = GetRarity(unit)
                        if rarity then
                            local shouldSell = (
                                (rarity == "Basic"     and Config.SellBasic) or
                                (rarity == "Uncommon"  and Config.SellUncommon) or
                                (rarity == "Rare"      and Config.SellRare) or
                                (rarity == "Epic"      and Config.SellEpic) or
                                (rarity == "Legendary" and Config.SellLegendary)
                            )
                            if shouldSell then
                                pcall(function()
                                    local args1 = {
                                        [1] = {
                                            [1] = {
                                                [1] = "\226\129\130E",
                                                [2] = { [1] = unit.Name }
                                            }
                                        }
                                    }
                                    local args2 = {
                                        [1] = {
                                            [1] = {
                                                [1] = "\226\129\130P",
                                                [2] = { [1] = unit.Name }
                                            }
                                        }
                                    }
                                    ReplicatedStorage.NetworkingContainer.DataRemote:FireServer(unpack(args1))
                                    wait(0.1)
                                    ReplicatedStorage.NetworkingContainer.DataRemote:FireServer(unpack(args2))
                                    soldCount = soldCount + 1
                                    wait(0.2)
                                end)
                            end
                        end
                    end
                end
            end
        end

        totalSold = totalSold + soldCount

        if soldCount == 0 then
            break
        end

        wait(0.5)
    end

    Fluent:Notify({
        Title = "Sell",
        Content = "ขายไปทั้งหมด " .. totalSold .. " ตัวครับ ✅",
        Duration = 3
    })
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
    Main     = Window:AddTab({ Title = "Main",     Icon = "home" }),
    Farm     = Window:AddTab({ Title = "Farm",     Icon = "sword" }),
    Sell     = Window:AddTab({ Title = "Sell",     Icon = "tag" }),
    Visual   = Window:AddTab({ Title = "Visual",   Icon = "monitor" }),
    Webhook  = Window:AddTab({ Title = "Webhook",  Icon = "globe" }),
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

local AutoSummonToggle = Tabs.Farm:AddToggle("AutoSummon", {
    Title = "Auto Summon",
    Description = "กด Summon ด้วยมือ 1 ครั้งก่อนเปิดครับ",
    Default = Config.AutoSummon
})
AutoSummonToggle:OnChanged(function()
    Config.AutoSummon = Options.AutoSummon.Value
    SaveConfig()
end)

--========================
-- SELL TAB
--========================

Tabs.Sell:AddParagraph({
    Title = "Sell Unit",
    Content = "เลือก Rarity ที่อยากขาย แล้วกด Sell Now"
})

local SellBasicToggle = Tabs.Sell:AddToggle("SellBasic", {
    Title = "Basic",
    Description = "ขาย Unit ระดับ Basic",
    Default = Config.SellBasic
})
SellBasicToggle:OnChanged(function()
    Config.SellBasic = Options.SellBasic.Value
    SaveConfig()
end)

local SellUncommonToggle = Tabs.Sell:AddToggle("SellUncommon", {
    Title = "Uncommon",
    Description = "ขาย Unit ระดับ Uncommon",
    Default = Config.SellUncommon
})
SellUncommonToggle:OnChanged(function()
    Config.SellUncommon = Options.SellUncommon.Value
    SaveConfig()
end)

local SellRareToggle = Tabs.Sell:AddToggle("SellRare", {
    Title = "Rare",
    Description = "ขาย Unit ระดับ Rare",
    Default = Config.SellRare
})
SellRareToggle:OnChanged(function()
    Config.SellRare = Options.SellRare.Value
    SaveConfig()
end)

local SellEpicToggle = Tabs.Sell:AddToggle("SellEpic", {
    Title = "Epic",
    Description = "ขาย Unit ระดับ Epic",
    Default = Config.SellEpic
})
SellEpicToggle:OnChanged(function()
    Config.SellEpic = Options.SellEpic.Value
    SaveConfig()
end)

local SellLegendaryToggle = Tabs.Sell:AddToggle("SellLegendary", {
    Title = "Legendary",
    Description = "ขาย Unit ระดับ Legendary",
    Default = Config.SellLegendary
})
SellLegendaryToggle:OnChanged(function()
    Config.SellLegendary = Options.SellLegendary.Value
    SaveConfig()
end)

Tabs.Sell:AddButton({
    Title = "Sell Now",
    Description = "ขาย Unit ที่เลือกทั้งหมดทันที",
    Callback = function()
        SellUnits()
    end
})

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
local SummonArgs = nil

local Remote = ReplicatedStorage.NetworkingContainer.DataRemote
local OldFire = Remote.FireServer
Remote.FireServer = function(self, ...)
    local args = {...}
    if args[1] and args[1][1] and args[1][1][1] == "\226\129\130J" then
        SummonArgs = args
    end
    return OldFire(self, ...)
end

-- Auto Skip Loop
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

-- Auto Queue Loop
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

-- Auto Summon Loop
spawn(function()
    while true do
        wait(1)
        if Options.AutoSummon.Value then
            if SummonArgs then
                pcall(function()
                    Remote:FireServer(unpack(SummonArgs))
                end)
            else
                Fluent:Notify({
                    Title = "Auto Summon",
                    Content = "กรุณากด Summon ด้วยมือ 1 ครั้งก่อนครับ",
                    Duration = 3
                })
                wait(5)
            end
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

-- เช็คแมพตอนโหลด
task.spawn(function()
    wait(3)
    if game.PlaceId ~= TargetPlaceID then
        Fluent:Notify({
            Title = "Teleport",
            Content = "กำลังเข้าแมพ TTD...",
            Duration = 3
        })
        wait(2)
        TeleportService:Teleport(TargetPlaceID)
    elseif workspace:FindFirstChild("Lifts") then
        Fluent:Notify({
            Title = "✅ ล็อบบี้",
            Content = "อยู่ในล็อบบี้แล้วครับ",
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "⚔️ In Game",
            Content = "กำลังเล่นอยู่ ไม่ Teleport ครับ",
            Duration = 3
        })
    end
end)
