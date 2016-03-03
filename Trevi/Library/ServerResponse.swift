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
            header[Content_Type] = "text/plain;charset=utf-8"
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
            let jsonData = try? NSJSONSerialization.dataWithJSONObject(bodys!, options:NSJSONWritingOptions(rawValue:0))
            // if need jsonString, use it
            // let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)! as String
            return jsonData
        }
        return nil
    }
    
    private var status: String!
    
    private var firstLine: String!
    
    public init(socket: Socket) {
        super.init(socket: socket)
        self._body = ""
    }
    
    public func end(){
        let hData: NSData = self.prepareHeader()
        let result: NSMutableData = NSMutableData(data: hData)
        result.appendData(self.bodyData!)
        self._end(result)
    }
    
    public func writeHead(statusCode: Int, headers: [String:String]! = nil){
        self.statusCode = statusCode
        firstLine = "\(httpVersion) \(statusCode) \(status)" + CRLF
    }
    
    //will move outgoingMessage
    public func write(data: AnyObject?, encoding: String! = nil, type: String! = ""){
        
        switch data {
        case let str as String :
            self._body = str
        case let dt as NSData:
            self._bodyData! = dt
            if let t = type{
                header[Content_Type] = t
            }
        case let dic as [String:AnyObject]:
            self.bodys = dic
        default:
            break
        }
        if let _ = data{
            self._hasbody = true
            statusCode = 200
        }
        
    }
    
    /**
     * Factory method fill header data
     *
     * @private
     * return {NSData} headerdata
     */
    private func prepareHeader () -> NSData {
        
        header[Date] = NSDate.GtmString()
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
    
    private func dictionaryToString ( dic: NSDictionary ) -> String! {
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

