//
//  BarView.swift
//  GroundStationPrototype
//
//  Created by Stephen Flores on 4/28/17.
//  Copyright © 2017 Prograde. All rights reserved.
//

import Foundation
import Cocoa
import CoreGraphics

// *** How this will work
// So this class will get its data from the parsing function of the 
// telemetry classes. It basically only needs one data point to function, as
// it just draws a rectangle of \(value) length. Just need to map the input
// value against a known (hardcoded) maximum and plot that in relation to
// the length of the view (so it can be resized)

// In order to allow passing values from telemetry to the BarView instance, 
// you should define a global function

// Height or width? Height!

@IBDesignable
class BarView: NSView {
    
    // Set min and max values (for mapping) (set during instantiation)
    // Assumed to be voltage, so 4.0 to 7.0
    var min = 0.0
    var max = 5.5
    var value = 0.0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Fill background colour
        NSColor.black.set()
        NSRectFill(bounds)
        
        // Add border and colour!
        self.layer?.borderWidth = 2
        let borderColour = CGColor(red: 95/255, green: 95/255, blue: 111/255, alpha: 1)
        self.layer?.borderColor = borderColour
        
        
        // *** Draw lines
        
        // Find mapped height of inputValue
        let mappedVal = (Double(rect.height) * (value - min)) / (max - min)
        
        // Draw many rectangles?
        var barColour = NSColor(calibratedRed: 59/255, green: 203/255, blue: 247/255, alpha: 1)
        
        // Low battery colour (threshold 0.5?)
        if value - min < 0.5 {
            barColour = NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 1)
        }
        barColour.set()
        
        var i = 0
        while i < Int(round(mappedVal)) {
            // Draw rect
            let r = NSRect(x: 0, y: i, width: Int(rect.width), height: 3)
            let path = NSBezierPath(roundedRect: r, xRadius: 0, yRadius: 0)
            path.fill()
            
            // Increment height (spacing)
            i += 5
        }
        
    }
    
    
    // Call to invoke draw() function and update graph
    func updateDisplay() {
        self.setNeedsDisplay(self.bounds)
    }
    
}
