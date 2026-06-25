gamepad = {}
gamepad.active = false
gamepad.selected = 0
gamepad.timer = 0
gamepad.first = true

gamepad.delay = 0.8
gamepad.interval = 0.04

gamepad.update = function(dt)
    if gamepad.left or gamepad.right then
        local n = gamepad.first and 1 or 0
        gamepad.first = false
        gamepad.timer = gamepad.timer + dt
        if gamepad.timer > gamepad.delay then
            gamepad.timer = gamepad.timer - gamepad.delay
            n = n + 1
            gamepad.repeating = true
        end
        if gamepad.repeating and gamepad.timer > gamepad.interval then
            n = n + math.floor(gamepad.timer / gamepad.interval)
            gamepad.timer = gamepad.timer % gamepad.interval
        end
        return n
    else
        gamepad.first = true
        gamepad.repeating = false
    end
    return 0
end

gamepad.highlight = function(n)
    return (gamepad.selected == n) and "> " or ""
end
gamepad.max = 11


return gamepad
