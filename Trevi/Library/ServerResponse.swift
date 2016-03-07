//
//  ServerResponse.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 3. 3..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation



public class ServerResponse: OutgoingMessage{
    //for Lime
    public var req: IncomingMessage!
    public let startTime: NSDate
    public var onFinished : ((ServerResponse) -> Void)?
    
    public var httpVersion: String = ""
    public var url: String!
    public var method: String!
    public var statusCode: Int!{
        didSet{
            self.status = StatusCode(rawValue: statusCode)!.statusString()
        }
    }
    
    private var _hasbody = false
    
    private var _body: String?{
        didSet {
            self._hasbody = true
            var type = "text/plain;charset=utf-8"
            if ((_body?.containsString("!DOCTYPE")) != nil){
                type = "text/html;charset=utf-8"
            }
            header[Content_Type] = type
        }
    }
    
    private var _bodyData: NSData! {
        didSet{
            self._hasbody = true
            header[Content_Type] = ""
        }
    }
    
    //for dictionary
    private var bodys: [ String: AnyObject ]?{
        didSet{
            self._hasbody = true
            header[Content_Type] = "application/json"
        }
    }
    
    private var bodyData : NSData? {
        if let dt = _bodyData{
            return dt
        }else if let bodyString = _body {
            return bodyString.dataUsingEncoding(NSUTF8StringEncoding)!
        }else if (bodys != nil)  {
            #if os(Linux)
            let jsonData = try? NSJSONSerialization.dataWithJSONObject(bodys as! AnyObject, options:NSJSONWritingOptions(rawValue:0))
            #else
            let jsonData = try? NSJSONSerialization.dataWithJSONObject(bodys!, options:NSJSONWritingOptions(rawValue:0))
            #endif
            // if need jsonString, use it
            // let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)! as String
            return jsonData
        }
        return nil
    }
    
    private var status: String!
    
    private var firstLine: String!
    
    public init(socket: Socket) {
        startTime = NSDate ()
        onFinished = nil
        super.init(socket: socket)
        self._body = ""
    }
    
    public func end(){
        let hData: NSData = self.prepareHeader()
        let result: NSMutableData = NSMutableData(data: hData)
        result.appendData(self.bodyData!)
        onFinished?(self)
        self._end(result)
    }
    
    public func writeHead(statusCode: Int, headers: [String:String]! = nil){
        self.statusCode = statusCode
        firstLine = "\(httpVersion) \(statusCode) \(status)" + CRLF
    }
    
    //will move outgoingMessage
    public func write(data: String, encoding: String! = nil, type: String! = ""){
        _body = data
        _hasbody = true
    }
    
    //will move outgoingMessage
    public func write(data: NSData, encoding: String! = nil, type: String! = ""){
        _bodyData = data
        if let t = type{
            header[Content_Type] = t
        }
        _hasbody = true
    }

    //will move outgoingMessage
    public func write(data: [String : AnyObject], encoding: String! = nil, type: String! = ""){
        bodys = data
        _hasbody = true
    }
    
    /**
     * Factory method fill header data
     *
     * @private
     * return {NSData} headerdata
     */
    private func prepareHeader () -> NSData {
        
        header[Date] = getCurrentDatetime("E,dd LLL yyyy HH:mm:ss 'GMT'")
        header[Server] = "Trevi-lime"
        header[Accept_Ranges] = "bytes"
        
        if self._hasbody {
            header[Content_Length] = "\(bodyData!.length)" // replace bodyString length
        }
        
        if firstLine == nil{
            firstLine = "\(httpVersion) \(statusCode) \(status)" + CRLF
        }
        var headerString = firstLine
        headerString! += dictionaryToString ( header )
        return headerString!.dataUsingEncoding ( NSUTF8StringEncoding )!
    }
    
    private func dictionaryToString ( dic: [String : String] ) -> String! {
        var resultString = ""
        for (key, value) in dic {
            if value.lengthOfBytesUsingEncoding ( NSUTF8StringEncoding ) == 0 {
                resultString += "\(key)\r\n"
            } else {
                resultString += "\(key):\(value)\r\n"
            }
        }
        resultString += CRLF
        return resultString;
    }
}

