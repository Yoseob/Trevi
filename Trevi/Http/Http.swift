//
//  Http.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 20..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public typealias HttpCallback = ( ( Request, Response) -> Bool )

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
        receivedRequestCallback()
        socket = HttpSocket(listener)
        for rm in requireModule {
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
     ㅋ @param {Middleware} mw
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
    private func receivedRequestCallback() {
        listener = MainListener()
        
        listener.on("data") { stream in
            
            let readData = stream.read()
            self.totalLength += readData.length
            
            if readData.length > 0 {
                let (contentLength, headerLength) = self.prepare.appendReadData(readData)
                
                if contentLength > headerLength{
                    self.totalLength -= headerLength
                }
                if self.totalLength >= contentLength || contentLength == 0{
                    self.listener.emit("end", stream)
                }
            }
            return readData.length
        }
        
        listener.on("end") { stream in
            let httpClient = ClientSocket ( socket: stream )
            self.mwManager.handleRequest(self.prepare.handleRequest(httpClient))
            self.prepare.dInit()
            self.totalLength = 0
            
            return 0
        }
    }
    

}
