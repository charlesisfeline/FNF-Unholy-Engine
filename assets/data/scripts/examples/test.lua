-- Character Example
local char = Character.new(boyfriend.position + Vector2(240, -325), 'bf-femboy', true)
add_char(char) -- you could use 'Game.add_child()' but that doesnt account for char groups or auto idle

local char2 = Character.new(boyfriend.position + Vector2(380, -310), 'bf-girl', true)
add_char(char2)
function goodNoteHit(n)
    char.sing(n)
    char2.sing(n)
end

function goodSustainPress(n)
    char.sing(n, '', false)
    char2.sing(n, '', false)
end
