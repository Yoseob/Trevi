//
//  Response.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Response {
    
    public var body = [String : String]()
    public var header  = [String:String]()
    public var bodyString : String
    public var statusCode : Int
    
    private var socket : SwiftSocket?
    public var renderer : Renderer?
    
    public init() {
        statusCode = 0
        bodyString = ""
    }
    
    public init(socket : SwiftSocket){
        self.socket = socket   // if render , send , template func is called call self.socket.send(AnyOnject)
        statusCode = 0
        bodyString = ""
    }
    
    //like send func
    public func send(data : Any){
        bodyString += String(data);
        implSend()
    }
    
    public func send(){
        implSend()
    }
    
    public func render(obj: AnyObject ...){
        let filename = obj[0] as! String
        let args: [String: String]
        
        if obj.count > 1 {
            args = obj[1] as! [String: String]
        } else {
            args = [:]
        }
        
        if let data = renderer?.render(filename, args: args) {
            bodyString = data;
            implSend()
        } else {
            implSend()
        }
    }
    
    public func template(){
        implSend()
    }

    private func implSend(){
        defualtSet()
        let sendData: NSData = makeResponse(prepareHeader(), body: prepareBody())
        socket?.sendData(sendData)
    }

    private func defualtSet(){
//        let fristLine = "HTTP/1.1 \(statusCode) OK"
//        header[fristLine] = ""
        header["Content-Length"] = "\(bodyString.length())" // replace bodyString length
        header["Content-Type"] = "text/html;charset=utf-8"
    }
    
    private func makeResponse(header : NSData , body : NSData) -> (NSData){
        let result = NSMutableData(data: header)
        result.appendData(body)
        return result;
    }

    private func prepareHeader() -> NSData {
        var headerString = "HTTP/1.1 \(statusCode) OK"
        headerString += dictionaryToString(header)
//        let headerString = dictionaryToString(header)
        return headerString.dataUsingEncoding(NSUTF8StringEncoding)!

    }
    private func prepareBody()->NSData{
        bodyString += dictionaryToString(body);
        return bodyString.dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    private func dictionaryToString(dic: NSDictionary) -> String!{
        var resultString = ""
        for (key,value) in dic{
            if value.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
                resultString += "\(key)\r\n"
            }else{
                resultString += "\(key):\(value)\r\n"
            }
        }
        resultString += "\r\n"
        return resultString;
    }
}