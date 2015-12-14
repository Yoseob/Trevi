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
    
    let eventHandle : EventHandler<T>
    
    // Create socket and bind address
    public init?(address : T, options : [SocketOption]? = nil,
                    queue : dispatch_queue_t? = defaultQueue) {
        
        let fd = socket(T.domain, SOCK_STREAM, 0)
        
        eventHandle = EventHandler(fd: fd, queue: queue!)
        
        super.init(fd: fd, address: address)
        
        // change error handling
        guard fd != -1 else {
            return nil
        }
        
        setSocketOption(options!)
                        
        guard bind() else {
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
    
    public func listen(nonBlock : Bool, backlog : Int32 = 50,
        clientCallback: (ConnectedSocket<T>) -> Void) -> Bool { 
        
       self.isNonBlocking = nonBlock
            
        let rc = Darwin.listen(fd, backlog)
        guard rc == 0 else {
            log.error("ListenSocket listen")
            return false
        }

        log.info("Server listens on port \(self.address.port())")
        
        eventHandle.dispatchReadEvent(){
            _ in
            
            // Should change this part to short(Injection).
            //  -> Correct common things with ConnectedSocket's loop and error handling
            repeat{
                let (clientFd, clientAddr) = self.accept()
                
                if clientFd > 0 {
                    let clientSocket = ConnectedSocket<T>(fd: clientFd,
                                                address: clientAddr, options: [.NOSIGPIPE(true)])
                    
                    guard clientSocket != nil else {
                        log.error("Cannot create client socket")
                        return
                    }
                    //clientSocket!.isNonBlocking = nonBlock
                    clientCallback(clientSocket!)
                }
                else if errno == EWOULDBLOCK {
                    break
                }
                else if errno == EAGAIN{
                    log.info("EAGAIN")
                    continue
                }
                else {
                    log.error("Listen error: \(errno)")
                }
            } while(true)
        }

        return true
    }
}