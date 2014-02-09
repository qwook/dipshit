-------------------------------
-- Cache, load, and play sounds

local maxSounds = 5
local soundLibrary = {}
local soundPlaying = {}

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
    sound:rewind()
    sound:play()
end

------------------------------
-- Cache, load, and play music

local musicLibrary = {}

function cacheMusic(name)
    musicLibrary[name] = musicLibrary[name] or love.audio.newSource("assets/music/" .. name)
end

function playMusic(name, volume)
    for name, source in pairs(musicLibrary) do source:stop() end
    musicLibrary[name] = musicLibrary[name] or love.audio.newSource("assets/music/" .. name)
    musicLibrary[name]:setVolume(volume)
    musicLibrary[name]:setLooping(true)
    musicLibrary[name]:play()
end
