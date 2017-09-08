//
//  MapView.swift
//  GroundStationPrototype
//
//  Created by Stephen Flores on 4/23/17.
//  Copyright © 2017 Prograde. All rights reserved.
//

import Foundation
import Cocoa
import CoreGraphics

// Model coordinate for minimap
class CSPoint {
    // Data
    var x = 0.0
    var y = 0.0
    
    // Constructor
    init(_ a: Double, _ b: Double) {
        x = a
        y = b
    }
}

@IBDesignable
class MapView: NSView {
    // Data 
    var dataPoints: [CSPoint] = [CSPoint(189, 189)]
    //var previousPoint = CSPoint(189, 189)
    
    // Hold radius of map in mind
    var scaleFactor = 0.36
    // With radius of 180 pts, can only fit 180m into thing.
    // If scale 0.5, then can fit 360m
    // canFit = 180 / scaleFactor
    
    override func draw(_ rect: CGRect) {
        // Draw circle
        
        // Data:
        let centerX = rect.size.width / 2
        let centerY = rect.size.width / 2
        
        
        // Center circle in rect
        let circleRect = NSMakeRect(5, 5, rect.size.width - 10, rect.size.height - 10)
        
        let circle = NSBezierPath(ovalIn: circleRect)
        let circleColour = NSColor(calibratedRed: 35/255, green: 35/255, blue: 44/255, alpha: 1)
        circleColour.set()
        circle.fill()
        
        let circleBorderColour = NSColor(calibratedRed: 95/255, green: 95/255, blue: 111/255, alpha: 1)
        circleBorderColour.set()
        circle.lineWidth = 2
        circle.stroke()
        
        
        // If first point doesn't exist, add it
        if dataPoints.count < 1 {
            dataPoints.append(CSPoint(Double(centerX), Double(centerY)))
        }
        
        // Test with data points
//        for _ in 0..<100 {
//            addPoint(deg: 45, vel: 5)
//        }
        
        // Draw all points in dataPoints (start at centerpoint)
        for index in 1..<dataPoints.count {
            let pt = dataPoints[index]
            
            let r = NSRect(x: pt.x, y: pt.y, width:3, height: 3)
            let p = NSBezierPath(roundedRect: r, xRadius: 1.5, yRadius: 1.5)
            
            // Control dot colour here!
            let dotColour = NSColor(red: 137/255, green: 222/255, blue: 146/255, alpha: 1)
            dotColour.set()
            p.fill()
        }
        
        
    }
    
    func updateDisplay() {
        self.setNeedsDisplay(self.bounds)
    }
    
    // Add point to dataPoints 
    func addPoint(deg theta: Double, vel velocity: Double) {
        // Convert heading and velocity to horizontal distance travelled
        // Can't exceed 180pts distance from center
        
        // Uses previous point in memory (currently set to center of box)
        let prevPt = dataPoints.last!
        
        // Get horizontalSpeed
        let hSpeed = velocity / sqrt(2.0)
        
        let x = prevPt.x + (sin(theta * .pi / 180.0) * hSpeed) * scaleFactor
        let y = prevPt.y + (cos(theta * .pi / 180.0) * hSpeed) * scaleFactor
        
        // Add new point to array
        let newPoint = CSPoint(x, y)
        dataPoints.append(newPoint)
    }
}
