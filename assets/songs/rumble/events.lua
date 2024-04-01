bg1 = {'ext', 'wall', 'lamp', 'henchman', 'boof', 'light', 'boxes', 'add', 'filter', 'd'}
bg2 = {'bg', 'light2'}

function onCreatePost()
    normalBG()

    addCharacterToList('convict', 'dad')
    addCharacterToList('gorevict50', 'dad')
    addCharacterToList('twistedconvict', 'dad')
    addCharacterToList('flashvict1', 'dad')
    addCharacterToList('flashvict2', 'dad')

    addCharacterToList('pico', 'boyfriend')
    addCharacterToList('flashpico', 'boyfriend')
end

function onStepHit()
    if curStep == 528 then
        playAnim('dad', 'laugh')
    elseif curStep == 632 or curStep == 1552 or curStep == 1934 then
        triggerEvent('Change Character', 1, 'gorevict50')
        playAnim('henchman', 'idleAlt', true)
    elseif curStep == 896 then
        cameraFlash('camGame', 'FFFFFF', 0.5, false)
        flashback()
        triggerEvent('Change Character', 1, 'flashvict1')
        triggerEvent('Change Character', 0, 'flashpico')
    elseif curStep == 1044 then
        triggerEvent('Change Character', 1, 'flashvict2')
    elseif curStep == 1164 then
        cameraFlash('camGame', 'FFFFFF', 0.5, false)
        normalBG()
        triggerEvent('Change Character', 1, 'convict')
        triggerEvent('Change Character', 0, 'pico')
    elseif curStep == 1452 or curStep == 1776 then
        triggerEvent('Change Character', 1, 'twistedconvict')
    end
end

-- EVENT CODE

function flashback()
    setProperty('defaultCamZoom', 0.9)
    for i = 1, #bg1 do
        setProperty(bg1[i]..'.visible', false)
    end
    for i = 1, #bg2 do
        setProperty(bg2[i]..'.visible', true)
    end
end

function normalBG()
    setProperty('defaultCamZoom', 0.5)
    for i = 1, #bg1 do
        setProperty(bg1[i]..'.visible', true)
    end
    for i = 1, #bg2 do
        setProperty(bg2[i]..'.visible', false)
    end
end