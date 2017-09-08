//
//  CustomButtonView.swift
//  GroundStationPrototype
//
//  Created by Stephen Flores on 5/1/17.
//  Copyright © 2017 Prograde. All rights reserved.
//

import Foundation
import Cocoa
import CoreGraphics

// Dimensions:
// Height: 21
// Width: 137 or thereabouts

@IBDesignable
class CustomButtonView: NSButton {
    
    // Draw button manually
    override func draw(_ rect: CGRect) {
        // Needed colours:
        let foreGroundColour = NSColor(calibratedRed: 35/255, green: 35/255, blue: 44/255, alpha: 1)
        let borderColour = NSColor(calibratedRed: 95/255, green: 95/255, blue: 111/255, alpha: 1)
        
        // Color in the background
//        backgroundColour.set()
//        NSRectFill(bounds)
//        
        // Draw rounded rectangle
        let baseRect = NSRect(x: 1, y: 1, width: rect.width - 2, height: rect.height - 2)
        let path = NSBezierPath(roundedRect: baseRect, xRadius: 5, yRadius: 5)
        
        borderColour.set()
        path.lineWidth = 2
        path.stroke()
        
        // Fill the rect
        foreGroundColour.set()
        path.fill()
        
    }
}
