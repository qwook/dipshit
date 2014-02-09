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
local musicSoundData = {}
local currentSong = nil
local musicTimeStart = 0

function cacheMusic(name)
    musicSoundData[name] = musicSoundData[name] or love.sound.newSoundData("assets/music/" .. name)
    musicLibrary[name] = musicLibrary[name] or love.audio.newSource(musicSoundData[name])
end

function playMusic(name, volume)
    for name, source in pairs(musicLibrary) do source:stop() end
    musicSoundData[name] = musicSoundData[name] or love.sound.newSoundData("assets/music/" .. name)
    musicLibrary[name] = musicLibrary[name] or love.audio.newSource(musicSoundData[name])
    musicLibrary[name]:setVolume(volume)
    -- musicLibrary[name]:setLooping(true)
    musicTimeStart = love.timer.getTime()
    musicLibrary[name]:play()
    currentSong = musicSoundData[name]
end

function getSample()
    if not currentSong then return 0 end

    local sampleRate = currentSong:getSampleRate()
    local t = (love.timer.getTime() - musicTimeStart) * 100 * 100 * 100 * 100
    local pos = math.floor(t / sampleRate)

    print(pos, t, sampleRate, currentSong:getSampleCount())

    if pos > currentSong:getSampleCount() then return end

    return currentSong:getSample(pos)
end
