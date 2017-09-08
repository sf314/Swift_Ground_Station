//
//  ViewController.swift
//  GroundStationPrototype
//
//  Created by Stephen Flores on 4/20/17.
//  Copyright © 2017 Prograde. All rights reserved.
//

// **** TODO:
// Add map display
// Change state string to be human-readable
// Set of User-definable command text fields




import Cocoa

class GSController: NSViewController, ORSSerialPortDelegate {
    
    // ********** Data ********************************************************
    //var parser = Parser()
    var returnString = "" // For parser
    
    // ********** Set up Serial ports *****************************************
    
    let serialPortManager = ORSSerialPortManager.shared()
    var serialPort: ORSSerialPort? {
        didSet { // Is this necessary?
            oldValue?.close()
            oldValue?.delegate = nil
            serialPort?.delegate = nil
        }
    }
    
    // ********** UI elements *************************************************
    
    
    @IBOutlet weak var sendTextField: NSTextField!
    // Create by dragging from storyboard
    @IBOutlet var receivedTextField: NSTextView!
    
    @IBOutlet var connectButton: NSButton!
    @IBOutlet var gliderBadPackets: NSTextField!
    @IBOutlet var containerBadPackets: NSTextField!
    
    @IBOutlet var payloadMet: NSTextField!
    @IBOutlet var payloadPacket: NSTextField!
    @IBOutlet var payloadAlt: NSTextField!
    @IBOutlet var payloadPress: NSTextField!
    @IBOutlet var payloadSpeed: NSTextField!
    @IBOutlet var payloadTemp: NSTextField!
    @IBOutlet var payloadVolt: NSTextField!
    @IBOutlet var payloadHead: NSTextField!
    @IBOutlet var payloadState: NSTextField!
    
    @IBOutlet var containerMet: NSTextField!
    @IBOutlet var containerPacket: NSTextField!
    @IBOutlet var containerAlt: NSTextField!
    @IBOutlet var containerTemp: NSTextField!
    @IBOutlet var containerVolt: NSTextField!
    @IBOutlet var containerState: NSTextField!
    
    // Graphs
    @IBOutlet var gAltGraph: GraphView!
    @IBOutlet var gPressGraph: GraphView!
    @IBOutlet var gTempGraph: GraphView!
    @IBOutlet var gSpeedGraph: GraphView!
    @IBOutlet var gVoltGraph: GraphView!
    @IBOutlet var gHeadGraph: GraphView!
    
    @IBOutlet var miniMap: MapView!
    
    @IBOutlet var cAltGraph: GraphView!
    @IBOutlet var cTempGraph: GraphView!
    @IBOutlet var cVoltGraph: GraphView!
    
    // Buttons
    @IBOutlet weak var savingToggle: NSButton!
    @IBOutlet weak var deployButton: NSButton!
    @IBOutlet weak var custom1: NSButton! // Preset commands
    @IBOutlet weak var custom2: NSButton!
    @IBOutlet weak var custom3: NSButton!
    @IBOutlet weak var custom4: NSButton!
    
    // Bars (outlet accessible outside?)
    @IBOutlet weak var gliderVoltMeter: BarView!
    @IBOutlet weak var containerVoltMeter: BarView!
    @IBOutlet weak var compassView: CompassView!
    @IBOutlet weak var speedometer: SpeedometerView!
    
    // For custom (typed) interface
    @IBOutlet var customCommand1: NSTextField!
    @IBOutlet var customCommand2: NSTextField!
    @IBOutlet var customCommand3: NSTextField!
    @IBOutlet var customCommand4: NSTextField!
    
    // For sending these commands:
    @IBAction func sendCC1(_: AnyObject) {sendCommand(customCommand1.stringValue)}
    @IBAction func sendCC2(_: AnyObject) {sendCommand(customCommand2.stringValue)}
    @IBAction func sendCC3(_: AnyObject) {sendCommand(customCommand3.stringValue)}
    @IBAction func sendCC4(_: AnyObject) {sendCommand(customCommand4.stringValue)}
    
    
    // ********** Update UI with new data *************************************
    
