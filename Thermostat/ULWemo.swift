//
//  ULWemo.swift
//  Thermostat
//
//  Created by Peter K on 11/27/15.
//  Copyright © 2015 Peter Kuhar. All rights reserved.
//

import UIKit

class ULWemo: NSObject {
    class func control(address:String,on:Bool){
        

        let url = address + ( on ? "on":"off")
        
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: url)!), queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if let error = error{
                NSLog("Error \(error) \(error.localizedDescription)")
                
            }
            if let data = data{
                let status = NSString(data: data, encoding: NSUTF8StringEncoding) as? String ?? ""
                NSLog("wemo status \(status)")
            }
        }
        
    }
}
