function onCreate()
    runHaxeCode([[
        game.skipArrowStartTween = true;
    ]])
    makeLuaSprite("eroicolor", nil, 0, 0)
    makeGraphic("eroicolor", screenWidth, screenHeight, '8B008B')
    setScrollFactor("eroicolor", 0.0, 0.0)
    setProperty("eroicolor.alpha", 0)
    setObjectCamera("eroicolor", 'other')
    setBlendMode("eroicolor", 'ADD')
    addLuaSprite("eroicolor")

    setPropertyFromClass("openfl.Lib", "application.window.title", "Friday Night Funkin': VS Oruta - "..songName..' - Composed By Tolupu_teru - Charted By Siron')
end

function round(x, n) 
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

function onCreatePost()
    scoreZooom = scoreZoom
    addHaxeLibrary("Highscore")
    runHaxeCode([[
        for (i in 0...8)
        {
            var strumY:Float;
            var strum = game.strumLineNotes.members[i];
            if (strum != null)
            {
                if (i >= 0 && i <= 3)
                {
                    strum.alpha = 0.4;
                }
                if (ClientPrefs.downScroll)
                    strum.y = -500;
                else
                    strum.y = 800;
            }
        }
    ]])

    setPropertyFromClass("ClientPrefs", "scoreZoom", false)
    scoreUpdated()
    getProperty("dad.healthColorArray")
    setProperty("scoreTxt.alpha", 0)

    
    setTextFont("scoreTxt", "default.ttf")
    setTextFont("timeTxt", "default.ttf")
    setProperty("timeTxt.y", getProperty("timeTxt.y") - 15)

    setProperty("healthBarBG.visible", false)
    setProperty("healthBar.visible", false)
end

function onCountdownStarted()
    infoTxt = getTextFromFile('data/'..songPath..'/info.txt', false)

    if downscroll then
        aboutTxtY = 0
    else
        aboutTxtY = 600
    end

    makeLuaText("aboutTxt", string.gsub(infoTxt, "\r", ""), 0, -screenWidth / 2, aboutTxtY)
    setTextSize("aboutTxt", 24)
    setTextAlignment('aboutTxt', 'left')
    setTextFont('aboutTxt', 'default.ttf')
    setTextBorder('aboutTxt', 1, '000000')
    addLuaText('aboutTxt')
    setObjectCamera('aboutTxt', 'hud')
end

function onSongStart()
    runHaxeCode([[
        for (i in 0...8)
        {
            var strum = game.strumLineNotes.members[i];
            if (strum != null)
            {
                FlxTween.tween(strum, {y: (ClientPrefs.downScroll ? (FlxG.height - 150) : 50)}, 0.7, {ease: FlxEase.cubeInOut});
            }
        }
    ]])
    doTweenX('aTTw', 'aboutTxt', 10, 1, 'quintInOut')

    scoreUpdated()
    doTweenAlpha("sTTw", "scoreTxt", 1, 1, "linear")
end

---
--- @param elapsed float
---
function onUpdatePost(elapsed)
    if getProperty("healthBar.percent") == 50 then
        setProperty("iconP1.x", getProperty('healthBar.x') + 500)
        setProperty("iconP2.x", getProperty('healthBar.x') - 100)
    elseif getProperty("healthBar.percent") >= 50 then
        setProperty("iconP1.x", (getProperty("healthBar.x") - (getProperty("healthBar.width") * getProperty("healthBar.percent") * 0.01) + (150 * getProperty("iconP1.scale.x") - 150) / 2 - 26) * 2 + 800)
        setProperty("iconP2.x", getProperty('healthBar.x') - 100)
    elseif getProperty("healthBar.percent") < 50 then
        setProperty("iconP2.x", (getProperty("healthBar.x") - (getProperty("healthBar.width") * getProperty("healthBar.percent") * 0.01) + (150 * getProperty("iconP2.scale.x") - 150) / 2 - 26) * 2 + 200)
        setProperty("iconP1.x", getProperty('healthBar.x') + 500)
    end
end

