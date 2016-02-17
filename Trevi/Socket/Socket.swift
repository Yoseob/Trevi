//
//  Socket.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 8..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

#if os(Linux)
    import SwiftGlibc
#else
    import Darwin
#endif

/**
 * Socket class
 *
 * Manage POSIX C socket's file descriptor, and provides socket functions.
 *
 * 'isNonblocking' module will be extracted when socket server model created.
 * 'select' and 'poll' module should be added.
 *
 */
 
// Should abstract Socket states.
public class Socket {
    
    // Socket properties.
    public let fd : Int32
    public var address : InetAddress
    
    // EventHandler for socket's read and write event.
    // ReadEvent will be set according with socket's non-block state.
    public var eventHandle : EventHandler! = nil {
        didSet{
            self.eventHandle.readEvent = NonBlockingRead()
        }
    }
    
    // Socket states.
    public var isCreated : Bool { return fd >= 0 }
    public var isBound : Bool = false
    public var isListening : Bool = false
    public var isHandlerCreated : Bool { return eventHandle != nil }
    
    public init(fd : Int32, address : InetAddress, nonblock : Bool = true) {
        self.fd = fd
        self.address = address
//        self.nonblock = nonblock
    }
    
     /**
      Create a socket.
     
     - Parameter address: A address family for this socket.
     - Parameter type: Socket type (SOCK_STREAM / SOCK_DGRAM).
     
     - Returns:  If socket function succeeds, calls init(). However, if it fails, returns nil.
     */
    public convenience init?(address : InetAddress, type : Int32){
        #if os(Linux)
            let fd = SwiftGlibc.socket(address.domain(), Int32(SOCK_STREAM.rawValue), 0)
        #else
            let fd = Darwin.socket(address.domain(), SOCK_STREAM, 0)
        #endif
        
        guard fd > 0 else {
            log.error("Socket convenience init")
            return nil
        }
        
        self.init(fd: fd, address: address)
    }
    
    deinit{
        close()
    }
    
    public func close(){
        #if os(Linux)
            SwiftGlibc.close(self.fd)
        #else
            Darwin.close(self.fd)
        #endif
    }
    
     /**
     Bind socket with server's address.
    
     - Returns:  Success or failure.
     */
    public func bind() -> Bool {
        guard isCreated && !isBound else {
            log.error("Socket bind")
            return false
        }
        
        let status = withUnsafePointer(&address) { ptr -> Int32 in
            let name = UnsafePointer<sockaddr>(ptr)
            let nameLen = socklen_t(address.length())
            
            #if os(Linux)
                return SwiftGlibc.bind(self.fd, name, nameLen)
            #else
                return Darwin.bind(self.fd, name, nameLen)
            #endif
        }
        
        isBound = status == 0 ? true : false
        
        return isBound
    }
    
    /**
     Accept client request.
     
     - Parameter backlog: Backlog queue setting. Handle client's concurrent connect requests.
     
     - Returns: (Client's file descriptor, Client's address family)
     */
    public func accept() -> (Int32, InetAddress) {
        var clientAddr    = IPv4()
        var clientAddrLen = socklen_t(self.address.length())
        
        let clientFd = withUnsafeMutablePointer(&clientAddr) {
            ptr -> Int32 in
            let addrPtr = UnsafeMutablePointer<sockaddr>(ptr)
            
            #if os(Linux)
                return SwiftGlibc.accept(self.fd, addrPtr,  &clientAddrLen)
            #else
                return Darwin.accept(self.fd, addrPtr,  &clientAddrLen)
            #endif
        }
        
        return (clientFd, clientAddr)
    }
    
    /**
     Listen client sockets.
     
     - Parameter backlog: Backlog queue setting. Handle client's concurrent connect requests.
     
     - Returns:  Success or failure
     */
    public func listen(backlog : Int32 = 50) -> Bool {
        guard !isListening else { return false }
        
        #if os(Linux)
            let status = SwiftGlibc.listen(self.fd, backlog)
        #else
            let status = Darwin.listen(self.fd, backlog)
        #endif
        guard status == 0 else { return false }
        
        log.info("Server listens on ip : \(self.address.ip()), port : \(self.address.port())")
        self.isListening = true
        
        return self.isListening
    }
    
}

extension Socket {
    
     /**
     Set various sockets' option.
     
     Example:
        setSocketOption([.BROADCAST(true), .REUSEADDR(true), .NOSIGPIPE(true)])
     
     - Parameter options: SocketOption enum array.
     
     - Returns: Success or failure
     */
    public func setSocketOption(options: [SocketOption]?) -> Bool {
        if options == nil { return false }
        
        for option in options!{
            let name = option.match.name
            var buffer = option.match.value
            let bufferLen = socklen_t(sizeof(Int32))
            
            #if os(Linux)
                let status  = SwiftGlibc.setsockopt(self.fd, SOL_SOCKET, name, &buffer, bufferLen)
            #else
                let status  = Darwin.setsockopt(self.fd, SOL_SOCKET, name, &buffer, bufferLen)
            #endif
            
            if status == -1 {
                log.error("Failed to set socket option : \(option), value : \(buffer)")
                return false
            }
            
            //   log.info("Success to set socket option : \(option), value : \(buffer)")
        }
        return true
    }
    
     /**
     Get a socket option by input option.
     
     Example:
     getSocketOption(.REUSEADDR(true))
     
     SocketOption's value does not metter in a result, so this example is same with
    getSocketOption(.REUSEADDR(false))
     
     - Parameter options: SocketOption enum
     
     - Returns: Success or failure
     */
    public func getSocketOption(option: SocketOption) -> Int32 {
        let name = option.match.name
        var buffer = Int32(0)
        var bufferLen = socklen_t(sizeof(Int32))
        
        #if os(Linux)
            let status  = SwiftGlibc.getsockopt(fd, SOL_SOCKET, name, &buffer, &bufferLen)
        #else
            let status  = Darwin.getsockopt(fd, SOL_SOCKET, name, &buffer, &bufferLen)
        #endif
        
        if status == -1 {
            log.error("Failed to get socket option name : \(name)")
            return status
        }
        return buffer
    }
}
