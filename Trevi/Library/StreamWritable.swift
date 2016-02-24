//
//  Writable.swift
//  Trevi
//
//  Created by SeungHyunLee on 2/22/16.
//  Copyright © 2016 LeeYoseob. All rights reserved.
//

import Foundation

public typealias writableCallback = (AnyObject?) -> Void
public struct WorkNode {
    let chunk: Buffer
    let callback: writableCallback?
    
    init(chunk: Buffer, callback: writableCallback?) {
        self.chunk = chunk
        self.callback = callback
    }
}

public class WritableState {
    var highWaterMark: Int
    var buffer: Buffer
    var length: Int
    var workQueue: Array<WorkNode>
    
    // current status
    var sync: Bool
    var writing: Bool
    var queueClearing: Bool
    var ending: Bool
    var ended: Bool
    var finished: Bool
    
    var bookEmitFinish: Bool
    var isFinishEmitted: Bool
    var bookEmitDrain: Bool
    var isDrainEmitted: Bool
    var isErrorEmitted: Bool
    
    var writeLength: Int
    var writeCallback: writableCallback?
    
    init() {
        highWaterMark = 16 * 1024
        buffer = Buffer()
        length = 0
        workQueue = Array<WorkNode>()
        
        sync = false
        writing = false
        queueClearing = false
        ending = false
        ended = false
        finished = false
        
        bookEmitFinish = false
        isFinishEmitted = false
        bookEmitDrain = false
        isDrainEmitted = false
        isErrorEmitted = false
        
        writeLength = 0
        writeCallback = nil
    }
}

public class StreamWritable: EventEmitter {
    private var _state: WritableState
    public var writable: Bool = false
    
    public override init() {
        _state = WritableState()
    }
    
    // User implement
    func _write(chunk: Buffer, encoding: NSStringEncoding?, callback: writableCallback) {
        print("Not implemented")
    }
    
    // User implement
    func _writev(chunk: Buffer, encoding: NSStringEncoding?, callback: writableCallback) {
    }
    
    func cork() {
        print("Not implemented")
    }
    
    func end(chunk: String? = nil, encoding: NSStringEncoding? = nil, callback: Any? = nil) {
        if (chunk != nil) {
            write(chunk!)
        }
        
        if !_state.ending && !_state.finished {
            _state.ending = true
            
            // check finished
            if !_state.writing && _state.length == 0 && _state.ending && !_state.finished {
                _state.finished = true
                self.emit("finish")
                
                // execute callback
                // need to modify: self.once("finish", callback)
                if callback != nil {
                    // execute callback
                    _state.writeCallback!(nil)
                }
            }
            
            _state.ended = true
        }
    }
    
    func setDefaultEncoding() {
        print("Not implemented")
    }
    
    func uncork() {
        print("Not implemented")
    }
    
    func write(chunk: String, encoding: NSStringEncoding? = nil, callback: Any? = nil) -> Bool {
        return write(Buffer(data: chunk), encoding: encoding, callback: callback)
    }
    
    func write(chunk: Buffer, encoding: NSStringEncoding? = nil, callback: Any? = nil) -> Bool {
        var canInputMore = false
        
        if _state.ended {
            // error handling : writing after end
        } else {
            // put into buffer
            _state.length += chunk.length
            
            // check buffer space
            canInputMore = _state.length < _state.highWaterMark
            if !canInputMore {
                _state.bookEmitDrain = true
            }
            
            // check while writing
            if _state.writing {
                // put work into work queue
                _state.workQueue.append(WorkNode(chunk: chunk, callback: callback as? writableCallback))
            } else {
                // call _write
                _state.writeCallback = callback as? writableCallback
                _state.writeLength = chunk.length
                _state.writing = true
                _state.sync = true
                self._write(chunk, encoding: encoding, callback: writeCallback)
                _state.sync = false
            }
        }
        
        return canInputMore
    }
    
    func writeCallback(error: AnyObject? = nil) {
        
        // update state of Writable.
        _state.writing = false
        _state.length -= _state.writeLength
        _state.writeLength = 0
        
        if error != nil {
            // error handling
            _state.writeCallback!(error!)
            _state.isErrorEmitted = true
            self.emit("error", error!)
        } else {
            // check finish
            let isFinished = !_state.writing && _state.length == 0 && _state.ending && !_state.finished
            
            // clear work queue when finish
            if isFinished && !_state.workQueue.isEmpty && !_state.queueClearing {
                // clear work queue
                clearWorkQueue()
            }
            
            // process after writing
            if !(isFinished) {
                if _state.length == 0 && _state.bookEmitDrain {
                    self.emit("drain")
                    _state.bookEmitDrain = false
                }
            }
            
            // execute callback
            if let callback = _state.writeCallback {
                callback(nil)
            }
            
            // check finished
            if !_state.writing && _state.length == 0 && _state.ending && !_state.finished {
                _state.finished = true
                self.emit("finish")
            }
        }
        
        _state.writeCallback = nil
    }
    
    func clearWorkQueue() {
        // set clearing flag
        _state.queueClearing = true
        
        // clearing queue
        //        for work in _state.workQueue {
        while let work = _state.workQueue.first {
            // dequeue
            _state.workQueue.removeFirst()
            
            // call _write
            _state.writeCallback = work.callback
            _state.writeLength = work.chunk.length
            _state.writing = true
            _state.sync = true
            self._write(work.chunk, encoding: nil, callback: writeCallback)
            _state.sync = false
            
            // check writing
            if (_state.writing) {
                break
            }
        }
        
        // reset clearing flag
        _state.queueClearing = false
    }
}