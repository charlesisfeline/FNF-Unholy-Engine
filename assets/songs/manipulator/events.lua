function onCreatePost()
    addCharacterToList('fakebflaugh', 'dad')
    addCharacterToList('fakebf2', 'dad')
end

function onStepHit()
    if curStep == 832 then
        triggerEvent('Change Character', 1, 'fakebflaugh')
        playAnim('dad', 'laugh')
    elseif curStep == 848 then
        cameraFlash('camGame', 'FFFFFF', 0.5)
        triggerEvent('Change Character', 1, 'fakebf2')
    end
end

function onBeatHit()
    if curStep >= 848 then
        playAnim('gf', 'cheer')
    end
end