function onBeatHit()
    if curBeat % 2 == 0 then
        doTweenAngle("1", "iconP1", 20, 0.01, "circInOut")
        doTweenAngle("2", "iconP2", -20, 0.01, "circInOut")
    elseif curBeat % 2 ~= 0 then
        doTweenAngle("1", "iconP1", -20, 0.01, "circInOut")
        doTweenAngle("2", "iconP2", 20, 0.01, "circInOut")
    end
    if curBeat == 16 then
        setProperty("eroicolor.alpha", 0.27)
    elseif curBeat == 257 then
        setProperty("eroicolor.alpha", 0)
    end
    if curBeat >= 16 and curBeat <= 257 then
        if curBeat % 2 == 0 then
            if curBeat == 16 then
                runHaxeCode([[
                    for (i in 0...8)
                    {
                        var strum = game.strumLineNotes.members[i];
                        if (strum != null)
                        {
                            if (i == 3)
                            {
                                FlxTween.tween(strum, {y: strum.y - 30}, 0.1, {ease: FlxEase.sineInOut});
                            }
                            if (i == 7)
                            {
                                FlxTween.tween(strum, {y: strum.y - 30}, 0.1, {ease: FlxEase.sineInOut});
                            }
                        }
                    }
                ]])
            end
            runHaxeCode([[
                for (i in 0...8)
                {
                    var strum = game.strumLineNotes.members[i];
                    if (strum != null)
                    {
                        if (i == 0)
                        {
                            FlxTween.tween(strum, {y: strum.y + 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 1)
                        {
                            FlxTween.tween(strum, {y: strum.y - 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 2)
                        {
                            FlxTween.tween(strum, {y: strum.y + 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 3)
                        {
                            FlxTween.tween(strum, {y: strum.y - 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 4)
                        {
                            FlxTween.tween(strum, {y: strum.y + 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 5)
                        {
                            FlxTween.tween(strum, {y: strum.y - 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 6)
                        {
                            FlxTween.tween(strum, {y: strum.y + 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 7)
                        {
                            FlxTween.tween(strum, {y: strum.y - 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                    }
                }
            ]])
        elseif curBeat % 2 ~= 0 then
            if curBeat == 17 then
                runHaxeCode([[
                    for (i in 0...8)
                    {
                        var strum = game.strumLineNotes.members[i];
                        if (strum != null)
                        {
                            if (i == 0)
                            {
                                FlxTween.tween(strum, {y: strum.y - 30}, 0.1, {ease: FlxEase.sineInOut});
                            }
                            if (i == 1)
                            {
                                FlxTween.tween(strum, {y: strum.y + 30}, 0.1, {ease: FlxEase.sineInOut});
                            }
                            if (i == 2)
                            {
                                FlxTween.tween(strum, {y: strum.y - 30}, 0.1, {ease: FlxEase.sineInOut});
                            }
                            if (i == 3)
                            {
                                FlxTween.tween(strum, {y: strum.y + 30}, 0.1, {ease: FlxEase.sineInOut});
                            }
                            if (i == 4)
                            {
                                FlxTween.tween(strum, {y: strum.y - 30}, 0.1, {ease: FlxEase.sineInOut});
                            }
                            if (i == 5)
                            {
                                FlxTween.tween(strum, {y: strum.y + 30}, 0.1, {ease: FlxEase.sineInOut});
                            }
                            if (i == 6)
                            {
                                FlxTween.tween(strum, {y: strum.y - 30}, 0.1, {ease: FlxEase.sineInOut});
                            }
                            if (i == 7)
                            {
                                FlxTween.tween(strum, {y: strum.y + 30}, 0.1, {ease: FlxEase.sineInOut});
                            }
                        }
                    }
                ]])
            end
            runHaxeCode([[
                for (i in 0...8)
                {
                    var strum = game.strumLineNotes.members[i];
                    if (strum != null)
                    {
                        if (i == 0)
                        {
                            FlxTween.tween(strum, {y: strum.y - 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 1)
                        {
                            FlxTween.tween(strum, {y: strum.y + 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 2)
                        {
                            FlxTween.tween(strum, {y: strum.y - 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 3)
                        {
                            FlxTween.tween(strum, {y: strum.y + 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 4)
                        {
                            FlxTween.tween(strum, {y: strum.y - 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 5)
                        {
                            FlxTween.tween(strum, {y: strum.y + 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 6)
                        {
                            FlxTween.tween(strum, {y: strum.y - 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                        if (i == 7)
                        {
                            FlxTween.tween(strum, {y: strum.y + 20}, 0.1, {ease: FlxEase.sineInOut});
                        }
                    }
                }
            ]])
        end
    end
end

---
--- @param tag string
--- @param ?vars ?
---
function onTweenCompleted(tag, vars)
    if tag == '1' then
        doTweenAngle("1a", "iconP1", 0, 0.2, "linear")
    elseif tag == '2' then
        doTweenAngle("2a", "iconP2", 0, 0.2, "linear")
    end
end

function scoreUpdated()
    customAccuracy = round(rating * 100, 2)
    if ratingFC ~= '' then
        setTextString('scoreTxt', 'Score: '..getProperty('songScore')..'\nCombo Breaks: '..getProperty('songMisses')..'\nAccuracy: '..customAccuracy..'%\nRating: '..getProperty("ratingName")..'\nFC: '..ratingFC)
    else
        setTextString('scoreTxt', 'Score: '..getProperty('songScore')..'\nCombo Breaks: '..getProperty('songMisses')..'\nAccuracy: '..customAccuracy..'%\nRating: '..getProperty("ratingName")..'\nFC: ?')
    end
    setTextAlignment("scoreTxt", 'left')
    screenCenter("scoreTxt", 'y')
    setProperty("scoreTxt.x", 10)
end

---
--- @param miss boolean
---
function onUpdateScore(miss)
    scoreUpdated()
end

function onEndSong()
    setPropertyFromClass("ClientPrefs", "scoreZoom", scoreZooom)
end

---
--- @param eventName string
--- @param value1 string
--- @param value2 string
--- @param strumTime float
---
function onEvent(eventName, value1, value2, strumTime)
    if eventName == 'Flash Camera' then
        runHaxeCode([[
            for (i in 0...8)
            {
                var strum = game.strumLineNotes.members[i];
                if (strum != null)
                {
                    if (strum.angle == 360)
                    {
                        if (i == 0)
                        {
                            FlxTween.tween(strum, {angle: 0}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 1)
                        {
                            FlxTween.tween(strum, {angle: 0}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 2)
                        {
                            FlxTween.tween(strum, {angle: 0}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 3)
                        {
                            FlxTween.tween(strum, {angle: 0}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 4)
                        {
                            FlxTween.tween(strum, {angle: 0}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 5)
                        {
                            FlxTween.tween(strum, {angle: 0}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 6)
                        {
                            FlxTween.tween(strum, {angle: 0}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 7)
                        {
                            FlxTween.tween(strum, {angle: 0}, 0.5, {ease: FlxEase.sineInOut});
                        }
                    }
                    else
                    {
                        if (i == 0)
                        {
                            FlxTween.tween(strum, {angle: 360}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 1)
                        {
                            FlxTween.tween(strum, {angle: 360}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 2)
                        {
                            FlxTween.tween(strum, {angle: 360}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 3)
                        {
                            FlxTween.tween(strum, {angle: 360}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 4)
                        {
                            FlxTween.tween(strum, {angle: 360}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 5)
                        {
                            FlxTween.tween(strum, {angle: 360}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 6)
                        {
                            FlxTween.tween(strum, {angle: 360}, 0.5, {ease: FlxEase.sineInOut});
                        }
                        if (i == 7)
                        {
                            FlxTween.tween(strum, {angle: 360}, 0.5, {ease: FlxEase.sineInOut});
                        }
                    }
                }
            }
        ]])
    end
end

function onDestroy()
    setPropertyFromClass("openfl.Lib", "application.window.title", "Friday Night Funkin': VS Oruta")
end