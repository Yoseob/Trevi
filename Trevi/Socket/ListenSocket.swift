//
//  ListenSocket.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Darwin
import Dispatch

public class ListenSocket<T: InetAddress> : Socket<T> {
    
    var isListening : Bool = false
    
    // Create socket and bind address
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
    
    // Should extract nonBlock input, and make Server Model Module
    public func listen(nonBlock : Bool, backlog : Int32 = 50) -> Bool {
        guard !isListening else { return false }
        
        self.isNonBlocking = nonBlock
        
        let status = Darwin.listen(fd, backlog)
        guard status == 0 else { return false }
        
        log.info("Server listens on port \(self.address.port())")
        self.isListening = true
        
        return self.isListening
    }
    
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
    
    public func listenClientEvent(nonBlock : Bool, backlog : Int32 = 50,
        clientCallback: (ConnectedSocket<T>) -> Void) -> Bool {
            
            guard listen(nonBlock, backlog: backlog) else { return false }
            
            self.eventHandle.dispatchReadEvent() {
                _ in
                
                let tid : mach_port_t = pthread_mach_thread_np(pthread_self())
                print("Accept thread : \(tid)")
                
                let (clientFd, clientAddr) = self.accept()
                
                let clientSocket = ConnectedSocket<T>(fd: clientFd, address: clientAddr)
                
                guard clientSocket != nil else {
                    log.error("Cannot create client socket")
                    return 0
                }
                
                // Should move this client's nonBlock setting to Server Model Module
                clientSocket!.isNonBlocking = nonBlock
                
                clientCallback(clientSocket!)
                
                return 42
            }
            
            return true
    }
    
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