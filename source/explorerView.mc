import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.Math;
import Toybox.Time;
using Toybox.SensorHistory as Sensor;
import Toybox.ActivityMonitor;
import Toybox.Application;


class explorerView extends WatchUi.WatchFace {
    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }
   
	// Solve complication
	private function getComplicationString(input_string as String) as String {
		var dateStr = "";
		var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		
		switch (input_string){
			case 0: // date
				var date_format = Application.getApp().Properties.getValue("date_format");
		        switch (date_format){
		        	case 0:
		        		dateStr = Lang.format("$1$/$2$", [info.day, info.month]);
		        		break;
		        	case 1:
		        		dateStr = Lang.format("$1$/$2$", [info.month, info.day]);
		        		break;
		        }
		        
	    		var dateView = View.findDrawableById("DateDisplay") as Text;
	    		return dateStr;
	    		break;
	    	case 1: // 1 battery
	    		var myStats = System.getSystemStats();
				var batStr = Lang.format( "$1$%", [ myStats.battery.format( "%2d" ) ] );
		        var batView = View.findDrawableById("BatteryDisplay") as Text;
		        return batStr;
	    		break;
	    	case 2: // 2 heartrate
	    		var hrStr = "--";
	    		var sample = Sensor.getHeartRateHistory( {:order=>Sensor.ORDER_NEWEST_FIRST}).next();
				if( sample != null) {
					if (sample.data != null){
						hrStr = sample.data.toString();
					}
				}
	    		if ((hrStr == null) || (hrStr == "null")){
	    			hrStr = "--";
	    		}
	    		return hrStr;
	    		break;
	    	case 3: // 3 steps
		        var steps = ActivityMonitor.getInfo().steps;
		        if (steps > 1000){
		        	steps = (steps/1000.0).format("%.1f")+"k";
		        }
		        return steps;
	    		break;
	    	case 4: // leave blank
	    		return "";
	    		break;
	    	default: // leave blank
	    		return "";
	    		break;
		}	
	}

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Dial specifics - CONFIGURATION VALUES
        var indices_length = 28;
        var indices_thickness = 8;
    	var lume_color = Graphics.COLOR_WHITE;
        var minute_mark_color = Graphics.COLOR_WHITE;
		var hand_and_detail_color = Graphics.COLOR_LT_GRAY;

		// Defaults assume minute hash marks drawn and dial drawn to the edge, option updates values below
		var minute_mark_length = 10;
		var indices_distance_from_edge = 30;

		if (Application.getApp().Properties.getValue("edge_hash_marks") == 1){
			minute_mark_length = 0;
        	indices_distance_from_edge = 25;
		}
		
        // Internal parameters
        var scale_to_fenix = dc.getWidth().toFloat()/260;
		var hand_coord_centre = dc.getWidth()/2;

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

		// Draw the hash marks around the edges of the screen
        // args: Count, Modulus skip counter, scaler
		dc.setColor(minute_mark_color, Graphics.COLOR_TRANSPARENT);
        drawHashMarks(dc, 60, 100, minute_mark_length, scale_to_fenix);

		// Draw gauges if enabled
		if (Application.getApp().Properties.getValue("gauges_enabled") == 0){
			// Draw steps gauge against set target
			var steps = ActivityMonitor.getInfo().steps/1.0;
			if (steps == 0.0){
				steps=1;
			}
			var stepsgoal =  ActivityMonitor.getInfo().stepGoal/1.0;
			drawGauge(dc, 6, 1, 0, 0.0, stepsgoal, steps, ["", "", (steps/1000.0).format("%.1f")+"k"]);

			// Draw battery gauge against 100%
			var bat = System.getSystemStats().battery;
			var batStr = Lang.format( "$1$%", [ bat.format("%2d") ] );
			drawGauge(dc, 6, 1, 1, 0.0, 100.0, bat, ["", "", batStr]);
		}

        // Draw main numerals - 3, 6, 9
        // args: Offset (distance from edge)
        dc.setColor(lume_color, Graphics.COLOR_TRANSPARENT);
        drawMainNumbers(dc, indices_distance_from_edge, scale_to_fenix);
        
        // Drawing the triangles around the dial
        dc.setColor(lume_color, Graphics.COLOR_TRANSPARENT);
        drawMainIndices(dc, 12, 3, indices_thickness, minute_mark_length + 4, indices_length, scale_to_fenix); // Count, skipper, thickness, shortener - all are scaled to fenix inside the function

        // Computing hand angles, convert time to minutes and compute the angle.
        // Get current time
        var clockTime = System.getClockTime();
        var hourHandAngle = (((clockTime.hour % 12) * 60) + clockTime.min);
        hourHandAngle = Math.PI * 2 * hourHandAngle / (12 * 60.0);
	    var minuteHandAngle = (clockTime.min / 60.0) * Math.PI * 2;
	    
	    // Complications - get settings value
    	var param_1_setting = Application.getApp().Properties.getValue("top_complication");
    	var param_2_setting = Application.getApp().Properties.getValue("bot_complication");
    	var complication_location = Application.getApp().Properties.getValue("complication_location");
    	var date_format = Application.getApp().Properties.getValue("date_format");

		// Compute the required string and save result
		var top_complication = getComplicationString(param_1_setting);
		var bottom_complication = getComplicationString(param_2_setting);
	
	    // Compute location for complication - average angle of hour/minute - PI
	    dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
	    var textrad = hand_coord_centre;
	    var textdist = 90 * scale_to_fenix;
	    var textangle = (hourHandAngle + minuteHandAngle )/2;
	    
	    // Set angle/location depending on setting
	    switch (complication_location){
	    	case 0: // rotating
			    textangle = (hourHandAngle + minuteHandAngle )/2;
			    if ((hourHandAngle - minuteHandAngle).abs() < Math.PI){ textangle = textangle + Math.PI; } 
			   	textangle = textangle - Math.PI/2;
			   	break;
	    	case 1: // 12 o clock
	    	    textangle = Math.PI*1.5;
	    		break;
	    	case 2: // 3 o clock
	    		textangle = 0;
	    		break;
	    	case 3: // 6 o clock
	    	    textangle = Math.PI/2;
	    		break;
	    	case 4: // 9 o clock
	    	    textangle = Math.PI;
	    		break;
	    
	    }
        var sY = textrad + (textrad - textdist ) * Math.sin(textangle);
        var sX = textrad + (textrad - textdist ) * Math.cos(textangle);
	    dc.drawText(sX, sY - 18*scale_to_fenix, Graphics.FONT_TINY, top_complication, Graphics.TEXT_JUSTIFY_CENTER);
	    dc.drawText(sX, sY + 2*scale_to_fenix, Graphics.FONT_TINY, bottom_complication, Graphics.TEXT_JUSTIFY_CENTER);
	
        // RENDERING HANDS
        var minusradius = -10 * scale_to_fenix;
        var arrowstart = 0; // computed below
        dc.setColor(hand_and_detail_color, Graphics.COLOR_TRANSPARENT);
        
		// Hour hand style - 0 is circle, 1 is arrow
		if (Application.getApp().Properties.getValue("hour_hand_style") == 0){
			arrowstart = 55 * scale_to_fenix;
			// Hour hand base - circle
			dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], hourHandAngle, 
				75 * scale_to_fenix,
				minusradius,
				14 * scale_to_fenix,
				5 * scale_to_fenix));
			
			// Hour hand tip - circle
			dc.fillCircle(
				hand_coord_centre + Math.sin(hourHandAngle) * arrowstart,
				hand_coord_centre - Math.cos(hourHandAngle) * arrowstart,
				11 * scale_to_fenix);
		} else {
			arrowstart = 70 * scale_to_fenix;
			// Hour hand vbase - arrow
			dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], hourHandAngle, 
				80 * scale_to_fenix,
				minusradius,
				18 * scale_to_fenix,
				5 * scale_to_fenix));
			
			// Hour hand tip - arrow
			dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], hourHandAngle,
				90*scale_to_fenix,
				-arrowstart + 4*scale_to_fenix,
				24 * scale_to_fenix,
				3 * scale_to_fenix));
			
		}

		// Minute hand
		dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], minuteHandAngle,
			105 * scale_to_fenix,
			minusradius,
			10 * scale_to_fenix,
			5 * scale_to_fenix));
        
		// LUMES, hence changing to the right color
		dc.setColor(lume_color,Graphics.COLOR_TRANSPARENT);
		
		if (Application.getApp().Properties.getValue("hour_hand_style") == 0){
			// Hour hand base lume - ball
			dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], hourHandAngle,
				70 * scale_to_fenix,
				0,
				8 * scale_to_fenix,
				2 * scale_to_fenix));

			// Hour hand tip lume - ball
			dc.fillCircle(
				dc.getWidth()/2 + Math.sin(hourHandAngle) * arrowstart,
				dc.getHeight()/2 - Math.cos(hourHandAngle) * arrowstart,
				8 * scale_to_fenix);
		} else {
			// Hour hand tip lume - arrow
			dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], hourHandAngle,
				83 * scale_to_fenix,
				-arrowstart,
				14 * scale_to_fenix,
				1 * scale_to_fenix));
		}

        // Spike lume - minute hand
		dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], minuteHandAngle,
			95 * scale_to_fenix,
			minusradius,
			6 * scale_to_fenix,
			1*scale_to_fenix));
         
	    // Center dot
	    dc.setColor(hand_and_detail_color,Graphics.COLOR_TRANSPARENT);
	    dc.fillCircle(hand_coord_centre, hand_coord_centre, -minusradius + 3 * scale_to_fenix);
	    dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
	    dc.drawCircle(hand_coord_centre, hand_coord_centre, -minusradius + 3 * scale_to_fenix);
    }

    function onShow() as Void {}
    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}
