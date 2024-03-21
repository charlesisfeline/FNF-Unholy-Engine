var bopOnBeat:Bool = false;
var bopOnOpponentHit:Bool = false;
var bopOnPlayerHit:Bool = false;
var bopMult:Float = 1.3;
function beatHit (beat) {
    switch (beat) {
        case 24:
            PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
            bopOnBeat = true;
        case 8:       PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
        case 40:      PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
        case 56:      PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
        case 72:      PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
        case 88:      PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
        case 168:     PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
        case 185:     PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
        case 200:     PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
        case 216:     PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
        case 232:     PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
        case 248:     PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
        case 312:     PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
        case 328:     PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 1000);
        case 104:
            bopOnBeat = false;
        case 136:
            PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
            bopOnBeat = true;
        case 193:
            bopOnBeat = false;
        case 208:
            bopOnBeat = true;
            bopMult = 0.6;
        case 228:
            bopOnBeat = false;
        case 264:
            PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
            bopOnOpponentHit = true;
            bopMult = 0.4;
        case 280:
            bopOnOpponentHit = false;
            PlayState.camGame.flash(FlxColor.PURPLE, Conductor.crochet / 2000);
            bopOnPlayerHit = true;


    }
    if (bopOnBeat)  {
        bop();
    }
    
}
function bop () {
    if (getPref('camera-zoom')) {
        PlayState.camGame.zoom += 0.015 * bopMult;
        PlayState.camHUD.zoom += 0.03 * bopMult;
    } 
}

function noteHit (note, isPlayer) {
    if (isPlayer && bopOnPlayerHit) bop();
    if (!isPlayer && bopOnOpponentHit) bop();

}
function goodNoteHit(note) noteHit(note, true);
function opponentNoteHit(note) noteHit(note, false); 
