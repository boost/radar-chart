package boost.charts {
	import flash.geom.Point;
	import mx.controls.Label;
	import flash.events.EventDispatcher;
	import flash.display.Sprite;
	import boost.charts.RadarChart;

	internal class RadarAxis {
		private var _name:String;
		private var _text:String;
		private var _chart:RadarChart;
		
		function RadarAxis(chart:RadarChart, name:String, text:String = null) {
			_chart = chart;
			_name = name;
			_text = text ? text : name;
		}
		
		public function get name():String { return _name; }
		public function get text():String { return _text; }
		
		private var _angle:Number;
		internal function get angle():Number { return _angle; }
		internal function set angle(value:Number):void { _angle = value; }
		
		private var _length:Number;
		internal function get length():Number { return _length; }
		internal function set length(value:Number):void { _length = value; }
		
		private var _start:Point;
		private var _end:Point;
		internal function get start():Point { return _start; }
		internal function get end():Point { return _end; }
		internal function set start(value:Point):void { _start = value; }
		internal function set end(value:Point):void { _end = value; }
		
		private var _label:Label;
		public function get label():Label { return _label; }
		public function set label(value:Label):void { _label = value; }
		
		private var _labels:Array;
		public function get labels():Array { return _labels; }
		public function set labels(value:Array):void { _labels = value; }
		
		private var _max:Number;
		private var _min:Number;
		internal function get max():Number { return _max; }
		internal function get min():Number { return _min; }
		internal function set max(value:Number):void { _max = value; }
		internal function set min(value:Number):void { _min = value; }
		
		private var _updated:Boolean;
		internal function get updated():Boolean { return _updated; }
		internal function set updated(value:Boolean):void { _updated = value; }
	}
}