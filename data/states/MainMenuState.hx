

function update() {
    if(FlxG.keys.justPressed.P) FlxG.switchState(new ModState("PortalState"));
}