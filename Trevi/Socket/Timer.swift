//
//  Timer.swift
//  Trevi
//
//  Created by JangTaehwan on 2015. 12. 27..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Dispatch

public func createTimer(interval : __uint64_t, leeway : __uint64_t,
    queue : dispatch_queue_t, block : dispatch_block_t) -> dispatch_source_t! {
    
    let timer : dispatch_source_t! = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
    if timer != nil {
        dispatch_source_set_timer(timer, dispatch_walltime(nil, Int64(interval)), interval, leeway)
        dispatch_source_set_event_handler(timer, block)
        dispatch_resume(timer)
    }
    return timer
}

public func resumeTimer(source : dispatch_source_t) {
    dispatch_resume(source)
}

public func suspendTimer(source : dispatch_source_t) {
    dispatch_suspend(source)
}

public func closeAfterSetTime(time : __uint64_t, close : dispatch_block_t) -> Void {
    createTimer(time * NSEC_PER_SEC, leeway : 1 * NSEC_PER_SEC,
        queue: defaultQueue, block: close)
}
