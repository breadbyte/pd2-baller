--[[
    this code hooks into the flash grenade's behavior

    it will hook into the beeping code so we know when to play the baller soundbite,
    since in the original meme, the baller image only shows up at the end of the spoken "baller".

    in this case, we show the image at the start of when the actual flash occurs.
    we don't modify the flashbang's at all.

    The screen UI code is shown in screen.lua.

    The flash grenade's code is located in lib/units/weapons/grenades/quickflashgrenade.lua.

    Idea taken from Dr_Newbie's (https://modworkshop.net/user/7573) flashbang mod (https://modworkshop.net/mod/39457).

    The same idea on how the mod did it is implemented here, we play a sound at the same time as the flashbang, and show an image on the screen.
    But instead of copy pasting the code from that one, I painstakingly researched on how to write mods myself.
    
    Huge shoutout to the guys at the modworkshop discord for bearing with me with all my basic questions
--]]

-- Setup our data and file paths
local ballersnd = ModPath .. "baller.ogg" -- Filepath to the baller sound.
local buffer = nil -- Local copy of the audio buffer

-- Setup SuperBLT
blt.xaudio.setup()

-- XAudio uses only one buffer for everything, so this is good enough
buffer = XAudio.Buffer:new(ballersnd)

-- Setup our SuperBLT hooks.
--[[
    This means we are post-hooking the init function of QuickFlashGrenade (called after the function executes),
    and we're calling our hook initHook.
--]]
Hooks:PostHook(QuickFlashGrenade, 'init', 'initHook', function(self)
    self._baller = false -- let's give the flashbang a baller variable so it can be baller
    self._audsrc = nil -- let's give the flashbang a variable to it's audio source so we can clean it up later
end)

--[[    
    Player destroyed the flashbang, so we need to stop playing the audio if we played it.
--]]
Hooks:PostHook(QuickFlashGrenade, 'on_flashbang_destroyed', 'stopTheCap', function(self) 
    if self._audsrc then
        self._audsrc:stop()
    end
end)

--[[    
    Close the audio source as soon as possible to prevent memory leaks
--]]
Hooks:PostHook(QuickFlashGrenade, 'destroy_unit', 'removeAudSrc', function(self)
    if self._audsrc then
        self._audsrc:close()
    end
end)

--[[
    Determine when we need to play the baller sound
--]]
Hooks:PostHook(QuickFlashGrenade, '_beep', 'determineBallerTime', function(self)

    -- debug, log the beep time
    log(self._beep_t);

    -- start playing baller at a certain point
    if self._beep_t < 0.2 then -- 0.2 by default, accounting for the image flash
        if not self._baller then -- check if we're already baller so we don't fire multiple times

            --log("firing baller sound at " .. tostring(self._shoot_position)); -- debug, just checking

            -- NB: Don't call UnitSource on the player because 
            -- flashbangs may get triggered on the other side of the map!
            -- Should be impossible in theory, but still a good idea to check against
        
            -- TODO: Sound seems to still follow the player, is that a problem with XAudio or our volume?
            self._audsrc = XAudio.Source:new(self._baller_snd)
            self._audsrc:set_position(self._shoot_position)
            self._audsrc:set_buffer(buffer)
            self._audsrc:play()

            self._baller = true -- we are now baller
        end
    end
end)