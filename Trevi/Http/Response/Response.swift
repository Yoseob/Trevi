//
//  Response.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public protocol Sender{
    func send(data: AnyObject?) -> Bool
    func end () -> Bool
    func template() -> Bool
    func render ( filename: String, args: AnyObject? ) -> Bool
}

public class Response :Sender{
    
    public var header = [ String: String ] ()
    
    //use fill statusline of header
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
    
    //for binary
    private var data : NSData?{
        didSet{
            //set response content-type of header
            //image.. Any
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
    
    /**
     * Make body. Surport all kind of Class. This value only used getter
     *
     *
     * @param { String|number|AnyObject} data
     * @return {NSData} bodyData
     * @private
     */
    
    private var bodyData : NSData? {
        if let dt = data{
            return dt
        }else if let bodyString = bodyString {
            return bodyString.dataUsingEncoding(NSUTF8StringEncoding)!
        }else if (body != nil)  {
            let jsonData = try? NSJSONSerialization.dataWithJSONObject(body!, options:NSJSONWritingOptions(rawValue:0))
            // if need jsonString, use it
            // let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)! as String
            return jsonData
        }
        return nil
    }
    
    public var method : HTTPMethodType = .UNDEFINED
    
    private var internalStatus : StatusCode = .OK
    
    public let startTime: NSDate
    
    public var socket : ClientSocket?
    
    public var renderer : Renderer?
    
    public var onFinished : (( Response ) -> Void)?
    
    public init (){
        self.startTime = NSDate ()
    }
    
    public init ( socket: ClientSocket ) {
        self.startTime = NSDate ()
        self.socket = socket   // if render , send , template func is called call self.socket.send(AnyOnject)
    }
    
    /**
     * Send a response data
     *
     *
     * Examples:
     *
     *     res.send([:])
     *     res.send('some String')
     *
     * @param { String|number|AnyObject} data
     * @public
     */
    
    public func send (data: AnyObject?) -> Bool {
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
    
    /**
     * Send with html,etc, this function is help MVC
     *
     *
     * Examples:
     *
     *     res.render('some html')
     *     res.render('some html',[:])
     *
     * @param { String } filename
     * @param { AnyObject } args
     * @public
     */
    public func render ( filename: String, args: AnyObject? ) -> Bool {
        
        var _args = [ String : String ]()
        if args != nil {
            _args = args as! [String:String]
        }
        
        if let data = renderer?.render ( filename, args: _args ) {
            bodyString = data;
        }
        
        //this function called when rand html. forced change content-type = text/html
        // should add control flow  filename.css or filename.js filename.html etc
        let temp : [String] = filename.componentsSeparatedByString(".")
        var filetype = temp.last! as String
        if filetype.length() > 0 && filetype == "ssp" {
            filetype = "html"
        }
        let content_type = "text/\(filetype);charset=utf-8"
        
        header[Content_Type] = content_type
        return end()
    }
    
    //not yet impliment
    public func template() -> Bool{
        return end()
    }
    /**
     * Prepare header and body to send, Impliment send
     *
     *
     * @private
     * return {Bool} isSend
     */
    public func end () ->Bool{
        
        if onFinished != nil {
            onFinished! ( self )
        }
        
        let headerData       = prepareHeader ()
        let sendData: NSData = makeResponse ( headerData, body: self.bodyData )
        socket!.sendData ( sendData )
        if header[Connection] != "keep-alive"{
            socket!.close()
        }
        return true
    }
    
    /**
     * Redirect Page redering with destination url
     *
     * @param { String} url
     * @public
     * return {Bool} isSend
     */
    public func redirect ( url u: String )->Bool{
        self.status = 302
        self.header[Location] = u
        return end()
    }
    
    
    /**
     * Factory method make to response and make complate send message
     *
     * @param { NSData} header
     * @param { NSData} body
     * @private
     * return {NSData} bodyData
     */
    private func makeResponse ( header: NSData, body: NSData?) -> ( NSData ) {
        if method != .HEAD{
            if let b = body {
                let result = NSMutableData ( data: header )
                result.appendData (b)
                return result
            }
        }
        return header
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
        
        if let bodyData = bodyData  {
            header[Content_Length] = "\(bodyData.length)" // replace bodyString length
        }
        
        var headerString = "\(HttpProtocol) \(statusCode) \(statusString)" + CRLF
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
        resultString += CRLF
        return resultString;
    }
}
