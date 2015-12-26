//
//  InetAddress.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 6..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Darwin

public protocol InetAddress {
    static var domain : Int32 { get }
    static var length : __uint8_t { get }
    func port() -> in_port_t
    init()
}

// IPv4 address extention
let INADDR_ANY = in_addr(s_addr: 0)
public typealias IPv4 = sockaddr_in

extension in_addr {
    public init() {
        s_addr = INADDR_ANY.s_addr
    }
}

extension sockaddr_in : InetAddress {
    
    public static let domain = AF_INET
    public static let length = __uint8_t(sizeof(IPv4))
    public func port() -> in_port_t { return  in_port_t(ntohs(self.sin_port)) }
    
    public init(ip : String, port : Int){
        sin_len = __uint8_t(sizeof(sockaddr_in))
        sin_family = sa_family_t(AF_INET)
        sin_port = in_port_t(htons(CUnsignedShort(port)))
        sin_addr = in_addr(s_addr: inet_addr(ip))
        sin_zero = (0,0,0,0,0,0,0,0)
    }
    
    public init(ip : in_addr = INADDR_ANY, port : Int) {
        sin_len = __uint8_t(sizeof(sockaddr_in))
        sin_family = sa_family_t(AF_INET)
        sin_port = in_port_t(htons(CUnsignedShort(port)))
        sin_addr = ip
        sin_zero = (0,0,0,0,0,0,0,0)
    }
}

// IPv6 address extention
// It's not stable
let IN6ADDR_ANY = in6addr_any
public typealias IPv6 = sockaddr_in6

extension sockaddr_in6 : InetAddress {
    
    public static let domain = AF_INET6
    public static let length = __uint8_t(sizeof(IPv6))
    public func port() -> in_port_t { return in_port_t(ntohs(self.sin6_port)) }
    
    public init(ip : in6_addr = IN6ADDR_ANY, port : Int = 0) {
        sin6_len = __uint8_t(sizeof(sockaddr_in6))
        sin6_family = sa_family_t(AF_INET6)
        sin6_port = in_port_t(htons(CUnsignedShort(port)))
        sin6_flowinfo = 0
        sin6_addr = ip
        sin6_scope_id = 0
    }
}