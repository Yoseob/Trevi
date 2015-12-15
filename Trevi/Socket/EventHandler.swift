//
//  EventHandler.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 8..
//  Copyright © 2015년 JangTaehwan. All rights reserved.
//

import Dispatch

public let defaultQueue = dispatch_get_global_queue(0, 0)

// Event type setting according with block and non-block
// prototype considering better way
public protocol ReadEvent {
    func excute(callback : (UInt)->Void, length : UInt)
}
public class BlockingRead : ReadEvent {
    public func excute(callback: (UInt) -> Void, length : UInt) {
        while(true) { callback(length) }
    }
}
public class NonBlockingRead : ReadEvent {
    public func excute(callback: (UInt) -> Void, length : UInt) {
        callback(length)
    }
}

public class EventHandler {
    
    let fd : Int32
    var queue : dispatch_queue_t
    var writeQueue : dispatch_queue_t?
    var source : dispatch_source_t?
    
    var readEvent : ReadEvent = BlockingRead()
    
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
        source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
            UInt(fd), 0, queue)
        
        if let source = self.source {
            dispatch_source_set_event_handler(source) {
                let length = dispatch_source_get_data(source)
                self.readEvent.excute(callback, length : length)
            }
        
            dispatch_resume(source)
            return true
        }
        else {
            log.error("Could not dispatch event")
            return false
        }
    }
    
    public func dispatchWriteEvent<M>(buffer : UnsafePointer<M>,
        length : Int, close : (()->Void) ) -> Bool{
            
        let typeSize = sizeof(M) <= 0 ? 1 : sizeof(M)
        let bufferSize = length*typeSize
            
        guard length > 0 else {
            return true
        }
            
        if writeQueue == nil {
            writeQueue = self.queue
        }
            
        guard let dispatchData = dispatch_data_create(buffer, bufferSize, writeQueue!, nil) else {
            return false
        }
        
        dispatch_write(fd, dispatchData, queue) {
            _,_ in
            close()
        }
            
        return true
    }
}