local bruh = true
local alpha = true
local health = 0
local drain = 0.01
local zooming = false
local zooming2 = false
local zooming3 = false

function onCreate()
    setProperty('health', 2) --sets health to max
    
    makeLuaSprite('filter', 'bg/black', -540, -725) --dark filter just to make shit seem darker
    scaleObject('filter', 2, 2)
    setProperty('filter.alpha', 1)
    addLuaSprite('filter', true)

    setProperty('healthBar.alpha', 0)
    setProperty('iconP1.alpha', 0)
    setProperty('iconP2.alpha', 0)
    setProperty('scoreTxt.alpha', 0)

    makeLuaText('introtext', '', '700', 280, 150) --creates the subtitle text
        setTextAlignment('introtext', 'center')
        setTextSize('introtext', '65')
        setObjectCamera('introtext', 'other')
        setProperty('introtext.alpha', 0)
        addLuaText('introtext')
        setTextFont('introtext', 'VCR.ttf')

    makeLuaText('text', '', '424', 425, 500) --creates the subtitle text, or atleast thats according to the command thats being input
        setTextAlignment('text', 'center')
        setTextSize('text', '40')
        addLuaText('text')
        setTextFont('text', 'vcr.ttf')

    makeLuaText('introtext2', '', '700', 280, 300) --creates the subtitle text, according to 5 different tutorials that i just looked up on youtube
        setTextAlignment('introtext2', 'center')
        setTextSize('introtext2', '65')
        setProperty('introtext2.alpha', 0)
        setObjectCamera('introtext2', 'other')
        addLuaText('introtext2')
        setTextFont('introtext2', 'VCR.ttf')

    makeLuaText('introtext3', '', '700', 280, 500) --creates the subtitle text, or well, thats what it is supposed to do
        setTextAlignment('introtext3', 'center')
        setTextSize('introtext3', '65')
        setProperty('introtext3.alpha', 0)
        setObjectCamera('introtext3', 'other')
        addLuaText('introtext3')
        setTextFont('introtext3', 'VCR.ttf')

    makeLuaText('introtext4', 'WAKE', '1250', 0, 200) --creates the subtitle text, but sometimes it rebels and beats me up. please send help
        setTextAlignment('introtext4', 'center')
        setTextSize('introtext4', '250')
        setProperty('introtext4.alpha', 0)
        setObjectCamera('introtext4', 'other')
        addLuaText('introtext4')
        setTextFont('introtext4', 'VCR.ttf')
        
end

function onUpdate(elapsed)
    if bruh == true then
        setProperty('gf.alpha', 0) -- make gf invisible
        setProperty('boyfriend.alpha', 0) --make bf invisible
    end
    if alpha == true then
        for i = 0,7 do
            setPropertyFromGroup('strumLineNotes', i, 'alpha', 0)
        end
    end
end

function opponentNoteHit(id, direction, noteType, isSustainNote) --if opponent hits a note then drain health based on the current drain value
    health = getProperty('health')
    if health > 0.25 then
	setProperty('health', health- drain);
    end
end

function onSongStart()
    bruh = false
    runTimer('notesappear', 9) --notes say hi hi, text bye bye's
    setProperty('introtext.alpha', 1)
end

function onBeatHit()
    if zooming == true then
        if curBeat % 1 == 0 then
            doTweenZoom('zoom', 'camGame', 1.7, 0.0001, 'linear')
        end
    end
    if zooming2 == true then
        if curBeat % 4 == 1 then
            doTweenZoom('zoom', 'camGame', 1.7, 0.0001, 'linear')
        end
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'notesappear' then -- when timer of the notes are done, camhud is enabled and some text is gone and the main text comes in
        alpha = false
        for i = 0,7 do
            noteTweenAlpha('noteAppear'..i, i, 1, 0.75, 'linear') -- each note strum corresponds with a number ranging from 0 to 7; opponent notes strums are 0-3 while the player's are 4-7 | this takes all note strums and tweens them to become visible
        end
    end
end

