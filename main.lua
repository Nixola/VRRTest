require "run"

local fps, frameTime, lastUpdate
local fpsMax, fpsTimer, fluctuating, fpsSpeed

local random, randomAmount, randomTime

local speed, num, bars, width
local WIDTH, HEIGHT

local fullscreen

local vsync

local str = [[
target FPS: %d (change with up/down arrow)
actual FPS: %d
speed: %d (change with left/right arrow)
number of bars: %d (change with -/+)
fullscreen: %s (toggle with ctrl+f)
busy wait: %s (toggle with b)
vsync: %s (toggle with s)
fluctuating: %s (toggle with f, change max with ctrl + up/down arrow, change speed with ctrl + left/right arrow)
random stutter: %s [%dms] (toggle with r, change max amount with ctrl + +/-, shift to change faster)

Freesync will only work when the application is fullscreen on Linux.
Busy waiting is more precise, but much heavier on processor and battery.
Vsync should eliminate tearing, but increases input lag and adds no smoothness.]]

local y


newBars = function()
    width = WIDTH / (num * 3)
    for i = 1, num do
        bars[i] = WIDTH / num * (i - 1)
    end
end

love.load = function()

    love.busy = false

    WIDTH, HEIGHT = love.graphics.getDimensions()
    local flags = select(3, love.window.getMode())

    y = (#select(2, love.graphics.getFont():getWrap(str, WIDTH)) + 1) * love.graphics.getFont():getHeight() + 8

    fps = flags.refreshrate - 5
    fps = (fps > 0) and fps or 56

    fpsMax = fps
    fpsTimer = 0
    fluctuating = false
    fpsSpeed = 10

    random = false
    randomTime = 0
    randomAmount = 0

    frameTime = 1 / fps
    lastUpdate = 0
    speed = 10
    num = 3
    bars = {}
    newBars()

    love.graphics.setBackgroundColor(3/8, 3/8, 3/8)
    love.graphics.setColor(5/8, 5/8, 5/8)

    fullscreen = flags.fullscreen
    vsync = flags.vsync > 0
    love.keyboard.setKeyRepeat(true)

end


love.update = function(dt)

    if love.busy then
        while lastUpdate + frameTime + randomTime > love.timer.getTime() do end
    else
        while lastUpdate + frameTime + randomTime > love.timer.getTime() do
            love.timer.sleep(0.001)
        end
    end
    lastUpdate = love.timer.getTime()

    fpsTimer = fpsTimer + dt * fpsSpeed / 10
    if fluctuating then
        fpsCur = fps + (math.sin(fpsTimer)/2 + 0.5) * (fpsMax - fps)
        frameTime = 1/fpsCur
    end

    if random then
        randomTime = (love.math.random() - 0.5 ) * randomAmount/1000
    end

    for i = 1, num do
        bars[i] = (bars[i] + speed * dt * WIDTH / 20) % (WIDTH)
    end
end


love.draw = function()
    local fstr = fluctuating and ("true [max: %d, speed: %d, current: %d]"):format(fpsMax, fpsSpeed, fpsCur) or "false"

    local str = string.format(str, 
        fps,
        love.timer.getFPS(),
        speed,
        num,
        tostring(fullscreen),
        tostring(love.busy),
        tostring(vsync),
        fstr,
        tostring(random), randomAmount)

    for i = 1, num do
        love.graphics.rectangle("fill", bars[i], y, width, HEIGHT)
        if bars[i] > WIDTH - width then
            love.graphics.rectangle("fill", bars[i] - WIDTH, y, width, HEIGHT)
        end
    end
    love.graphics.print(str, 8, 8)
    --[[
    love.graphics.print(fps, 0, 0)
    love.graphics.print(speed, 0, 16)
    love.graphics.print(tostring(fullscreen), 0, 32)--]]

end


sanitize = function()
    fps = math.max(1, fps)
    frameTime = 1/fps
    fpsMax = math.max(fpsMax, fps)
    fpsSpeed = math.max(1, fpsSpeed)

    randomAmount = math.max(math.min(randomAmount, 1000), 0)

    speed = math.max(1, speed)
end

love.keypressed = function(key, keycode)

    local ctrl = love.keyboard.isDown("lctrl", "rctrl")
    local shift = love.keyboard.isDown("lshift", "rshift")

    if ctrl then
        if key == "up" then
            fpsMax = fpsMax + 1
        elseif key == "down" then
            fpsMax = fpsMax - 1
        elseif key == "left" then
            fpsSpeed = fpsSpeed - 1
        elseif key == "right" then
            fpsSpeed = fpsSpeed + 1
        elseif key == "+" then
            randomAmount = randomAmount + (shift and 5 or 1)
        elseif key == "-" then
            randomAmount = randomAmount - (shift and 5 or 1)
        elseif key == "f" then
            if fullscreen then
                love.window.setFullscreen(false)
                love.window.setPosition(1, 1)
            else
                love.window.setFullscreen(true)
                love.window.setPosition(0, 0)
            end
            fullscreen = not fullscreen
        end
    else
        if key == "up" then
            fps = fps + 1
        elseif key == "down" then
            fps = fps - 1
        elseif key == "left" then
            speed = speed - 1
        elseif key == "right" then
            speed = speed + 1
        elseif key == "-" or key == "_" then
            num = num - 1
            num = math.max(1, num)
            newBars()
        elseif key == "=" or key == "+" then
            num = num + 1
            num = math.max(1, num)
            newBars()
        elseif key == "f" then
            fluctuating = not fluctuating
            fpsTimer = 0
        elseif key == "b" then
            love.busy = not love.busy
        elseif key == "s" then
            local w, h, flags = love.window.getMode()
            flags.vsync = (flags.vsync == 0) and 1 or 0
            love.window.setMode(w, h, flags)
            flags = select(3, love.window.getMode())
            vsync = flags.vsync > 0
        elseif key == "r" then
            random = not random
            randomTime = 0
        end
    end
    sanitize()
end
