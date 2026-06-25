local scene = {}
scene.name = "Bars"
scene.controls = 2
scene.color = {}
scene.color.fg =     {5/8, 5/8, 5/8}
scene.color.active = {7/8, 7/8, 3/8}
scene.color.bg =     {3/8, 3/8, 3/8}

local speed, num, bars, barWidth

local WIDTH, HEIGHT

local lines = {
"speed: %d (change with left/right arrow)\n",
"number of bars: %d (change with -/+)\n",
[[

Vertical bars quickly moving horizontally,
this is a pretty classic and effective test
for screen tearing, which is readily apparent
if any bars appear jagged.
If the movement looks stuttery and not smooth,
variable refresh rate is probably not working.]]
}

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
    local font = love.graphics.getFont()
    local width1 = font:getWidth(lines[1]:format(1000));
    local width2 = font:getWidth(lines[2]:format(1000));
    local width3 = font:getWidth(lines[3]);
    scene.strWidth = math.max(width1, width2, width3);
end

scene.resize = function(w, h)
    WIDTH, HEIGHT = w, h
end

scene.update = function(dt, fps, gamepadUpdates)
    if gamepadUpdates > 0  and gamepad.selected > gamepad.max then
        local m = gamepad.left and -gamepadUpdates or gamepadUpdates
        if gamepad.selected == 12 then
            speed = speed + m
            speed = math.max(1, speed)
        elseif gamepad.selected == 13 then
            num = num + m
            num = math.max(1, num)
            newBars()
        end
    end
    for i = 1, num do
        bars[i] = (bars[i] + speed * dt * WIDTH / 20) % (WIDTH)
    end
    scene.str = {
        colors[12], lines[1]:format(speed),
        colors[13], lines[2]:format(num),
        colors[0],  lines[3]
    }
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

    if key == "left" then
        speed = speed - 1
    elseif key == "right" then
        speed = speed + 1
    end
    speed = math.max(1, speed)
end

scene.textinput = function(str)
    local ctrl = love.keyboard.isDown("lctrl", "rctrl")
    local shift = love.keyboard.isDown("lshift", "rshift")
    local alt = love.keyboard.isDown("ralt", "lalt")

    if str == "-" then
        num = num - 1
        num = math.max(1, num)
        newBars()
    elseif str == "+" then
        num = num + 1
        num = math.max(1, num)
        newBars()
    end
end

return scene
