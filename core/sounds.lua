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
    -- musicBeats[name] = musicBeats[name] or {bdAudioProcess(musicSoundData[name])}

    if not musicBeats[name] then
        if not love.filesystem.exists("cache") then
            love.filesystem.createDirectory("cache")
        end

        -- matches blah/blah/[song].ogg
        local filename = name:match("[/\\]?(.+)%..+$")

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
    cacheMusic(name)

    musicLibrary[name]:setVolume(volume)

    currentSong = musicSoundData[name]
    curBeat = musicBeats[name]

    musicTimeStart = love.timer.getTime()
    musicLibrary[name]:stop()
    musicLibrary[name]:play()
end

function gaussian(alpha)
    return math.exp(-math.pow(alpha - 0.5, 2) / 2)
end

function getPitch()
    if not currentSong then return 0 end

    local n = 8192
    local binsize = 8000
    -- local binsize = currentSong:getSampleRate()/n
    local sample = getWindowedSample(n)
    sample[0] = 0
    local imaginary = {}
    imaginary[0] = 0
    for i = 1, n do
        imaginary[i] = 0
    end
    fft(binsize, sample, imaginary)

    -- find the peak

    local maxVal = -1
    local maxIndex = -1

    for j = 1, math.floor(binsize/2) do
        local v = sample[j-1] * sample[j-1] + imaginary[j-1] * imaginary[j-1]
        if (v > maxVal) then
            maxVal = v
            maxIndex = j
        end
    end

    return maxIndex, maxVal
end

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

function getBeat()
    if not currentSong then return 0 end

    local t = (love.timer.getTime() - musicTimeStart)

    local pcm = t*currentSong:getSampleRate()
    local s = math.ceil(pcm/1024)

    local peak = 0
    if (curBeat[1][s] == 1 or curBeat[1][s+1] == 1 or curBeat[1][s-1] == 1) then
        peak = 1
    end

    return peak--, curBeat[2][s] or 0
end

-- pitch detection (not mine)

function buildHanWindow(size)
    local window = {}
    for i = 1, size do
        window[i] = .5 * (1 - math.cos( 2 * math.pi * (i-1) / (size-1) ))
    end
    return window
end

function getWindowedSample(size)
    local window = buildHanWindow(size)
    local sample = {}
    for i = 1, size do
        local pos = i - size/2
        table.insert(sample, getSample(pos) * window[i] * 1000)
    end
    return sample
end

-- this function is ported from:
--   http://www.kurims.kyoto-u.ac.jp/~ooura/fftman/ftmn1_24.html#sec1_2_4
-- base code is from:
--   http://game11.2ch.net/test/read.cgi/gameama/1182042852/420
function fft(n, ar, ai)
    local m, mq, i, j, j1, j2, j3, k=0,0,0,0,0,0,0,0
    local theta, w1r, w1i, w3r, w3i=0,0,0,0,0
    local x0r, x0i, x1r, x1i, x3r, x3i=0,0,0,0,0,0
    local atan = math.atan
    local cos = math.cos
    local sin = math.sin
    local floor = math.floor
    
    theta = -8 * atan(1.0) / n
    m = n
    while m > 2 do -- for (m = n; m > 2; m >>= 1)
        mq = floor(m/4) -- mq = m >> 2;
        i = 0
        while i < mq do -- for (i = 0; i < mq; i++) {
            w1r = cos(theta * i)
            w1i = sin(theta * i)
            w3r = cos(theta * 3 * i)
            w3i = sin(theta * 3 * i)
            k = m
            while k<=n do -- for (k = m; k <= n; k <<= 2) {
                j = k - m + i
                while j < n do -- for (j = k - m + i; j < n; j += 2 * k) {
                    j1 = j + mq
                    j2 = j1 + mq
                    j3 = j2 + mq
                    x1r = ar[j] - ar[j2]
                    x1i = ai[j] - ai[j2]
                    ar[j] = ar[j] + ar[j2]
                    ai[j] = ai[j] + ai[j2]
                    x3r = ar[j3] - ar[j1]
                    x3i = ai[j3] - ai[j1]
                    ar[j1] = ar[j1] + ar[j3]
                    ai[j1] = ai[j1] + ai[j3]
                    x0r = x1r - x3i
                    x0i = x1i + x3r
                    ar[j2] = w1r * x0r - w1i * x0i
                    ai[j2] = w1r * x0i + w1i * x0r
                    x0r = x1r + x3i
                    x0i = x1i - x3r
                    ar[j3] = w3r * x0r - w3i * x0i
                    ai[j3] = w3r * x0i + w3i * x0r
                    j = j + (2*k)
                end
                k = k * 4
            end
            i=i+1
        end
        theta =theta * 2
        m = floor(m/2)
    end

    k = 2
    while k<=n do -- for (k = 2; k <= n; k <<= 2) {
        j = k - 2
        while j < n do -- for (j = k - 2; j < n; j += 2 * k) {
            x0r = ar[j] - ar[j + 1]
            x0i = ai[j] - ai[j + 1]
            ar[j] =ar[j]+ar[j + 1]
            ai[j] =ai[j]+ai[j + 1]
            ar[j + 1] = x0r
            ai[j + 1] = x0i
            j = j+(k*2)
        end
        k = k * 4
    end

    i = 0
    j = 1
    while j < n - 1 do -- for (j = 1; j < n - 1; j++) {
        k = floor(n/2)
        i=bit.bxor(i,k)
        while k > i do -- for (k = n >> 1; k > (i ^= k); k >>= 1);
            k = floor(k/2)
            i=bit.bxor(i,k)
        end
        if j < i then
            x0r = ar[j]
            x0i = ai[j]
            ar[j] = ar[i]
            ai[j] = ai[i]
            ar[i] = x0r
            ai[i] = x0i
        end
        j=j+1
    end
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
