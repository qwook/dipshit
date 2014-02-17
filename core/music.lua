
------------------------------
-- Cache, load, and play music

local musicLibrary = {}
local musicBeats = {}
local musicSoundData = {}
local currentSong = nil
local musicTimeStart = 0

function cacheMusic(name)
    musicSoundData[name] = musicSoundData[name] or love.sound.newSoundData("assets/music/" .. name)
    musicLibrary[name] = musicLibrary[name] or love.audio.newSource(musicSoundData[name])

    -- load the detected beats for the music
    if not musicBeats[name] then
        if not love.filesystem.exists("cache") then
            love.filesystem.createDirectory("cache")
        end

        -- a .beat file will contain a bunch of 1's and 0's for each sample
        -- 1's meaning it detects a beat at that sample, 0 means theres no beat.

        -- grab the filename for the music file using a regular expression.
        -- excludes all folder names and extensions
        -- matches blah/blah/[song].ogg
        local filename = name:match("[/\\]?(.+)%..+$")

        -- this will load a .beat file if it exists
        -- else, it will create the .beat file.
        if love.filesystem.exists("cache/" .. filename .. ".beat") then
            local file = love.filesystem.read("cache/" .. filename .. ".beat")
            local beat = {{}, {}}
            file:gsub(".", function(s)
                table.insert(beat[1], tonumber(s))
            end)
            musicBeats[name] = beat
        else
            musicBeats[name] = {bdAudioProcess(musicSoundData[name])}
            love.filesystem.write("cache/" .. filename .. ".beat", table.concat(musicBeats[name][1], ""))
            print("Written: " .. love.filesystem.getSaveDirectory() .. "/cache/" .. filename .. ".beat")
        end
    end
end

function playMusic(name, volume)
    -- check if the music is cached
    cacheMusic(name)

    musicLibrary[name]:stop()
    musicLibrary[name]:setVolume(volume)

    currentSong = musicSoundData[name]
    curBeat = musicBeats[name]

    -- this is for grabbing the sample
    musicTimeStart = love.timer.getTime()

    musicLibrary[name]:play()
end

-- get the current sample
function getSample(offset)
    if not currentSong then return 0 end

    local t = (love.timer.getTime() - musicTimeStart)
    local pcm = t*currentSong:getSampleRate()

    if
        (pcm + offset >= currentSong:getSampleCount()) or
        (pcm + offset < 0)
    then
        return 0
    end

    return currentSong:getSample(pcm + offset) or 0
end

-- returns a 1 or 0 if there's a beat at the current time
function getBeat()
    if not currentSong then return 0 end

    local t = (love.timer.getTime() - musicTimeStart)

    local pcm = t*currentSong:getSampleRate()
    local s = math.ceil(pcm/1024)

    local peak = 0
    if (curBeat[1][s] == 1 or curBeat[1][s+1] == 1 or curBeat[1][s-1] == 1) then
        peak = 1
    end

    return peak
end

-- beat detection (not mine)

local K_ENERGIE_RATIO = 1.3
local K_TRAIN_DIMP_SIZE = 108
local length

function getRightSample(song, pos)
    return song:getSample((pos+1)*song:getChannels()-2)
end

function getLeftSample(song, pos)
    return math.max(song:getSample(((pos+1)*song:getChannels())-1), getRightSample(song, pos))
end

function bdEnergy(song, offset, window)
    local energy = 0
    local i = offset
    while (i < offset + window) and (i < length) do
        energy = energy + getLeftSample(song, i) * getLeftSample(song, i) / window
        i = i + 1
    end
    return energy
end

function bdNormalize(signal, size, max_val)
    local max = 0
    for i = 0, size-1 do
        if math.abs(signal[i+1] or 0) > max then max = math.abs(signal[i+1] or 0) end
    end

    local ratio = max_val/max
    for i = 0, size-1 do
        signal[i+1] = (signal[i+1] or 0)*ratio
    end
end

function bdSearchMax(signal, pos, fenetre_half_size)
    local max = 0
    local max_pos = pos
    for i = pos-fenetre_half_size, pos+fenetre_half_size do
        if (signal[i+1] > max) then
            max = signal[i+1]
            max_pos = i
        end
    end
    return max_pos
end

