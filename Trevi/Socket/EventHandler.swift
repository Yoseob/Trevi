//
//  EventHandler.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 8..
//  Copyright © 2015년 JangTaehwan. All rights reserved.
//

import Dispatch

public let defaultQueue = dispatch_get_global_queue(0, 0)

public class EventHandler<T: InetAddress> {
    
    let fd : Int32
    var queue : dispatch_queue_t
    var writeQueue : dispatch_queue_t?
    var source : dispatch_source_t?
    
    public init(fd: Int32, queue : dispatch_queue_t = defaultQueue) {
        self.fd = fd
        self.queue = queue
    }
    deinit{
        if let source = self.source {
            dispatch_source_cancel(source)
        }
    }
    
    public func isEventValid() -> Bool { return self.source != nil ? true : false }
    
    public func cancelEvent() -> Bool {
        if let source = self.source {
            dispatch_source_cancel(source)
            self.source = nil
            return true
        }
        return false
    }

    public func dispatchReadEvent(callback : (UInt) -> Void) -> Bool {
        source = dispatch_source_create(
            DISPATCH_SOURCE_TYPE_READ,
            UInt(fd),
            0,
            queue
        )
        
        if let source = self.source {
            dispatch_source_set_event_handler(source) {
                let data = dispatch_source_get_data(source)
                callback(data)
            }
        
            dispatch_resume(source)
            return true
        }
        else {
            log.error("Could not dispatch event")
            return false
        }
    }
    
    public func dispatchWriteEvent<type>(buffer : UnsafePointer<type>,
        length : Int, close : (()->Void) ) -> Bool{
            
        guard length > 0 else {
            return true
        }
            
        if writeQueue == nil {
            writeQueue = self.queue
        }
            
        guard let dispatchData = dispatch_data_create(buffer, length, writeQueue!, nil) else {
            return false
        }
        
        dispatch_write(fd, dispatchData, queue) {
            _,_ in
            close()
        }
        return true
    }
}