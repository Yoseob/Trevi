//
//  Async.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 11..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

// It is not Async module yet in Libuv. Just for a test.

public var globalClientCallback : ((ConnectedSocket) -> Int)! = nil

public var clientMap = Dictionary<Int32, ConnectedSocket>()

public class Async {
    
    public init () { }
    
    public func setClientEvent(client : ConnectedSocket) -> Bool {
        if let callback = globalClientCallback {
            callback(client)
            return true
        }
        return false
    }
    
    
}
