//
//  Timer.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 26..
//  Copyright © 2015년 JangTaehwan. All rights reserved.
//

import Dispatch

/**
 * Timer class
 *
 * Provide dispatch event after set time.
 *
 */
public class Timer {
    let interval : UInt64
    let leeway : UInt64
    var queue : dispatch_queue_t
    
    var source : dispatch_source_t? = nil
    
    public init(interval : UInt64, leeway : UInt64, queue : dispatch_queue_t){
        self.interval = interval * NSEC_PER_SEC
        self.leeway = leeway * NSEC_PER_SEC
        self.queue = queue
    }
    deinit {
        self.cancelTimer()
    }
    
    /**
     Start timer event.
     
     - Parameter event: Event which will happen each interval time.
    */
    public func startTimer(event : dispatch_block_t) {
        
        self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        
        if let source = self.source {
            dispatch_source_set_timer(source, dispatch_walltime(nil, Int64(interval)), interval, leeway)
            dispatch_source_set_event_handler(source, event)
            dispatch_resume(source)
        }
    }
    
    /**
     Start timer event just one time.
     
     - Parameter event: Event which will happen after interval time and be terminated.
     */
    public func startTimerOnce(event : dispatch_block_t) {
        self.startTimer() {
            self.cancelTimer()
            event()
        }
    }
    
    public func cancelTimer() {
        if let source = self.source {
            dispatch_source_cancel(source)
            self.source = nil
        }
    }
    
    public func restartTimer(event : dispatch_block_t) {
        self.cancelTimer()
        self.startTimerOnce(event)
    }
    
    public func suspendTimer() {
        if let source = self.source {
            dispatch_suspend(source)
        }
    }
}


