var maxHealth:Int = 2;
var enabled:Bool = false;
function badNoteHit(direction:Int) {
    maxHealth = PlayState.health;
    enabled = true;
}
function noteMiss(noteMissed:Note) {
    maxHealth = PlayState.health;
    enabled = true;
}
function updatePost(elapsed) {
    if (enabled) {
        if (maxHealth < PlayState.health) PlayState.health = maxHealth;
    }
}
function opponentNoteHit (note) {
    if (PlayState.dad.iconSpr.isDying) {
            
    }
}