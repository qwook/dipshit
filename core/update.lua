
seizure = 0

function love.update(dt)

    timer:update(dt)

    -- sets the "seizure" variable, which is created by beat detection
    local smpl, beatline, tempo = getBeat()
    if smpl == 1 then
        seizure = 1
    else
        seizure = math.approach2(seizure, 0, 3*dt)
    end

    -- update joystick axes detection
    -- its stupid we can do better
    inputUpdate(dt)

    input:update(dt)
    input2:update(dt)

    cameraLife = cameraLife - dt

    if input:wasKeyPressed("select") or input2:wasKeyPressed("select") then
        pausing = not pausing
        if not pausing then
            afkTimer = 0
        end
    end

    if (input:isKeyDown("start") and input:wasKeyPressed("select")) or
        (input:wasKeyPressed("start") and input:isKeyDown("select")) or
        (input2:isKeyDown("start") and input2:wasKeyPressed("select")) or
        (input2:wasKeyPressed("start") and input2:isKeyDown("select"))
    then
        reset() -- this is just a global function that will reset the entire level
        pausing = false
    end

    if pausing then return end

    player:update(dt)
    player2:update(dt)

    world:update(dt)

    for k, map in pairs(maps) do
        for i, object in pairs(map.objects) do
            map = object.map or map
            object:update(dt)
        end
    end

    for i, object in pairs(map.objects) do
        map = object.map or map
        object:update(dt)
    end

    if shouldExtend() then
        extendMap()
    end

    if shouldTruncate() then
        truncateMap()
    end

    loveframes.update(dt)

end
