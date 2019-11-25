require "run"

local fps, frameTime, lastUpdate

local speed, num, bars, width
local WIDTH, HEIGHT

local fullscreen

local vsync

local str = [[
target FPS: %d (change with up/down arrow)
actual FPS: %d
speed: %d (change with left/right arrow)
number of bars: %d (change with -/+)
fullscreen: %s (toggle with f)
busy wait: %s (toggle with b)
vsync: %s (toggle with v+s)

Freesync will only work when the application is fullscreen on Linux.
Busy waiting is more precise, but much heavier on processor and battery.
Vsync should eliminate tearing, but increases input lag and adds no smoothness.]]

local y


love.load = function()

    love.busy = false

    WIDTH, HEIGHT = love.graphics.getDimensions()
    local flags = select(3, love.window.getMode())

    y = (#select(2, love.graphics.getFont():getWrap(str, WIDTH)) + 1) * love.graphics.getFont():getHeight() + 8

    fps = flags.refreshrate - 5
    fps = (fps > 0) and fps or 56
    frameTime = 1 / fps
    lastUpdate = 0
    speed = 10
    num = 3
    width = WIDTH / 20
    bars = {}
    for i = 1, num do
        bars[i] = WIDTH / num * (i - 1)
    end


    love.graphics.setBackgroundColor(3/8, 3/8, 3/8)
    love.graphics.setColor(5/8, 5/8, 5/8)

    fullscreen = flags.fullscreen
    vsync = flags.vsync > 0
    love.keyboard.setKeyRepeat(true)

end

sanitize = function()
    fps = math.max(1, fps)
    frameTime = 1/fps

    speed = math.max(1, speed)
end


love.update = function()

    if love.busy then
        while lastUpdate + frameTime > love.timer.getTime() do end
    else
        while lastUpdate + frameTime > love.timer.getTime() do
            love.timer.sleep(0.001)
        end
    end
    lastUpdate = love.timer.getTime()

    for i = 1, num do
        bars[i] = (bars[i] + speed * width * frameTime) % (WIDTH)
    end
end


love.draw = function()

    local str = string.format(str, fps, love.timer.getFPS(), speed, num, tostring(fullscreen), tostring(love.busy), tostring(vsync))

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


love.keypressed = function(key, keycode)

    local s = love.keyboard.isDown("s")
    local v = love.keyboard.isDown("v")

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
        for i = 1, num do
            bars[i] = WIDTH / num * (i - 1)
        end
    elseif key == "=" or key == "+" then
        num = num + 1
        num = math.max(1, num)
        for i = 1, num do
            bars[i] = WIDTH / num * (i - 1)
        end
    elseif key == "f" then
        if fullscreen then
            love.window.setFullscreen(false)
            love.window.setPosition(1, 1)
        else
            love.window.setFullscreen(true)
            love.window.setPosition(0, 0)
        end
        fullscreen = not fullscreen
    elseif key == "b" then
        love.busy = not love.busy
    elseif (key == "v" and s) or (key == "s" and v) then
        local w, h, flags = love.window.getMode()
        flags.vsync = (flags.vsync == 0) and 1 or 0
        love.window.setMode(w, h, flags)
        flags = select(3, love.window.getMode())
        vsync = flags.vsync > 0
    end
    sanitize()
end
