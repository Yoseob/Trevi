//
//  Timer.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 26..
//  Copyright © 2015년 JangTaehwan. All rights reserved.
//

import Dispatch

public class Timer {
    
    let interval : __uint64_t
    let leeway : __uint64_t
    var queue : dispatch_queue_t
    
    var source : dispatch_source_t? = nil
    
    public init(interval : __uint64_t, leeway : __uint64_t, queue : dispatch_queue_t){
        self.interval = interval * NSEC_PER_SEC
        self.leeway = leeway * NSEC_PER_SEC
        self.queue = queue
    }
    deinit {
        self.cancelTimer()
    }
    
    public func startTimer(event : dispatch_block_t) {
        
        self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        
        if let source = self.source {
            dispatch_source_set_timer(source, dispatch_walltime(nil, Int64(interval)), interval, leeway)
            dispatch_source_set_event_handler(source, event)
            dispatch_resume(source)
        }
    }
    
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


