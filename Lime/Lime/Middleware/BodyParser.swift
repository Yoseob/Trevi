//
//  BodyParser.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi

private protocol parseAble{
    func parse() -> [String:AnyObject!]!
}

struct ParserdData {
    var name : String?
    var value : String?
    var type : String?
    var data : NSData?
}


/*
This class is the middleware as one of the most important
Consisting of many ways is easily allows us to write the user body.
*/


public class BodyParser: Middleware{

    public var name  = MiddlewareName.BodyParser
    
    public init(){
        
    }

    public func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback?) {
        
    }
    
    public static func getBody(req: IncomingMessage, _ cb: (body: String)->()){
        
        var body = ""
        func ondata(dt : String){
            body += dt
        }
        
        func onend(){
            cb(body: body)
        }
        req.on("data", ondata)
        req.on("end", onend)
    }
    
    public static func read(req: IncomingMessage, _ next: NextCallback?, parse: ((req: IncomingMessage,  next: NextCallback ,  body: String!)->())){
        getBody(req) { body in
            parse(req: req, next: next!, body: body)
            
        }
    }
    
    public static func urlencoded() -> HttpCallback{
        func parse(req: IncomingMessage, _ next: NextCallback? , _ bodyData: String!){
            var body = bodyData
            if body != nil {
                
                if body.containsString(CRLF){
                    body.removeAtIndex(body.endIndex.predecessor())
                }
                var resultBody = [String:String]()
                for component in body.componentsSeparatedByString("&") {
                    let trim = component.componentsSeparatedByString("=")
                    resultBody[trim.first!] = trim.last!
                }
                req.body = resultBody
            
                next!()
            }else {
                
            }
        }
        
        func urlencoded(req: IncomingMessage, res: ServerResponse, next: NextCallback?) {
            guard req.header[Content_Type] == "application/x-www-form-urlencoded" else {
                return next!()
            }
            
            guard req.hasBody == true else{
                return next!()
            }

            guard req.method == .POST || req.method == .PUT  else{
                return next!()
            }
            
            read(req, next!,parse: parse)
        }
        return urlencoded

    }
    
    
    public static func json() -> HttpCallback {
        
        func parse(req: IncomingMessage, _ next: NextCallback? , _ body: String!){
            do {
                
                let data = body.dataUsingEncoding(NSUTF8StringEncoding)
                let result = try NSJSONSerialization.JSONObjectWithData (data! , options: .AllowFragments ) as? [String:String]
                if let ret = result {
                    req.json = ret
                    return next!()
                }else {
                    // error handle
                }
            } catch {
                
            }
        }
        
        func jsonParser(req: IncomingMessage, res: ServerResponse, next: NextCallback?) {
            guard req.header[Content_Type] == "application/json" else {
                return next!()
            }
            
            guard req.hasBody == true else{
                return next!()
            }

            guard req.method == .POST || req.method == .PUT  else{
                return next!()
            }

            read(req, next!,parse: parse)
        }
        return jsonParser
    }
    
    
    public static func text() -> HttpCallback{
        
        func parse(req: IncomingMessage, _ next: NextCallback? , _ body: String!){

            if let ret = body {
                req.bodyText = ret
                return next!()
            }else {
                // error handle
            }
        }
        
        func textParser(req: IncomingMessage, res: ServerResponse, next: NextCallback?) {
            guard req.header[Content_Type] == "text/plain" else {
                return next!()
            }
            
            guard req.hasBody == true else{
                return next!()
            }
            
            guard req.method == .POST || req.method == .PUT  else{
                return next!()
            }
            
            read(req, next!,parse: parse)
        }
        
        return textParser
    }
    
}




    
