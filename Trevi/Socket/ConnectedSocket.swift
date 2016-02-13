//
//  ConnectedSocket.swift
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

    import Libuv

let ClientBufferSize = 4096

public var ClientCallback : (ConnectedSocket -> Int)!

/**
 * ConnectedSocket class
 *
 * Manage a tcp client socket, and provide read, write functions.
 *
 * Should add connect function.
 *
 */
public func ==(lhs: ConnectedSocket, rhs: ConnectedSocket) -> Bool {
    return lhs.fd == rhs.fd
}

public class ConnectedSocket : Socket<IPv4>, Hashable {
    
    var bufferPtr  = UnsafeMutablePointer<CChar>.alloc(ClientBufferSize + 2)
    var bufferLen : Int = ClientBufferSize
    
    var isConnected : Bool = false
    var isClosing : Bool = false
    
    public var timeout : Timer! = nil
    
    public var hashValue: Int {
        return Int(self.fd)
    }

    
     /**
     After accept, create a client socket.
     
     - Parameter fd: Client socket's file descriptor.
     - Parameter address: Client socket's address family.
     - Parameter queue: A dispatch queue for this socket's read event(request).
     
     - Returns:  If bind function succeeds, create a client socket. However, if it fails, returns nil.
     */
    public init?(fd : Int32, address : IPv4, queue : dispatch_queue_t = serverModel.readQueue) {
        
        super.init(fd: fd, address: address)
        eventHandle = EventHandler(fd: fd, queue: queue)
        
        // Should apply error handling
        guard isCreated else { return nil }
        let optStatus = setSocketOption([.NOSIGPIPE(true)])
        guard optStatus && isHandlerCreated else { return nil }
    }
    deinit {
        log.debug("Connected Socket closed")
        bufferPtr.dealloc(bufferLen + 2)
        clientMap.removeValueForKey(self.fd)
        self.close()
    }
    
    public override func close() {
        
        // Should be modified for thread safe.(atomic)
        self.isClosing = true
        
        self.cancelTimeout()
        eventHandle.cancelEvent()
        #if os(Linux)
            SwiftGlibc.shutdown(self.fd, 0)
        #else
            Darwin.shutdown(self.fd, SHUT_RD)
        #endif
        
        if eventHandle.isWriting() {
            return
        }
        
        super.close()
    }
    
    public func addClientCallback(){
        let uvPoll : Libuv = Libuv(fd: self.fd)
        uvPoll.runReadCallback()
        
    }
    
    /**
    Read recived data from this socket.
    
    - Returns:  (Data buffer pointer, Data length)
    */
    public func read() -> (buffer: UnsafeMutablePointer<CChar>, length: Int) {
        let readBufferPtr = UnsafeMutablePointer<CChar>(bufferPtr)
        #if os(Linux)
            let readBufferLen = SwiftGlibc.read(self.fd, bufferPtr, bufferLen)
        #else
            let readBufferLen = Darwin.read(self.fd, bufferPtr, bufferLen)
        #endif
        
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
        
        var req = uv_stream_t()
        
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
    public func setTimeout(seconds : UInt64) {
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