    func updateContainerUI() {
        containerMet.stringValue = String(containerTelemetry.missionTime) + "s"
        containerPacket.stringValue = String(containerTelemetry.packetCount)
        containerAlt.stringValue = String(containerTelemetry.altitude) + "m"
        containerTemp.stringValue = String(containerTelemetry.temperature) + "°C"
        containerVolt.stringValue = String(containerTelemetry.voltage) + "V"
        
        var temp = "none"
        switch containerTelemetry.state {
            case "0", "0 ", " 0":
                temp = "Boot"
            case "1", "1 ", " 1":
                temp = "Launchpad"
            case "2", "2 ", " 2":
                temp = "Ascent"
            case "3", "3 ", " 3":
                temp = "Descent"
            case "4", "4 ", " 4":
                temp = "Deploy"
            default:
                temp = "Invalid"
        }
        
        containerState.stringValue = temp
        
        containerBadPackets.stringValue = String(containerTelemetry.badPackets)
        
        containerVoltMeter.value = containerTelemetry.voltage
        
        // Update other UI things here (don't forget tuo call updateDisplay())
        
        updateContainerGraphs()
    }
    
    func updateGliderUI() {
        payloadMet.stringValue = String(gliderTelemetry.missionTime) + "s"
        payloadPacket.stringValue = String(gliderTelemetry.packetCount)
        payloadAlt.stringValue = String(gliderTelemetry.altitude) + "m"
        payloadPress.stringValue = String(gliderTelemetry.pressure) + "hPa"
        payloadSpeed.stringValue = String(gliderTelemetry.speed) + "m/s"
        payloadTemp.stringValue = String(gliderTelemetry.temp) + "°C"
        payloadVolt.stringValue = String(gliderTelemetry.voltage) + "V"
        payloadHead.stringValue = String(gliderTelemetry.heading) + "°"
        
        var temp = "none"
        switch gliderTelemetry.state {
            case "0", "0 ", " 0":
                temp = "Boot"
            case "1", "1 ", " 1":
                temp = "Descent"
            case "2", "2 ", " 2":
                temp = "Landed"
            default:
                temp = "invalid"
        }
        
        payloadState.stringValue = temp
        
        
        gliderBadPackets.stringValue = String(gliderTelemetry.badPackets)
        
        gliderVoltMeter.value = gliderTelemetry.voltage
        compassView.heading = Int(round(gliderTelemetry.heading))
        
        // Update speedometer here (don't forget tuo call updateDisplay())
        speedometer.setSpeed(gliderTelemetry.speed)
        
        // Update mini-map
        miniMap.addPoint(deg: gliderTelemetry.heading, vel: gliderTelemetry.speed)
        
        updateGliderGraphs()
    }
    

    
    
    // ********** Serial Commands *********************************************
    @IBAction func send(_: AnyObject) { // Custom ones
        print("Sending")
        let string = sendTextField.stringValue
        //sendTextField.stringValue = ""
        if let data = string.data(using: String.Encoding.utf8) {
            serialPort?.send(data)
            let notifyOfActivation = "Preset command sent (\(string))\n"
            self.receivedTextField.textStorage?.mutableString.append(notifyOfActivation)
            self.receivedTextField.needsDisplay = true
            receivedTextField.scrollToEndOfDocument(self)
            receivedTextField.textColor = NSColor(calibratedRed: 166/255, green: 170/255, blue: 169/255, alpha: 1)
            
        }
    }
    
    // Preset Commands
    @IBAction func custom_ForceDeploy(_: AnyObject) {
        let data = "x".data(using: String.Encoding.utf8)
        serialPort?.send(data!)
        //theta += 0.1  // For testing 
        //miniMap.updateDisplay()
        //compassView.heading += 5
        //compassView.updateDisplay()
        
        let notifyOfActivation = "Force Deploy command sent (x)\n"
        self.receivedTextField.textStorage?.mutableString.append(notifyOfActivation)
        self.receivedTextField.needsDisplay = true
        receivedTextField.scrollToEndOfDocument(self)
        receivedTextField.textColor = NSColor(calibratedRed: 166/255, green: 170/255, blue: 169/255, alpha: 1)
    }
    
    @IBAction func connectPort(_ sender: AnyObject) {
        if let port = serialPort {
            if port.isOpen {
                port.close()
                print("Closed port")
                connectButton.title = "Open"
            } else {
                port.open()
                port.delegate = self // BLOODY HELL
                port.baudRate = 9600
                port.numberOfStopBits = 1
                port.parity = ORSSerialPortParity(rawValue: 0)!
                port.numberOfStopBits = 1
                port.dtr = false
                port.rts = false
                connectButton.title = "Close"
                print("Opened port")
            }
        }
    }
    
    
    
