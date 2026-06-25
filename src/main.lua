require "run"
require "gamepad"

local color = require "colorFade"
local lines = require "lines"

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

lines.format = function(self)
    local fstr = fluctuating and ("true [%smax: %d, %sspeed: %d, current: %d]"):format(
        gamepad.highlight(6), fpsMax,
        gamepad.highlight(7), fpsSpeed,
        fpsCur
    ) or "false"
    return {
        colors[0],  self[1]:format(love.timer.getFPS()),
        colors[1],  self[2]:format(fps),
        colors[2],  self[3]:format(tostring(fullscreen)),
        colors[3],  self[4]:format(tostring(love.busy)),
        colors[4],  self[5]:format(tostring(vsync)),
        colors[5],  self[6]:format(fstr),
        colors[8],  self[7]:format(tostring(random), randomAmount),
        colors[9],  self[8]:format(display, displays),
        colors[10], self[9]:format(logLevel, logLevels - 1),
        colors[11], self[10]:format(scene, #scenes, scenes[scene].name),
        colors[0], self[11]
    }
end

colors = {}

local sceneStr

love.load = function()

    love.busy = false

    WIDTH, HEIGHT = love.graphics.getDimensions()

    local fontSize = math.max(8, HEIGHT/90)
    love.graphics.setFont(love.graphics.newFont(fontSize)) -- Ugly hack until LÖVE 12 when we get DPI scale awareness.

    local flags = select(3, love.window.getMode())

    scenes.y = lines:getHeight(WIDTH) + 8

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

    local maxControls = 0
    for i, v in ipairs(scenes) do
        maxControls = math.max(maxControls, v.controls)
    end
    for i = 0, gamepad.max + maxControls do
        colors[i] = {1, 1, 1}
    end
    colors[6] = colors[5]
    colors[7] = colors[5]


    color.setColor(scenes[scene].color.fg, scenes[scene].color.active, scenes[scene].color.bg)
end


love.update = function(dt)

    if quitting then
        quitting = quitting + dt
        if quitting > 1 then
            love.event.quit()
        end
    end

    if love.busy then
        while lastUpdate + frameTime + randomTime > love.timer.getTime() do end
    else
        while lastUpdate + frameTime + randomTime > love.timer.getTime() do
            love.timer.sleep(0)
        end
    end
    lastUpdate = love.timer.getTime()
    local gamepadRepeats = gamepad.update(dt)
    if gamepadRepeats > 0 then
        local m = gamepad.left and -gamepadRepeats or gamepadRepeats
        if gamepad.selected == 1 then
            fps = fps + m
        elseif gamepad.selected == 6 then
            fpsMax = fpsMax + m
        elseif gamepad.selected == 7 then
            fpsSpeed = fpsSpeed + m
        elseif gamepad.selected == 8 then
            randomAmount = randomAmount + m
        elseif gamepad.selected == 9 then
            setDisplay(display + m)
            gamepad.repeating = false
        elseif gamepad.selected == 10 then
            logLevel = (logLevel + m) % logLevels
        elseif gamepad.selected == 11 then
            scene = (scene + m - 1) % #scenes + 1
            color.setTarget(scenes[scene].color.fg, scenes[scene].color.active, scenes[scene].color.bg)
        end
        sanitize()
    end
    local fg = color.fg()
    local active = color.active()
    for i = 0, #colors do
        local v = colors[i]
        v[1] = fg[1]
        v[2] = fg[2]
        v[3] = fg[3]
    end
    if gamepad.active then
        local v = colors[gamepad.selected]
        v[1] = active[1] 
        v[2] = active[2]
        v[3] = active[3]
    end
        
    fpsTimer = fpsTimer + dt * fpsSpeed / 10
    if fluctuating then
        fpsCur = fps + (math.sin(fpsTimer)/2 + 0.5) * (fpsMax - fps)
        frameTime = 1/fpsCur
    end

    if random then
        randomTime = (love.math.random() - 0.5 ) * randomAmount/1000
    end

    scenes[scene].update(dt, fps, gamepadRepeats)
    color.update(dt)
    if logLevel > 1 then
        table.insert(deltaTimes, 1, string.format("%d µs", dt * 1000000))
        deltaTimes[logLines + 1] = nil
    end
end


love.draw = function()
    local str = lines:format()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(str, 8, 8)
    love.graphics.print(scenes[scene].str, WIDTH - scenes[scene].strWidth - 8, 8)
    love.graphics.setColor(color.fg())
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
        color.setTarget(scenes[scene].color.fg, scenes[scene].color.active, scenes[scene].color.bg)
        return
    end
    scenes[scene].keypressed(key, keycode)
    sanitize()
end

love.textinput = function(str)
    scenes[scene].textinput(str)
    sanitize()
end

love.gamepadpressed = function(_, button)
    gamepad.active = true
    if button == "dpup" then
        gamepad.selected = gamepad.selected - 1
    elseif button == "dpdown" then
        gamepad.selected = gamepad.selected + 1
    elseif button == "dpleft" then
        gamepad.left = true
        gamepad.timer = 0
    elseif button == "dpright" then
        gamepad.right = true
        gamepad.timer = 0
    elseif button == "a" then
        if gamepad.selected == 2 then
            if fullscreen then
                love.window.setFullscreen(false)
                love.window.setPosition(1, 1)
            else
                love.window.setFullscreen(true)
                love.window.setPosition(0, 0)
            end
            fullscreen = not fullscreen
        elseif gamepad.selected == 3 then
            love.busy = not love.busy
        elseif gamepad.selected == 4 then
            local w, h, flags = love.window.getMode()
            flags.vsync = (flags.vsync == 0) and 1 or 0
            love.window.setMode(w, h, flags)
            flags = select(3, love.window.getMode())
            vsync = flags.vsync > 0
        elseif gamepad.selected >= 5 and gamepad.selected <= 7 then
            fluctuating = not fluctuating
            fpsTimer = 0
        elseif gamepad.selected == 8 then
            random = not random
            randomTime = 0
        elseif gamepad.selected == 9 then
            setDisplay(display + 1)
        elseif gamepad.selected == 10 then
            logLevel = (logLevel + 1) % logLevels
        elseif gamepad.selected == 11 then
            scene = scene % #scenes + 1
            color.setTarget(scenes[scene].color.fg, scenes[scene].color.active, scenes[scene].color.bg)
        elseif gamepad.selected > gamepad.max then
            if scenes[scene].gamepadEnter then
                scenes[scene].gamepadEnter()
            end
        end
    elseif button == "b" or button == "start" then
        quitting = 0
    end
    if gamepad.selected <= 0 then
        gamepad.selected = gamepad.max + scenes[scene].controls
    end
    if gamepad.selected > gamepad.max + scenes[scene].controls then
        gamepad.selected = 1
    end
    if gamepad.selected == 6 and not fluctuating then
        gamepad.selected = 8
    end
    if gamepad.selected == 7 and not fluctuating then
        gamepad.selected = 5
    end
end

love.gamepadreleased = function(_, button)
    gamepad.active = true
    if button == "dpleft" then
        gamepad.left = false
    elseif button == "dpright" then
        gamepad.right = false
    elseif button == "b" or button == "start" then
        quitting = nil
    end
end
