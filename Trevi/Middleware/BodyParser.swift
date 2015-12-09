//
//  BodyParser.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class BodyParser : Middleware{
    
    public var name : MiddlewareName;
    
    public init(){
        name = .BodyParser
    }
    
    public func operateCommand(obj: AnyObject...) ->Bool {
        var req : Request = obj[0] as! Request;
        let r : Route = obj[2] as! Route
        parserBody(&req,r)
        return true
    }
    
    public func parserBody(inout req : Request , _ route : Route){
        // fill request.params use route.regExp and Params
        parseHeader(req)
        
    }
    
    public func parseHeader(req : Request){
        let headerString = String(data: req.requestData, encoding: NSUTF8StringEncoding)
        let headerComp : [String] = headerString!.componentsSeparatedByString("\r\n")
        let firstLine : String = headerComp.first!;
        
        var firstLineArr: [String] = firstLine.componentsSeparatedByString(" ")
        if firstLineArr.count > 0 {
            if let method = HTTPMethodType(rawValue: firstLineArr[0]) {
                req.method = method
            }
        }
        
        if firstLineArr.count > 1 {
            let url = firstLineArr[1]
            var urlElements: [String] = url.componentsSeparatedByString("?") as [String]
            req.path = urlElements[0]
            if urlElements.count == 2 {
                
                let args = urlElements[1].componentsSeparatedByString("&") as [String]
                for a in args {
                    var arg = a.componentsSeparatedByString("=") as [String]
                    var value = ""
                    if arg.count > 1 {
                        value = arg[1]
                    }
                    req.query.updateValue(value.stringByRemovingPercentEncoding!, forKey: arg[0].stringByRemovingPercentEncoding!)
                }
            }
        }

        //        self.method  = HTTPMethodType(rawValue: headerComp.first!)!
        for seg in headerComp{
            let segSet : [String] = seg.componentsSeparatedByString(": ");
            if segSet.count > 1 {
                req.header[segSet[0]] = segSet[1];
            }
        }
        if headerComp.last?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0{
            req.body = self.convertStringToDictionary(headerComp.last!)!
            
        }
        
    }
    
    private func wrap(json :[String:AnyObject]!){

    }
    
    private func convertStringToDictionary(text: String) -> [String:AnyObject!]! {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject!]
                print("convertStringToDictionary")
                
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    
    
}