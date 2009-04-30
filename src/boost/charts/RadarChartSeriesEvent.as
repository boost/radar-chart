package boost.charts {
	import flash.events.Event;
	
	public class RadarChartSeriesEvent extends Event {
		public static const SERIES_ROLL_OUT:String = "series_roll_out";
		public static const SERIES_ROLL_OVER:String = "series_roll_over";
		public static const SERIES_CLICK:String = "series_click";
		
		private var _series:RadarSeries;
		
		public function RadarChartSeriesEvent(type:String, series:RadarSeries, bubbles:Boolean = false, cancelable:Boolean = false) {
			_series = series;
			super(type, bubbles, cancelable);
		}
		
		public function get series():RadarSeries {
			return _series;
		}
	}
}