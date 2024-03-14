function onBeatHit()
    if curBeat % 2 == 0 and getProperty('boyfriend.animation.curAnim.name') == 'idle' then
        characterPlayAnim('boyfriend', 'idle', true)
    end

    if curBeat % 2 == 0 and getProperty('dad.animation.curAnim.name') == 'idle' then
        characterPlayAnim('dad', 'idle', true)
    end

end