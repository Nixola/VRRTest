local scene = {}
scene.name = "Bars"
scene.color = {}
scene.color.fg = {5/8, 5/8, 5/8}
scene.color.bg = {3/8, 3/8, 3/8}

local speed, num, bars, barWidth

local WIDTH, HEIGHT

local str = [[
speed: %d (change with left/right arrow)
number of bars: %d (change with -/+)]]

newBars = function()
    barWidth = WIDTH / (num * 3)
    for i = 1, num do
        bars[i] = WIDTH / num * (i - 1)
    end
end

scene.load = function(w, h)
    WIDTH, HEIGHT = w, h
    speed = 10
    num = 3
    bars = {}
    newBars()
    scene.strWidth = love.graphics.getFont():getWidth(str:format(1000, 1000))
end

scene.resize = function(w, h)
    WIDTH, HEIGHT = w, h
end

scene.update = function(dt, fps)
    for i = 1, num do
        bars[i] = (bars[i] + speed * dt * WIDTH / 20) % (WIDTH)
    end
    scene.str = str:format(speed, num)
end

scene.draw = function(x, y)
    for i = 1, num do
        love.graphics.rectangle("fill", bars[i] + x , y, barWidth, HEIGHT)
        if bars[i] > WIDTH - barWidth then
            love.graphics.rectangle("fill", bars[i] - WIDTH + x, y, barWidth, HEIGHT)
        end
    end
end

scene.keypressed = function(key, keycode, isRepeat)
    local ctrl = love.keyboard.isDown("lctrl", "rctrl")
    local shift = love.keyboard.isDown("lshift", "rshift")
    local alt = love.keyboard.isDown("ralt", "lalt")

    if ctrl or shift or alt then return end

    if key == "-" then
        num = num - 1
        num = math.max(1, num)
        newBars()
    elseif key == "+" then
        num = num + 1
        num = math.max(1, num)
        newBars()
    elseif key == "left" then
        speed = speed - 1
    elseif key == "right" then
        speed = speed + 1
    end
    speed = math.max(1, speed)
end

return scene