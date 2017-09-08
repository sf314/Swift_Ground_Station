//
//  Graph.swift
//  GroundStationPrototype
//
//  Created by Stephen Flores on 4/22/17.
//  Copyright © 2017 Prograde. All rights reserved.
//

import Foundation
import Cocoa
import CoreGraphics

let numberOfPoints = 100

@IBDesignable
class GraphView: NSView {
    // Data
    var points = Array(repeating: 0.0, count: numberOfPoints)
    var height = 200.0 // Guess; it actually calculates it later
    var kScaleConst = 2.0
    var maxValue = 10.0
    
    // Add data point (backwards)
    func add(_ val: Double) {
        points.remove(at: 0)
        points.append(val)
    }
    
    // draw() override (called with updateDisplay)
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Set height and width (can change)
        height = Double(self.frame.height)
        kScaleConst = Double(self.frame.width) / Double(numberOfPoints)
        
//        for i in 0..<numberOfPoints {
//            points[i] = 5 * sin(Double(i) * 0.07) + Double(i) * 0.1
//        }
        
        // Background Colour
        //NSColor.white.setFill()
        let graphColor = NSColor(calibratedRed: 35/255, green: 35/255, blue: 44/255, alpha: 1)
        graphColor.set()
        NSRectFill(bounds)

        // Draw each point
        maxValue = setMax()
        for (index,value) in points.enumerated() {
            let r = NSRect(x: Double(index) * kScaleConst, y: map(value), width:3, height: 3)
            let p = NSBezierPath(roundedRect: r, xRadius: 1.5, yRadius: 1.5)
            
            // Control dot colour here!
            let dotColour = NSColor(red: 137/255, green: 222/255, blue: 146/255, alpha: 1)
            dotColour.set()
            p.fill()
        }
        
        // Add border and colour!
        // self.layer?.borderWidth = 2
        // let borderColour = CGColor(red: 95/255, green: 95/255, blue: 111/255, alpha: 1)
        // self.layer?.borderColor = borderColour
    }
    
    // Call to invoke draw() function and update graph
    func updateDisplay() {
        self.setNeedsDisplay(self.bounds)
    }
    
    // Find the maximum value in the array
    func setMax() -> Double {
        var max = 0.0
        for i in 0..<points.count {
            if points[i] > max {max = points[i]}
        }
        if max < 10.0 {
            max = 10.0
        }
        return max
    }
    
    // Map the y-value to a coordinate on the graph (takes height into account)
    func map(_ val: Double) -> Double{
        return (height * val / maxValue) * 0.8
    }
    
}
