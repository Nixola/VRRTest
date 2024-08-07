require "run"

local color = require "colorFade"

local fps, frameTime, lastUpdate
local fpsMax, fpsTimer, fluctuating, fpsSpeed

local random, randomAmount, randomTime

local displays, display

local fullscreen

local vsync

local logLevel, logLevels
local deltaTimes, logLines, logWidth

local WIDTH, HEIGHT

local scenes = {}
scenes.x = 0
scenes.y = 0
local scene = 1
local loadScenes = function(width, height)
    for i, file in ipairs(love.filesystem.getDirectoryItems("scenes")) do
        local f, err = love.filesystem.load("scenes/" .. file)
        if not f then
            print("Could not load", file..":", err)
        else
            f, err = pcall(f)
            if not f then
                print("Could not run", file..":", err)
            else
                scenes[i] = err
                err.load(width, height)
                print(i, err)
            end
        end
    end
end

local setDisplay = function(n)
    local new_displays = love.window.getDisplayCount()
    n = (n-1) % new_displays + 1
    if n == display and new_displays == displays then return end
    WIDTH, HEIGHT = love.window.getDesktopDimensions(n)
    love.window.setMode(WIDTH, HEIGHT, {display = n, fullscreen = fullscreen, vsync = vsync and 1 or 0})
    display = n
    displays = new_displays
    for i, scene in ipairs(scenes) do
        scene.resize(WIDTH - scenes.x, HEIGHT - scenes.y)
    end
end



local str = [[
actual FPS: %d
target FPS: %d (change with up/down arrow)
fullscreen: %s (toggle with ctrl+f)
busy wait: %s (toggle with b)
vsync: %s (toggle with s)
fluctuating: %s (toggle with f, change max with ctrl + up/down arrow, change speed with ctrl + left/right arrow)
random stutter: %s [%dms] (toggle with r, change max amount with alt + up/down arrow, shift to change faster)
display: %d/%d (switch with alt + left/right arrow)
log level: %d/%d (increase with l, wraps around)
selected scene: %d (%s)

Freesync will only work when the application is fullscreen on Linux.
Busy waiting is more precise, but much heavier on processor and battery.
Vsync should eliminate tearing, but increases input lag and adds no smoothness.
You can quit this program with the Escape or Q keys.]]
local sceneStr

love.load = function()

    love.busy = false

    WIDTH, HEIGHT = love.graphics.getDimensions()

    local flags = select(3, love.window.getMode())

    scenes.y = (#select(2, love.graphics.getFont():getWrap(str, WIDTH)) + 1) * love.graphics.getFont():getHeight() + 8

    fps = flags.refreshrate - 5
    fps = (fps > 0) and fps or 56

    fpsMax = fps
    fpsTimer = 0
    fluctuating = false
    fpsSpeed = 10

    random = false
    randomTime = 0
    randomAmount = 0

    displays = love.window.getDisplayCount()
    display = 1

    frameTime = 1 / fps
    lastUpdate = 0

    logLevel = 0
    logLevels = 3 -- 0-2
    deltaTimes = {}
    logLines = math.floor((HEIGHT - scenes.y) / love.graphics.getFont():getHeight())
    logWidth = love.graphics.getFont():getWidth("00000 µs") + 16

    fullscreen = flags.fullscreen
    vsync = flags.vsync > 0
    love.keyboard.setKeyRepeat(true)

    loadScenes(WIDTH - scenes.x, HEIGHT - scenes.y)

    color.setColor(scenes[scene].color.fg, scenes[scene].color.bg)
end


love.update = function(dt)

    if love.busy then
        while lastUpdate + frameTime + randomTime > love.timer.getTime() do end
    else
        while lastUpdate + frameTime + randomTime > love.timer.getTime() do
            love.timer.sleep(0)
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

    scenes[scene].update(dt, fps)
    color.update(dt)
    if logLevel > 1 then
        table.insert(deltaTimes, 1, string.format("%d µs", dt * 1000000))
        deltaTimes[logLines + 1] = nil
    end
end


love.draw = function()
    local fstr = fluctuating and ("true [max: %d, speed: %d, current: %d]"):format(fpsMax, fpsSpeed, fpsCur) or "false"

    local str = string.format(str, 
        love.timer.getFPS(),
        fps,
        tostring(fullscreen),
        tostring(love.busy),
        tostring(vsync),
        fstr,
        tostring(random), randomAmount,
        display, displays,
        logLevel, logLevels - 1,
        scene,
        scenes[scene].name)

    love.graphics.print(str, 8, 8)
    love.graphics.print(scenes[scene].str, WIDTH - scenes[scene].strWidth - 8, 8)
    if logLevel > 0 then
        love.graphics.printf(table.concat({love.graphics.getRendererInfo()}, "\n"), 0, scenes.y - love.graphics.getFont():getHeight() * 5, WIDTH - 8, "right")
    end

    scenes[scene].draw(scenes.x, scenes.y)

    if logLevel > 1 then
        --love.graphics.setColor(.75, 0, 0)
        love.graphics.setColor(color.bg())
        love.graphics.rectangle("fill", WIDTH - logWidth, scenes.y, logWidth + 1, HEIGHT)
        love.graphics.setColor(color.fg())
        for i, ms in ipairs(deltaTimes) do
            love.graphics.printf(ms, 0, scenes.y + (i - 1) * love.graphics.getFont():getHeight(), WIDTH - 8, "right")
        end
    end

end


sanitize = function()
    fps = math.max(1, fps)
    frameTime = 1/fps
    fpsMax = math.max(fpsMax, fps)
    fpsSpeed = math.max(1, fpsSpeed)

    randomAmount = math.max(math.min(randomAmount, 1000), 0)
end

love.keypressed = function(key, keycode)

    local ctrl = love.keyboard.isDown("lctrl", "rctrl")
    local shift = love.keyboard.isDown("lshift", "rshift")
    local alt = love.keyboard.isDown("ralt", "lalt")

    if ctrl then
        if key == "up" then
            fpsMax = fpsMax + 1
        elseif key == "down" then
            fpsMax = fpsMax - 1
        elseif key == "left" then
            fpsSpeed = fpsSpeed - 1
        elseif key == "right" then
            fpsSpeed = fpsSpeed + 1
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
    elseif alt then
        if key == "up" then
            randomAmount = randomAmount + (shift and 5 or 1)
        elseif key == "down" then
            randomAmount = randomAmount - (shift and 5 or 1)
        elseif key == "left" then
            setDisplay(display - 1)
            return
        elseif key == "right" then
            setDisplay(display + 1)
            return
        end
    else
        if key == "up" then
            fps = fps + 1
        elseif key == "down" then
            fps = fps - 1
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
        elseif key == "escape" or key == "q" then
            love.event.quit()
        elseif key == "l" then
            logLevel = (logLevel + 1) % logLevels
        end
    end
    if tonumber(key) and scenes[tonumber(key)] then
        scene = tonumber(key)
        color.setTarget(scenes[scene].color.fg, scenes[scene].color.bg)
        return
    end
    scenes[scene].keypressed(key, keycode)
    sanitize()
end

love.textinput = function(str)
    scenes[scene].textinput(str)
    sanitize()
end
