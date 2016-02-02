//
//  Http.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 20..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public typealias HttpCallback = ( ( Request, Response) -> Bool )
public typealias ReceivedParams = (buffer: UnsafeMutablePointer<CChar>, length: Int)

public class Http {
    
    private var socket : HttpSocket!
    private var mwManager = MiddlewareManager.sharedInstance ()
    private var listener : EventListener!
    
    var prepare = PreparedData()
    var totalLength = 0

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
    public func createServer ( requireModule: RoutAble... ) -> Http {
        for rm in requireModule {
            socket = HttpSocket(rm.eventListener!)
            rm.makeChildRoute(rm.superPath!, module:requireModule)
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
    public func createServer ( callBacks: CallBack... ) -> Http {
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
