//
//  Telemetry.swift
//  GroundStationPrototype
//
//  Created by Stephen Flores on 4/22/17.
//  Copyright © 2017 Prograde. All rights reserved.
//

// For parsing telemetry strings into data
// If telem unwrap fails, then save as zero

// FlightBee: 0013A200 - 40D7CA76
// GroundBee: 0013A200 - 40D7CA6E

import Foundation
import Cocoa

// Data for non-graph data representations (GLOBAL)
// Set the data within telem class
// For other views, retrieve this data at bottom of updateGliderUI()/ContainerUI()
var gliderVoltage = 0.0
var gliderHeading = 0.0
var containerVoltage = 0.0

// ********** Telemetry classes ***********************************************
class GliderTelemetry {
    // Data and telemetry
    var badPackets  = 0
    
    var missionTime = 0.0
    var packetCount = 0
    var altitude    = 0.0
    var pressure    = 0.0
    var speed       = 0.0
    var temp        = 0.0
    var voltage     = 0.0
    var heading     = 0.0
    var state       = "state"
    
    // Parse packet into telemetry data
    func add(_ packet: [String]) -> Bool {
        if packet[0].contains("2848") && packet[1].contains("GLIDER") { //&& packet.count == 11 {
            
            // Safely add packet. Defaults to zero
            if let val = Double(packet[2])  {missionTime = val} else {missionTime = 0.0}
            if let val = Int(packet[3])     {packetCount = val} else {packetCount = 0}
            if let val = Double(packet[4])  {altitude = val} else {altitude = 0.0}
            if let val = Double(packet[5])  {pressure = val} else {pressure = 0.0}
            if let val = Double(packet[6])  {speed = val} else {speed = 0.0}
            if let val = Double(packet[7])  {temp = val} else {temp = 0.0}
            if let val = Double(packet[8])  {voltage = val} else {voltage = 0.0}
            if let val = Double(packet[9])  {heading = val} else {heading = 0.0}
            if let val = String(packet[10]) {state = val} else {state = "?"}
            
            saveToDisk(data: createString(), withName: gliderFile)
            
            // Set global data
            gliderVoltage = voltage
            gliderHeading = heading
            
            return true
        } else {
            badPackets += 1
            return false
        }
    }
    
    // Create string for saving data to disk
    private func createString() -> String {
        var dataString = "2848,GLIDER,"
        dataString += String(missionTime) + ","
        dataString += String(packetCount) + ","
        dataString += String(altitude) + ","
        dataString += String(pressure) + ","
        dataString += String(speed) + ","
        dataString += String(temp) + ","
        dataString += String(voltage) + ","
        dataString += String(heading) + ","
        dataString += String(state) + "\n"
        print(dataString)
        
        return dataString
    }
    
}

class ContainerTelemetry {
    // Data
    var badPackets = 0
    
    var missionTime = 0.0
    var packetCount = 0
    var altitude = 0.0
    var temperature = 0.0
    var voltage = 0.0
    var state = "0"
    
    
    // Parse packet array into telemetry data
    func add(_ packet: [String]) -> Bool {
        // DEBUGGING
        
        if packet[0].contains("2848") && packet[1].contains("CONTAINER") { //&& packet.count == 8 {
            
            // Safely add packet using if-let
            if let val = Double(packet[2])  {missionTime = val} else {missionTime = 0}
            if let val = Int(packet[3])     {packetCount = val} else {packetCount = 0}
            if let val = Double(packet[4])  {altitude = val} else {altitude = 0}
            if let val = Double(packet[5])  {temperature = val} else {temperature = 0}
            if let val = Double(packet[6])  {voltage = val} else {voltage = 0}
            if let val = String(packet[7])  {state = val} else {state = "?"}
            
            print("packet[2] = \(packet[2])");
            
            saveToDisk(data: createString(), withName: containerFile)
            
            // Set global data
            containerVoltage = voltage
            
            return true
        } else {
            badPackets += 1
            return false
        }
    }
    
    // Create string for saving data to disk
    private func createString() -> String {
        var dataString = "2848,CONTAINER,"
        dataString += String(missionTime) + ","
        dataString += String(packetCount) + ","
        dataString += String(altitude) + ","
        dataString += String(temperature) + ","
        dataString += String(voltage) + ","
        dataString += String(state) + "\n"
        
        return dataString
    }
    
}

// ********** Parsing classes/functions ***************************************

// Parsing function:
//      Checks incoming data stream for newlines. If found, it will pass
//      the current result string to be parsed for telemetry. It has 
//      some built-in helper functions.
//      Needs to be unit-tested using bad data!
extension GSController {
    func parse(_ string: String) -> Bool {
        if string.contains("\n") {
            let stringArray = toComponents(string)
            if stringArray.count == 1 {
                if firstCharacter(of: stringArray[0]) == "\n" {
                    printToTerminal(returnString)
                    _ = parsePacket(returnString)
                    returnString = ""
                    returnString += stringArray[0]
                } else {
                    returnString += stringArray[0]
                    printToTerminal(returnString)
                    _ = parsePacket(returnString)
                    returnString = ""
                }
            } else if stringArray.count == 2 {
                returnString += stringArray[0]
                printToTerminal(returnString)
                _ = parsePacket(returnString)
                returnString = ""
                returnString += stringArray[1]
                return true
            } else { // Just a newline?
                printToTerminal(returnString)
                _ = parsePacket(returnString)
                returnString = ""
                // Ignore newline character
                return true
            }
            return true
        } else {
            // Simple append
            returnString += string
            return false
        }
    }
    
    // Convert a string to an array of strings using newline
    private func toComponents(_ str: String) -> [String] {
        return str.characters.split(separator: "\n").map(String.init)
    }
    
    // Get the first character of string
    private func firstCharacter(of str: String) -> String {
        return String(str[str.startIndex])
    }
    
    // Print raw string from serial to console
    private func printToTerminal(_ str: String) {
        print("Parser: \(str)")
    }
}
