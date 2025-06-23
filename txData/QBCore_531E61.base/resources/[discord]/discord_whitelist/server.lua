local QBCore = exports['qb-core']:GetCoreObject()

-- Fungsi untuk mendapatkan Discord ID player
local function GetDiscordId(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in pairs(identifiers) do
        if string.match(identifier, "discord:") then
            return string.gsub(identifier, "discord:", "")
        end
    end
    return nil
end

-- Fungsi HTTP Request ke Discord API
local function DiscordRequest(method, endpoint, data, callback)
    if Config.BotToken == '' then
        print("^1[DISCORD WHITELIST] Bot token tidak ditemukan!")
        return
    end

    local url = "https://discord.com/api/v10" .. endpoint
    local headers = {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bot ' .. Config.BotToken
    }

    PerformHttpRequest(url, function(status, response, headers)
        local data = response and json.decode(response) or nil
        if callback then callback(status, data) end
    end, method, data and json.encode(data) or nil, headers)
end

-- Cek apakah player ada di Discord server
local function IsPlayerInDiscord(discordId, callback)
    local endpoint = '/guilds/' .. Config.GuildId .. '/members/' .. discordId
    DiscordRequest('GET', endpoint, nil, function(status, data)
        callback(status == 200, data)
    end)
end

-- Cek apakah player punya role tertentu
local function PlayerHasRole(discordId, roleId, callback)
    IsPlayerInDiscord(discordId, function(inServer, memberData)
        if inServer and memberData and memberData.roles then
            for _, role in pairs(memberData.roles) do
                if role == roleId then
                    callback(true)
                    return
                end
            end
        end
        callback(false)
    end)
end

-- Berikan role ke member Discord
local function GiveDiscordRole(discordId, roleId, callback)
    local endpoint = '/guilds/' .. Config.GuildId .. '/members/' .. discordId .. '/roles/' .. roleId
    DiscordRequest('PUT', endpoint, nil, function(status, data)
        callback(status == 204)
    end)
end

-- Kirim log ke Discord webhook
local function SendDiscordLog(title, description, color)
    if Config.WebhookLogs == '' then return end

    local embed = {
        embeds = {{
            title = title,
            description = description,
            color = color or 3447003,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
            footer = {
                text = Config.ServerName,
                icon_url = "https://cdn.discordapp.com/attachments/QEZPfrh6kh/logo.png" -- Optional
            }
        }}
    }

    PerformHttpRequest(Config.WebhookLogs, function() end, 'POST', json.encode(embed), {
        ['Content-Type'] = 'application/json'
    })
end

-- Event ketika player connecting
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local source = source
    local discordId = GetDiscordId(source)

    deferrals.defer()
    Wait(100)

    deferrals.update("🔍 Checking Discord identity...")

    -- Cek apakah player punya Discord
    if not discordId then
        deferrals.done(Config.Messages.no_discord)
        return
    end

    deferrals.update("🔗 Checking Discord server membership...")

    -- Cek apakah player ada di Discord server
    IsPlayerInDiscord(discordId, function(inServer, memberData)
        if not inServer then
            deferrals.done(Config.Messages.not_in_server)
            return
        end

        deferrals.update("✅ Checking whitelist status...")

        -- Cek apakah player sudah diwhitelist
        PlayerHasRole(discordId, Config.Roles.whitelist, function(hasWhitelist)
            if hasWhitelist then
                -- Player sudah diwhitelist, boleh masuk
                deferrals.done()

                -- Log join
                print("^2[MNS RP WHITELIST]^7 " .. playerName .. " (" .. discordId .. ") joined the server")
                SendDiscordLog("Player Joined", "**" .. playerName .. "** joined the server\nDiscord: <@" .. discordId .. ">", 65280)

            else
                -- Player belum diwhitelist, beri role warga
                deferrals.update("⏳ Assigning Warga role...")

                GiveDiscordRole(discordId, Config.Roles.warga, function(success)
                    deferrals.done(Config.Messages.not_whitelisted)

                    if success then
                        print("^3[MNS RP WHITELIST]^7 " .. playerName .. " got Warga role, needs whitelist application")
                        SendDiscordLog("New Warga", "**" .. playerName .. "** got Warga role\nDiscord: <@" .. discordId .. ">\nStatus: Needs whitelist application", 16776960)
                    else
                        print("^1[MNS RP WHITELIST]^7 Failed to give Warga role to " .. playerName)
                    end
                end)
            end
        end)
    end)
end)

