local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

--========================
-- REQUEST
--========================

local req =
    syn and syn.request
    or http_request
    or request

--========================
-- CONFIG
--========================

local ConfigName = "MazokissConfig.json"

local Config = {
    AutoSkip = false,
    AutoQueue = false,
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
            writefile(
                ConfigName,
                HttpService:JSONEncode(Config)
            )
        end
    end)
end

--========================
-- UI
--========================

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"
))()

local Window = Library.CreateLib(
    "MaZoKiss Hub | Toilet Tower Defense",
    "DarkTheme"
)

local Main = Window:NewTab("Main")
local MainSection = Main:NewSection("Farm")

local WebhookTab = Window:NewTab("Webhook")
local WebhookSection = WebhookTab:NewSection("Discord")

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

            if v:IsA("ParticleEmitter")
            or v:IsA("Trail") then
                v.Enabled = false
            end

            if v:IsA("BlurEffect")
            or v:IsA("SunRaysEffect")
            or v:IsA("BloomEffect") then
                v.Enabled = false
            end
        end

        Lighting.GlobalShadows = false
        Lighting.FogEnd = 999999999

        settings().Rendering.QualityLevel =
            Enum.QualityLevel.Level01
    end)
end

--========================
-- TOGGLES
--========================

MainSection:NewToggle(
    "Auto Skip",
    "Skip wave automatically",
    function(state)

        Config.AutoSkip = state
        SaveConfig()
    end
)

MainSection:NewToggle(
    "Auto Queue",
    "Join queue automatically",
    function(state)

        Config.AutoQueue = state
        SaveConfig()
    end
)

MainSection:NewToggle(
    "White Screen",
    "FPS Boost",
    function(state)

        Config.WhiteScreen = state
        SaveConfig()

        if state then
            ApplyWhiteScreen()
        end
    end
)

WebhookSection:NewTextBox(
    "Webhook URL",
    "Paste Discord Webhook",
    function(text)

        Config.Webhook = text
        SaveConfig()
    end
)

WebhookSection:NewButton(
    "Test Webhook",
    "Send test message",
    function()

        if Config.Webhook == "" then
            return
        end

        local data = {
            ["content"] =
                "✅ Webhook Connected : "..player.Name
        }

        req({
            Url = Config.Webhook,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end
)

--========================
-- WEBHOOK STATE
--========================

local sentLobby = false

--========================
-- AUTO SKIP LOOP
--========================

spawn(function()

    while true do

        wait(5)

        if Config.AutoSkip then

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

--========================
-- AUTO QUEUE LOOP
--========================

spawn(function()

    while true do

        wait(2)

        if Config.AutoQueue then

            local char =
                player.Character
                or player.CharacterAdded:Wait()

            local hrp =
                char:WaitForChild("HumanoidRootPart")

            local humanoid =
                char:WaitForChild("Humanoid")

            if workspace:FindFirstChild("Lifts") then

                -- WEBHOOK
                if not sentLobby then

                    sentLobby = true

                    pcall(function()

                        if Config.Webhook ~= "" then

                            local coins =
                                player.leaderstats.Coins.Value

                            local data = {
                                ["embeds"] = {
                                    {
                                        ["title"] =
                                            "MaZoKiss X Hub | Toilet Tower Defense",

                                        ["color"] = 16711680,

                                        ["description"] =

                                            "**-> Profile :**\n" ..
                                            "┃ Username : `" ..
                                            player.Name ..
                                            "`\n\n" ..

                                            "**-> Coins Collected Result :**\n" ..
                                            "┃ Coins : `" ..
                                            tostring(coins) ..
                                            "`",

                                        ["footer"] = {
                                            ["text"] =
                                                "Status: กลับสู่ลอบบี้เรียบร้อย"
                                        }
                                    }
                                }
                            }

                            req({
                                Url = Config.Webhook,
                                Method = "POST",
                                Headers = {
                                    ["Content-Type"] =
                                        "application/json"
                                },
                                Body = HttpService:JSONEncode(data)
                            })
                        end
                    end)
                end

                -- TELEPORT TO LIFT
                hrp.CFrame =
                    workspace.Lifts.ToiletHQ.Base.CFrame
                    + Vector3.new(0, 3, 0)

                wait(30)

                -- RESET IF FAILED
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

--========================
-- AUTO LOAD SETTINGS
--========================

if Config.WhiteScreen then
    ApplyWhiteScreen()
end

Library:Notify(
    "MaZoKiss Hub Loaded",
    "Config Loaded Successfully",
    5
)
