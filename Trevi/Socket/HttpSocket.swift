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
public let acceptQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
public let readQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
public let writeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

typealias HttpCallback = ( ( Request, Response, TreviSocket ) -> Bool )
typealias ClientSocket = ConnectedSocket<IPv4>!

public class TreviSocket {
    
    weak var socket : ConnectedSocket<IPv4>!
    
    init(socket : ConnectedSocket<IPv4>){
        self.socket = socket
    }
    
    func sendData ( data: NSData ) {
        socket.write (data)
    }
    
    func socketClose(){
        socket.close ()
    }
    
    func socketCloseAfter(seconds : __uint64_t){
        socket.setTimeout(seconds)
    }
}

public class TreviSocketServer {
    
    var socket: ListenSocket<IPv4>!
    
    var httpCallback: HttpCallback?
    
    func startOnPort ( p: Int ) throws {

//        guard let socket = ListenSocket<IPv4> ( address: IPv4 (ip: "127.0.0.1", port: p)) else {
        guard let socket = ListenSocket<IPv4> ( address: IPv4 (port: p)) else {
            log.error("Could not create ListenSocket address : \(IPv4.domain)")
            return
        }
        
        socket.listenClientReadEvent (true) {
            client in
            
            var initialData: NSData?
            let ( buffer, length ) = client.read()
            
            client.setTimeout(3);
            
            if length > 0 {
                initialData = NSData ( bytes: buffer, length: length )
            }
            
            if let initialData = initialData {
                let preparedData = PreparedData ( requestData: initialData )
                let httpClient       = TreviSocket ( socket: client )
                let (req, res)   = preparedData.prepareReqAndRes ( httpClient )
                self.httpCallback! ( req, res, httpClient )
            }
            
            return length
        }
        
        self.socket = socket
    }
    
    func disconnect () {
        self.socket.close ()
    }
}
