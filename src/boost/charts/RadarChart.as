package boost.charts {
	import boost.common.ArrayExtension;
	import boost.common.ui.Util;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.controls.Label;
	import mx.core.UIComponent;
	
	[Style(name="centerRadius",type="Number",format="Length",inherit="yes")]
	[Style(name="axisColor",type="uint",format="Color",inherit="yes")]
	[Style(name="axisThickness",type="Number",format="Length",inherit="yes")]
	[Style(name="axisAlpha",type="Number",inherit="yes")]
	[Style(name="tickColor",type="uint",format="Color",inherit="yes")]
	[Style(name="tickThickness",type="Number",format="Length",inherit="yes")]
	[Style(name="tickAlpha",type="Number",inherit="yes")]
	// [Style(name="tickLength",type="Number",format="Length",inherit="yes")]
	[Style(name="showTicks",type="Boolean",inherit="yes")]
	[Style(name="showTitles",type="Boolean",inherit="yes")]
//	[Style(name="showLabels",type="Boolean",inherit="yes")]
	[Style(name="seriesLineThickness",type="Number",format="Length",inherit="yes")]
	[Style(name="seriesLineAlpha",type="Number",inherit="yes")]
	[Style(name="seriesFillAlpha",type="Number",inherit="yes")]
	[Style(name="seriesPointSize",type="Number",format="Length",inherit="yes")]
	[Style(name="seriesPointAlpha",type="Number",inherit="yes")]
	[Style(name="colors",type="Array",format="Color",inherit="yes")]
	[Style(name="rotateText",type="Boolean",inherit="no")]
	[Event(name="series_roll_out", type="common.charts.RadarChartSeriesEvent")]
	[Event(name="series_roll_over", type="common.charts.RadarChartSeriesEvent")]
	[Event(name="series_roll_click", type="common.charts.RadarChartSeriesEvent")]
	/**
	 * A radar (spider) chart implementation. This type of chart has multiple
	 * axes arranged in a circle around the center point. Each series has a point
	 * on each axes, connected with lines.
	 * 
	 * @example Example use: <listing>
	 *   var chart:RadarChart = new RadarChart();
	 *   addChild(chart);
	 *
	 *   chart.addAxis('bread');
	 *   chart.addAxis('cheese');
	 *   chart.addAxis('wine');
	 *   chart.addAxis('fish');
	 *   chart.addAxis('meat');
	 * 
	 *   chart.addSeries('Male', {bread: 3, cheese: 4, wine: 5, fish: 1, meat: 4});
	 *   chart.addSeries('Female', {bread: 4, cheese: 2, wine: 4, fish: 5, meat: 3});  
	 * </listing>
	 *  
	 * @author jeremy
	 * 
	 */	
	public class RadarChart extends UIComponent
	{		
		/**
		 * Array of RadarAxis objects on this chart 
		 */		
		private var _axes:Array;
		/**
		 * Array of RadarSeries objects on this chart 
		 */		
		private var _series:Array;
		/**
		 * Center point of the chart  
		 */		
		private var _center:Point;
		/**
		 * Calculated radius of the axis lines 
		 */		
		private var _radius:Number;
		/**
		 * Calculated gap required for axis labels 
		 */		
		private var _labelGap:Number;
		/**
		 * Boolean indicating commitProperties has been called 
		 */		
		private var propertiesCommitted:Boolean = false;
		/**
		 * Boolean used to block series events from being dispatched while
		 * series are being drawn 
		 */		
		private var eventBlock:Boolean = false;
		
        // Define a static variable.
        private static var classConstructed:Boolean = classConstruct();
    
        // Define a static method.
        private static function classConstruct():Boolean {
        	Util.generateDefaultCSS("RadarChart", function():void {
        		this.centerRadius = 5;
        		
        		this.axisColor = 0;
        		this.axisThickness = 1;
        		this.axisAlpha = 1;
        		
        		this.tickColor = 0;
        		this.tickThickness = 1;
        		this.tickAlpha = 1;
        		this.tickLength = 5;
        		
        		this.showTicks = true;
        		this.showTitles = true;
        		this.showLabels = true;
        		
        		this.seriesPointSize = 5;
        		this.seriesPointAlpha = 1;
        		
        		this.seriesLineThickness = 2;
        		this.seriesLineAlpha = 0.5;
        		this.seriesFillAlpha = 0.1;
        		
        		this.seriesHighlightPointSize = 5;
        		this.seriesHighlightPointAlpha = 1;
        		this.seriesHighlightLineThickness = 2;
        		this.seriesHighlightLineAlpha = 0.8;
        		this.seriesHighlightFillAlpha = 0.5;
        		
        		this.seriesHighlightOtherPointSize = 5;
        		this.seriesHighlightOtherPointAlpha = 0.5;
        		this.seriesHighlightOtherFillAlpha = 0.1;
        		this.seriesHighlightOtherLineAlpha = 0.2;
        		this.seriesHighlightOtherLineThickness = 2;
        		
        		this.colors = [0x257BB6, 0xB7247C, 0xCCC012, 0x41C04F, 0x296997, 0x26B69B, 0xCF5F0B, 0xA041C1];
        		
        		this.rotateText = false;
        		
                this.paddingLeft = 10;
                this.paddingRight = 10;
                this.paddingTop = 10;
                this.paddingBottom = 10;
                this.paddingMiddle = 20;

                this.backgroundColor = 0xECECEC;

                this.borderColor = 0x9d9d9d;
                this.borderThickness = 1;
                this.borderAlpha = 1;
        	});
        	
        	return true;
        }	
		
		function RadarChart() {
			super();
			
			// Initialize boost array extension
			ArrayExtension.extend();
			
			_axes = new Array();
			_series = new Array();
		}
		
		/**
		 * Array of axes on this chart 
		 * @return 
		 * 
		 */		
		private function get axes():Array {
			return _axes;
		}
		
		/**
		 * Add an axis with a name and an optional label. The label will be set
		 * to the name if not provided.
		 *  
		 * @param name
		 * @param label
		 * 
		 */		
		public function addAxis(name:String, label:String = null):void {
			_axes.push(new RadarAxis(this, name, label));
			invalidateAxes();
		}
		
		/**
		 * Remove an axis by name.
		 * @param name
		 * 
		 */		
		public function removeAxis(name:String):void {
			_axes = _axes.filter(function(o:RadarAxis, i:int, a:Array):Boolean {
				return o.name != name;
			});
			
			invalidateAxes();
		}
		
		/**
		 * Get a readonly array of series on the chart. 
		 * @return 
		 * 
		 */		
		public function get series():Array {
			return _series.clone();
		}
		
		/**
		 * Add a series. The name of the series should be unique. The data should
		 * be an object with numerical values keyed to axes on this chart.
		 * 
		 * @param name
		 * @param data
		 * @param color
		 * 
		 */		
		public function addSeries(name:String, data:Object, color:Object = null):void {
			var series:RadarSeries = new RadarSeries(name, data);
			if(color != null) 
				series.color = uint(color);
			_series.push(series);
				
			invalidateAxes();
		}
		
		/**
		 * Remove a series by name. 
		 * @param name
		 * 
		 */		
		public function removeSeries(name:String):void {
			_series = _series.filter(function(o:RadarSeries, i:int, a:Array):Boolean {
				return o.name != name;
			});
			
			invalidateAxes();
		}
		
		/**
		 * Invalidate everything required when changing an axis 
		 * 
		 */		
		private function invalidateAxes():void {
			invalidateSize();
			invalidateProperties();
			invalidateDisplayList();
		}
		
		/**
		 * Gather all series data for this axis. Returns an object in the form
		 * { series_a: value, series_b: value, series_c: value }
		 *   
		 * @param name
		 * @return 
		 * 
		 */		
		private function getAxisData(name:String):Object {
			var data:Object = {};
			
			for each(var serie:Object in series) {
				var value:Object = serie.data[name];
				data[serie.name] = Number(value);
			}
			
			return data;
		}
		
		/**
		 * Convert an object (hash) into an array of the objects values. For
		 * example, {a: 1, b: 2, c: 3} becomes [1, 2, 3].
		 *  
		 * @param hash
		 * @return 
		 * 
		 */		
		private function hashToArray(hash:Object):Array {
			var arr:Array = [];
			for(var m:String in hash)
				arr.push(hash[m]);
			return arr;
		}
		
		/**
		 * Get the maximum series value on an axis. 
		 * @param name
		 * @return 
		 * 
		 */		
		private function getAxisMax(name:String):Number {
			return hashToArray(getAxisData(name)).max();
		}
		
		/**
		 * Get the minimum series value on an axis. 
		 * @param name
		 * @return 
		 * 
		 */		
		private function getAxisMin(name:String):Number {
			return hashToArray(getAxisData(name)).min();
		}
		
		/**
		 * Collect any data required for each axis before drawing commences. 
		 * 
		 */		
		private function updateAxes():void {
			var totalMax:Number = Math.ceil(axes.collect('name').map(function(name:String, i:int, a:Array):Number {
				return getAxisMax(name);
			}).max());
			
			for each(var axis:RadarAxis in axes) {
				updateAxis(axis, totalMax);
			}
		}
		
		/**
		 * Create axis labels and update min and max data  
		 * @param axis
		 * @param totalMax
		 * 
		 */		
		private function updateAxis(axis:RadarAxis, totalMax:Number):void {
			axis.max = totalMax; //Math.ceil(getAxisMax(axis.name));
			axis.min = Math.floor(getAxisMin(axis.name));
			
			if(axis.labels) {
				for each(var oldLabel:Label in axis.labels) {
					removeChild(oldLabel);
				}
			}
			
			axis.labels = new Array();
			
			for(var i:Number = 1; i <= axis.max; i++) {
				var label:Label = new Label();
				label.data = i;
				label.text = i.toString();
				label.setStyle('textAlign', 'center');
				axis.labels.push(label);
				addChild(label);
			}

			if(axis.label)
				removeChild(axis.label);
				
			axis.label = new Label();
			axis.label.text = axis.text;
			axis.label.setStyle('textAlign', 'center');
			addChild(axis.label);
			
			axis.updated = true;
		}

		/**
		 * @inheritDoc 
		 * 
		 */
		override protected function createChildren():void {
			super.createChildren();				
		}		
		
		/**
		 * @inheritDoc 
		 * 
		 */		
		override protected function commitProperties():void {
			super.commitProperties();
			updateAxes();
			propertiesCommitted = true;
		}

		/**
		 * @inheritDoc 
		 * 
		 */
		override protected function measure():void {
			super.measure();
		}
		
		/**
		 * @inheritDoc 
		 * @param unscaledWidth
		 * @param unscaledHeight
		 * 
		 */		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			if(!propertiesCommitted) { invalidateProperties(); return; }
			
			var g:Graphics = graphics;
			g.clear();
			
			g.beginFill(getStyle('backgroundColor'), getStyle('backgroundAlpha'));
			g.lineStyle(
				getStyle('borderThickness'),
				getStyle('borderColor'),
				getStyle('borderAlpha')
			);
			
			g.drawRect(0, 0, unscaledWidth-getStyle('borderThickness'), unscaledHeight-getStyle('borderThickness'));
			g.endFill();
			
			_center = new Point(unscaledWidth/2, unscaledHeight/2);
			_radius = (Math.min(unscaledWidth, unscaledHeight)/2) - axes.collect('labels').flatten().compact().max('getExplicitOrMeasuredHeight');
			
			if(getStyle('showTitles'))
				_labelGap = axes.collect('label').max('textHeight');
			else
				_labelGap = 0;

			g.lineStyle(getStyle('axisThickness'), getStyle('axisColor'), getStyle('axisAlpha'));
			
			if(getStyle('centerRadius') > 0)
				g.drawCircle(_center.x, _center.y, getStyle('centerRadius'));
			
			drawAxes();
			drawSeries();
		}
		
		/**
		 * Setup an axis for drawing by calculating its start and end points
		 * @param axis
		 * @param angle
		 * 
		 */		
		private function setupAxisForDrawing(axis:RadarAxis, angle:Number):void {
			axis.angle = angle;
			
			axis.start = new Point(
				_center.x + Math.cos(angle) * getStyle('centerRadius'),
				_center.y + Math.sin(angle) * getStyle('centerRadius')
			);
				
			axis.end = new Point(
				_center.x + Math.cos(angle) * (_radius - _labelGap),
				_center.y + Math.sin(angle) * (_radius - _labelGap)
			);
				
			axis.length = _radius - (getStyle('centerRadius') + _labelGap);
		}
		
		/**
		 * Position the axis' label 
		 * @param axis
		 * 
		 */		
		private function positionAxisLabel(axis:RadarAxis):void {
			axis.label.visible = getStyle('showTitles');
			
			if(axis.label.visible) {
				axis.label.rotation = 0;
				Util.actualize(axis.label, true);
				
				if(getStyle('rotateText')) {
					var opposite:Number = axis.label.width/2;
					var adjacent:Number = _radius + _labelGap;
					var hypoenuse:Number = Math.sqrt(Math.pow(opposite,2) + Math.pow(adjacent, 2));
					var angle:Number = Math.atan(opposite / adjacent);
					
					axis.label.move(
						_center.x + Math.cos(axis.angle - angle) * hypoenuse,
						_center.y + Math.sin(axis.angle - angle) * hypoenuse
					);					
					
					axis.label.rotation = axis.angle * 180/Math.PI + 90;
					
					var ta:Number = axis.label.rotation;
					if(ta < 0) ta += 360;
					
					if(ta > 135 && ta < 270) {
						axis.label.rotation += 180;
						axis.label.move(
							_center.x + Math.cos(axis.angle + angle) * (hypoenuse - axis.label.height),
							_center.y + Math.sin(axis.angle + angle) * (hypoenuse - axis.label.height)
						);
					}
				} else {
					axis.label.move(
						_center.x + Math.cos(axis.angle) * (_radius + _labelGap - axis.label.height),
						_center.y + Math.sin(axis.angle) * (_radius + _labelGap - axis.label.height)
					);
					
					if(axis.angle > Math.PI/2 && axis.angle < 1.5*Math.PI)
						axis.label.x -= axis.label.width;
					
					axis.label.y -= axis.label.height/2;
				}
			}
		}
		
		/**
		 * Position the axis' scale labels 
		 * @param axis
		 * @param label
		 * 
		 */		
		private function positionAxisLabels(axis:RadarAxis, label:Label):void {
			label.visible = getStyle('showLabels');
			
			// Calculate percent down the axis
			var percent:Number = Number(label.data) / axis.max;
			// Calculate position down the axis
			var radius:Number = (axis.length * percent) + getStyle('centerRadius');
			
			if(label.visible) {
				// Size the label
				Util.actualize(label, true);
			
				// Calculate an offset angle taking into account the labels width
				// so that it appears under the line instead of on it
				var opposite:Number = label.textWidth + getStyle('centerRadius');
				var adjacent:Number = radius;
				var hypotenuse:Number = Math.sqrt(Math.pow(opposite, 2) + Math.pow(adjacent, 2));
				var angle:Number = Math.atan(opposite / adjacent);
				
				var point:Point = new Point(
					_center.x + Math.cos(axis.angle + angle) * hypotenuse,
					_center.y + Math.sin(axis.angle + angle) * hypotenuse
				);
	
				point.x -= (label.width/2);
				point.y -= (label.height/2);
				label.move(point.x, point.y);
			}
			
			// Draw the tick
			drawTick(axis, radius);
		}
		
		/**
		 * Draw a tick mark on an axis 
		 * @param axis
		 * @param position
		 * 
		 */		
		private function drawTick(axis:RadarAxis, position:Number):void {
			var length:Number = getStyle('tickLength');
			var opposite:Number = length /2 ;
			var adjacent:Number = position;
			var hypotenuse:Number = Math.sqrt(Math.pow(opposite, 2) + Math.pow(adjacent, 2));
			var angle:Number = Math.atan(opposite / adjacent);
					
			graphics.lineStyle(
				getStyle('tickThickness'),
				getStyle('tickColor'),
				getStyle('tickAlpha')
			);		
						
			graphics.moveTo(
				_center.x + Math.cos(axis.angle - angle) * hypotenuse,
				_center.y + Math.sin(axis.angle - angle) * hypotenuse
			);					
			graphics.lineTo(
				_center.x + Math.cos(axis.angle + angle) * hypotenuse,
				_center.y + Math.sin(axis.angle + angle) * hypotenuse
			);
		}
		
		/**
		 * Draw an axis 
		 * @param axis
		 * 
		 */		
		private function drawAxis(axis:RadarAxis):void {
			var g:Graphics = graphics;
			
			g.lineStyle(
				getStyle('axisThickness'),
				getStyle('axisColor'),
				getStyle('axisAlpha')
			);
			
			g.moveTo(axis.start.x, axis.start.y);
			g.lineTo(axis.end.x, axis.end.y);
			
			positionAxisLabel(axis);
			
			for each(var label:Label in axis.labels) {
				positionAxisLabels(axis, label);
			}
		}
		
		/**
		 * Draw all the axes 
		 * 
		 */		
		private function drawAxes():void {
			var axisAngle:Number = (2*Math.PI) / axes.length;
			var angle:Number = 0;
			
			for each(var axis:RadarAxis in axes) {
				if(!axis.updated) updateAxes();
				
				setupAxisForDrawing(axis, angle);
				drawAxis(axis);
				angle += axisAngle;
			}
		}
		
		/**
		 * Work out the point on each axes for a series 
		 * 
		 */		
		private function calculateSeriesPoints():void {
			for each(var serie:RadarSeries in series) {
				serie.points = new Array();
					
				for each(var axis:RadarAxis in axes) {
					var sar:Number = ((serie.data[axis.name] / axis.max) * axis.length) + getStyle('centerRadius');
					var point:Point = new Point(
						_center.x + Math.cos(axis.angle) * sar,
						_center.y + Math.sin(axis.angle) * sar
					);
					serie.points.push(point);
				}
				
				var area:Number = 0;
				var xDiff:Number = 0;
				var yDiff:Number = 0;

		        for(var k:int = 0; k < serie.points.length-1; k++ ) {
		            xDiff = serie.points[k+1].x - serie.points[k].x;
		            yDiff = serie.points[k+1].y - serie.points[k].y;
		            area += serie.points[k].x * yDiff - serie.points[k].y * xDiff;
		        }
        		serie.area = 0.5 * area;
			}
		}
		
		/**
		 * Draw a series. The highlight can be "on", "off" or "other" 
		 * @param serie
		 * @param highlight
		 * 
		 */		
		private function drawSerie(serie:RadarSeries, highlight:String = "off"):void {
			eventBlock = true;
			
			if(!serie.hasColor) {
				var colors:Array = getStyle('colors');
				serie.color = colors[series.indexOf(serie) % colors.length];
			}
			
			var style:String = highlight == 'on' ? 'Highlight' : highlight == 'other' ? 'HighlightOther' : '';
			
			if(!serie.sprite) {
				serie.sprite = new Sprite();
				serie.sprite.addEventListener(MouseEvent.MOUSE_OVER, mouseOverSeriesHandler);
				serie.sprite.addEventListener(MouseEvent.MOUSE_OUT, mouseOutSeriesHandler);
				serie.sprite.addEventListener(MouseEvent.CLICK, mouseClickSeriesHandler);
			}
			
			addChild(serie.sprite);
			
			var g:Graphics = serie.sprite.graphics;
			var point:Point;
			
			g.clear();
			
			for each(point in serie.points) {
				g.beginFill(serie.color, getStyle('series' + style + 'PointAlpha'));
				g.lineStyle(0, 0, 0);
				g.drawCircle(point.x, point.y, getStyle('series' + style + 'PointSize'));
				g.endFill();
			}
			
			g.lineStyle(getStyle('series' + style + 'LineThickness'), serie.color, getStyle('series' + style + 'LineAlpha'));
			g.moveTo(serie.points[0].x, serie.points[0].y);
			g.beginFill(serie.color, getStyle('series' + style + 'FillAlpha'));
			
			for each(point in serie.points) {
				g.lineTo(point.x, point.y);
			}
			
			g.endFill();
			
			eventBlock = false;
		}
		
		/**
		 * Draw all the series 
		 * 
		 */		
		private function drawSeries():void {
			calculateSeriesPoints();
			
			var sortedSeries:Array = getSortedSeries();
			for each(var serie:RadarSeries in sortedSeries) {
				drawSerie(serie);
			}
		}
		
		/**
		 * Return the array of series sorted by total area 
		 * @return 
		 * 
		 */		
		private function getSortedSeries():Array {
			return series.clone().sort(function(a:RadarSeries, b:RadarSeries):int {
				if(a.area > b.area) return -1;
				if(a.area == b.area) return 0;
				if(a.area < b.area) return 1;
				return 0;
			});
		}
		
		/**
		 * Using the sprite that a series is drawn on, find the series 
		 * @param sprite
		 * @return 
		 * 
		 */		
		private function getSeriesFromSprite(sprite:Sprite):RadarSeries {
			return (series.filter(function(s:RadarSeries, i:int, a:Array):Boolean {
				return s.sprite == sprite;
			}))[0];
		}
		
		/**
		 * Redraw the series with highlight on. 
		 * @param serie
		 * @param highlightOn
		 * 
		 */		
		private function highlightSeries(serie:RadarSeries, highlightOn:Boolean):void {
			var sortedSeries:Array = getSortedSeries();
			for each(var otherSerie:RadarSeries in sortedSeries) {
				if(otherSerie != serie)
					drawSerie(otherSerie, (highlightOn ? 'other' : 'off'));
			}
			
			drawSerie(serie, (highlightOn ? 'on' : 'off'));
			
		}
		
		/**
		 * Handle mouse over events for series. Highlights the serives and
		 * dispatch a series roll over event. 
		 * @param e
		 * 
		 */		
		private function mouseOverSeriesHandler(e:MouseEvent):void {
			if(eventBlock) return;
			
			var serie:RadarSeries = getSeriesFromSprite(Sprite(e.target));
			highlightSeries(serie, true);
			dispatchEvent(new RadarChartSeriesEvent(RadarChartSeriesEvent.SERIES_ROLL_OVER, serie)); 
		}
		
		/**
		 * Handle mouse out events for series. Removes the highlight and
		 * dispatches a series roll out event. 
		 * 
		 * @param e
		 * 
		 */		
		private function mouseOutSeriesHandler(e:MouseEvent):void {
			if(eventBlock) return;
			
			var serie:RadarSeries = getSeriesFromSprite(Sprite(e.target));
			highlightSeries(serie, false);
			dispatchEvent(new RadarChartSeriesEvent(RadarChartSeriesEvent.SERIES_ROLL_OUT, serie));			
		}
		
		/**
		 * Handle mouse click events for series. Dispatches a series click event. 
		 * @param e
		 * 
		 */		
		private function mouseClickSeriesHandler(e:MouseEvent):void {
			if(eventBlock) return;
			
			var serie:RadarSeries = getSeriesFromSprite(Sprite(e.target));
			dispatchEvent(new RadarChartSeriesEvent(RadarChartSeriesEvent.SERIES_CLICK, serie));	
		}
		
		/**
		 * @inheritDoc 
		 * @param styleProp
		 * 
		 */		
		public override function styleChanged(styleProp:String):void {
			super.styleChanged(styleProp);
		}
	}
}

