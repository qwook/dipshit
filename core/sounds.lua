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
    -- for name, source in pairs(musicLibrary) do source:stop() end
    musicSoundData[name] = musicSoundData[name] or love.sound.newSoundData("assets/music/" .. name)
    musicLibrary[name] = musicLibrary[name] or love.audio.newSource(musicSoundData[name])
    musicLibrary[name]:setVolume(volume)
    -- musicLibrary[name]:setLooping(true)
    musicLibrary[name]:play()
    musicTimeStart = love.timer.getTime()
    currentSong = musicSoundData[name]
end

function gaussian(alpha)
    return math.exp(-math.pow(alpha - 0.5, 2) / 2)
end

for i = 0, 100 do
    print(gaussian(i/100))
end

function getAverageGaussian()
    local sum = 0
    for i = 0, 20 do
        local gaus = gaussian(i/10)
        local sample = getSample(i) or 0

        sum = sum + sample*gaus
    end

    return sum/20
end

function getAverageRateOfChange()
    local sum = 0
    local lastSample = getSample(0)
    for i = 1, 50 do
        if not lastsample then return 0 end
        local sample = math.abs(getSample(i) or 0)
        local diff = math.abs(sample - lastSample)
        lastSample = sample

        sum = sum + diff
    end

    return sum/50
end

function getSample(offset)
    if not currentSong then return 0 end

    offset = offset or 0

    local sampleRate = currentSong:getSampleRate()
    local channels = currentSong:getChannels()
    local t = (love.timer.getTime() - musicTimeStart)
    local pos = math.floor(t * sampleRate) * channels

    if pos > currentSong:getSampleCount()*channels then return end

    return currentSong:getSample(pos)
end
