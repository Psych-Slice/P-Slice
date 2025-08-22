package mobile.objects;


import mobile.objects.grid.GridTile;
import flixel.util.FlxSignal.FlxTypedSignal;

@:access(mobile.objects.grid.GridTile.new)
class GridButtons extends FlxTypedSpriteGroup<GridTile>
{
	public final onItemSelect:FlxTypedSignal<GridTile -> Void> = new FlxTypedSignal();
	public var selectedItem(get, never):Null<GridTile>;
	public var selectedSomethin:Bool = false;

	
	private var selectedXPosition:Int = 0;
	private var selectedYPosition:Int = 0;
	private var buttons:Array<Array<GridTile>> = new Array();


	function get_selectedItem():GridTile
	{
		if (selectedXPosition < 0 || selectedYPosition < 0)
			return null;
		return buttons[selectedXPosition][selectedYPosition];
	}

	final xItemOffset:Float;

	public function new(x:Float, y:Float,x_length:Int, xItemOffset:Int = 200)
	{
		super(x,y);
		for (i in 0...x_length)
		{
			buttons.push(new Array());
		}
		this.xItemOffset = xItemOffset;
	}

	public function makeButton(name:String, gridX:Int, callback:() -> Void):GridTile
	{
		var menuItem:GridTile = new GridTile(this, callback);
		menuItem.configureBitmap('mainmenu/menu_' + name, name + " basic", name + " white");
		addButton(menuItem, gridX);
		return menuItem;
	}

	public function addButton(menuItem:GridTile, gridX:Int)
	{
		var offsetX:Float = gridX * xItemOffset;
		var offsetY:Float = buttons[gridX].length * 160;
		menuItem.x = offsetX;
		menuItem.y = offsetY;
		menuItem.gridXPos = gridX;
		menuItem.gridYPos = buttons[gridX].length;
		buttons[gridX].push(menuItem);
		add(menuItem);
		// button.updateHitbox();
	}

	public function selectButton(x:Null<Int> = null, y:Null<Int> = null)
	{
        if(selectedSomethin) return;
        if(x != null || y != null){
			selectedItem?.playIdleAnim();
            if(x != null) selectedXPosition = x;
            if(y != null) selectedYPosition = y;
        }

		FlxG.sound.play(Paths.sound('scrollMenu'));
		selectedItem?.playHoverAnim();
	}
    public function changeSelection(xDiff:Int,yDiff:Int) {
		selectedItem?.playIdleAnim();
        selectedXPosition = FlxMath.wrap(selectedXPosition+xDiff,0,buttons.length-1);
        selectedYPosition = FlxMath.wrap(selectedYPosition+yDiff,0,buttons[selectedXPosition].length-1);
        selectButton();
    }

	public function confirmCurrentButton()
	{
        if(selectedSomethin) return;
		selectedSomethin = true;

		onItemSelect.dispatch(selectedItem);
        selectedItem.playSelectedAnim();

	}
	public function hideButtons() {
		var curItem = selectedItem;
		for (item in members)
			if (item != curItem) item.hideTile();
	}
	public function revealButtons() {
		for (item in members){

			item.revive();
			item.alpha = 1;
			item.visible = true;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

}

