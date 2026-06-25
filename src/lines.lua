lines = {
    "actual FPS: %d\n",
    "target FPS: %d (change with up/down arrow)\n",
    "fullscreen: %s (toggle with ctrl+f)\n",
    "busy wait: %s (toggle with b)\n",
    "vsync: %s (toggle with s)\n",
    "fluctuating: %s (toggle with f, change max with ctrl + up/down arrow, change speed with ctrl + left/right arrow)\n",
    "random stutter: %s [%dms] (toggle with r, change max amount with alt + up/down arrow, shift to change faster)\n",
    "display: %d/%d (switch with alt + left/right arrow)\n",
    "log level: %d/%d (increase with l, wraps around)\n",
    "selected scene: %d/%d (%s) (change with number keys)\n",
    [[

Freesync will only work when the application is fullscreen on Linux.
Busy waiting is more precise, but much heavier on processor and battery.
Vsync should eliminate tearing, but it increases input lag and it adds no smoothness.
If you're using a gamepad, you can choose a setting with the up and down arrows,
then toggle it with the A (Xbox) or X (Sony) button, or tweak it with left or right.
You can quit this program with the Escape or Q keys, or holding Start or B/Circle.]]
}
lines.getHeight = function(self, w)
    local font = love.graphics.getFont()
    local wraps = 2
    for i, v in ipairs(self) do
        local _, l = font:getWrap(v, w)
        wraps = wraps + #l - 1
    end
    return wraps * font:getHeight()
end


return lines
