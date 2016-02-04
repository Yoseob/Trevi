//
//  InetAddress.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 6..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

#if os(Linux)
    import SwiftGlibc
#else
    import Darwin
#endif

public protocol InetAddress {
    static var domain : Int32 { get }
    static var length : UInt8 { get }
    func ip() -> String
    func port() -> in_port_t
    init()
}

// IPv4 address extention.
let INADDR_ANY = in_addr(s_addr: 0)
public typealias IPv4 = sockaddr_in

extension in_addr {
    public init() {
        s_addr = INADDR_ANY.s_addr
    }
}

extension sockaddr_in : InetAddress {
    
    public static let domain = AF_INET
    public static let length = UInt8(sizeof(IPv4))
    public func ip() -> String {
        return blockToUTF8String(inet_ntoa(sin_addr))
    }
    public func port() -> in_port_t { return  in_port_t(self.sin_port.bigEndian) }
    
    public init(ip : String, port : UInt16) {
        #if os(Linux)
        #else
        sin_len = UInt8(sizeof(sockaddr_in))
        #endif
        sin_family = sa_family_t(AF_INET)
        sin_port = in_port_t(port.bigEndian)
        sin_addr = in_addr(s_addr: inet_addr(ip))
        sin_zero = (0,0,0,0,0,0,0,0)
    }
    
    public init(ip : in_addr = INADDR_ANY, port : UInt16) {
        #if os(Linux)
        #else
        sin_len = UInt8(sizeof(sockaddr_in))
        #endif
        sin_family = sa_family_t(AF_INET)
        sin_port = in_port_t(port.bigEndian)
        sin_addr = ip
        sin_zero = (0,0,0,0,0,0,0,0)
    }
}

// IPv6 address extention.
// It's not stable.
let IN6ADDR_ANY = in6addr_any
public typealias IPv6 = sockaddr_in6

extension sockaddr_in6 : InetAddress {
    
    public static let domain = AF_INET6
    public static let length = UInt8(sizeof(IPv6))
    public func ip() -> String {
        return ""
    }
    public func port() -> in_port_t { return in_port_t(self.sin6_port.bigEndian) }
    
    public init(ip : in6_addr = IN6ADDR_ANY, port : UInt16 = 0) {
        #if os(Linux)
        #else
        sin6_len = UInt8(sizeof(sockaddr_in6))
        #endif
        sin6_family = sa_family_t(AF_INET6)
        sin6_port = in_port_t(port.bigEndian)
        sin6_flowinfo = 0
        sin6_addr = ip
        sin6_scope_id = 0
    }
}