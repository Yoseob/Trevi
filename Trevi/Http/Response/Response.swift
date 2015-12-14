//
//  Response.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation


public class Response{

    public var header = [ String: String ] ()
    
    public var statusString: String {
        return internalStatus.statusString ()
    }
    public var statusCode: Int {
        return internalStatus.rawValue
    }
    public var status: Int {
        set {
            internalStatus = StatusCode ( rawValue: newValue )!
        }
        get {
            return statusCode
        }
    }
    
    
    private var data : NSData?
    private var body = [ String: AnyObject ] ()
    private var bodyString: String? {
        didSet {
            if let _ = header[Content_Type] {
                header[Content_Type] = "text/plain;text/html;charset=utf-8"
            }
        }
    }

    private var bodyData : NSData? {
        if let dt = data{
            return dt
        }
        var resultBodyString : String!
        if let bodyString = bodyString {
            resultBodyString = bodyString
            return resultBodyString.dataUsingEncoding(NSUTF8StringEncoding)!
        }else if body.keys.count > 0{
            return   NSKeyedArchiver.archivedDataWithRootObject(body) as NSData
        }

        return nil
    }


    private var internalStatus : StatusCode = .OK

    public var socket : TreviSocket?

    public var  renderer: Renderer?

    public init(){
    }

    public init ( socket: TreviSocket ) {
        self.socket = socket   // if render , send , template func is called call self.socket.send(AnyOnject)
    }
    

    
    /**
     * Send a response data
     *
     *
     * Examples:
     *
     *     res.send({ some: 'dictionary' });
     *     res.send('some html');
     *
     * @param { String|number|Any} data
     * @public
     */

    public func send ( dt: AnyObject ) -> Bool {
        //need control flow that can divide any type
        switch dt {
        case let str as String :
            bodyString = str
        case let d as NSData:
            self.data = d
        default:
            break
        }
        return implSend ()
    }

    public func send () -> Bool {
        return implSend ()
        
    }

    public func render ( obj: AnyObject... ) -> Bool {
        let filename = obj[0] as! String
        let args: [String:String]

        if obj.count > 1 {
            args = obj[1] as! [String:String]
        } else {
            args = [:]
        }

        if let data = renderer?.render ( filename, args: args ) {
            bodyString = data;
        }

        return implSend ()

    }

    public func template () -> Bool{
       return implSend ()
    }

    public func redirect ( url u: String ) {
        self.status = 302
        self.header[Location] = u
    }

    private func implSend () ->Bool{
        let headerData       = prepareHeader ()
        let sendData: NSData = makeResponse ( headerData, body: self.bodyData! )
        socket!.sendData ( sendData )
        return true
    }


    private func makeResponse ( header: NSData, body: NSData ) -> ( NSData ) {
        let result = NSMutableData ( data: header )
        result.appendData ( body )
        return result;
    }

    private func prepareHeader () -> NSData {
        header[Content_Length] = "\(bodyData!.length)" // replace bodyString length
        var headerString = "\(HttpProtocol) \(statusCode) \(statusString)" + NewLine
        headerString += dictionaryToString ( header )
        return headerString.dataUsingEncoding ( NSUTF8StringEncoding )!

    }

    private func prepareBody () -> NSData {
        var resultBodyString: String!
        if let bodyString = bodyString where bodyString.length () > 1 {
            resultBodyString = bodyString
        } else {
            resultBodyString = dictionaryToString ( body );
        }

        return resultBodyString.dataUsingEncoding ( NSUTF8StringEncoding )!
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
        resultString += NewLine
        return resultString;
    }
}
