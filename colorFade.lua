local color = {}

local current = {}
current.fg = {}
current.bg = {}

local target = {}
target.fg = {}
target.bg = {}

local speed = {}
speed.fg = {}
speed.bg = {}

color.setColor = function(fg, bg)
    current.fg = {unpack(fg)}
    current.bg = {unpack(bg)}
    target.fg = {unpack(fg)}
    target.bg = {unpack(bg)}
    speed.fg = {0, 0, 0}
    speed.bg = {0, 0, 0}
end

color.setTarget = function(fg, bg)
    target.fg = {unpack(fg)}
    target.bg = {unpack(bg)}
    speed.fg = {target.fg[1] - current.fg[1], target.fg[2] - current.fg[2], target.fg[3] - current.fg[3]}
    speed.bg = {target.bg[1] - current.bg[1], target.bg[2] - current.bg[2], target.bg[3] - current.bg[3]}
end


color.update = function(dt)
    for i = 1, 3 do
        local new_fg = current.fg[i] + speed.fg[i] * dt
        if new_fg <= target.fg[i] and current.fg[i] >= target.fg[i] or
          new_fg >= target.fg[i] and current.fg[i] <= target.fg[i] then
            new_fg = target.fg[i]
        end
        current.fg[i] = new_fg

        local new_bg = current.bg[i] + speed.bg[i] * dt
        if new_bg <= target.bg[i] and current.bg[i] >= target.bg[i] or
          new_bg >= target.bg[i] and current.bg[i] <= target.bg[i] then
            new_bg = target.bg[i]
        end
        current.bg[i] = new_bg
    end
    love.graphics.setColor(current.fg)
    love.graphics.setBackgroundColor(current.bg)
end

return color