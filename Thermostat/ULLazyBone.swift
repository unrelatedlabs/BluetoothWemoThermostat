//
//  ULLazyBone.swift
//  Thermostat
//
//  Created by Peter K on 11/18/15.
//  Copyright © 2015 Peter Kuhar. All rights reserved.
//

import UIKit
import CocoaAsyncSocket



class ULLazyBone: NSObject {
    static var sn:SendNet!
    
    class func control(address:String,on:Bool){
        sn =  SendNet()
        sn.state = on
        sn.setupConnection(address)

    }
}


public class SendNet: NSObject, GCDAsyncSocketDelegate {
    
    var socket:GCDAsyncSocket! = nil
    var state:Bool = false
    
    func setupConnection(address:String){
        
        if (socket == nil) {
            socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        } else {
            socket.disconnect()
        }
        
        let error = try? socket.connectToHost(address, onPort: UInt16(2000), withTimeout: 5)
        
        NSLog("Error \(error)")
        
       
    }
    
    public func socket(socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16) {
        
        //println("Connected to \(host) on port \(p).")
        
        self.socket = socket
        
        
        sendString( state ? "e\n" : "o\n" );

        
    
        
    }
    
    func sendString(string:String){
        
        let data = string.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        socket.writeData(data, withTimeout: 4, tag: 0)
        socket.readDataWithTimeout(-1.0, tag: 0)

    }
    
    func send(msgBytes: [UInt8]) {
        
        let msgData = NSData(bytes: msgBytes, length: msgBytes.count)
        socket.writeData(msgData, withTimeout: -1.0, tag: 0)
        socket.readDataWithTimeout(-1.0, tag: 0)
        
    }
    
  
    
    public func socket(socket : GCDAsyncSocket!, didReadData data:NSData!, withTag tag:Int){
        
        let msgData = NSMutableData()
        msgData.setData(data)
        
        var msgType:UInt16 = 0
        msgData.getBytes(&msgType, range: NSRange(location: 2,length: 1))
        
       // println(msgType)
        

        
    }
}
