--[[local left = Character.new(boyfriend.position - Vector2(180 * boyfriend.scale.x, 360), 'bf-girl', true)
add_char(left, 'boyfriend')

local up = Character.new(boyfriend.position + Vector2(180, -345), 'bf-femboy', true)
add_char(up)

local right = Character.new(boyfriend.position + Vector2(300, -325), 'bf-soul', true)
add_char(right)

function noteAdded(id)
    --Game.notes[id].no_anim = Game.notes[id].dir ~= 1
end

function goodNoteHit(i)
    left.sing(i) boyfriend.sing(i)
    up.sing(math.abs(i - 3)) right.sing(math.abs(i - 3)) 
end

function goodSustainPress(i)
    left.sing(i, '', false) boyfriend.sing(i, '', false)
    up.sing(math.abs(i - 3), '', false) right.sing(math.abs(i - 3), '', false)
end]]