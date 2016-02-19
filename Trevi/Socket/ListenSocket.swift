//
//  ListenSocket.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//


#if os(Linux)
    import SwiftGlibc
#else
    import Darwin
#endif

/**
 * ListenSocket class
 *
 * Manage a tcp listen socket, and accept client socket.
 *
 */
public class ListenSocket : Socket {
    
    /**
     Create a listen socket.
     
     - Parameter address: A address family for this socket.
     - Parameter queue: A dispatch queue for this socket's read event(accept client).
     
     - Returns:   If bind function succeeds, calls super.init(). However, if it fails, returns nil.
     */
    public init?(address : InetAddress, queue : dispatch_queue_t = serverModel.acceptQueue) {
        #if os(Linux)
            let fd = SwiftGlibc.socket(address.domain(), Int32(SOCK_STREAM.rawValue), 0)
        #else
            let fd = Darwin.socket(address.domain(), SOCK_STREAM, 0)
        #endif
        
        super.init(fd: fd, address: address)
        eventHandle = EventHandler(fd: fd, queue: queue)
        
        let optStatus = setSocketOption([.REUSEADDR(true)])
        
        // Should apply error handling.
        guard isCreated else { return nil }
        guard bind() else { return nil }
        guard optStatus && isHandlerCreated else {
            return nil
        }
    }
    deinit {
        self.close()
    }
    
    /**
     Listen client sockets, and dispatch client event.
     
     Example:
     let server: ListenSocket? = ListenSocket(address: IPv4(port: 8080))
     
     server!.listenClientEvent() {
     clientSocket in
     
     clientSocket.eventHandle.dispatchReadEvent(){
     
     let (count, buffer) = clientSocket.read()
     
     clientSocket.write(buffer, length: count, queue: dispatch_get_main_queue())
     
     return count
     }
     }
     
     - Parameter backlog: Backlog queue setting. Handle client's concurrent connect requests.
     - Parameter clientCallback: Client socket's callback after it is created.
     
     - Returns:  Success or failure
     */
    public func listenClientEvent(backlog : Int32 = 50,
        clientCallback: (ConnectedSocket) -> Int) -> Bool {
            
            guard listen(backlog) else { return false }
            
//            globalClientCallback = clientCallback
            // Libuv readable test code. Should be modified and moved to Socket class' property.
            let uvPoll : Libuv = Libuv(fd: self.fd)
            uvPoll.runAcceptCallback()
            
            //            self.eventHandle.dispatchReadEvent() {
            //                _ in
            //
            //                let (clientFd, clientAddr) = self.accept()
            //
            //                let clientSocket = ConnectedSocket<T>(fd: clientFd, address: clientAddr)
            //
            //                guard clientSocket != nil else {
            //                    log.error("Cannot create client socket")
            //                    return 0
            //                }
            //
            //                clientCallback(clientSocket!)
            //
            //                return 42
            //            }
            
            return true
    }
    
    /**
     Listen client sockets, and dispatch client read event.
     
     Example:
     let server: ListenSocket? = ListenSocket(address: IPv4(port: 8080))
     
     server!.listenClientReadEvent() {
     clientSocket in
     
     let (length, buffer) = clientSocket.read()
     
     clientSocket.write(buffer, length: length, queue: dispatch_get_main_queue())
     
     return count
     }
     
     - Parameter backlog: Backlog queue setting. Handle client's concurrent connect requests.
     - Parameter clientReadCallback: Client socket's read callback when a client socket get a request.
     In this closure, you should return read length, so if 0 value return socket will be closed.
     - Returns:  Success or failure
     */
    public func listenClientReadEvent(backlog : Int32 = 50,
        clientReadCallback: (ConnectedSocket) -> Int) -> Bool {
            
            
//            let status = listenClientEvent(backlog) {
//                clientSocket in
//                
//                clientSocket.eventHandle.dispatchReadEvent(){
//                    return clientReadCallback(clientSocket)
//                }
//            }
            return false//status
    }
}