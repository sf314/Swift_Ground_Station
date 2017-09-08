//
//  CompassView.swift
//  GroundStationPrototype
//
//  Created by Stephen Flores on 5/2/17.
//  Copyright © 2017 Prograde. All rights reserved.
//

import Foundation
import Cocoa
import CoreGraphics

@IBDesignable
class SpeedometerView: NSView {
    
    var velocity = 0.0 // m/s
    
    func setSpeed(_ v: Double) {
        velocity = v
    }
    
    
    override func draw(_ rect: CGRect) {
        
        // It's a circle (assumes that display is same width/heigt
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
        
        // Draw compass based on heading information
        let pi = 3.14159265358
        var angle: Double
        
        if velocity < 15 {
            angle = (180.0 / 15.0) * velocity - 135
        } else {
            angle = (90.0 / 15.0) * velocity - 45
        }
        
        // Convert angle to radians
        angle = angle * pi / 180.0
        
        
        let path = NSBezierPath()
        let startPoint = NSPoint(x: centerX, y: centerY)
        let endY = Double(centerX) + Double(centerX) * cos(angle) * 0.8 // swapped for CW rotation
        let endX = Double(centerY) + Double(centerY) * sin(angle) * 0.8
        let endPoint = NSPoint(x: endX, y: endY)
        path.move(to: startPoint)
        path.line(to: endPoint)
        path.close()
        
        NSColor.orange.set()
        path.lineWidth = 3
        path.stroke()
        
    }
    
    func updateDisplay() {
        self.setNeedsDisplay(self.bounds)
    }
}
