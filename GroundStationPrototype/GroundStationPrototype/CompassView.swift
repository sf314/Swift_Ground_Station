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
class CompassView: NSView {
    
    var heading = 0 // Degrees
    
    
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
        let angle = Double(heading) * pi / 180.0
        let path = NSBezierPath()
        let startPoint = NSPoint(x: centerX, y: centerY)
        let endY = Double(centerX) + Double(centerX) * cos(angle) * 0.8 // swapped for CW rotation
        let endX = Double(centerY) + Double(centerY) * sin(angle) * 0.8
        let endPoint = NSPoint(x: endX, y: endY)
        path.move(to: startPoint)
        path.line(to: endPoint)
        path.close()
        
        NSColor.red.set()
        path.lineWidth = 3
        path.stroke()
        
        // Draw other side of the compass
        let newPath = NSBezierPath() // Same start point
        let newEndX = Double(centerY) + Double(centerY) * sin(-(angle)) * 0.7
        let newEndY = Double(centerY) + Double(centerX) * cos(pi - angle) * 0.7
        let newEndPoint = NSPoint(x: newEndX, y: newEndY)
        newPath.move(to: startPoint)
        newPath.line(to:newEndPoint)
        newPath.close()
        
        NSColor.white.set()
        newPath.lineWidth = 3
        newPath.stroke()
        
    }
    
    func updateDisplay() {
        self.setNeedsDisplay(self.bounds)
    }
}
