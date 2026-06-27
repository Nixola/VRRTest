local color = {}

local current = {}
current.fg = {}
current.text = {}
current.active = {}
current.bg = {}

local target = {}
target.fg = {}
target.text = {}
target.active = {}
target.bg = {}

local speed = {}
speed.fg = {}
target.text = {}
speed.active = {}
speed.bg = {}

color.setColor = function(fg, text, active, bg)
    current.fg = {unpack(fg)}
    current.text = {unpack(text)}
    current.active = {unpack(active)}
    current.bg = {unpack(bg)}
    target.fg = {unpack(fg)}
    target.text = {unpack(text)}
    target.active = {unpack(active)}
    target.bg = {unpack(bg)}
    speed.fg = {0, 0, 0}
    speed.text = {0, 0, 0}
    speed.active = {0, 0, 0}
    speed.bg = {0, 0, 0}
end

color.setTarget = function(fg, text, active, bg)
    target.fg = {unpack(fg)}
    target.text = {unpack(text)}
    target.active = {unpack(active)}
    target.bg = {unpack(bg)}
    speed.fg = {target.fg[1] - current.fg[1], target.fg[2] - current.fg[2], target.fg[3] - current.fg[3]}
    speed.text = {target.text[1] - current.text[1], target.text[2] - current.text[2], target.text[3] - current.text[3]}
    speed.active = {target.active[1] - current.active[1], target.active[2] - current.active[2], target.active[3] - current.active[3]}
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

        local new_text = current.text[i] + speed.text[i] * dt
        if new_text <= target.text[i] and current.text[i] >= target.text[i] or
          new_text >= target.text[i] and current.text[i] <= target.text[i] then
            new_text = target.text[i]
        end
        current.text[i] = new_text

        local new_active = current.active[i] + speed.active[i] * dt
        if new_active <= target.active[i] and current.active[i] >= target.active[i] or
          new_active >= target.active[i] and current.active[i] <= target.active[i] then
            new_active = target.active[i]
        end
        current.active[i] = new_active

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

color.bg = function()
    return current.bg
end

color.active = function()
    return current.active
end

color.text = function()
    return current.text
end

color.fg = function()
    return current.fg
end

return color
