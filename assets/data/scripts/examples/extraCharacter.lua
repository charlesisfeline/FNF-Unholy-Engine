local char = Character.new(boyfriend.position + Vector2(240, -325), 'pico', true)
add_char(char) -- you could use 'Game.add_child()' but that doesnt account for char groups or auto idle

function goodNoteHit(n)
    char.sing(n)
end

function goodSustainPress(n)
    char.sing(n, '', false)
end
