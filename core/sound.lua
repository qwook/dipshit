-------------------------------
-- Cache, load, and play sounds

local maxSounds = 5
local soundLibrary = {}
local soundPlaying = {}

local curBeat

function cacheSound(name)
    soundLibrary[name] = soundLibrary[name] or {}
    soundPlaying[name] = soundPlaying[name] or 0
    if #soundLibrary[name] == 0 then
        for i = 1, maxSounds do
            table.insert(soundLibrary[name], love.audio.newSource("assets/sounds/" .. name))
        end
    end
end

function playSound(name, volume)
    cacheSound(name)
    soundPlaying[name] = (soundPlaying[name] + 1) % maxSounds
    local sound = soundLibrary[name][soundPlaying[name] + 1]
    sound:setVolume(volume or 1)
    sound:setVolume(0.1)
    sound:rewind()
    sound:play()
end
