//
//  Request.swift
//  IWas
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Request{
    private var requestData : NSData?
    
    public var method : HTTPMethodType = HTTPMethodType.UNDEFINED
    
    // path /test/:id
    public var params = [String : String]()
    
    // path /test?id = "123"
    public var query = [String : String]()
    
    public var header = [String : String]()
    public var body = [String:AnyObject]()
    
    public var pathComponent : [String] = [String]()
    public var path : String{
        didSet{
            let segment = self.path.componentsSeparatedByString("/")
            for seg in segment{
                pathComponent.append(seg)
            }
        }
    }
    
    public init(){
        self.path = String()
    }
    public init( _ reqData : NSData){
        self.path = String()
        self.requestData = reqData
        self.parseHeader(reqData)
    }
    
    public func parseHeader(headerData : NSData){
        let headerString = String(data: headerData, encoding: NSUTF8StringEncoding)
        let headerComp : [String] = headerString!.componentsSeparatedByString("\r\n")
        
        let firstLine : String = headerComp.first!;
        
        var firstLineArr: [String] = firstLine.componentsSeparatedByString(" ")
        if firstLineArr.count > 0 {
            if let method = HTTPMethodType(rawValue: firstLineArr[0]) {
                self.method = method
            }
        }
        
        if firstLineArr.count > 1 {
            
            let url = firstLineArr[1]
            var urlElements: [String] = url.componentsSeparatedByString("?") as [String]
            
            self.path = urlElements[0]
            
            if urlElements.count == 2 {
                
                let args = urlElements[1].componentsSeparatedByString("&") as [String]
                
                for a in args {
                    
                    var arg = a.componentsSeparatedByString("=") as [String]
                    
                   
                    var value = ""
                    if arg.count > 1 {
                        value = arg[1]
                    }
                    
                    // Adding the values removing the %20 bullshit and stuff
                    self.query.updateValue(value.stringByRemovingPercentEncoding!, forKey: arg[0].stringByRemovingPercentEncoding!)
                }
            }
        }

        
//        self.method  = HTTPMethodType(rawValue: headerComp.first!)!
        for seg in headerComp{
            let segSet : [String] = seg.componentsSeparatedByString(": ");
            if segSet.count > 1 {
                self.header[segSet[0]] = segSet[1];
            }
        }
        if headerComp.last?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0{
            self.body = self.convertStringToDictionary(headerComp.last!)!
        }
        
    }
    
    private func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
}