//
//  UIWebViewController.swift
//  Thermostat
//
//  Created by Peter K on 11/27/15.
//  Copyright © 2015 Peter Kuhar. All rights reserved.
//

import UIKit
import JavaScriptCore

class UIWebViewController: UIViewController,UIWebViewDelegate {
    var webView:UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView = UIWebView(frame: self.view.bounds)
        webView.autoresizingMask = UIViewAutoresizing(rawValue:  UIViewAutoresizing.FlexibleHeight.rawValue | UIViewAutoresizing.FlexibleWidth.rawValue)
        view.addSubview(webView)
        webView.delegate = self
        
        let index = NSBundle.mainBundle().URLForResource("index", withExtension: "html", subdirectory: "web")
        loadUrl(index!.absoluteString)
        
        let context = self.webView.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as! JSContext
        
        let logFunction : @convention(block) (String) -> Void =
        {
            (msg: String) in
            
            NSLog("Console: %@", msg)
        }
        context.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, AnyObject.self),
            forKeyedSubscript: "log")
        
        let reloadButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44) )
        reloadButton.addTarget(self, action: "reload:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(reloadButton)
    }
    
    func reload(sender:AnyObject){
        webView.reload()
    }
    
    func loadUrl(url:String){
        webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        updateWebView()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        //http://192.168.1.140:9700/devices/bedroom_heater/
        
        let scheme = request.URL?.scheme ?? ""
        let query = request.URL?.query ?? ""
        let path = request.URL?.parameterString ?? ""
        
        let url = request.URL?.absoluteString ?? ""
        
        if(scheme == "command"){
            let jsonString = (url as NSString).substringFromIndex("command:".lengthOfBytesUsingEncoding(NSUTF8StringEncoding) ).stringByRemovingPercentEncoding!
            
            let json = try? NSJSONSerialization.JSONObjectWithData(jsonString.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions(rawValue: 0))
            
            if let json = json as? [String:AnyObject]{
                
                if let wemo = json["wemo"] as? [String:AnyObject]{
                    let address = wemo["address"] as? String ?? ""
                    let on = wemo["on"] as? Bool ?? false
                    
                    ULWemo.control(address,on: on)
                }
                
                if let wemo = json["lazybone"] as? [String:AnyObject]{
                    let address = wemo["address"] as? String ?? ""
                    let on = wemo["on"] as? Bool ?? false
                    
                    ULLazyBone.control(address,on: on)
                }
                return false;
            }else{
                webView.stringByEvaluatingJavaScriptFromString("alert('Error in command ');");
            }
            
            
        }
        
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var temperatures:[String:Double] = [:]
    
    func updateTemperatures(temperatures:[String:Double]){
        temperatures.forEach { (name, temperature) -> () in
            self.temperatures[name] = temperature
            updateWebView()
        }
    }
    
    func updateWebView(){
        
        let json = NSString(data: try! NSJSONSerialization.dataWithJSONObject(self.temperatures, options: NSJSONWritingOptions.PrettyPrinted),encoding:NSUTF8StringEncoding)!
       // webView?.stringByEvaluatingJavaScriptFromString("thermostat.updateTemperatures(\(json));")
        webView?.stringByEvaluatingJavaScriptFromString("var event = new CustomEvent('temperature', { 'detail':\(json)});window.dispatchEvent(event);")

    }
}
