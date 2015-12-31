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
     * init?
     * After accept, create a client socket,
     *
     * @param
     *  First : Client socket's file descriptor.
     *  Second : Client socket's address family.
     *  Third : A dispatch queue for this socket's read event.
     *
     * @return
     *  If bind function succeeds, create a client socket.
     *  However, if it fails, returns nil
     */
    public init?(fd : Int32, address : T, queue : dispatch_queue_t = readQueue) {
        
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
    
    // Should add connect()
    
    /**
    * read
    * Read recived data from this socket.
    *
    * @param
    *
    * @return
    *  First : Read length.
    *  Second : Read data buffer pointer.
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
     * write
     * Write response data to this socket.
     *
     * @param
     *  First : Data buffer pointer.
     *  Second : Data length.
     *  Third : A dispatch queue for write event.
     *             If you use dispatch_get_main_queue(), all write event in this program
     *             will be processed by main thread.
     *
     * @return
     *  Success or failure.
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
    
    public func cancelTimeout() {
        if let timeout = self.timeout {
            timeout.cancelTimer()
            self.timeout = nil
        }
    }
    
    public func setTimeout(seconds : __uint64_t) {
        self.cancelTimeout()
        timeout = Timer(interval: seconds, leeway: 1, queue: readQueue)
        
        timeout.startTimerOnce(){
            [unowned self] in
            guard self.isClosing else {
                self.close()
                return
            }
        }
    }
}




