//
//  HttpSocket.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 20..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

typealias HttpCallback = ( ( Request, Response, TreviSocket ) -> Bool )

public class TreviSocket {

    var socket: ConnectedSocket<IPv4>!
    
    init(socket : ConnectedSocket<IPv4>){
        self.socket = socket
    }

    func sendData ( data: NSData ) {

        socket.write (data, queue: dispatch_get_main_queue())
      
        socket.close ()
    }
}

class TreviSocketServer {

    var socket: ListenSocket<IPv4>!

    var httpCallback: HttpCallback?

    func startOnPort ( p: Int ) throws {

        guard let socket = ListenSocket<IPv4> ( address: IPv4 ( port: p )) else {
            // Should handle Listener error
            return
        }
        socket.listenClientReadEvent (true) {
            client in

            var initialData: NSData?
            let (length, buffer ) = client.read()

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
