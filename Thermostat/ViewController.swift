//
//  ViewController.swift
//  Thermostat
//
//  Created by Peter Kuhar Jagodnik on 1/22/15.
//  Copyright (c) 2015 Peter Kuhar. All rights reserved.
//

import UIKit
extension Double {
    func format(f: Int) -> String {
        return NSString(format: "%.\(f)f", self)
    }
}

class ViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var heaterSwitch: UISwitch!
    @IBOutlet weak var thermostatSwitch: UISwitch!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperatureDiffLabel: UILabel!
    @IBOutlet weak var targetTemperatureLabel: UILabel!
    @IBOutlet weak var temperatureSlider: UISlider!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    var thermometer = ULBluetoothThermometer()
    var hysteresis:Double = 0.3;
    
    var targetTemperature:Double{
        get{
            return Double(temperatureSlider.value)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thermometer.temperatureChange = { (temperature) ->  Void in
            self.updateThermostat()
        }
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        UIDevice.currentDevice().proximityMonitoringEnabled = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func updateThermostat(){
        self.temperatureLabel.text = "\(thermometer.temperature.format(1))°C"
        let targetF = targetTemperature * 180 / 100 + 32
        targetTemperatureLabel.text = "\(targetTemperature.format(1))°C \(targetF.format(1))°F"
        let diff = thermometer.temperature - targetTemperature;


        temperatureDiffLabel.text = "\(diff.format(1))"
        
        if diff > hysteresis{
            turn(false);
        }
    
        if -diff > hysteresis{
            turn(true);
        }
        
        self.writeToFile(thermometer.temperature, target: targetTemperature, state: heaterEnabled)
    }
    
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func turn(onOff:Bool){
        NSLog("turn \(onOff)");
        if thermostatSwitch.on{
            
            heaterSwitch.on = onOff;
            controllHeader(onOff)
        }
        
    }
    
    func controllHeader(onOff:Bool){
        heaterEnabled = onOff;
        
        let url = textField.text + ( onOff ? "on":"off")
        
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: url)!), queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if let error = error{
                self.statusLabel.text = error.localizedDescription
            }
            if let data = data{
                self.statusLabel.text = NSString(data: data, encoding: NSUTF8StringEncoding)
            }
        }
        
    }
    
    var heaterEnabled = false

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func heaterSwitchChanged(sender: UISwitch) {
        controllHeader(sender.on)
        self.writeToFile(thermometer.temperature, target: targetTemperature, state: heaterEnabled)
    }
    

    @IBAction func thermostatSwitchChanged(sender: UISwitch) {
        self.updateThermostat()
    }
    
    @IBAction func temperatureSliderChange(sender: UISlider) {
        self.updateThermostat()
    }
    
    var logFile:NSFileHandle? = nil
    func writeToFile(current:Double,target:Double,state:Bool){
        var str = "\(NSDate()),\(current),\(target),\(state)\n"
        
        if logFile == nil{
            let filename = "~/Documents/log.csv".stringByExpandingTildeInPath
            if !NSFileManager.defaultManager().fileExistsAtPath(filename){
                NSFileManager.defaultManager().createFileAtPath(filename, contents: nil, attributes: nil)
            }
            
            logFile = NSFileHandle(forWritingAtPath:filename)
        }
        logFile?.writeData( str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)! );
    }
}

