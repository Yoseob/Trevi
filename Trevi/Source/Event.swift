//
//  Event.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 19..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//


import Libuv

// Libuv callback event Prototype.
// Should be modified.

public class Event {
    
    public var onClose : ((uv_handle_ptr)->())!
    public var onAlloc : Any!
    public var onRead : ((uv_stream_ptr, Int, uv_buf_const_ptr)->())!
    public var afterShutdown : Any!
    public var afterWrite : Any!
    public var onConnection : (uv_stream_ptr -> ())!
    public var afterConnect : Any!
    
    public init(){}
    deinit{}
    
    static let uvEvents : [String : Any] =   [
        "onAlloc" : Stream.onAlloc,
        "onRead" : Stream.onRead,
        "afterShutdown" : Stream.afterShutdown,
        "afterWrite" : Stream.afterWrite,
        "onConnection" : Tcp.onConnection,
        "afterConnect" : Tcp.afterConnect
    ]
    
    public static func checkEvent (event : Any, key : String) -> Bool {
        
        return true
    }

    
}
