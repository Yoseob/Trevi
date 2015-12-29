//
//  Http.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 20..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Http {
    
    typealias HttpCallback = ( ( Request, Response, ClientSocket ) -> Bool )
    private var httpCallback: HttpCallback?
    
    private var socket = HttpSocket ()
    private var mwManager = MiddlewareManager.sharedInstance ()


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
    public func createServer ( requireModule: RouteAble... ) -> Http {
        for rm in requireModule {
            rm.makeChildRoute(rm.superPath!, module:requireModule)
            mwManager.enabledMiddlwareList += rm.middlewareList;
        }
        receivedRequestCallback();
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
        for cb in callBacks {
            mwManager.enabledMiddlwareList.append ( cb )
        }
        receivedRequestCallback();
        return self
    }
    
    /**
     * Set port, Begin Server and listen socket
     *
     * @param {Int} port
     * @public
     */
    public func listen ( port: __uint16_t ) throws {
        
        try socket.startListening( port ) {
            client in
            
            var initialData: NSData?
            let ( buffer, length ) = client.read()
        
            if length > 0 {
                initialData = NSData ( bytes: buffer, length: length )
            }
            
            if let initialData = initialData {
                let preparedData = PreparedData ( requestData: initialData )
                let httpClient       = ClientSocket ( socket: client )
                let (req, res)   = preparedData.prepareReqAndRes ( httpClient )
                self.httpCallback! ( req, res, httpClient )
            }
            
            return length
        }
        
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
        self.httpCallback = {
            req,res,sock in
            self.mwManager.handleRequest(req,res)
            return false
        }
    }
    

}
