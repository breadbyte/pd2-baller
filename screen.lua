local wallTimeStart = nil -- Tick start variable
local ballerTex = nil -- Local copy of the texture in the hud
local flashbangTime = nil -- The duration of the flashbang
local isBaller = false -- Is the screen being shown currently

local ballerpicPath = ModPath .. "baller.texture" -- Local path of the texture
BLT.AssetManager:CreateEntry(Idstring("ballertex"), Idstring("texture"), ballerpicPath) -- Put our texture into the game

Hooks:PostHook(CoreEnvironmentControllerManager, 'set_flashbang', 'checkFlashInRangeDuration', function(self)

    -- Check the flashbang time for our edge cases.
    if (self._current_flashbang_flash <= 0.2) then
        --log("Edge case: flash time is " .. self._current_flashbang_flash)
        -- edge cases:
        -- if we're at the edge of the flashbang radius, we don't get affected (we get a flash time of 0)
        -- if the flashbang time is too short, we don't want to show a one frame image (we get a flash time of 0.2 or lower)
        return
    end

    -- Check if we're already showing an image on the screen.
    if isBaller then    -- Only keep one baller image on the screen.
        --log("Tried to create new baller flash, but already flashed!")
        return          -- It might be possible to keep track of multiple flashbangs on the screen,
    end                 -- but for now, show only one for the sake of simplicity.
    isBaller = true     -- debounce

    -- Load the baller image.
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
    ballerTex = hud.panel:bitmap({
        texture = Idstring("ballertex"),
        x = hud.panel:world_center_x() - 300, -- show the image on the center of the screen
        y = 0,
        --w = hud.panel:w(),
        --h = hud.panel:h(),
        visible = false
    })
    --log("Texture loaded.")

    flashbangTime = self._current_flashbang_flash
    wallTimeStart = TimerManager:wall():time()

    --log("flashbang multiplier: " .. self._flashbang_duration)
    --log("flashbang duration: " .. self._current_flashbang_flash)
    --log("Tick started at wall time: " .. TimerManager:wall():time()) --oras ng dingding
    
end)


Hooks:PostHook(CoreEnvironmentControllerManager, 'update', 'hookUpdate', function(self)
    -- Start ticking if we have a start tick time.
    if wallTimeStart then
        -- Show the baller image, with reducing transparency as time goes on.
        local calc = 1 - ((TimerManager:wall():time() - wallTimeStart) / flashbangTime)
        ballerTex:show()

        if calc <= 0.0 then
            -- We don't have alpha anymore (calculating negative!), time to reset baller
            --log("Alpha reset (reached 0)")
            __resetRound()
        else
            --log(calc .. " alpha in " .. TimerManager:wall():time() - wallTimeStart)
            ballerTex:set_alpha(calc);
        end
    end
end)


function __resetRound()
    __unloadTexture()
    __resetVariables()
    --log("Round reset.")
end

function __unloadTexture()
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
    hud.panel:remove(ballerTex)
    --log("Texture unloaded.")
end

function __resetVariables()
    wallTimeStart = nil
    flashbangTime = nil
    ballerTex = nil
    isBaller = false
    --log("Variables cleared.")
end