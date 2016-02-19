//
//  Http.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 20..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public typealias HttpCallback = ( ( Request, Response ) -> Bool )

public typealias ReceivedParams = (buffer: UnsafeMutablePointer<CChar>, length: Int)

public typealias CallBack = ( Request, Response ) -> Bool // will remove next




public class EventEmitter{
    var events = [String:Any]()
    
    init(){}
    
    func on(name: String, _ emitter: Any){
        events[name] = emitter
    }
    
    func emit(name: String, _ arg : Any...){
        let emitter = events[name]
        
        
        switch emitter {
        case let ra as RoutAble:
            if arg.count == 2{
                let req = arg[0] as! Request
                let res = arg[1] as! Response
                ra.handleRequest(req, res)
            }
            break
        case let cb as HttpCallback:
            if arg.count == 2{
                let req = arg[0] as! Request
                let res = arg[1] as! Response
                cb(req,res)
            }
            break
        default:
            break
        }
    }
}

//temp class
protocol httpStream {}

public class IncomingMessage: httpStream{
    init(){}
}


public class ServerResponse{
    init(){}
}


public class TreviServer: EventEmitter{
    
    private var socket: HttpSocket!
    private var requestListener: Any!
    
    init(requestListener: Any){
        super.init()
        self.requestListener = requestListener
        
        socket = HttpSocket(nil)
        
        self.on("request", requestListener) // Not fixed calling time
        
        self.on("listening", onlistening) //when server start listening client socket, Should called this callback
        
        self.on("connection", connectionListener) // when Client Socket accepted
    }
    
    func onlistening(){
        switch requestListener {
        case let ra as RoutAble:
            ra.makeChildRoute(ra.superPath!, module:ra)
            break
        case let cb as HttpCallback:
            print(cb)
            break
        default:
            break
        }
    }
    
    func connectionListener(socket: Any /* this socket client socket or stream */){
        
        /*
            /* start // never fixed */
            first socket.onread  binding listener
            // parse road data and parsing, not figureout Request, Response just parse
        
        */
        
    }
    
    /**
     * Set port, Begin Server and listen socket
     *
     * @param {Int} port
     * @public
     */
    public func listen ( port: __uint16_t ) throws {

        try socket.startListening( port )
        
        if true {
            while true {
                NSRunLoop.mainRunLoop ().run ()
            }
        }
    }
    
    public func stopListening () {
        socket.disconnect ()
    }
}


public class Http {
    
    private var socket : HttpSocket!
    private let mwManager = MiddlewareManager.sharedInstance ()
    private var listener : EventListener!
    
    public init () {
    
    }
    /*
        TEST
        will modify any type that suport routable, CallBack and Adapt TreviServer Model
    */
    public func createServer_Test ( requestListener: Any... ) -> TreviServer{
        let server = TreviServer(requestListener: requestListener)
        return server
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
    public func createServer ( requireModule: RoutAble... ) -> Http {
        for rm in requireModule {
            socket = HttpSocket(rm.eventListener!)
            rm.makeChildsRoute(rm.superPath!, module:requireModule)
            mwManager.enabledMiddlwareList += rm.middlewareList;
        }
        return self
    }
    
    /**
     * Create Server base on just single callback, after few time, modify can use many callback
     * end return self.
     *
     * Examples:
     *     http.createServer({  req,res in
     *          return send("hello Trevi!")
     *      }).listen(Port)
     *
     *
     *
     * @param {RouteAble} requireModule
     * @return {Http} self
     * @public
     */
    public func createServer ( callBacks: HttpCallback... ) -> Http {
        receivedRequestCallback()
        socket = HttpSocket(listener)
        for cb in callBacks {
            mwManager.enabledMiddlwareList.append ( cb )
        }
        return self
    }
    
    /**
     * Add MiddleWare direct at Server
     *
     * @param {Middleware} mw
     * @public
     */
    public func set( mw :  Middleware ...){
        mwManager.enabledMiddlwareList.append(mw)
    }
    
    /**
     * Set port, Begin Server and listen socket
     *
     * @param {Int} port
     * @public
     */
    public func listen ( port: __uint16_t ) throws {
        try socket.startListening( port )
                
        if true {
            while true {
                NSRunLoop.mainRunLoop ().run ()
            }
        }
    }

    public func stopListening () {
        socket.disconnect ()
    }
}


extension Http{
    /**
     * Register request callback function
     * request received delegate middleware manager
     *
     * @private
     */
    private func receivedRequestCallback(){
        
        listener = MainListener()
        
        listener.on("data") { info in
            var req : Request?
            if let params = info.params {
                let (strData,_) = String.fromCStringRepairingIllFormedUTF8(params.buffer)
                let data = strData! as String
                req = Request(data)
                
                if let req = req {
                    let res = Response( socket: ClientSocket ( socket: info.stream! ) )
                    res.method = req.method
                    if let connection = req.header[Connection]{
                        res.header[Connection] = connection
                    }
                    self.mwManager.handleRequest(req, res)
                }
                
            }
        }
    }
}