function onStepHit() --boy oh boy. i sure love setTextString! anyway team f enchanted coding when

    if curStep == 4 then
        setTextString('introtext', 'I will')
    end

    if curStep == 12 then
        setTextString('introtext', 'I will fool')
    end

    if curStep == 19 then
        setTextString('introtext', 'I will fool the shepherds.')
    end

    if curStep == 32 then -- cool intro 
        doTweenAlpha('shepardaway', 'introtext', 0, 0.2, 'quintIn')
        setProperty('introtext2.alpha', 1)
        setTextString('introtext2', 'I ')
    end

    if curStep == 35 then
        setTextString('introtext2', 'I will')
    end

    if curStep == 38 then
        setTextString('introtext2', 'I will know')
    end

    if curStep == 45 then
        setTextString('introtext2', 'I will know their')
    end

    if curStep == 48 then
        setTextString('introtext2', 'I will know their greatest')
    end

    if curStep == 56 then
        setTextString('introtext2', 'I will know their greatest fear.')
    end

    if curStep == 66 then
        doTweenAlpha('shepardaway2', 'introtext2', 0, 0.2, 'quintIn')
        setProperty('introtext3.alpha', 1)
        setTextString('introtext3', 'I')
    end

    if curStep == 70 then
        setTextString('introtext3', 'I will')
    end

    if curStep == 73 then
        setTextString('introtext3', 'I will know')
    end

    if curStep == 77 then
        setTextString('introtext3', 'I will know your')
    end

    if curStep == 80 then
        setTextString('introtext3', 'I will know your greatest')
    end

    if curStep == 90 then
        setTextString('introtext3', 'I will know your greatest fear.')
    end

    if curStep == 104 then
        doTweenAlpha('shepardaway3', 'introtext3', 0, 0.2, 'quintIn')
    end

    if curStep == 112 then
        setProperty('introtext4.alpha', 1)
    end

    if curStep == 116 then
        setTextString('introtext4', 'UP')
    end

    if curStep == 120 then
        setTextString('introtext4', 'JOSEPH')
    end

    if curStep == 128 then -- text goes away, camhud comes in. i forgot what i intended to do with camera tbh so i commented it out
        setTextString('introtext', ' ')
        setTextString('introtext2', ' ')
        setTextString('introtext3', ' ')
        setTextString('introtext4', ' ')
        setProperty('filter.alpha', 0)
        --doTweenZoom('zoom', 'camGame', 2, 0.2, 'quintIn')
        cameraFlash('game', '000000', 1.0, false)
        setBlendMode('vintage', 'darken')
    end

    if curStep == 256 then
        drain = 0.04
        cameraFlash('game', 'ffffff', 1.0, false)
        setBlendMode('vintage', 'lighten')
        doTweenAlpha('healthfade', 'healthBar', 1, 0.75, 'linear')
        doTweenAlpha('icon1fade', 'iconP1', 1, 0.75, 'linear')
        doTweenAlpha('icon2fade', 'iconP2', 1, 0.75, 'linear')
        doTweenAlpha('scorefade', 'scoreTxt', 1, 0.75, 'linear')
    end
    
    if curStep == 256 or curStep == 320 or curStep == 384 or curStep == 416 or curStep == 448 or curStep == 480 or curStep == 1936 or curStep == 2000 or curStep == 2064 or curStep == 2096 or curStep == 2128 or curStep == 2160 or curStep == 2832 or curStep == 2896 then
        doTweenZoom('zoom', 'camGame', 1.25, 0.0001, 'linear')
    end

    if curStep == 512 or curStep == 514 or curStep == 518 or curStep == 520 or curStep == 524 or curStep == 526 or curStep == 530 or curStep == 532 or curStep == 536 or curStep == 540 or curStep == 544 or curStep == 546 or curStep == 550 or curStep == 552 or curStep == 556 or curStep == 558 or curStep == 562 or curStep == 564 or curStep == 568 or curStep == 572 or curStep == 2192 or curStep == 2194 or curStep == 2198 or curStep == 2200 or curStep == 2204 or curStep == 2206 or curStep == 2210 or curStep == 2212 or curStep == 2216 or curStep == 2220 or curStep == 2224 or curStep == 2226 or curStep == 2230 or curStep == 2232 or curStep == 2236 or curStep == 2238 or curStep == 2242 or curStep == 2244 or curStep == 2248 or curStep == 2252 then
        doTweenZoom('zoom', 'camGame', 1.7, 0.0001, 'linear')
    end
    
    if curStep == 578 or curStep == 732 or curStep == 860 or curStep == 2252 or curStep == 2316 or curStep == 2572 or curStep == 2700 then
        zooming = true
    end

    if curStep == 605 or curStep == 728 or curStep == 780 or curStep == 844 or curStep == 908 or curStep == 2284 or curStep == 2556 or curStep == 2684 or curStep == 2796 then
        zooming = false
    end

    if curStep == 672 then
        drain = 0.02
        cameraFlash('game', 'ffffff', 1.0, false)
        doTweenZoom('zoom', 'camGame', 1.7, 0.0001, 'linear')
        zooming = true
    end

    if curStep == 800 then
        doTweenZoom('zoom', 'camGame', 1.7, 0.0001, 'linear')
        zooming = true
    end

    if curStep == 992 then
        cameraShake('hud', '0.0025', '4.5')
        cameraShake('game', '0.0025', '4.5')
    end

    if curStep == 1064 or curStep == 1192 then
        doTweenZoom('zoom', 'camGame', 1.7, 0.0001, 'linear')
        zooming2 = true
    end

    if curStep == 1160 or curStep == 1288 then
        zooming2 = false
    end

    if curStep == 1344 then -- vintage blends in with character, looks pretty cool. 'wait a second, this sounds familiar to me..' oh, yeah and also a bunch of things being hidden
        drain = 0
        setProperty('healthBar.alpha', 0)
        setProperty('iconP1.alpha', 0)
        setProperty('iconP2.alpha', 0)
        setProperty('scoreTxt.alpha', 0);
        setProperty('timeTxt.alpha', 0);
        setProperty('timeBarBG.alpha', 0);
        setProperty('timeBar.alpha', 0);
        cameraFlash('game', '000000', 2.0, false)
        setBlendMode('vintage', 'darken')
    end
    if curStep == 1936 then -- vintage goes back to "normal"
        drain = 0.01
        setProperty('healthBar.alpha', 1)
        setProperty('iconP1.alpha', 1)
        setProperty('iconP2.alpha', 1)
        setProperty('scoreTxt.alpha', 1);
        setProperty('timeTxt.alpha', 1);
        setProperty('timeBarBG.alpha', 1);
        setProperty('timeBar.alpha', 1);
        cameraFlash('game', 'ffffff', 2.0, false)
        setBlendMode('vintage', 'lighten')
    end

    if curStep == 2832 then
        cameraFlash('game', 'FFFFFF', 2.0, false)
    end

    if curStep == 2960 then
        doTweenAlpha('fadeout', 'filter', 1, 1.2, 'linear')
        doTweenAlpha('GUItween', 'camHUD', 0, 1.2, 'linear');
        doTweenZoom('zoom', 'camGame', 1.25, 0.0001, 'linear')
    end
end

function onGameOver()
    alpha = false
    return Function_Continue;
end