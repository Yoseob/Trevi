//
//  SocketUtility.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 9..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

#if os(Linux)
    import SwiftGlibc
#else
    import Darwin
#endif

// Section lock code
//            var mutex = pthread_mutex_t()
//            pthread_mutex_init(&mutex, nil)
//            pthread_mutex_lock(&mutex)
//            pthread_mutex_unlock(&mutex)

//public struct curl_context_s {
//    let poll_handle : uv_poll_t
//    let sockfd : Int32
//}

public typealias sockaddr_ptr = UnsafeMutablePointer<sockaddr>

// Reference form
// https://developer.apple.com/library/ios/samplecode/SimpleTunnel/Listings/tunnel_server_UDPServerConnection_swift.html

func getEndpointFromSocketAddress(socketAddressPointer: sockaddr_ptr) -> (host: String, port: Int)? {
    let socketAddress = UnsafePointer<sockaddr>(socketAddressPointer).memory
    
    switch Int32(socketAddress.sa_family) {
    case AF_INET:
        var socketAddressInet = UnsafePointer<sockaddr_in>(socketAddressPointer).memory
        let length = Int(INET_ADDRSTRLEN) + 2
        var buffer = [CChar](count: length, repeatedValue: 0)
        let hostCString = inet_ntop(AF_INET, &socketAddressInet.sin_addr, &buffer, socklen_t(length))
        let port = Int(UInt16(socketAddressInet.sin_port).byteSwapped)
        return (String.fromCString(hostCString)!, port)
        
    case AF_INET6:
        var socketAddressInet6 = UnsafePointer<sockaddr_in6>(socketAddressPointer).memory
        let length = Int(INET6_ADDRSTRLEN) + 2
        var buffer = [CChar](count: length, repeatedValue: 0)
        let hostCString = inet_ntop(AF_INET6, &socketAddressInet6.sin6_addr, &buffer, socklen_t(length))
        let port = Int(UInt16(socketAddressInet6.sin6_port).byteSwapped)
        return (String.fromCString(hostCString)!, port)
        
    default:
        return nil
    }
}

// Get String from the pointer
public func blockToString(block: UnsafePointer<CChar>, length: Int) -> String {
    var idx = block
    var value = "" as String
    
    for _ in 0...length {
        //if idx.memory > 31{
            let c = String(format: "%c", idx.memory)
            value += c
        //}
        idx++
    }
    return value
}

public func blockToUTF8String(block: UnsafePointer<CChar>) -> String {
    let (k,_) = String.fromCStringRepairingIllFormedUTF8(block)
    let value = k! as String
    return value
}

