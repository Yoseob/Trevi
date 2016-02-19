//
//  HttpSocket.swift
//  Trevi
//
//  Created by JangTaehwan on 2015. 12. 27..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

/**
* ClientSocket class
*
* Interface for managing HttpSocket's client
*
*/
public class ClientSocket {
    
    let ip : String
    weak var socket : ConnectedSocket!
    
    public init (socket : ConnectedSocket) {
        self.socket = socket
        self.ip = socket.address.ip()
    }
    
    public func sendData ( data: NSData ) {
        socket.write (data)
    }
    
    public func close(){
        socket.close ()
    }
    
    public func closeAfter( seconds : UInt64 ) {
        socket.setTimeout(seconds)
    }
}


public class HttpSocket {
    
    var ip : String?
    var listenSocket : ListenSocket!
    
    var listener : EventListener?
    
    // If set closeTime a client will be disconnected withn closeTime.
    var closeTime: UInt64?
    
    init(){
        
    }
    
    init(ip : String? = nil){

        self.ip = ip
    }
    
    init( _ eListener : EventListener? = nil){
        self.listener = eListener
        self.ip = "8080"
    }
    
    
     /**
     Set server model by input dispatch queues.
     
     - Parameter accept: Client accept queue setting.
     - Parameter read: Client request read queue setting.
     - Parameter write: Write response queue setting.
     */
    public func setServerModel(accept : DispatchQueue,
        _ read : DispatchQueue, _ write : DispatchQueue) {
        serverModel.acceptQueue = accept.queue
        serverModel.readQueue = read.queue
        serverModel.writeQueue = write.queue
    }
    
     /**
     Listen http socket and dispatch client event.
     
     - Parameter port: Server port setting.
     */
    public func startListening ( port : UInt16 ) throws {
        
        var address : IPv4! {
            get{
                if let ip = self.ip{
                    do{
                        return try IPv4(ip: ip, port: port)
                    }
                    catch {
                        return nil
                    }
                }
                else{
                    return IPv4(port: port)
                }
            }
        }
        
        guard let listenSocket = ListenSocket ( address: address) else {
            log.error("Could not create ListenSocket on ip : \(self.ip), port : \(port))")
            return
        }
        
        listenSocket.listenClientReadEvent () {
            client in
            
            if let time = self.closeTime {
                client.setTimeout(time)
            }
            
            
            
            return self.readDataHandler(client)
        }
        
        self.listenSocket = listenSocket
    }
    
    public func disconnect () {
        self.listenSocket.close ()
    }
    
    
    private func readDataHandler(stream : SocketStream) -> Int {
        
        let readData : ReceivedParams = stream.read()
        
        let info = EventInfo()
        info.params = readData
        info.stream = stream
        listener?.emit("data", info)
        
        return readData.length
        
        
    }

}