    // ********** Protocol compliance *****************************************
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print("Removed from system")
        self.serialPort = nil
        connectButton.title = "Open"
        // Would set serial port to nil
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) { // Here's where data is received
        if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            print(string)
            
            // Parse for newline
            _ = parse(string as String)
            
            // Add to text field
            self.receivedTextField.textStorage?.mutableString.append(string as String)
            self.receivedTextField.needsDisplay = true
            receivedTextField.scrollToEndOfDocument(self)
            receivedTextField.textColor = NSColor(calibratedRed: 166/255, green: 170/255, blue: 169/255, alpha: 1)
        } else {
            print("Invalid received data")
        }
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        connectButton.title = "Close"
        print("Port was opened")
    }
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        connectButton.title = "Open"
        receivedTextField.scrollToEndOfDocument(self) // NOTE: Stephen, this is the best thing!!! **
        print("Port was closed")
    }
    
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("SerialPort \(serialPort) encountered an error: \(error)")
    }
    
    
    // ********** Parsing packet data *****************************************
    func parsePacket(_ str: String) -> Bool {
        // Ignore any bad packets and tell telem to increment
        let arr = str.characters.split(separator: ",").map(String.init)
        
        if str.contains("CONTAINER") {
            _ = containerTelemetry.add(arr)
            updateContainerUI()
            return true
        } else if str.contains("GLIDER") {
            _ = gliderTelemetry.add(arr)
            updateGliderUI()
            return true
        } else {
            // Bad packet received
            print("Bad packet received")
            return false
        }
    }
    
    // Update all graphs
    func updateGliderGraphs() {
        // Add vals and update graphs
        gAltGraph.add(gliderTelemetry.altitude)
        gPressGraph.add(gliderTelemetry.pressure)
        gSpeedGraph.add(gliderTelemetry.speed)
        gTempGraph.add(gliderTelemetry.temp)
        gVoltGraph.add(gliderTelemetry.voltage)
        gHeadGraph.add(gliderTelemetry.heading)
        
        gAltGraph.updateDisplay()
        gPressGraph.updateDisplay()
        gSpeedGraph.updateDisplay()
        gTempGraph.updateDisplay()
        gVoltGraph.updateDisplay()
        gHeadGraph.updateDisplay()
        
        gliderVoltMeter.updateDisplay()
        compassView.updateDisplay()
        speedometer.updateDisplay()
        
        miniMap.updateDisplay()
    }
    
    func updateContainerGraphs() {
        // Add vals and update graphs
        cAltGraph.add(containerTelemetry.altitude)
        cTempGraph.add(containerTelemetry.temperature)
        cVoltGraph.add(containerTelemetry.voltage)
        
        cAltGraph.updateDisplay()
        cTempGraph.updateDisplay()
        cVoltGraph.updateDisplay()
        
        containerVoltMeter.updateDisplay()
    }
    
    @IBAction func toggleFileSaving(_ sender: AnyObject) {
        if saveOutput {
            saveOutput = false
            savingToggle.title = "Saving disabled"
        } else {
            saveOutput = true
            savingToggle.title = "Saving enabled"
        }
    }
    
    // MARK: - Extra stuff

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        connectButton.title = "Open"
        
        // Background window colours
        //view.wantsLayer = true
        //self.view.layer?.backgroundColor = CGColor(red: 28/255, green: 28/255, blue: 34/255, alpha: 1)
        
        // Text field colours
        receivedTextField.isEditable = false
        receivedTextField.backgroundColor = NSColor(calibratedRed: 35/255, green: 35/255, blue: 44/255, alpha: 1)
        receivedTextField.textColor = NSColor(calibratedRed: 166/255, green: 170/255, blue: 169/255, alpha: 1)
        
        updateGliderUI()
        updateContainerUI()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    // Generic send function
    func sendCommand(_ s: String) {
        if let data = s.data(using: String.Encoding.utf8) {
            serialPort?.send(data)
            let notifyOfActivation = "Preset command sent (\(s))\n"
            self.receivedTextField.textStorage?.mutableString.append(notifyOfActivation)
            self.receivedTextField.needsDisplay = true
            receivedTextField.scrollToEndOfDocument(self)
            receivedTextField.textColor = NSColor(calibratedRed: 166/255, green: 170/255, blue: 169/255, alpha: 1)
        } else {
            print("Unable to send command '\(s)'")
        }
        
    }


}