function bdAudioProcess(song)

    length = song:getSampleCount() --/ currentSong:getChannels()

    -- calculate instantaneous energy
    local energy1024 = {}
    for i = 0, length/1024-1 do
        energy1024[i+1] = bdEnergy(song, 1024*i, 4096)
    end

    -- calculate energy for 1 second
    --------------------------------
    local energy44100 = {}
    local sum = 0
    for i = 0, 43-1 do
        sum = sum + energy1024[i+1]
    end
    energy44100[1] = sum / 43

    -- for the others..
    for i = 1, length/1024-1 do
        sum = sum - energy1024[i-1+1] + (energy1024[i+42+1] or 0)
        energy44100[i+1] = sum / 43
    end

    -- ration energy1024/energy44100
    energy_peak = {}
    for i = 0, length/1024+21-1 do
        energy_peak[i+1] = 0
    end
    for i = 21, length/1024-1 do
        if (energy1024[i+1] > K_ENERGIE_RATIO * energy44100[i-21+1]) then
            energy_peak[i+1] = 1
        end
    end

    if true then
        return energy_peak, beat
    end


    -- calculate the BPMs
    ---------------------
    local T = {}
    local i_prec = 0
    for i = 1, length/1024-1 do
        if (energy_peak[i+1] == 1) then
            local di = i-i_prec
            if di > 4 then -- henry: originally 5, playing around
                table.insert(T, di)
                i_prec = i
            end
        end
    end

    local T_occ_max = 0
    local T_occ_moy = 0

    local occurences_T = {}
    for i = 0, 86-1 do occurences_T[i+1] = 0 end
    for i = 1, #T-1 do
        if(T[i+1] <= 86) then occurences_T[T[i+1]] = occurences_T[T[i+1]]+1 end
    end

    local occ_max = 0
    for i = 1, 86-1 do
        if (occurences_T[i+1]>occ_max) then
            T_occ_max = i
            occ_max = occurences_T[i+1]
        end
    end

    local voisin = T_occ_max - 1
    if (occurences_T[T_occ_max+1+1] > occurences_T[voisin+1]) then voisin = T_occ_max+1 end
    local div = occurences_T[T_occ_max+1] + occurences_T[voisin+1]

    if (div == 0) then T_occ_moy = 0
    else T_occ_moy = (T_occ_max * occurences_T[T_occ_max+1] + (voisin)*occurences_T[voisin]) / div end

    tempo = 60/(T_occ_moy*(1024/44100))

    -- Calculate the beat line
    --------------------------
    local train_dimp = {}
    local escape = 0
    train_dimp[0+1] = 1
    for i = 1, K_TRAIN_DIMP_SIZE-1 do
        if (escape >= T_occ_moy) then
            train_dimp[i+1] = 1
            escape = escape - T_occ_moy
        else
            train_dimp[i+1] = 0
        end
        escape = escape + 1
    end

    -- convolution
    local conv = {}
    for i = 0, length/1024-K_TRAIN_DIMP_SIZE-1 do
        for j = 0, K_TRAIN_DIMP_SIZE-1 do
            conv[i+1] = (conv[i+1] or 0) + energy1024[i+j+1] * train_dimp[j+1]
        end
    end
    bdNormalize(conv, length/1024, 1)

    -- something in french about convolution
    local beat = {}
    for i = 1, length/1024-1 do
        beat[i+1] = 0
    end

    local max_conv = 0
    local max_conv_pos = 0
    for i = 1, length/1024-1 do
        if conv[i+1] > max_conv then
            max_conv = conv[i+1]
            max_conv_pos = i
        end
    end

    beat[max_conv_pos] = 1

    local i = max_conv_pos+T_occ_max
    while((i < length/1024) and (conv[i+1] > 0)) do
        local conv_max_pos_loc = bdSearchMax(conv, i, 2)
        beat[conv_max_pos_loc+1] = 1
        i = conv_max_pos_loc+T_occ_max
    end

    -- something gauce
    i = max_conv_pos - T_occ_max
    while(i > 0) do
        local conv_max_pos_loc = bdSearchMax(conv, i, 2)
        beat[conv_max_pos_loc+1] = 1
        i = conv_max_pos_loc-T_occ_max
    end

    return energy_peak, beat

end
