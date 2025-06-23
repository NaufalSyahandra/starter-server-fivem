Config = {}

-- Discord Settings (Akan diambil dari server.cfg)
Config.BotToken = GetConvar('discord_bot_token', '')
Config.GuildId = GetConvar('discord_guild_id', '')
Config.WebhookLogs = GetConvar('discord_webhook_logs', '')

-- Discord Role IDs (Ganti dengan ID role Discord Anda)
Config.Roles = {
    warga = "1385174177832501248",           -- Role untuk member baru
    whitelist = "1385175312400257024",   -- Role yang bisa main
    staff = "1385175833118900247",           -- Role staff
    admin = "1385176641348698224",           -- Role admin
    owner = "YOUR_OWNER_ROLE_ID"            -- Role owner
}

-- Channel IDs (Ganti dengan ID channel Discord Anda)
Config.Channels = {
    logs = "1385179102092197939",
    whitelist = "1385177615685652540",
    welcome = "1385160917611974707"
}

-- Server Settings
Config.ServerName = "MNS RP"
Config.DiscordInvite = "https://dsc.gg/mns-rp"

-- Messages
Config.Messages = {
    no_discord = "❌ Discord tidak terdeteksi!\n\n🔧 Cara mengatasi:\n1. Pastikan Discord sudah login\n2. Restart FiveM\n3. Restart Discord",
    not_in_server = "❌ Kamu belum join Discord server MNS RP!\n\n🔗 Join sekarang: " .. Config.DiscordInvite,
    not_whitelisted = "⏳ Selamat datang di MNS RP!\n\n📝 Kamu sudah mendapat role Warga\n💡 Untuk bermain, ajukan aplikasi whitelist di Discord\n🔗 " .. Config.DiscordInvite,
    welcome = "✅ Selamat datang di MNS RP! Selamat bermain roleplay!",
    whitelist_success = "✅ Player berhasil diwhitelist oleh staff!",
    no_permission = "❌ Kamu tidak memiliki permission untuk command ini!",
    player_not_found = "❌ Player tidak ditemukan atau offline!",
    usage_whitelist = "📋 Usage: /whitelist [player_id]",
    whitelist_failed = "❌ Gagal memberikan whitelist role ke Discord!"
}