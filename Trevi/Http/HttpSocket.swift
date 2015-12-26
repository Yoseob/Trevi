//
//  HttpSocket.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 20..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

typealias HttpCallback = ( ( Request, Response) -> Bool )

public protocol RequestHandler{
    func beginHandle(req : Request , _ res :Response )
}


public class TreviSocket {

    var socket: ConnectedSocket<IPv4>!
    
    init(socket : ConnectedSocket<IPv4>){
        self.socket = socket
    }
    

    
    func sendData ( data: NSData ) {
        socket.write (data, queue: dispatch_get_main_queue())
    }

    func socketClose(){
        socket.close ()
    }
}

class TreviSocketServer : RequestHandler{

    
    var totalLength = 0
    var socket: ListenSocket<IPv4>!
    
    var httpCallback: HttpCallback?
    var prepare = PreparedData()

    
    func startOnPort ( p: Int ) throws {
        prepare.requestHandler = self
        
        guard let socket = ListenSocket<IPv4> ( address: IPv4 ( port: p )) else {
            // Should handle Listener error
            return
        }

        socket.listenClientReadEvent (true) {
            client in
   
            let readData = client.read()
            
            self.totalLength += readData.length
            
            if readData.length > 0 {
                let (contentLength, headerLength) = self.prepare.appendReadData(readData)
                
                if contentLength > headerLength{
                    self.totalLength -= headerLength
                }
                if self.totalLength >= contentLength || contentLength == 0{
                     let httpClient = TreviSocket ( socket: client )
                    self.prepare.handleRequest(httpClient)
                }
            }
            return readData.length
        }

        self.socket = socket
    }

    func disconnect () {
        self.socket.close ()
    }
    
    func beginHandle(req : Request , _ res :Response) {
        
        self.httpCallback! ( req, res )
        self.prepare.dInit()
    }
}
