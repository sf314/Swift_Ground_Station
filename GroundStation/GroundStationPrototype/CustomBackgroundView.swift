//
//  CustomBackgroundView.swift
//  GroundStationPrototype
//
//  Created by Stephen Flores on 5/1/17.
//  Copyright © 2017 Prograde. All rights reserved.
//

import Foundation
import Cocoa
import CoreGraphics

class CustomBackgroundView: NSView {
    override func draw(_ rect: CGRect) {
        let backgroundColour = NSColor(calibratedRed: 28/255, green: 28/255, blue: 34/255, alpha: 1)
        backgroundColour.set()
        NSRectFill(bounds)
    }
}
