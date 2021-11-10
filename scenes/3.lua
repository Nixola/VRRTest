local scene = {}
scene.name = "BFI"
scene.color = {}
scene.color.fg = {0.7, 0.7, 0.7}
scene.color.bg = {0, 0, 0}

local frame, strobing
local padding = 8
local text, rawText, lineHeight
local font
local scrollY = 0
local fontSize = 12
local WIDTH, HEIGHT

local str = [[
strobing: %s (change with space)
padding: %d (change with left/right arrow)
font size: %d (change with +/-)

Strobing inserts a black frame every other frame.
This is called Black Frame Insertion and can help with image clarity, though it'd probably best be done at a monitor firmware level.]]

local wrapText = function()
    local _
    _, text = font:getWrap(rawText, WIDTH - padding * 2, fontSize)
end

local changeFont = function()
    font = love.graphics.newFont(fontSize)
    lineHeight = font:getHeight()
    wrapText()
end

scene.load = function(w, h)
    WIDTH, HEIGHT = w, h
    frame = 0
    strobing = false
    font = love.graphics.getFont()
    scene.strWidth = font:getWidth(str:format("off", 9999, 999))
    rawText = love.filesystem.read("story.txt")
    changeFont(font)
end

scene.resize = function(w, h)
    WIDTH, HEIGHT = w, h
end

scene.update = function(dt, fps)
    frame = (frame + 1) % 2
    scene.str = str:format(strobing and "on" or "off", padding, fontSize)
    if love.keyboard.isDown("pagedown") then
        local amount = love.keyboard.isDown("lshift", "rshift") and 25 or 5
        scrollY = math.max(scrollY - lineHeight * amount * dt, -math.max(0, #text * lineHeight - HEIGHT + 32))
    end
    if love.keyboard.isDown("pageup") then
        local amount = love.keyboard.isDown("lshift", "rshift") and 25 or 5
        scrollY = math.min(scrollY + lineHeight * amount * dt, 0) -- TODO: calculate actual max scroll
    end
    return strobing and frame==0
end

scene.draw = function(x, y)
    local oldFont = love.graphics.getFont()
    love.graphics.setFont(font)
    local line = math.floor(-scrollY / lineHeight) + 1
    local scroll = scrollY % -lineHeight
    love.graphics.translate(0, y + 16)
    love.graphics.setScissor(0, y + 16, WIDTH, HEIGHT)
    for i = line, math.min(line + HEIGHT / lineHeight + 2, #text) do
        local y = scroll + lineHeight * (i - line)
        love.graphics.print(text[i], padding, math.floor(y))
    end
    love.graphics.setScissor()
    love.graphics.setFont(oldFont)
end

scene.keypressed = function(key, keycode, isRepeat)
    local ctrl = love.keyboard.isDown("lctrl", "rctrl")
    local shift = love.keyboard.isDown("lshift", "rshift")
    local alt = love.keyboard.isDown("ralt", "lalt")

    if ctrl or alt then return end

    if key == "space" and not shift then
        strobing = not strobing
    elseif key == "right" then
        padding = padding + (shift and 5 or 1)
        wrapText()
    elseif key == "left" then
        padding = math.max(padding - (shift and 5 or 1), 0)
        wrapText()
    elseif key == "-" then
        fontSize = math.max(1, fontSize - (shift and 5 or 1))
        changeFont()
    elseif key == "+" then
        fontSize = fontSize + (shift and 5 or 1)
        changeFont()
    end
end

return scene