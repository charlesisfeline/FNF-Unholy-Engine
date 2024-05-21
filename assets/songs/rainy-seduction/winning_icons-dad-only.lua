--Script by _Boxed!
--Script fixed by Shokora! Big thanks to them!
function onCreate()
	makeLuaSprite('winningIconDad', 'icons/win-'..getProperty('boyfriend.healthicon'), getProperty('iconP2.x'), getProperty('iconP2.y'))
	setObjectCamera('winningIconDad', 'hud')
	addLuaSprite('winningIconDad', true)
	setObjectOrder('winningIconDad', getObjectOrder('iconP2') + 1)
	setProperty('winningIconDad.flipX', false)
	setProperty('winningIconDad.visible', false)
	
	dad = getProperty('boyfriend.healthicon')
end

function onUpdate(elapsed)
		dad = getProperty('dad.healthicon')
		--WHITELIST add more characters if you wish
		--if dad == 'dad' or dad =='dad' or dad =='dad' or dad =='dad' --WHITELIST - comment '--' to disable, uncomment to enable
		--BLACKLIST add more characters if you wish
		--if not dad =='dad' or dad =='dad' or dad =='dad' or dad =='dad' --BLACKLIST - comment '--' to disable, uncomment to enable
		--then --uncomment if using WHITELIST or BLACKLIST
			makeLuaSprite('winningIconDad', 'icons/win-'..getProperty('iconP2.animation.curAnim.name'), getProperty('iconP2.x'), getProperty('iconP2.y'))
			setObjectCamera('winningIconDad', 'hud')
			addLuaSprite('winningIconDad', true)
			setObjectOrder('winningIconDad', getObjectOrder('iconP2') + 1)
			setProperty('winningIconDad.flipX', false)
			setProperty('winningIconDad.visible', false)
		
			setProperty('winningIconDad.x', getProperty('iconP2.x'))
			setProperty('winningIconDad.angle', getProperty('iconP2.angle'))
			setProperty('winningIconDad.y', getProperty('iconP2.y'))
			setProperty('winningIconDad.scale.x', getProperty('iconP2.scale.x'))
			setProperty('winningIconDad.scale.y', getProperty('iconP2.scale.y'))
			
			if getProperty('health') <= .375 then
				setProperty('iconP2.visible', false)
				setProperty('winningIconDad.visible', true)
			else
				setProperty('iconP2.visible', true)
				setProperty('winningIconDad.visible', false)
			end
		--end --uncomment if using WHITELIST or BLACKLIST
end