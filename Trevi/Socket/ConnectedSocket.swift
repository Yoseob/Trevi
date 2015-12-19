//
//  ConnectedSocket.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Darwin

let ClientBufferSize = 4096

// Should add connect function
public class ConnectedSocket<T: InetAddress> : Socket<T> {
    
    var bufferPtr  = UnsafeMutablePointer<CChar>.alloc(ClientBufferSize + 2)
    var bufferLen : Int = ClientBufferSize
    
    var isConnected : Bool = false
    var isClosing : Bool = false
    
    // Accept client socket
    public init?(fd : Int32, address : T, queue : dispatch_queue_t = defaultQueue) {
        
        super.init(fd: fd, address: address)
        eventHandle = EventHandler(fd: fd, queue: queue)
        
        // Should apply error handling
        guard isCreated else { return nil }
        let optStatus = setSocketOption([.NOSIGPIPE(true)])
        guard optStatus && isHandlerCreated else { return nil }
    }
    deinit {
//        log.debug("Connected Socket closed")
        bufferPtr.dealloc(bufferLen + 2)
        self.close()
    }
    
    public override func close() {
        
        eventHandle.cancelEvent()
        
        Darwin.shutdown(fd, SHUT_RD)
        
        if eventHandle.isWriting() {
            isClosing = true
            return
        }
        
        super.close()
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

    // Should add connect()
    
    public func read() -> (length: Int, buffer: UnsafePointer<CChar>) {
        let readBufferPtr = UnsafePointer<CChar>(bufferPtr)
        let readBufferLen = Darwin.read(fd, bufferPtr, bufferLen)
        
        guard readBufferLen >= 0 else {
            bufferPtr[0] = 0
            return ( readBufferLen, readBufferPtr )
        }
        
        bufferPtr[readBufferLen] = 0
        
        return ( readBufferLen, readBufferPtr )
    }
    
    public func write<M>(buffer: UnsafePointer<M>, length : Int,
        queue : dispatch_queue_t = defaultQueue) -> Bool {
            
            eventHandle.writeQueue = queue
            
            let status = eventHandle.dispatchWriteEvent(buffer, length : length) {
                if self.isClosing { self.close() }
            }
            
            return status
    }
    
    public func write(data : NSData,
        queue : dispatch_queue_t = defaultQueue) -> Bool {
            
            return write(data.bytes, length: data.length, queue: queue)
    }
}

