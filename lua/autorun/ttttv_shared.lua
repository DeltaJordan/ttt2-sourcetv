AddCSLuaFile("demoplayer.lua")
AddCSLuaFile("ttttv_demoplayer_fixes.lua")
AddCSLuaFile("ttttv_demoplayer_proxchat.lua")
if SERVER and engine.ActiveGamemode() == "terrortown" then
    RunConsoleCommand("tv_enable", 1)
    function TryFixup(ply)
        --print("[Source TV TTT] [Debug] - Attempting to fix " .. ply:Nick() .. ". (checking for " .. GetConVar("tv_name"):GetString() .. ")")  
        if ply:Nick() == GetConVar("tv_name"):GetString() then
            print("[Source TV TTT] - Forcing SourceTV into spectator")
            --if not ply:IsSpec() then
            --    ply:Kill()
            --end
            GAMEMODE:PlayerSpawnAsSpectator(ply)
            ply:SetTeam(TEAM_SPEC)
            ply:SetForceSpec(true)
            ply:Spawn()
            ply.isReady = false
            ply:SetRagdollSpec(false) -- dying will enable this, we don't want it here 
        end
    end

    hook.Add("TTTPrepareRound", "SourceTVFix", function()
        for k, v in pairs(player.GetAll()) do
            TryFixup(v)
        end
    end)

    hook.Add("PlayerInitialSpawn", "SourceTVFixPlayerJoin", function(ply)
        if ply:Nick() ~= GetConVar("tv_name"):GetString() then
            name = os.date("%d-%m-%Y-at-%H-%M", Timestamp) .. "-on-" .. game.GetMap()
            RunConsoleCommand("tv_record", "replays/" .. name)
            RunConsoleCommand("tv_record", name)
            print("[Source TV TTT] - Started recording to " .. name)
        end
    end)

    --RunConsoleCommand("tv_record", os.date( "%H-%M-%d-%m-%Y" , Timestamp )
    hook.Add("PlayerDisconnected", "SourceTVFixPlayerLeft", function()
        count = table.Count(player.GetAll())
        if table.Count(player.GetAll()) <= 2 then
            RunConsoleCommand("tv_stoprecord")
            print("[Source TV TTT] - Stopped recording")
        end
    end)

    --for k,v in pairs(player.GetAll()) do
    --    TryFixup(v)
    --end
    print("[Source TV TTT] - Source TV fixes is active and initialised!")
end

if CLIENT and engine.ActiveGamemode() == "terrortown" then
    include("demoplayer.lua")
    hook.Add("TTTScoreGroup", "SourceTVHidePlayer", function(ply) if ply:Nick() == GetConVar("tv_name"):GetString() then return 99 end end)
end