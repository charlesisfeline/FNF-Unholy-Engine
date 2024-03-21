function onCreatePost()
     setProperty('timeBar.visible', false)
    setProperty('timeBar.x', 10)
    setProperty('timeBarBG.visible', false)
    setProperty('timeTxt.x', 750)
    setProperty('timeTxt.y', 45)
    setProperty('healthBar.visible', false)
    setProperty('healthBarBG.visible', false)
    for i = 0,3 do
        setPropertyFromGroup('opponentStrums', i, 'visible', false);
        setPropertyFromGroup('opponentStrums', i, 'x', -1000);
        setPropertyFromGroup('playerStrums', i, 'y', 15);
    end
end
function onUpdatePost()
       setProperty('scoreTxt.scale.x', 0.5)
       setProperty('scoreTxt.scale.y', 0.5)
        setProperty('scoreTxt.alpha', 0.25)
        setProperty('iconP2.x', 10)
	setProperty('iconP2.y', 570)
	setProperty('iconP1.x', 1130)
	setProperty('iconP1.y', 580)
end