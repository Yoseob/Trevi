//
//  Socket.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 8..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Darwin

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
public class Socket<T: InetAddress> {
    
    // Socket properties.
    public let fd : Int32
    public var address : InetAddress
    
    // EventHandler for socket's read and write event.
    // ReadEvent will be set according with socket's non-block state.
    public var eventHandle : EventHandler! = nil {
        didSet{
            if self.nonblock {
                self.eventHandle.readEvent = NonBlockingRead()
            }
            else {
                self.eventHandle.readEvent = BlockingRead()
            }
        }
    }
    
    // Socket states.
    public var isCreated : Bool { return fd >= 0 }
    public var isBound : Bool = false
    public var isHandlerCreated : Bool { return eventHandle != nil }
    
    public init(fd : Int32, address : InetAddress, nonblock : Bool = true) {
        self.fd = fd
        self.address = address
        self.nonblock = nonblock
    }
    
    
     /**
      Create a socket.
     
     - Parameter address: A address family for this socket.
     - Parameter type: Socket type (SOCK_STREAM / SOCK_DGRAM).
     
     - Returns:  If socket function succeeds, calls init(). However, if it fails, returns nil.
     */
    public convenience init?(address : InetAddress, type : Int32){
        let tfd = socket(T.domain, type, 0)
        
        guard tfd > 0 else {
            log.error("Socket convenience init")
            return nil
        }
        
        self.init(fd: tfd, address: address)
    }
    
    deinit{
        close()
    }
    
    public func close(){
        Darwin.close(fd)
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
            let nameLen = socklen_t(T.length)
            return Darwin.bind(self.fd, name, nameLen)
        }
        
        isBound = status == 0 ? true : false
        
        return isBound
    }
}

// Socket options.
public enum SocketOption {
    case BROADCAST(Bool),
    DEBUG(Bool),
    DONTROUTE(Bool),
    OOBINLINE(Bool),
    REUSEADDR(Bool),
    KEEPALIVE(Bool),
    NOSIGPIPE(Bool),
    
    SNDBUF(Int32),
    RCVBUF(Int32)
    
    var match : (name : Int32, value : Int32) {
        switch self {
        case .BROADCAST(let value) :   return (SO_BROADCAST, Int32(Int(value)))
        case .DEBUG(let value) :            return (SO_DEBUG, Int32(Int(value)))
        case .DONTROUTE(let value) :   return (SO_DONTROUTE, Int32(Int(value)))
        case .OOBINLINE(let value) :      return (SO_OOBINLINE, Int32(Int(value)))
        case .REUSEADDR(let value):     return (SO_REUSEADDR, Int32(Int(value)))
        case .KEEPALIVE(let value) :      return (SO_KEEPALIVE, Int32(Int(value)))
        case .NOSIGPIPE(let value) :      return (SO_NOSIGPIPE, Int32(Int(value)))
            
        case .SNDBUF(let value):            return (SO_SNDBUF, value)
        case .RCVBUF(let value):            return (SO_RCVBUF, value)
        }
    }
}

extension Socket{
    
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
            
            let status  = setsockopt(fd, SOL_SOCKET, name, &buffer, bufferLen)
            
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
        
        let status  = getsockopt(fd, SOL_SOCKET, name, &buffer, &bufferLen)
        
        if status == -1 {
            log.error("Failed to get socket option name : \(name)")
            return status
        }
        return buffer
    }
}

// Socket Flags and Socket's blocking or non-blocking setting.
extension Socket {
    public var flags : Int32 {
        get {
            return swift_fcntl(fd, F_GETFL, 0)
        }
        set {
            if swift_fcntl(fd, F_SETFL, Int32(newValue)) == -1 {
                log.error("Socket fcntl set error")
            }
        }
    }
    
    public var nonblock : Bool {
        get {
            return (flags & O_NONBLOCK) != 0 ? true : false
        }
        set {
            if newValue {
                flags |= O_NONBLOCK
            }
            else {
                flags = flags & ~O_NONBLOCK
            }
        }
    }
}
