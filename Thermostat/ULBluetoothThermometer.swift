//
//  ULBluetoothThermometer.swift
//  Thermostat
//
//  Created by Peter Kuhar Jagodnik on 1/22/15.
//  Copyright (c) 2015 Peter Kuhar. All rights reserved.
//

import UIKit
import CoreBluetooth

class ULBluetoothThermometer: NSObject,CBCentralManagerDelegate {
    
    let kTemperatureClass = CBUUID(string: "1809");
    
    var bluetoothManager = CBCentralManager(delegate: nil, queue: dispatch_get_main_queue())
    
    var temperatureChange: ((Double,String)->Void)?
    var sensorUUID:String?;
    var temperature:Double = 0;
    
    var deviceNames = ["2600032D":"bedroom","57A7993C":"living-room"]
    
    override init(){
        super.init()
        bluetoothManager.delegate = self;
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager){
        switch central.state{
        case CBCentralManagerState.PoweredOn:
            central.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
            break;
        default:
            break;
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber){
        
        if let temperature = self.tempFromAdvData(advertisementData){
            var name = peripheral.name ?? peripheral.identifier.UUIDString
            name = deviceNames[name] ?? name
            NSLog("Temperature \(temperature) \(name)");
            if let callbackBlock = temperatureChange{
                self.temperature = temperature;
                callbackBlock(temperature, name);
            }
        }
    }
    
    func tempFromAdvData(data:[NSObject:AnyObject]) -> Double?{
        if let data = data["kCBAdvDataServiceData"] as? [NSObject:AnyObject]{
            if let data = data[kTemperatureClass] as? NSData{
                let bytes = data.bytes;
                let n = UnsafePointer<UInt8>(bytes);
                var temp: Double = Double(n[1]) * 256.0 + Double(n[0])  ;
                temp = temp / 100.0
                return temp
            }
        }
        return nil;
    }
}
