//
//  ConnectedSocket.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 7..
//  Copyright © 2015년 JangTaehwan. All rights reserved.
//

import Darwin

// Should add connect function
public class ConnectedSocket<T: InetAddress> : Socket<T> {

    var bufferPtr  = UnsafeMutablePointer<CChar>.alloc(4096 + 2)
    var bufferLen : Int = 4096 {
        didSet {
            bufferPtr.dealloc(oldValue + 2)
        }
        willSet{
            bufferPtr = UnsafeMutablePointer<CChar>.alloc(newValue + 2)
        }
    }

    var sendCount : Int = 0
    var closeRequested : Bool = false
    
    // Accept client socket
    public init?(fd : Int32, address : T, queue : dispatch_queue_t = defaultQueue) {
        
        super.init(fd: fd, address: address)
        eventHandle = EventHandler(fd: fd, queue: queue)
        
        guard isCreated else { return nil }
        let optStatus = setSocketOption([.NOSIGPIPE(true)])
        guard optStatus && isHandlerCreated else { return nil }
    }
    deinit {
        bufferPtr.dealloc(bufferLen + 2)
        self.close()
    }

    public override func close() {
        
        eventHandle.cancelEvent()
        
        Darwin.shutdown(fd, SHUT_RD)
        
        if sendCount > 0 {
            closeRequested = true
            return
        }
        
        super.close()
    }
    
    public func setReadEvent(callback : (ConnectedSocket, Int) -> Void) -> Bool {
        let status = eventHandle.dispatchReadEvent(){ [unowned self]
            length in
            
            callback (self, Int(length))
        }
        return status
    }
    
    public func read() -> (length: Int, buffer: UnsafePointer<CChar>, error: Int32){
        let readBufferPtr = UnsafePointer<CChar>(bufferPtr)
        let readBufferLen = Darwin.read(fd, bufferPtr, bufferLen)
        
        guard readBufferLen >= 0 else {
            bufferPtr[0] = 0
            return ( readBufferLen, readBufferPtr, errno )
        }
        
        bufferPtr[readBufferLen] = 0
        
        return ( readBufferLen, readBufferPtr, 0 )
    }
    
    public func write<M>(buffer: UnsafePointer<M>, length : Int,
                                        queue : dispatch_queue_t = defaultQueue) -> Bool {
      
        eventHandle.writeQueue = queue
        
        self.sendCount++
        
        let status = eventHandle.dispatchWriteEvent(buffer, length : length){
            
            --self.sendCount
            
            if self.sendCount == 0 && self.closeRequested {
                self.close()
                self.closeRequested = false
            }
        }
    
       return status
    }

}

