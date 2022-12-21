import Toybox.Math;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.System;

function generateHandCoordinates(centerPoint as Array<Number>, angle as Float, handLength as Number, tailLength as Number, startWidth as Number, endWidth as Number) as Array< Array<Float> > {
    // Map out the coordinates of the watch hand
    var coords = [[-(startWidth / 2), tailLength] as Array<Number>,
                    [-(endWidth / 2), -handLength] as Array<Number>,
                    [endWidth / 2, -handLength] as Array<Number>,
                    [startWidth / 2, tailLength] as Array<Number>] as Array< Array<Number> >;
    var result = new Array< Array<Float> >[4];
    var cos = Math.cos(angle);
    var sin = Math.sin(angle);

    // Transform the coordinates
    for (var i = 0; i < 4; i++) {
        var x = (coords[i][0] * cos) - (coords[i][1] * sin) + 0.5;
        var y = (coords[i][0] * sin) + (coords[i][1] * cos) + 0.5;

        result[i] = [centerPoint[0] + x, centerPoint[1] + y] as Array<Float>;
    }
    return result;
}

// Draws the clock tick marks around the outside edges of the screen.
function drawHashMarks(dc as Dc, count as Number, skip as Number, offset as Number, scale_to_fenix as Number) as Void {
    var width = dc.getWidth();
    var height = dc.getHeight();
    
    var outerRad = width / 2;
    var innerRad = outerRad - offset * scale_to_fenix;
    
    for (var i = 1; i <= count; i += 1) {
        if (i % skip != 0) {
            var angle = i * (Math.PI/count)*2;
            var sY = outerRad + innerRad * Math.sin(angle);
            var eY = outerRad + outerRad * Math.sin(angle);
            var sX = outerRad + innerRad * Math.cos(angle);
            var eX = outerRad + outerRad * Math.cos(angle);
            dc.drawLine(sX, sY, eX, eY);
            }
    }
}

function drawMainNumbers(dc as Dc, distance_from_side as Number, scale_to_fenix as Number) as Void {
    var width = dc.getWidth();
    var height = dc.getHeight();
    
    var outerRad = width / 2;
    var distfromside = distance_from_side * scale_to_fenix;
    
    dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
    dc.drawText(width/2, width-distfromside, Graphics.FONT_NUMBER_MEDIUM, 6, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    dc.drawText(width-distfromside, width/2, Graphics.FONT_NUMBER_MEDIUM, 3, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    dc.drawText(distfromside, width/2, Graphics.FONT_NUMBER_MEDIUM, 9, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    var top_indicator = Application.getApp().Properties.getValue("top_numeric");
    switch (top_indicator){
        case 0:
            // Creating the pilot triangle at the top
            var triangle_width = 13 * scale_to_fenix;
            var triangle_height = 35 * scale_to_fenix;
            var triangle_spacer = -14 * scale_to_fenix;
            var triangle_eye_rad = 5 * scale_to_fenix;
            
            dc.fillPolygon([
                [width/2, distfromside + triangle_spacer + triangle_height],
                [width/2 - triangle_width, distfromside + triangle_spacer],
                [width/2 + triangle_width, distfromside + triangle_spacer]
                ]);
            break;
        case 1:
            dc.drawText(width/2, distfromside, Graphics.FONT_NUMBER_MILD, 12, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            break;
    }
    
}

function drawMainIndices(dc as Dc, count as Number, skipper as Number, thickness as Number, edge_offset as Number, index_length as Number, scale_to_fenix as Number) as Void {
    var width = dc.getWidth();
    var height = dc.getHeight();
    var hand_coord_centre = width/2;
    
    edge_offset = edge_offset * scale_to_fenix;
    thickness = thickness * scale_to_fenix;
    index_length = index_length * scale_to_fenix;

    // internal params
    var index_edge_value = hand_coord_centre - edge_offset;
    var index_inner_value = -(index_edge_value - index_length);

    for (var i = 0; i < count; i += 1) {
        if (skipper == 0 ||  i % skipper != 0){
            // s in on the inside
            var angle = i * (Math.PI/count)*2;
            dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], angle,
                index_edge_value,
                index_inner_value,
                thickness,
                thickness));
                }
    }
}
