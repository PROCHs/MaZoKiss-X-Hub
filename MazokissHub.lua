local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VIS = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local req = syn and syn.request or http_request or request

local ConfigName = "MazokissConfig.json"

local Config = {
    AutoSkip = false,
    AutoQueue = false,
    AutoSummon = false,
    WhiteScreen = false,
    AutoHide = false,
    Webhook = "",
    SellBasic = false,
    SellUncommon = false,
    SellRare = false,
    SellEpic = false,
    SellLegendary = false,
    SellMythic = false
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

local function ToggleUI()
    VIS:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
    task.wait(0.1)
    VIS:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
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
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Brightness = 2
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

    if colorStr:find("0.890196") then return "Basic"
    elseif colorStr:find("0.615686") then return "Legendary"
    elseif colorStr:find("0 0.85098 0") then return "Epic"
    elseif colorStr:find("0 0 0.85098") then return "Rare"
    elseif colorStr:find("0 0 1 0 0 1 0 0.694118") then return "Uncommon"
    elseif colorStr:find("0 1 0 0") then return "Mythic"
    end
    return nil
end

local SellCmd = nil

local function SellUnits()
    if not SellCmd then
        Fluent:Notify({
            Title = "Sell",
            Content = "กรุณากด Sell ด้วยมือ 1 ครั้งก่อนครับ",
            Duration = 3
        })
        return
    end

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

    local sellList = {}

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
                            (rarity == "Legendary" and Config.SellLegendary) or
                            (rarity == "Mythic"    and Config.SellMythic)
                        )
                        if shouldSell then
                            table.insert(sellList, unit.Name)
                        end
                    end
                end
            end
        end
    end

    if #sellList == 0 then
        Fluent:Notify({
            Title = "Sell",
            Content = "ไม่มี Unit ที่ต้องขายครับ",
            Duration = 3
        })
        return
    end

    pcall(function()
        local args = {
            [1] = {
                [1] = {
                    [1] = SellCmd,
                    [2] = sellList
                }
            }
        }
        ReplicatedStorage.NetworkingContainer.DataRemote:FireServer(unpack(args))
    end)

    Fluent:Notify({
        Title = "Sell",
        Content = "ขายไปทั้งหมด " .. #sellList .. " ตัวครับ ✅",
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

Tabs.Main:AddButton({
    Title = "Toggle UI",
    Description = "เปิด/ปิด UI",
    Callback = function()
        ToggleUI()
    end
})

Tabs.Main:AddToggle("AutoHide", {
    Title = "Auto Hide UI",
    Description = "ซ่อน UI อัตโนมัติตอนโหลดสคริปต์",
    Default = Config.AutoHide
}):OnChanged(function()
    Config.AutoHide = Options.AutoHide.Value
    SaveConfig()
end)

--========================
-- FARM TAB
--========================

Tabs.Farm:AddParagraph({
    Title = "Farm",
    Content = "ฟังชั่นสำหรับ Farm อัตโนมัติ"
})

Tabs.Farm:AddToggle("AutoSkip", {
    Title = "Auto Skip",
    Description = "Skip Wave อัตโนมัติ",
    Default = Config.AutoSkip
}):OnChanged(function()
    Config.AutoSkip = Options.AutoSkip.Value
    SaveConfig()
end)

Tabs.Farm:AddToggle("AutoQueue", {
    Title = "Auto Queue",
    Description = "วาปเข้า Lift อัตโนมัติ",
    Default = Config.AutoQueue
}):OnChanged(function()
    Config.AutoQueue = Options.AutoQueue.Value
    SaveConfig()
end)

Tabs.Farm:AddToggle("AutoSummon", {
    Title = "Auto Summon",
    Description = "กด Summon ด้วยมือ 1 ครั้งก่อนเปิดครับ",
    Default = Config.AutoSummon
}):OnChanged(function()
    Config.AutoSummon = Options.AutoSummon.Value
    SaveConfig()
end)

--========================
-- SELL TAB
--========================

Tabs.Sell:AddParagraph({
    Title = "Sell Unit",
    Content = "เลือก Rarity ที่อยากขาย แล้วกด Sell Now\nกด Sell ด้วยมือ 1 ครั้งก่อนใช้งานครับ"
})

Tabs.Sell:AddToggle("SellBasic", {
    Title = "Basic",
    Description = "ขาย Unit ระดับ Basic",
    Default = Config.SellBasic
}):OnChanged(function()
    Config.SellBasic = Options.SellBasic.Value
    SaveConfig()
end)

Tabs.Sell:AddToggle("SellUncommon", {
    Title = "Uncommon",
    Description = "ขาย Unit ระดับ Uncommon",
    Default = Config.SellUncommon
}):OnChanged(function()
    Config.SellUncommon = Options.SellUncommon.Value
    SaveConfig()
end)

Tabs.Sell:AddToggle("SellRare", {
    Title = "Rare",
    Description = "ขาย Unit ระดับ Rare",
    Default = Config.SellRare
}):OnChanged(function()
    Config.SellRare = Options.SellRare.Value
    SaveConfig()
end)

Tabs.Sell:AddToggle("SellEpic", {
    Title = "Epic",
    Description = "ขาย Unit ระดับ Epic",
    Default = Config.SellEpic
}):OnChanged(function()
    Config.SellEpic = Options.SellEpic.Value
    SaveConfig()
end)

Tabs.Sell:AddToggle("SellLegendary", {
    Title = "Legendary",
    Description = "ขาย Unit ระดับ Legendary",
    Default = Config.SellLegendary
}):OnChanged(function()
    Config.SellLegendary = Options.SellLegendary.Value
    SaveConfig()
end)

Tabs.Sell:AddToggle("SellMythic", {
    Title = "Mythic",
    Description = "ขาย Unit ระดับ Mythic",
    Default = Config.SellMythic
}):OnChanged(function()
    Config.SellMythic = Options.SellMythic.Value
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

Tabs.Visual:AddToggle("WhiteScreen", {
    Title = "White Screen / FPS Boost",
    Description = "ลด Graphic และทำให้จอขาวเพิ่ม FPS",
    Default = Config.WhiteScreen
}):OnChanged(function()
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

Tabs.Webhook:AddButton({
    Title = "Check Inventory",
    Description = "ส่งรายงาน Unit ในกระเป๋าไปยัง Discord",
    Callback = function()
        if Config.Webhook == "" then
            Fluent:Notify({
                Title = "Error",
                Content = "กรุณาใส่ Webhook URL ก่อนครับ",
                Duration = 3
            })
            return
        end

        local lobby = player.PlayerGui:FindFirstChild("Lobby")
        if not lobby then
            Fluent:Notify({
                Title = "Error",
                Content = "ไม่เจอ Lobby UI กรุณาอยู่ในล็อบบี้ก่อนครับ",
                Duration = 3
            })
            return
        end

        local unitList = lobby.UnitFrame.UnitList
        local count = {
            Basic = 0, Uncommon = 0, Rare = 0,
            Epic = 0, Legendary = 0, Mythic = 0
        }
        local total = 0

        for _, row in pairs(unitList:GetChildren()) do
            if row.Name:find("Row") then
                for _, unit in pairs(row:GetChildren()) do
                    if unit:IsA("Frame") then
                        local rarity = GetRarity(unit)
                        if rarity and count[rarity] ~= nil then
                            count[rarity] = count[rarity] + 1
                            total = total + 1
                        end
                    end
                end
            end
        end

        pcall(function()
            local data = {
                ["embeds"] = {
                    {
                        ["title"] = "MaZoKiss X Hub | Inventory Report",
                        ["color"] = 3447003,
                        ["description"] =
                            "**-> Profile :**\n" ..
                            "┃ Username : `" .. player.Name .. "`\n\n" ..
                            "**-> Unit ในกระเป๋า :**\n" ..
                            "┃ 🔵 Basic : `" .. count.Basic .. "`\n" ..
                            "┃ 🟢 Uncommon : `" .. count.Uncommon .. "`\n" ..
                            "┃ 🟣 Rare : `" .. count.Rare .. "`\n" ..
                            "┃ 🟠 Epic : `" .. count.Epic .. "`\n" ..
                            "┃ 🟡 Legendary : `" .. count.Legendary .. "`\n" ..
                            "┃ 🔴 Mythic : `" .. count.Mythic .. "`\n\n" ..
                            "┃ 📦 Total : `" .. total .. "`",
                        ["footer"] = {
                            ["text"] = "MaZoKiss X Hub"
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
        end)

        Fluent:Notify({
            Title = "Webhook",
            Content = "ส่ง Inventory Report สำเร็จครับ ✅",
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

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" and self == Remote then
        local args = {...}
        if args[1] and args[1][1] then
            local cmd = args[1][1][1]
            if cmd == "\226\129\130J" then
                SummonArgs = {unpack(args)}
            end
            if cmd ~= "\226\129\130J" and
               cmd ~= "\226\129\130(" and
               args[1][1][2] then
                SellCmd = cmd
            end
        end
    end
    return oldNamecall(self, ...)
end))

-- Auto Skip Loop
spawn(function()
    local lastVisible = false
    while true do
        wait(0.3)
        if Config.AutoSkip then
            pcall(function()
                local match = player.PlayerGui:FindFirstChild("Match")
                if match then
                    local tf = match:FindFirstChild("TopFrame")
                    local sw = tf and tf:FindFirstChild("SkipWave")
                    if sw then
                        if sw.Visible and not lastVisible then
                            Remote:FireServer(unpack({
                                [1] = { [1] = { [1] = "\226\129\130(" } }
                            }))
                        end
                        lastVisible = sw.Visible
                    end
                end
            end)
        end
    end
end)

-- Auto Queue Loop
spawn(function()
    while true do
        wait(2)
        if Config.AutoQueue then
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:WaitForChild("Humanoid")

            if workspace:FindFirstChild("Lifts") then
                if not sentLobby then
                    sentLobby = true
                    pcall(function()
                        if Config.Webhook ~= "" then
                            local coins = player.leaderstats.Coins.Value
                            local count = {
                                Basic = 0, Uncommon = 0, Rare = 0,
                                Epic = 0, Legendary = 0, Mythic = 0
                            }
                            local total = 0
                            local lobby = player.PlayerGui:FindFirstChild("Lobby")
                            if lobby then
                                local unitList = lobby.UnitFrame.UnitList
                                for _, row in pairs(unitList:GetChildren()) do
                                    if row.Name:find("Row") then
                                        for _, unit in pairs(row:GetChildren()) do
                                            if unit:IsA("Frame") then
                                                local rarity = GetRarity(unit)
                                                if rarity and count[rarity] ~= nil then
                                                    count[rarity] = count[rarity] + 1
                                                    total = total + 1
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            local data = {
                                ["embeds"] = {
                                    {
                                        ["title"] = "MaZoKiss X Hub | Toilet Tower Defense",
                                        ["color"] = 16711680,
                                        ["description"] =
                                            "**-> Profile :**\n" ..
                                            "┃ Username : `" .. player.Name .. "`\n\n" ..
                                            "**-> Coins Collected Result :**\n" ..
                                            "┃ Coins : `" .. tostring(coins) .. "`\n\n" ..
                                            "**-> Unit ในกระเป๋า :**\n" ..
                                            "┃ 🔵 Basic : `" .. count.Basic .. "`\n" ..
                                            "┃ 🟢 Uncommon : `" .. count.Uncommon .. "`\n" ..
                                            "┃ 🟣 Rare : `" .. count.Rare .. "`\n" ..
                                            "┃ 🟠 Epic : `" .. count.Epic .. "`\n" ..
                                            "┃ 🟡 Legendary : `" .. count.Legendary .. "`\n" ..
                                            "┃ 🔴 Mythic : `" .. count.Mythic .. "`\n" ..
                                            "┃ 📦 Total : `" .. total .. "`",
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
        if Config.AutoSummon then
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

if Config.AutoHide then
    wait(1)
    ToggleUI()
end
