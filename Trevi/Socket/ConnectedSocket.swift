//
//  ConnectedSocket.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Darwin

let ClientBufferSize = 4096

/**
 * ConnectedSocket class
 *
 * Manage a tcp client socket, and provide read, write functions.
 *
 * Should add connect function.
 *
 */
public class ConnectedSocket<T: InetAddress> : Socket<T> {
    
    var bufferPtr  = UnsafeMutablePointer<CChar>.alloc(ClientBufferSize + 2)
    var bufferLen : Int = ClientBufferSize
    
    var isConnected : Bool = false
    var isClosing : Bool = false
    
    public var timeout : Timer! = nil
    
     /**
     After accept, create a client socket.
     
     - Parameter fd: Client socket's file descriptor.
     - Parameter address: Client socket's address family.
     - Parameter queue: A dispatch queue for this socket's read event(request).
     
     - Returns:  If bind function succeeds, create a client socket. However, if it fails, returns nil.
     */
    public init?(fd : Int32, address : T, queue : dispatch_queue_t = serverModel.readQueue) {
        
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
        
        // Should be modified for thread safe.(atomic)
        self.isClosing = true
        
        self.cancelTimeout()
        eventHandle.cancelEvent()
        Darwin.shutdown(fd, SHUT_RD)
        
        if eventHandle.isWriting() {
            return
        }
        
        super.close()
    }
    
    /**
    Read recived data from this socket.
    
    - Returns:  (Data buffer pointer, Data length)
    */
    public func read() -> (buffer: UnsafeMutablePointer<CChar>, length: Int) {
        let readBufferPtr = UnsafeMutablePointer<CChar>(bufferPtr)
        let readBufferLen = Darwin.read(fd, bufferPtr, bufferLen)
        
        guard readBufferLen >= 0 else {
            bufferPtr[0] = 0
            return ( readBufferPtr, readBufferLen )
        }
        
        bufferPtr[readBufferLen] = 0
        
        return ( readBufferPtr, readBufferLen )
    }
    
     /**
     Write response data to this socket.
     
     - Parameter buffer: Data buffer pointer.
     - Parameter length: Data length.
     
     - Returns:  Success or failure
     */
    public func write<M>(buffer: UnsafePointer<M>, length : Int) -> Bool {
            
            let status = eventHandle.dispatchWriteEvent(buffer, length : length) {
                if self.isClosing { self.close() }
            }
            
            return status
    }
    
    public func write(data : NSData) -> Bool {
            
            return write(data.bytes, length: data.length)
    }
     
     /**
     Close this socket after set time.
     If call this function again the previous time event will be terminated.
     
     - Parameter seconds: Time(Seconds).
     */
    public func setTimeout(seconds : __uint64_t) {
        self.cancelTimeout()
        timeout = Timer(interval: seconds, leeway: 1, queue: serverModel.readQueue)
        
        timeout.startTimerOnce(){
            [unowned self] in
            guard self.isClosing else {
                self.close()
                return
            }
        }
    }
    public func cancelTimeout() {
        if let timeout = self.timeout {
            timeout.cancelTimer()
            self.timeout = nil
        }
    }
}




