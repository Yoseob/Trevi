//
//  BodyParser.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
private protocol parseAble{
    func parse() -> [String:AnyObject!]!
}
public typealias Function =  (NSData) -> [String:AnyObject!]!

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
    
    
    
    public func operateCommand ( params: MiddlewareParams ) -> Bool {
        var req: Request = params.req
        
        if req.method == .POST || req.method == .PUT {
            if let type = req.header[Content_Type]  where (functionTable[type] != nil)  {
                parserBody ( &req, boundry: nil, function: functionTable[type]!)
            }else if let type = req.header[Content_Type] {
                
                // below case need splite contenttype and boundary
                //Content-Type: multipart/form-data; boundary=----WebKitFormBoundarywXfXEDEZqJO6nhGr
                
                let ret = spliteContentType(type)
                parserBody(&req, boundry: ret.boundry, function: nil)
            }
        }
        return false
    }

    private func spliteContentType(contentType : String) -> (content_type:String ,boundry : String){
        
        
        let components = contentType.componentsSeparatedByString("; ")
        let lastObject = components.last!
        let boundary = lastObject.componentsSeparatedByString("=").last
        
        return (components.first!,boundary!)
    }
    
    
    
    private func parserBody ( inout req: Request , boundry : String? , function : Function? ) {
        
        let bodyStringLength = "\(req.body.length)"
        if bodyStringLength != req.header[Content_Length]  {
            let headerList = req.headerString.componentsSeparatedByString(CRLF)
            
            let newBodyData = NSMutableData()
            var flag = false
            
            for line in headerList{
                if line.length() == 0 {
                    flag = true
                }
                if flag && line.length() > 0{
                    newBodyData.appendData(line.dataUsingEncoding(NSUTF8StringEncoding)!)
                }
            }
            
            let oldBodyData = NSData(bytes: req.body.mutableBytes, length: req.body.length)
            newBodyData.appendData(oldBodyData)
            req.body = newBodyData
            
        }
        if let boundry = boundry {
            req.json = form_data_parser(req.body, boundry: boundry)
            return
        }
        req.json = function!(req.body)
    }
    
    private func fake_parser ( data: NSData) -> [String:AnyObject!]!{
        
        return nil
    }
    private func json_parser ( data: NSData ) -> [String:AnyObject!]!{
        do {
            return try NSJSONSerialization.JSONObjectWithData ( data, options: .MutableContainers ) as? [String:AnyObject!]
        } catch {
            print ( "Something went wrong" )
            return nil
        }
    }
    
    private func plain_parser ( data: NSData ) -> [String:AnyObject!]!{
        print ( "plain_parser" )
        return nil
    }
    
    private func x_www_form_urlencoded_parser ( data: NSData ) -> [String:AnyObject!]!{
        print(data.length)
        print ( "x_www_form_urlencoded_parser" )
        return nil
    }
    
    private func form_data_parser ( data: NSData , boundry:String) -> [String:AnyObject!]!{
        print ( "form_data_parser" )
        let bodyData = String(data: data, encoding: NSUTF8StringEncoding)
        let datas = bodyData!.componentsSeparatedByString(boundry)
        for dt in datas {
            print(dt)
        }

        return nil
    }
 
}