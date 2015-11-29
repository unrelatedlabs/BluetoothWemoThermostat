//
//  ULDweet.swift
//  Thermostat
//
//  Created by Peter K on 11/13/15.
//  Copyright © 2015 Peter Kuhar. All rights reserved.
//

import UIKit

class ULDweet: NSObject {
    class func post(thing:String,data:[String:Double],completionBlock:((error:NSError!)->Void)){
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://dweet.io:443/dweet/for/\(thing)" )!)
        
        //com.unrelatedlabs.oxford-bedroom-temperature
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.PrettyPrinted)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if let data = data{
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary{
                    
                    
                    
                    completionBlock(error: nil)
                    return
                    
                }
                
                
            }
            
            
            completionBlock(error: nil)
            
        }
    }
}


class IOTData: NSObject {
    class func post(thing:String,data:[String:Double],completionBlock:((error:NSError!)->Void)){
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://iotdata.parseapp.com:443/\(thing)" )!)
        
        //com.unrelatedlabs.oxford-bedroom-temperature
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.PrettyPrinted)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if let data = data{
                if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary{
                    
                    
                    
                    completionBlock(error: nil)
                    return
                    
                }
                
                
            }
            
            
            completionBlock(error: nil)
            
        }
    }
}
