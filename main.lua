require "run"

local fps, frameTime, lastUpdate

local steps, current, width
local WIDTH, HEIGHT

local fullscreen

local str = [[
target FPS: %d (change with up/down arrow)
actual FPS: %d
steps: %d (change with left/right arrow)
fullscreen: %s (toggle with f)
busy wait: %s (toggle with b)
Freesync will only work when the application is fullscreen on Linux.
Busy waiting is more precise, but much heavier on processor and battery.]]

local y


love.load = function()

    love.busy = false

    WIDTH, HEIGHT = love.graphics.getDimensions()
    local flags = select(3, love.window.getMode())

    y = (#select(2, love.graphics.getFont():getWrap(str, WIDTH)) + 1) * love.graphics.getFont():getHeight()

    fps = flags.refreshrate - 5
    fps = (fps > 0) and fps or 56
    frameTime = 1 / fps
    lastUpdate = 0
    steps = 20
    width = WIDTH / steps
    current = 0

    love.graphics.setBackgroundColor(3/8, 3/8, 3/8)
    love.graphics.setColor(5/8, 5/8, 5/8)

    fullscreen = flags.fullscreen
    love.keyboard.setKeyRepeat(true)

end

sanitize = function()
    fps = math.max(1, fps)
    frameTime = 1/fps

    steps = math.max(1, steps)
    width = WIDTH / steps
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

    current = (current + 1) % (steps )

end


love.draw = function()

    local str = string.format(str, fps, love.timer.getFPS(), steps, tostring(fullscreen), tostring(love.busy))

    love.graphics.rectangle("fill", width * current, y, width, HEIGHT)
    love.graphics.print(str)
    --[[
    love.graphics.print(fps, 0, 0)
    love.graphics.print(steps, 0, 16)
    love.graphics.print(tostring(fullscreen), 0, 32)--]]

end


love.keypressed = function(k, kk)

    if kk == "up" then
        fps = fps + 1
    elseif kk == "down" then
        fps = fps - 1
    elseif kk == "left" then
        steps = steps - 1
    elseif kk == "right" then
        steps = steps + 1
    elseif kk == "f" then
        if fullscreen then
            love.window.setFullscreen(false)
            love.window.setPosition(1, 1)
        else
            love.window.setFullscreen(true)
            love.window.setPosition(0, 0)
        end
        fullscreen = not fullscreen
    elseif kk == "b" then
        love.busy = not love.busy
    end
    sanitize()
end