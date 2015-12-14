//
//  Response.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//



/*

Cache-Control → no-cache, no-store, must-revalidate
Connection →
Connection
Options that are desired for the connection
close
Content-Encoding → gzip
Content-Type → text/html; charset=UTF-8
Date → Sun, 13 Dec 2015 22:22:54 GMT
P3P → CP="CAO DSP CURa ADMa TAIa PSAa OUR LAW STP PHY ONL UNI PUR FIN COM NAV INT DEM STA PRE"
Pragma → no-cache
Server → nginx
Transfer-Encoding → chunked
X-Frame-Options → SAMEORIGIN


*/
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
    
    //for image
    private var data : NSData?{
        didSet{
            
        }
    }
    
    //for dictionary
    private var body : [ String: AnyObject ]?{
        didSet{
            header[Content_Type] = "application/json;charset=utf-8"
        }
    }
    
    //for text
    private var bodyString: String? {
        didSet {
                header[Content_Type] = "text/plain;charset=utf-8"
        }
    }

    //for all kind of data
    private var bodyData : NSData? {
        
        if let dt = data{
            return dt
        }else if let bodyString = bodyString {
            return bodyString.dataUsingEncoding(NSUTF8StringEncoding)!
        }else if (body != nil)  {
            let jsonData = try? NSJSONSerialization.dataWithJSONObject(body!, options:NSJSONWritingOptions(rawValue:0))
//            if need jsonString, use it
//            let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)! as String
            return jsonData
        }

        return nil
    }


    private var internalStatus : StatusCode = .OK

    private var socket : SwiftSocket?

    public var  renderer: Renderer?

    public init(){
    }

    public init ( socket: SwiftSocket ) {
        self.socket = socket   // if render , send , template func is called call self.socket.send(AnyOnject)
    }
    

    
    /**
     * Send a response data
     *
     *
     * Examples:
     *
     *     res.send([:])
     *     res.send('some html')
     *
     * @param { String|number|AnyObject} data
     * @public
     */

    public func send (data: AnyObject? = nil) -> Bool {
        //need control flow that can divide AnyObject type
        switch data {
        case let str as String :
            bodyString = str
        case let dt as NSData:
            self.data = dt
        case let dic as [String:AnyObject]:
            body = dic
        default:
            break
        }
        return end()
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
        //this function called when rand html. forced change content-type = text/html
        header[Content_Type] = "text/html;charset=utf-8"
        return end()

    }

    public func template() -> Bool{
       return end()
    }

    public func redirect ( url u: String )->Bool{
        self.status = 302
        self.header[Location] = u
        return end()
    }

    private func end() ->Bool{
        let headerData = prepareHeader ()
        let sendData: NSData = makeResponse ( headerData, body: self.bodyData )
        socket?.sendData ( sendData )
        return true
    }


    private func makeResponse ( header: NSData, body: NSData?) -> ( NSData ) {
        let result = NSMutableData ( data: header )
        
        if let b = body {
            result.appendData ( b )
        }

        return result;
    }

    private func prepareHeader () -> NSData {
        //        header[Date] = String(NSDate().formatted)  Not GMT
        header[Server] = "Trevi"
        header[Accept_Ranges] = "bytes"
        
        if let bodyData = bodyData  {
            header[Content_Length] = "\(bodyData.length)" // replace bodyString length
        }
        var headerString = "\(HttpProtocol) \(statusCode) \(statusString)" + NewLine
        headerString += dictionaryToString ( header )
        return headerString.dataUsingEncoding ( NSUTF8StringEncoding )!

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
