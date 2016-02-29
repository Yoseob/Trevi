//
//  LibuvUtility.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 17..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//


import Libuv


public typealias void_ptr = UnsafeMutablePointer<Void>
public typealias sockaddr_ptr = UnsafeMutablePointer<sockaddr>


public typealias uv_any_handle_ptr = UnsafeMutablePointer<uv_any_handle>
public typealias uv_handle_ptr = UnsafeMutablePointer<uv_handle_t>
public typealias uv_loop_ptr = UnsafeMutablePointer<uv_loop_t>
public typealias uv_poll_ptr = UnsafeMutablePointer<uv_poll_t>
public typealias uv_stream_ptr = UnsafeMutablePointer<uv_stream_t>
public typealias uv_connect_ptr = UnsafeMutablePointer<uv_connect_t>
public typealias uv_pipe_ptr = UnsafeMutablePointer<uv_pipe_t>
public typealias uv_tcp_ptr = UnsafeMutablePointer<uv_tcp_t>
public typealias uv_shutdown_ptr = UnsafeMutablePointer<uv_shutdown_t>
public typealias uv_timer_ptr = UnsafeMutablePointer<uv_timer_t>
public typealias uv_async_ptr = UnsafeMutablePointer<uv_async_t>


public typealias uv_req_ptr = UnsafeMutablePointer<uv_req_t>
public typealias uv_write_ptr = UnsafeMutablePointer<uv_write_t>
public typealias uv_work_ptr = UnsafeMutablePointer<uv_work_t>
public typealias uv_fs_ptr = UnsafeMutablePointer<uv_fs_t>


public typealias uv_buf_ptr = UnsafeMutablePointer<uv_buf_t>
public typealias uv_buf_const_ptr = UnsafePointer<uv_buf_t>


func ==(lhs: uv_fs_type, rhs: uv_fs_type) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

extension uv_fs_type : Hashable {
    
    public var hashValue: Int {
        return Int(self.rawValue)
    }
}


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

public func uvErrorName() -> String {
    return blockToUTF8String(uv_strerror(UV_EAGAIN.rawValue))
}

// Get String from the pointer
public func blockToString(block: UnsafePointer<CChar>, length: Int) -> String {
    var idx = block
    var value = "" as String
    
    if length <= 0 { return ""}
    
    for _ in 0...length {
//        if idx.memory > 31{
            let c = String(format: "%c", idx.memory)
            value += c
//        }
        idx++
    }
    return value
}

public func blockToUTF8String(block: UnsafePointer<CChar>) -> String {
    let (k,_) = String.fromCStringRepairingIllFormedUTF8(block)
    let value = k! as String
    return value
}

public func getThreadID() -> mach_port_t {
    return pthread_mach_thread_np(pthread_self())
    
}


