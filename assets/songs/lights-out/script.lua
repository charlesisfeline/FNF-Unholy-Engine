function onCreate()
	setProperty('skipCountdown', true)
end
function onCreatePost()
	runHaxeCode([[
        for(i in 0...4){
            game.playerStrums.members[i].cameras = [game.camGame];
            game.opponentStrums.members[i].cameras = [game.camGame];
            game.playerStrums.members[i].scrollFactor.set(1, 1);
            game.opponentStrums.members[i].scrollFactor.set(1, 1);

            game.playerStrums.members[i].y = -300;

            game.opponentStrums.members[i].y = -300;
            game.opponentStrums.members[i].x = game.opponentStrums.members[i].x - 300;
        }
		for(i in 0...game.unspawnNotes.length){
			game.unspawnNotes[i].cameras = [game.camGame];
			game.unspawnNotes[i].scrollFactor.set(1, 1);  
		}
	]])        
end

function onStepHit()
	if curStep == 128 then
		doTweenAlpha('in1', 'camHUD', 1, 1)
		setProperty('cameraSpeed', 1)
	end
	if curStep == 1536 then
		if flashingLights == true then
			cameraFlash('camHUD', 'FFFFFF', 1)
		end
	end
	if curStep == 1584 then
		setProperty('cameraSpeed', 1)
	end
	if curStep == 1856 then
		setProperty('cameraSpeed', 100)
	end
	if curStep == 1921 then
		setProperty('boyfriendGroup.alpha', false)
	end
end
