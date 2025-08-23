package mobile.objects.grid;

class GridTileDonate extends GridTile {
    public function new(host:GridButtons) {
        super(host,() ->{
            CoolUtil.browserLoad('https://needlejuicerecords.com/pages/friday-night-funkin');
        });
        final name = 'donate';
        configureBitmap('mainmenu/menu_' + name, name + " basic", name + " white");
    }
    override function playSelectedAnim()
	{
		callback();
        host.selectedSomethin = false;
        // var state = cast (FlxG.state,MainMenuState);
        // @:privateAccess
        // state.selectedSomethin = false;
	}
}