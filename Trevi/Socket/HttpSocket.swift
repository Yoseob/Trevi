//
//  HttpSocket.swift
//  Trevi
//
//  Created by JangTaehwan on 2015. 12. 27..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

/**
* Set a queue to 'dispatch_get_main_queue()' for single thread task handling.
* Then all event in the queue will be dispatched to main queue in GCD, and they will be processed by main thread.
* Examples:
*   public let defaultQueue = dispatch_get_main_queue()
*
* On the other hand if you want multi thread server model and more parallelizing,
* set the defaultQueue to dispatch_get_global_queue(_ ,  0)
*
*/
let globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
let mainQueue = dispatch_get_main_queue()
let defaultQueue : dispatch_queue_t? = globalQueue // mainQueue

public let acceptQueue = defaultQueue != nil ? defaultQueue : globalQueue
public let readQueue = defaultQueue != nil ? defaultQueue : globalQueue
public let writeQueue = defaultQueue != nil ? defaultQueue : globalQueue

public class ClientSocket {
    
    weak var socket : ConnectedSocket<IPv4>!
    
    public init( socket : ConnectedSocket<IPv4> ){
        self.socket = socket
    }
    
    public func sendData ( data: NSData ) {
        socket.write (data)
    }
    
    public func close(){
        socket.close ()
    }
    
    public func closeAfter( seconds : __uint64_t ) {
        socket.setTimeout(seconds)
    }
}


public protocol RequestHandler{
    func beginHandle(req : Request , _ res :Response )
}

public class HttpSocket : RequestHandler {
    
    var listenSocket: ListenSocket<IPv4>!
    var ip : String = "0.0.0.0"
    
    var httpCallback: HttpCallback?
    var prepare = PreparedData()
    var totalLength = 0
    
    
    // Set closeTime to terminate connection with a client after the time from last client request.
    var closeTime: __uint64_t?
    
    public func startListening (port : __uint16_t ) throws {

        guard let listenSocket = ListenSocket<IPv4> ( address: IPv4 (ip: ip, port: port)) else {
            log.error("Could not create ListenSocket on ip : \(self.ip), port : \(port))")
            return
        }
        
        prepare.requestHandler = self
        
        listenSocket.listenClientReadEvent (true) {
            client in
            
            if let time = self.closeTime {
                client.setTimeout(time)
            }
            return self.prepareRequest(client)
        }
        
        self.listenSocket = listenSocket
    }
    
    public func disconnect () {
        self.listenSocket.close ()
    }
    
    public func beginHandle(req : Request , _ res :Response) {
        
        self.httpCallback! ( req, res )
        self.prepare.dInit()
        self.totalLength = 0
    }
    
    
    private func prepareRequest(client : ConnectedSocket<IPv4>) -> Int{
        
        let readData = client.read()
        self.totalLength += readData.length
        

        
        if readData.length > 0 {
            let (contentLength, headerLength) = self.prepare.appendReadData(readData)
            
            if contentLength > headerLength{
                self.totalLength -= headerLength
            }
            if self.totalLength >= contentLength || contentLength == 0{
                let httpClient = ClientSocket ( socket: client )
                self.prepare.handleRequest(httpClient)
            }
        }

        return readData.length

    }
}
