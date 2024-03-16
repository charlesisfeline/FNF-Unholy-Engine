
local go = false
function onUpdatePost(e)
	if (formatTime(getProperty('songLength') - (getSongPosition() - noteOffset))) == '2:15' then
		go = true
	end
	if (formatTime(getProperty('songLength') - (getSongPosition() - noteOffset))) == '1:55' then
		go = false
	end

	if go then 
		setProperty('iconP2.animation.curAnim.curFrame', 1) 
	end
end

function formatTime(ms) -- stolen :imp:
	s = math.floor(ms/1000);
	return string.format('%01d:%02d', (s/60)%60, s%60);
end

function onUpdate(e)
	if keyJustPressed('space') then
		setPropertyFromClass('Conductor', 'songPosition', 1080000)
		setProperty('vocals.time', 1080000)
		setPropertyFromClass('flixel.FlxG', 'sound.music.time', 1080000)
	end
end	

function onEvent(n)
	if go then
		if n == 'Change Character' then
			triggerEvent('Add Camera Zoom', '', '')
			if getProperty('health') > 0.08 then
				setProperty('health', getProperty('health') - 0.08)
			end
		end
	end
end

function onCreatePost()
	for i = 0, getProperty('eventNotes.length') do
		if getPropertyFromGroup('eventNotes', i, 'value1') == '0' or getPropertyFromGroup('eventNotes', i, 'value1') == 'bf' then
			removeFromGroup('eventNotes', i)
		end
	end
end