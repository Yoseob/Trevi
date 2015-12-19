//
//  ListenSocket.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Darwin
import Dispatch

/**
 * ListenSocket class
 *
 * Manage a tcp listen socket, and accept client socket.
 *
 */
public class ListenSocket<T: InetAddress> : Socket<T> {
    
    var isListening : Bool = false
    
    /**
     * init?
     * Create a listen socket, 
     *
     * @param
     *  First : Listen socket's address family.
     *  Second : A dispatch queue for this socket's read event.
     *
     * @return
     *  If bind function succeeds, calls super.init().
     *  However, if it fails, returns nil
     */
    public init?(address : T, queue : dispatch_queue_t = defaultQueue) {
        
        let fd = socket(T.domain, SOCK_STREAM, 0)
        
        super.init(fd: fd, address: address)
        eventHandle = EventHandler(fd: fd, queue: queue)
        
        let optStatus = setSocketOption([.REUSEADDR(true)])
        
        // Should apply error handling
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
     * listen
     * Listen client sockets
     *
     * @param
     *  First : Socket's nonBlock mode. 
     *  Second : Backlog queue setting. Handle client's concurrent connect requests.
     *
     * @return
     *  Success or failure
     */
    // Should extract nonBlock input, and move to Server Model Module
    public func listen(nonBlock : Bool, backlog : Int32 = 50) -> Bool {
        guard !isListening else { return false }
        
        self.isNonBlocking = nonBlock
        
        let status = Darwin.listen(fd, backlog)
        guard status == 0 else { return false }
        
        log.info("Server listens on port \(self.address.port())")
        self.isListening = true
        
        return self.isListening
    }
    
    /**
     * accept
     * Accept client request.
     *
     * @param
     *
     * @return
     *  First : Client's file descriptor.
     *  Second : Client's address family.
     */
    public func accept() -> (Int32, T) {
        var clientAddr    = T()
        var clientAddrLen = socklen_t(T.length)
        
        let clientFd = withUnsafeMutablePointer(&clientAddr) {
            ptr -> Int32 in
            let addrPtr = UnsafeMutablePointer<sockaddr>(ptr)
            return Darwin.accept(self.fd, addrPtr, &clientAddrLen);
        }
        
        return (clientFd, clientAddr)
    }
    
    /**
     * listenClientEvent
     * Listen client sockets, and dispatch client event.
     *
     * Examples:
     *  let server: ListenSocket? = ListenSocket(address: IPv4(port: 8080))
     *
     *  server!.listenClientEvent(false) {
     *      clientSocket in
     *
     *      clientSocket.eventHandle.dispatchReadEvent(){
     *
     *          let (count, buffer) = clientSocket.read()
     *
     *          clientSocket.write(buffer, length: count, queue: dispatch_get_main_queue())
     *
     *          return count
     *      }
     * }
     *
     * @param
     *  First : Socket's nonBlock mode.
     *  Second : Backlog queue setting. Handle client's concurrent connect requests.
     *  Third : Client socket's callback after it is created.
     *
     * @return
     *  Success or failure
     */
    public func listenClientEvent(nonBlock : Bool, backlog : Int32 = 50,
        clientCallback: (ConnectedSocket<T>) -> Void) -> Bool {
            
            guard listen(nonBlock, backlog: backlog) else { return false }
            
            self.eventHandle.dispatchReadEvent() {
                _ in
                
                let (clientFd, clientAddr) = self.accept()
                
                let clientSocket = ConnectedSocket<T>(fd: clientFd, address: clientAddr)
                
                guard clientSocket != nil else {
                    log.error("Cannot create client socket")
                    return 0
                }
                
                // Should extract this client's nonBlock setting, and move to Server Model Module
                clientSocket!.isNonBlocking = nonBlock
                
                clientCallback(clientSocket!)
                
                return 42
            }
            
            return true
    }
    
    
    /**
     * listenClientReadEvent
     * Listen client sockets, and dispatch client event.
     *
     * Examples:
     *  let server: ListenSocket? = ListenSocket(address: IPv4(port: 8080))
     *
     *  server!.listenClientReadEvent(false) {
     *      clientSocket in
     *
     *      let (length, buffer) = clientSocket.read()
     *
     *      clientSocket.write(buffer, length: length, queue: dispatch_get_main_queue())
     *
     *      return count
     * }
     *
     * @param
     *  First : Socket's nonBlock mode.
     *  Second : Backlog queue setting. Handle client's concurrent connect requests.
     *  Third : Client socket's read callback when a client socket get a request.
     *             In this closure, you should return read length, so if 0 value return socket will be closed.
     *
     * @return
     *  Success or failure.
     */
    public func listenClientReadEvent(nonBlock : Bool, backlog : Int32 = 50,
        clientReadCallback: (ConnectedSocket<T>) -> Int) -> Bool {
            
            let status = listenClientEvent(nonBlock, backlog: backlog) {
                clientSocket in
                
                clientSocket.eventHandle.dispatchReadEvent(){
                    return clientReadCallback(clientSocket)
                }
            }
            return status
    }
}