import Toybox.Graphics;
import Toybox.Math;

// Draw hash marks and labels for gauges - from my Garmin watch face tutorial / mattermetrics watch face
function drawHashMarksAndLabels(dc as Dc, hours as Array<Number>, labels as Array<String>, scale_to_fenix as Number) as Void {
    var width = dc.getWidth();
    var height = dc.getHeight();

    // Creating the scaler based on the Fenix on which this was developed
    var thickness = 9 * scale_to_fenix;
    
    var outerRad = width / 2;
    var innerRad = outerRad - 10 * scale_to_fenix;
    var textInnerRad = innerRad - 15 * scale_to_fenix;
    
    for (var i = 0; i < hours.size(); i += 1) {
        var angle = (hours[i]/360.0)*2*Math.PI+Math.PI/2.0;
        var sX = outerRad + innerRad * Math.cos(angle);
        var sY = outerRad + innerRad * Math.sin(angle);

        var eY_u = outerRad + (outerRad + 10*scale_to_fenix) * Math.sin(angle) + thickness * Math.cos(angle);
        var eX_u = outerRad + (outerRad + 10*scale_to_fenix) * Math.cos(angle) + thickness * Math.sin(angle);
        
        var eY_l = outerRad + (outerRad + 10*scale_to_fenix) * Math.sin(angle) - thickness * Math.cos(angle);
        var eX_l = outerRad + (outerRad + 10*scale_to_fenix) * Math.cos(angle) - thickness * Math.sin(angle);

        dc.fillPolygon([[sY, sX],[eY_u, eX_u],[eY_l, eX_l]]);

        var textY = outerRad + textInnerRad * Math.cos(angle);
        var textX = outerRad + textInnerRad * Math.sin(angle);
        dc.drawText(textX, textY, Graphics.FONT_XTINY, labels[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

// Draw gauge function - from my Garmin watch face tutorial / mattermetrics watch face
function drawGauge(
    dc as Dc,
    start_hour as Number,
    duration_hours as Number,
    direction as Number,
    start_val as Float,
    end_val as Float,
    cur_val as Float,
    labels as Array<String>
) as Void {
    // Compute scaler
    var scale_to_fenix = dc.getWidth().toFloat()/260;

    // Make sure nothing overruns or overflows
    if (cur_val>=end_val) {
        cur_val=end_val;
        // labels[2] = "";
    }
    if (cur_val<=start_val){
        cur_val=start_val;
    }
    
    // Convert hour indices to arc start and end values in degreees
    var arcStart = 90.0 - start_hour*30.0;
    var arcEnd;
    if (direction == 0) {
        arcEnd = arcStart + 30.0*duration_hours; // this represents the value of the arc ending, IF the value was at 100%
    } else {
        arcEnd = arcStart - 30.0*duration_hours;
    }

    // Compute arc lengths
    var arcLengthInDegrees = arcEnd - arcStart;

    // Adjust arc length in case it is too long
    if (arcLengthInDegrees > 180){
        if (direction == 1) {
            arcLengthInDegrees = arcLengthInDegrees-90;
        } else {
            arcLengthInDegrees = arcLengthInDegrees;
        }
    }

    // Computing the end point of the actual measurement arc
    var proportion = (cur_val-start_val)/(end_val-start_val);

    // Make sure proportion isn't 0.0
    if (proportion == 0){
        proportion = 0.01;
    } else if (proportion < 0){
        proportion = 0.01;
    }

    var arcEndActual = arcStart + proportion*arcLengthInDegrees;
    var arcCenter = (arcStart+arcEnd)/2;
    //var arcFirstFourth = (arcStart+arcCenter)/2;

    // Compute coordinates for arc - X, Y and radius - they are all the same for a circular watch
    var arcCenterX = dc.getWidth()/2;
    var arcCenterY = arcCenterX;
    var arcRadius = arcCenterX;

    // Drawing the measuring gauge in white
    dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
    var scaledThickness = 1 * scale_to_fenix;
    var scaledThicknessSecond = 4 * scale_to_fenix;
    for (var i = scaledThickness; i <= scaledThickness+scaledThicknessSecond; i += 1) {
        dc.drawArc(arcCenterX, arcCenterY, arcRadius-i, direction, arcStart, arcEndActual);
    }

    // Switch to gray background colour
    dc.setColor(Graphics.COLOR_DK_GRAY,Graphics.COLOR_TRANSPARENT);

    // Draw value label in the middle
    if (labels[2] != ""){
        var outerRad = dc.getWidth() / 2;
        var innerRad = outerRad - 10*scale_to_fenix;
        var textInnerRad = innerRad - 13*scale_to_fenix;
        var angle = arcCenter/360 * 2 * Math.PI + Math.PI/2;
        var textY = outerRad + textInnerRad * Math.cos(angle);
        var textX = outerRad + textInnerRad * Math.sin(angle);
        dc.drawText(textX, textY, Graphics.FONT_XTINY, labels[2], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Draw the background arc        
    for (var i = 0; i <= scaledThickness; i += 1) {
        dc.drawArc(arcCenterX, arcCenterY, arcRadius-i, direction, arcStart, arcEnd);
    }

    // Draw start and end indicators and add labels
    drawHashMarksAndLabels(dc, [arcStart, arcEnd], [labels[0], labels[1]], 1);
}
