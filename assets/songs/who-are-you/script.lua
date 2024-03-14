function onCreate()
	setProperty('timeTxt.visible', false)
        setProperty('timeBar.visible', false)
        setProperty('timeBarBG.visible', false)
        setProperty('scoreTxt.visible', false)
	setProperty("bg.alpha", 0);
	setProperty('gf.visible', false);
end

stepHitFuncs = {
	[90] = function()
	doTweenZoom('zoom', 'camGame', 1.7, 5, 'quadInOut')
	end,
	[120] = function()
	cancelTween('zoom')
	setProperty('boyfriend.visible', false)
	setProperty('dad.visible', false)
	end,
	[128] = function()
	setProperty('boyfriend.visible', true)
	setProperty("bg.alpha", 1);
	doTweenAlpha('fuck', 'thefuck', 0, 0.0001, 'smootherInOut')
	addLuaSprite('shine', true);
		   makeLuaSprite('flash', '', 0, 0);
        makeGraphic('flash',1280,720,'FFFFFF')
	      addLuaSprite('flash', true);
	      setLuaSpriteScrollFactor('flash',0,0)
	      setProperty('flash.scale.x',2)
	      setProperty('flash.scale.y',2)
	      setProperty('flash.alpha',0)
		setProperty('flash.alpha',1)
		doTweenAlpha('flTw','flash',0,2,'smootherInOut')
	end,
}

function onStepHit()
    if stepHitFuncs[curStep] then 
        stepHitFuncs[curStep]() -- Executes function at curStep in stepHitFuncs
    end
end


