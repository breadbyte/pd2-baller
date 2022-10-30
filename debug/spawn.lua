local pos = managers.player:player_unit():position()
log("Flashbang spawned! at " .. tostring(pos) .. "!")
managers.groupai:state():sync_smoke_grenade(pos, pos, 1, true)