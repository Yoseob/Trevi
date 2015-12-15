//
//  ListenSocket.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 7..
//  Copyright © 2015년 JangTaehwan. All rights reserved.
//

import Darwin
import Dispatch

public class ListenSocket<T: InetAddress> : Socket<T> {
    
    // Create socket and bind address
    public init?(address : T, queue : dispatch_queue_t = defaultQueue) {
        
        let fd = socket(T.domain, SOCK_STREAM, 0)
        
        super.init(fd: fd, address: address)
        eventHandle = EventHandler(fd: fd, queue: queue)

        // Should apply error handling
        guard isCreated else { return nil }
        guard bind() else { return nil }
        let optStatus = setSocketOption([.REUSEADDR(true)])
        guard optStatus && isHandlerCreated else{
            return nil
        }
    }
    deinit{
        self.close()
    }
    
    func accept() -> (Int32, T) {
        var clientAddr    = T()
        var clientAddrLen = socklen_t(T.length)
                
        let clientFd = withUnsafeMutablePointer(&clientAddr) {
            ptr -> Int32 in
            let addrPtr = UnsafeMutablePointer<sockaddr>(ptr)
            return Darwin.accept(self.fd, addrPtr, &clientAddrLen);
        }
        
        return (clientFd, clientAddr)
    }
    
    // Should sperate listen and dispatch listen event, client socket read event
    // Should extract nonBlock input
    public func listen(nonBlock : Bool, backlog : Int32 = 50,
        clientCallback: (ConnectedSocket<T>, UInt) -> Void) -> Bool {
        
       self.isNonBlocking = nonBlock
            
        let rc = Darwin.listen(fd, backlog)
        guard rc == 0 else {
            log.error("ListenSocket listen")
            return false
        }

        log.info("Server listens on port \(self.address.port())")
    
        eventHandle.dispatchReadEvent() {
            _ in
            
            // Should change this part to short(Injection).
            //  -> Correct common things with ConnectedSocket's loop and error handling
            
            let (clientFd, clientAddr) = self.accept()
            
            let clientSocket = ConnectedSocket<T>(fd: clientFd, address: clientAddr)
            
            guard clientSocket != nil else {
                log.error("Cannot create client socket")
                return
            }
            
            clientSocket!.eventHandle.dispatchReadEvent(){
                length in
                clientCallback(clientSocket!, length)
            }
        }

        return true
    }
}