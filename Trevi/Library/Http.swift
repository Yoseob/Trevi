//
//  Http.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 20..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Libuv
import Foundation


public typealias HttpCallback = ( ( IncomingMessage, ServerResponse, NextCallback?) -> Void )

public typealias NextCallback = ()->()

public typealias ReceivedParams = (buffer: UnsafeMutablePointer<CChar>, length: Int)


//temp class
protocol httpStream {}

public class OutgoingMessage: httpStream{
    
    var socket: Socket!
    public var connection: Socket!
    
    public var header: [String: String]!
    public var shouldKeepAlive = false
    public var chunkEncoding = false
    
    public init(socket: AnyObject){
        header = [String: String]()
    }
    deinit{
        socket  = nil
        connection = nil
    }
    public func _end(data: NSData, encoding: Any! = nil){
        self.socket.write(data, handle: self.socket.handle)
        if shouldKeepAlive == false {
            self.socket.close()
        }
    }
}


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
            header[Content_Type] = "text/html;charset=utf-8"
        }
    }
    
    private var _bodyData: NSData? {
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
            self._bodyData = dt
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





public class IncomingMessage: StreamReadable{
    
    public var socket: Socket!
    
    public var connection: Socket!
    
    // HTTP header
    public var header: [ String: String ]!
    
    public var httpVersionMajor: String = "1"
    
    public var httpVersionMinor: String = "1"
    
    public var version : String{
        return "\(httpVersionMajor).\(httpVersionMinor)"
    }
    
    public var method: String!
    
    // Seperated path by component from the requested url
    public var pathComponent: [String] = [ String ] ()
    
    // Qeury string from requested url
    // ex) /url?id="123"
    public var query = [ String: String ] ()
    
    public var path = ""
    
    // for lime (not fixed)
    public var baseUrl: String! = ""
    public var route: AnyObject!
    public var originUrl: String! = ""
    public var params: [String: AnyObject]!
    public var app: AnyObject!
    
    
    //server only
    public var url: String!{
        didSet{
            self.path = (url.componentsSeparatedByString( "?" ) as [String])[0]
            if self.path.characters.last != "/" {
                self.path += "/"
            }
               originUrl = url
        }
    }
    
    
    //response only
    public var statusCode: String!
    public var client: AnyObject!
    
    init(socket: Socket){
        super.init() 
        self.socket = socket
        self.connection = socket
        self.client = socket
        
    }
    
    deinit{
        socket = nil
        connection = nil
        client = nil
    }
    
    public override func _read(n: Int) {
        
    }
}



public class TreviServer: Net{
    
    private var parsers = [uv_stream_ptr:HttpParser!]()
    
    private var requestListener: Any!
    
    init(requestListener: Any!){
        super.init()
        self.requestListener = requestListener
        
        self.on("request", requestListener) // Not fixed calling time
        
        self.on("listening", onlistening) //when server start listening client socket, Should called this callback
        
        self.on("connection", connectionListener) // when Client Socket accepted
    }
    
    deinit{
        parsers.removeAll()
    }
    
    func onlistening(){
        print("Http Server starts ip : \(ip), port : \(port).")
        
        switch requestListener {
        case let ra as ApplicationProtocol:
            let eventName = "request"
            
            self.removeEvent(eventName)
            self.on(eventName, ra.createApplication())
            break
        default:
            break
        }
    }
    
    private func parser(socket: Socket) -> HttpParser{
        return parsers[socket.handle]!
    }
    
    func connectionListener(sock: AnyObject){
        
        let socket = sock as! Socket
        
        func parserSetup(){
            
            parser(socket).onHeader = {
                
            }
            
            parser(socket).onHeaderComplete = { info in
                let incoming = IncomingMessage(socket: self.parser(socket).socket)
                
                incoming.header = info.header
                incoming.httpVersionMajor = info.versionMajor
                incoming.httpVersionMinor = info.versionMinor
                incoming.url = info.url
                incoming.method = info.method
                
                self.parser(socket).incoming = incoming
                self.parser(socket).onIncoming!(incoming)
            }
            
            parser(socket).onBody = { body in
                let incoming = self.parser(socket).incoming
                incoming.push(body)
                
            }
            
            parser(socket).onBodyComplete = {
                
            }
        }
        
        parsers[socket.handle] = HttpParser()
        let _parser = parser(socket)
        _parser.socket = socket
        parserSetup()

        socket.ondata = { data, nread in
            
            if let _parser = self.parsers[socket.handle] {
                _parser.execute(data,length: nread)
            }else{
                print("no parser")
            }
        }
        
        socket.onend = {
        
            var _parser = self.parsers[socket.handle]
            _parser!.onBody = nil
            _parser!.onBodyComplete = nil
            _parser!.onHeader = nil
            _parser!.onIncoming = nil
            _parser!.onHeaderComplete = nil
            _parser!.socket = nil
            _parser!.incoming = nil
            _parser = nil
            self.parsers.removeValueForKey(socket.handle)
            
        }
        
        parser(socket).onIncoming = { req in
            
            let res = ServerResponse(socket: req.socket)
            res.socket = req.socket
            res.connection = req.socket
            
            res.httpVersion = "HTTP/"+req.version
            if let connection = req.header[Connection] where connection == "keep-alive" {
                res.header[Connection] = connection
                res.shouldKeepAlive = true
            }else{
                res.header[Connection] = "close"
                res.shouldKeepAlive = false
            }
            res.req = req
            self.emit("request", req ,res)
            
            return false
        }
        
    }
}


public protocol ApplicationProtocol {
    func createApplication() -> Any
}




public class Http {
    
    public init () {
        
    }

    
    /**
     * Create Server base on RouteAble Model, maybe it able to use many Middleware
     * end return self
     *
     * Examples:
     *     http.createServer(RouteAble).listen(Port)
     *
     *
     *
     * @param {RouteAble} requireModule
     * @return {Http} self
     * @public
     */

    public func createServer( requestListener: ( IncomingMessage, ServerResponse, NextCallback? )->()) -> Net{
        let server = TreviServer(requestListener: requestListener)
        return server
    }
    
    public func createServer( requestListener: Any) -> Net{
        let server = TreviServer(requestListener: requestListener)
        return server
    }
    

    
    
}

