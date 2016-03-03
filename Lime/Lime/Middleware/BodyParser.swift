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
public typealias Function =  (IncomingMessage, next: NextCallback?) -> [String:AnyObject!]!

public class BodyParser: Middleware {

    public var name: MiddlewareName;

    public var functionTable = [String : Function]()
    
    public init () {
        name = .BodyParser
    
        //add need content type parser
        self.functionTable["application/json"] = json_parser
        self.functionTable["multipart/form-data"] = fake_parser
        self.functionTable["application/x-www-form-urlencoded"] = x_www_form_urlencoded_parser
        
        //raw 
        self.functionTable["text/plain"] = plain_parser
        
    }
    
    private var bodyBuffer = ""
    
    /**
    The function implemented is Middleware protocol
    
     - Parameter path: parameter consists of route, Requests and response\
     
    - Returns: it is Mean that can next action
    */

    

    public func handle(var req: IncomingMessage, res: ServerResponse, next: NextCallback?) {
        
        // Test read body on bodyParser
        
        guard req.method == .POST || req.method == .PUT  else{
            return next!()
        }
        
        if let type = req.header[Content_Type]  where (functionTable[type] != nil){
            
            parserBody ( &req, boundry: nil, function: functionTable[type]!, next: next!)
            
        }else if let type = req.header[Content_Type] {
            
            // below case need splite content-type and boundary
            //Content-Type: multipart/form-data; boundary=----WebKitFormBoundarywXfXEDEZqJO6nhGr
            let ret = spliteContentType(type)
            
            parserBody(&req, boundry: "--"+ret.boundry, function: nil, next: next)
        }
    }
    
    
    private func spliteContentType(contentType : String) -> (content_type:String ,boundry : String){

        let components = contentType.componentsSeparatedByString("; ")
        let lastObject = components.last!
        let boundary = lastObject.componentsSeparatedByString("=").last        
        return (components.first!,boundary!)
    }
    
    
    /**
     Strategy patterns in their use of using body parsing     
     
     - Parameter path: Request and In certain cases, for boundary, Parse function
     
     - Returns: Void
     */
    private func parserBody ( inout req: IncomingMessage , boundry : String? , function : Function? , next: NextCallback?) {
        
        if let boundry = boundry {
            req.json = form_data_parser(req, boundry: boundry)
            return
        }
        
        function!(req, next: next!)

    }
    
    private func fake_parser ( req : IncomingMessage, next: NextCallback?) -> [String:AnyObject!]!{
        
        return nil
    }
    private func json_parser ( req : IncomingMessage, next: NextCallback?) -> [String:AnyObject!]!{
        

        var body = ""
        func ondata(dt : String){
            body += dt
        }
        
        func onend(){
            do {
                let data = (body as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                req.json = try NSJSONSerialization.JSONObjectWithData (data! , options: .AllowFragments ) as? [String:AnyObject!]
                
                next!()
            } catch {
            
            }
        }
        
        req.on("data", ondata)
        req.on("end", onend)

        return nil
    }
    
    private func plain_parser ( req : IncomingMessage, next: NextCallback? ) -> [String:AnyObject!]!{
        print ( "plain_parser" )
        return nil
    }
    
    private func x_www_form_urlencoded_parser ( req : IncomingMessage, next: NextCallback? ) -> [String:AnyObject!]!{
        print ( "x_www_form_urlencoded_parser" )
        return nil
    }
    
    private func form_data_parser ( req : IncomingMessage , boundry:String) -> [String:AnyObject!]!{
        print ( "form_data_parser" )
        
        

//        var begin = false
//        var end  = false
//        
//        var object : ParserdData?
//        for str in req.bodyFragments{
//            
//            str.enumerateLines({ (line, stop) -> () in
//                print(line)
//                if begin {
//                }else if end{
//                }
//
//                if line == boundry{
//                    if let obj = object {
//                        if obj.type == "image/jpeg"{
//                            req.body[obj.name!] = obj.value
//                        }else if obj.type == "form-data"{
//                            req.body[obj.name!] = obj.data
//                        }
//                    }
//                    object = ParserdData()
//                    begin = true
//                }else if line == CRLF{
//                    print("CRLF")
//                    end = true
//                    begin = false
//                }
//            })
//        }
        return nil
    }
    func convert<T>(count: Int, data: UnsafePointer<T>) -> [T] {
        
        let buffer = UnsafeBufferPointer(start: data, count: count);
        return Array(buffer)
    }
    
 }