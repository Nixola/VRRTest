local scene = {}
scene.name = "Squares"
scene.color = {}
scene.color.fg = {1, 1, 1}
scene.color.bg = {0, 0, 0}

local frame, size, width, height, frames, trail, gcd
local WIDTH, HEIGHT

local str = [[
trail (frames): %d (change with left/right arrow)
square size (px): %d (change with +/-)
period (seconds): ~%.2f (results from size)

trail=0 makes it easier to use a video or a
long-exposure picture (lasting up to the shown period)
to see repeated or dropped frames. Higher values can
help show latency between monitors or other ways of
mirroring a screen, when the same istance of this
program is displayed on all of them.]]

gcd = function(n1, n2)
    if n1 % n2 == 0 then
        return n2
    elseif n1 < n2 then
        n1, n2 = n2, n1
    end
    return gcd(n1 % n2, n2)
end

local wrap = function(n, limit)
    return n % limit
end

local sanitize = function()
    size = math.min(math.max(3, size), WIDTH, HEIGHT)
    width = math.ceil(WIDTH / size)
    height = math.ceil(HEIGHT / size)
    frames = width * height
    trail = math.min(math.max(trail, 0), frames - 1)
end

scene.load = function(w, h)
    WIDTH, HEIGHT = w, h
    frame = 0
    size = math.max(math.min(gcd(WIDTH, HEIGHT), WIDTH/4, HEIGHT/3), WIDTH/16, HEIGHT/9)
    width = math.ceil(WIDTH / size)
    height = math.ceil(HEIGHT / size)
    frames = width * height
    trail = 0
    scene.strWidth = love.graphics.getFont():getWidth(str:format(1000, 1000, 10.99))
end

scene.update = function(dt, fps)
    frame = wrap(frame + 1, frames)
    scene.str = str:format(trail, size, frames / fps)
end

scene.draw = function(x, y)
    for lx = 0, width do
        love.graphics.line(lx *  size + x, y, lx * size + x, HEIGHT + y)
    end
    for ly = 0, height do
        love.graphics.line(x, ly * size + y, WIDTH + x, ly * size + y)
    end

    for f = frame - trail,  frame do
        local f = wrap(f, frames)
        local rx = f % width
        local ry = math.floor(f / width)

        love.graphics.rectangle("fill", x + rx * size, y + ry * size, size, size)
    end

end

scene.keypressed = function(key, keycode, isRepeat)
    if key == "left" then
        trail = trail - 1
    elseif key == "right" then
        trail = trail + 1
    elseif key == "+" then
        size = size + 1
    elseif key == "-" then
        size = size - 1
    end
    sanitize()
end

return scene