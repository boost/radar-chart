package boost.charts {
	import flash.display.Sprite;

	public class RadarSeries {
		private var _name:String;
		private var _data:Object;
		
		function RadarSeries(name:String, data:Object) {
			_name = name;
			_data = data;
		}
		
		public function get name():String { return _name; }
		public function get data():Object { return _data; }
		
		private var _color:uint;
		private var _hasColor:Boolean = false;
		public function get color():uint { return _color; }
		public function set color(value:uint):void { _color = value; _hasColor = true; }
		internal function get hasColor():Boolean { return _hasColor; }
		
		private var _sprite:Sprite;
		internal function get sprite():Sprite { return _sprite; }
		internal function set sprite(value:Sprite):void { _sprite = value; }
		
		private var _area:Number;
		internal function get area():Number { return _area; }
		internal function set area(value:Number):void { _area = value; }
		
		private var _points:Array;
		internal function get points():Array { return _points; }
		internal function set points(value:Array):void { _points = value; }
	}
}