//
//  Response.swift
//  IWas
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Response{
    
    public var body = [String : String]()
    public var header  = [String:String]()
    public var bodyString :String
    public var statusCode : Int
    
    
    private var socket : SwiftSocket?
    
    
    public init(socket : SwiftSocket){
        self.socket = socket   // if render , send , template func is called call self.socket.send(AnyOnject)
        statusCode = 0
        bodyString = ""

    }
    
    //like send func
    public func sender(data : Any){
        bodyString =  String(data)
        defualtSet()
        let sendData: NSData = makeResponse(prepareHeader(), body: prepareBody())
        socket?.sendData(sendData)
    }
    
    public func render(obj: AnyObject ...){
        defualtSet()
        let sendData: NSData = makeResponse(prepareHeader(), body: prepareBody())
        socket?.sendData(sendData)
    }
    
    public func template(){
        defualtSet()
    }


    private func defualtSet(){
        let fristLine = "HTTP/1.1 \(statusCode) OK"
        header[fristLine] = ""
        header["Content-Length"] = "\(bodyString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))" // replace bodyString length
        header["Content-Type"] = "text/html;charset=utf-8"
        
        
    }
    
    private func makeResponse(header : NSData , body : NSData) -> (NSData){
        let result = NSMutableData(data: header)
        result.appendData(body)
        return result;
    }

    private func prepareHeader() -> NSData {
        let headerString = dictionaryToString(header)
        return headerString.dataUsingEncoding(NSUTF8StringEncoding)!

    }
    private func prepareBody()->NSData{
        if bodyString.characters.count > 0 {
            bodyString += dictionaryToString(body);
        }else{
            bodyString = dictionaryToString(body);
        }
        return bodyString.dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    private func dictionaryToString(dic: NSDictionary) -> String!{
        var resultString = ""
        for (key,value) in dic{
            if value.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
                resultString += "\(key)\r\n"
            }else{
                resultString += "\(key):\(value) \r\n"
            }
        }
        resultString += "\r\n"
        return resultString;
    }

}