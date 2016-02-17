//
//  Tcp.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 17..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv

public class Tcp : Stream {
    
    public let fd : uv_os_sock_t
    public var address : InetAddress
    
    public let tcpHandle : uv_tcp_ptr
    
    public init (fd : uv_os_fd_t, address : InetAddress) {
        self.fd = fd
        self.address = address
        self.tcpHandle = uv_tcp_ptr.alloc(1)
        
        uv_tcp_init(uv_default_loop(), self.tcpHandle)
        
        // It sets fd to non-block.
        uv_tcp_open(self.tcpHandle, self.fd)
        
        super.init(streamHandle : uv_stream_ptr(self.tcpHandle))
    }
    
    public convenience init (address : InetAddress) {
        
        #if os(Linux)
            let fd = SwiftGlibc.socket(address.domain(), Int32(SOCK_STREAM.rawValue), 0)
        #else
            let fd = Darwin.socket(address.domain(), SOCK_STREAM, 0)
        #endif
        
        self.init(fd : fd, address : address)
    }
    
    deinit {
        
    }
    
}



// Tcp static properties and methods

extension Tcp {
    
    //  Enable / disable Nagle’s algorithm.
    public static func setNoDelay (handle : uv_tcp_ptr, enable : Int32) {
        
        uv_tcp_nodelay(handle, enable)
    }
    
    public static func setKeepAlive (handle : uv_tcp_ptr, enable : Int32, delay : UInt32) {
        
        uv_tcp_keepalive(handle, enable, delay)
    }
    
    public static func setSimultaneousAccepts (handle : uv_tcp_ptr, enable : Int32) {
        
        uv_tcp_simultaneous_accepts(handle, enable)
    }
    
    public static func close (fd : uv_os_fd_t) {
        #if os(Linux)
            SwiftGlibc.close(fd)
        #else
            Darwin.close(fd)
        #endif
    }
    
    public static func bind (fd : uv_os_fd_t, var address : InetAddress)  -> Bool {
        
        let status = withUnsafePointer(&address) { ptr -> Int32 in
            let name = UnsafePointer<sockaddr>(ptr)
            let nameLen = socklen_t(address.length())
            
            #if os(Linux)
                return SwiftGlibc.bind(fd, name, nameLen)
            #else
                return Darwin.bind(fd, name, nameLen)
            #endif
        }
        
        return status == 0
    }
    
    public static func accept(fd : uv_os_fd_t) -> (Int32, InetAddress) {
            
        var clientAddr  = IPv4()
        var clientAddrLen = socklen_t(clientAddr.length())
        
        let clientFd = withUnsafeMutablePointer(&clientAddr) {
            ptr -> Int32 in
            let addrPtr = UnsafeMutablePointer<sockaddr>(ptr)
            
            #if os(Linux)
                return SwiftGlibc.accept(fd, addrPtr,  &clientAddrLen)
            #else
                return Darwin.accept(fd, addrPtr,  &clientAddrLen)
            #endif
        }
        
        return (clientFd, clientAddr)
    }
    
    public static func listen(fd : uv_os_fd_t, backlog : Int32 = 50) -> Bool {
        
        #if os(Linux)
            let status = SwiftGlibc.listen(fd, backlog)
        #else
            let status = Darwin.listen(fd, backlog)
        #endif
      
        return status == 0
    }
    
    public static func setSocketOption (fd : uv_os_fd_t, options: [SocketOption]?) -> Bool {
        if options == nil { return false }
        
        for option in options!{
            let name = option.match.name
            var buffer = option.match.value
            let bufferLen = socklen_t(sizeof(Int32))
            
            #if os(Linux)
                let status  = SwiftGlibc.setsockopt(fd, SOL_SOCKET, name, &buffer, bufferLen)
            #else
                let status  = Darwin.setsockopt(fd, SOL_SOCKET, name, &buffer, bufferLen)
            #endif
            
            if status == -1 {
                log.error("Failed to set socket option : \(option), value : \(buffer)")
                return false
            }
        }
        return true
    }
    
    public static func getSocketOption(fd : uv_os_fd_t, option: SocketOption) -> Int32 {
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
        case .BROADCAST(let value) :   return (SO_BROADCAST, Int32(value.hashValue))
        case .DEBUG(let value) :            return (SO_DEBUG, Int32(value.hashValue))
        case .DONTROUTE(let value) :   return (SO_DONTROUTE, Int32(value.hashValue))
        case .OOBINLINE(let value) :      return (SO_OOBINLINE, Int32(value.hashValue))
        case .REUSEADDR(let value):     return (SO_REUSEADDR, Int32(value.hashValue))
        case .KEEPALIVE(let value) :      return (SO_KEEPALIVE, Int32(value.hashValue))
        case .NOSIGPIPE(let value) :      return (SO_NOSIGPIPE, Int32(value.hashValue))
            
        case .SNDBUF(let value):            return (SO_SNDBUF, value)
        case .RCVBUF(let value):            return (SO_RCVBUF, value)
        }
    }
}

