local QBCore = exports['qb-core']:GetCoreObject()

-- Event ketika player spawn
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    print("^2[MNS RP]^7 Selamat datang di server!")
end)

-- Notification saat resource start
CreateThread(function()
    Wait(5000) -- Wait 5 seconds after joining
    -- Bisa ditambahkan welcome message atau tutorial di sini
end)