-- Command untuk whitelist player (Staff only)
QBCore.Commands.Add('whitelist', 'Whitelist a player (Staff Only)', {{name = 'id', help = 'Player Server ID'}}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local discordId = GetDiscordId(source)
    if not discordId then
        TriggerClientEvent('QBCore:Notify', source, Config.Messages.no_permission, 'error')
        return
    end

    -- Cek apakah player adalah staff
    PlayerHasRole(discordId, Config.Roles.staff, function(isStaff)
        -- Cek juga apakah admin atau owner
        if not isStaff then
            PlayerHasRole(discordId, Config.Roles.admin, function(isAdmin)
                if not isAdmin then
                    PlayerHasRole(discordId, Config.Roles.owner, function(isOwner)
                        if not isOwner then
                            TriggerClientEvent('QBCore:Notify', source, Config.Messages.no_permission, 'error')
                            return
                        else
                            ProcessWhitelist(source, args)
                        end
                    end)
                else
                    ProcessWhitelist(source, args)
                end
            end)
        else
            ProcessWhitelist(source, args)
        end
    end)
end, 'admin')

-- Fungsi process whitelist
function ProcessWhitelist(source, args)
    if not args[1] then
        TriggerClientEvent('QBCore:Notify', source, Config.Messages.usage_whitelist, 'primary')
        return
    end

    local targetId = tonumber(args[1])
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)

    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', source, Config.Messages.player_not_found, 'error')
        return
    end

    local targetDiscordId = GetDiscordId(targetId)
    if not targetDiscordId then
        TriggerClientEvent('QBCore:Notify', source, 'Target player tidak memiliki Discord yang terdeteksi!', 'error')
        return
    end

    -- Berikan whitelist role
    GiveDiscordRole(targetDiscordId, Config.Roles.whitelist, function(success)
        if success then
            TriggerClientEvent('QBCore:Notify', source, Config.Messages.whitelist_success, 'success')
            TriggerClientEvent('QBCore:Notify', targetId, '🎉 Selamat! Kamu telah diwhitelist oleh staff!', 'success')

            local staffName = QBCore.Functions.GetPlayer(source).PlayerData.charinfo.firstname .. " " .. QBCore.Functions.GetPlayer(source).PlayerData.charinfo.lastname
            local targetName = targetPlayer.PlayerData.charinfo.firstname .. " " .. targetPlayer.PlayerData.charinfo.lastname

            print("^2[MNS RP WHITELIST]^7 " .. GetPlayerName(targetId) .. " whitelisted by " .. GetPlayerName(source))

            SendDiscordLog("Player Whitelisted",
                "**" .. GetPlayerName(targetId) .. "** has been whitelisted!\n" ..
                "**Staff:** " .. GetPlayerName(source) .. "\n" ..
                "**Discord:** <@" .. targetDiscordId .. ">",
                65280)
        else
            TriggerClientEvent('QBCore:Notify', source, Config.Messages.whitelist_failed, 'error')
        end
    end)
end

-- Command untuk cek status whitelist
QBCore.Commands.Add('checkwl', 'Check your whitelist status', {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local discordId = GetDiscordId(source)
    if not discordId then
        TriggerClientEvent('QBCore:Notify', source, 'Discord tidak terdeteksi!', 'error')
        return
    end

    PlayerHasRole(discordId, Config.Roles.whitelist, function(hasWhitelist)
        if hasWhitelist then
            TriggerClientEvent('QBCore:Notify', source, '✅ Status: Whitelisted', 'success')
        else
            PlayerHasRole(discordId, Config.Roles.warga, function(hasWarga)
                if hasWarga then
                    TriggerClientEvent('QBCore:Notify', source, '⏳ Status: Warga (Belum Whitelist)', 'primary')
                else
                    TriggerClientEvent('QBCore:Notify', source, '❌ Status: Tidak dikenal', 'error')
                end
            end)
        end
    end)
end)

-- Event ketika resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("^2[MNS RP WHITELIST]^7 Discord Whitelist System started successfully!")

        -- Validasi konfigurasi
        if Config.BotToken == '' then
            print("^1[MNS RP WHITELIST] WARNING: Bot token belum diset di server.cfg!")
        end

        if Config.GuildId == '' then
            print("^1[MNS RP WHITELIST] WARNING: Guild ID belum diset di server.cfg!")
        end
    end
end)