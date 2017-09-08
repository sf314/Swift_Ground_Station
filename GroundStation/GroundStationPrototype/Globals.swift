//
//  Globals.swift
//  GroundStationPrototype
//
//  Created by Stephen Flores on 4/22/17.
//  Copyright © 2017 Prograde. All rights reserved.
//

import Foundation

// Hold all global data 

var saveOutput = true

var theta = 0.0

let gliderTelemetry = GliderTelemetry()
let containerTelemetry = ContainerTelemetry()

let gliderFile = "gliderTelem.csv"
let containerFile = "containerTelem.csv"

// TODO: append to file instead of replacing! Outputstream?

func saveToDisk(data str: String, withName fileName: String) {
    if saveOutput {
        // Create document URL
        let documentsUrl = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0] as NSURL
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        
        print("Saving to disk: '\(str)'")
        
        // Save
        if let oStream = OutputStream(url: fileURL!, append: true) {
            oStream.open()
            let length = str.lengthOfBytes(using: String.Encoding.utf8)
            oStream.write(str, maxLength: length) // Yes!!!!
            oStream.close()
        } else {
            print("Could not write to file \(fileName)")
        }
    }
}
