//
//  StreamReadable.swift
//  Trevi
//
//  Created by SeungHyunLee on 2/22/16.
//  Copyright © 2016 LeeYoseob. All rights reserved.
//

import Foundation
import Libuv

public class StreamReadableState {
    var highWaterMark: Int
    var buffer: Buffer
    var length: Int
    var sync: Bool
    var flowing: Bool
    var reading: Bool
    var ended: Bool
    
    var bookEmitReadable: Bool
    var isEndEmitted: Bool
    var isReadableEmitted: Bool
    
    init() {
        highWaterMark = 16 * 1024
        buffer = Buffer()
        length = 0
        sync = false
        flowing = false
        ended = false
        reading = false
        
        bookEmitReadable = false
        isEndEmitted = false
        isReadableEmitted = false
    }
}

public class StreamReadable: EventEmitter {
    private var _state: StreamReadableState
    
    public override init() {
        _state = StreamReadableState()
    }
    
    func _read(n: Int) {
        print("Not implemented")
    }
    
    //    func push(chunk: uv_buf_const_ptr, encoding: NSStringEncoding = 0) -> Bool {
    //        return addChunk(self, chunk: chunk, addToFront: false)
    //    }
    
    func push(chunk: String?, encoding: NSStringEncoding = 0) -> Bool {
        return addChunk(self, chunk: chunk, addToFront: false)
    }
    
    //    func unshift(chunk: uv_buf_const_ptr) -> Bool {
    //        return addChunk(self, chunk: chunk, addToFront: true)
    //    }
    
    func unshift(chunk: String?, encoding: NSStringEncoding = 0) -> Bool {
        return addChunk(self, chunk: chunk, addToFront: true)
    }
    
    func read(n: Int = -1) -> [Int8]? {
        
        if n > 0 {
            _state.isReadableEmitted = false
        }
        
        if n == 0 && _state.bookEmitReadable && (_state.length >= _state.highWaterMark || _state.ended) {
            if (_state.length == 0 && _state.ended) {
                endReadable(self)
            } else {
                emitReadable(self)
            }
            return nil
        }
        
        var readn = lengthToRead(n, state: _state)
        if readn == 0 && _state.ended {
            if _state.length == 0 {
                endReadable(self)
            }
            return nil
        }
        
        var doRead: Bool = _state.bookEmitReadable
        
        if _state.length == 0 || _state.length - n < _state.highWaterMark {
            doRead = true
        }
        
        if _state.ended || _state.reading {
            doRead = false
        }
        
        if doRead {
            _state.reading = true
            _state.sync = true
            if _state.length == 0 {
                _state.bookEmitReadable = true
            }
            self._read(_state.highWaterMark)
            _state.sync = false
        }
        
        var ret: [Int8]?
        if readn > 0 {
            ret = _state.buffer.data
            _state.buffer.truncate()
        } else {
            ret = nil
        }
        
        if ret == nil {
            _state.bookEmitReadable = true
            readn = 0
        }
        _state.length -= readn
        
        if _state.length == 0 && !_state.ended {
            _state.bookEmitReadable = true
        }
        
        // after EOF
        if n != readn && _state.ended && _state.length == 0 {
            endReadable(self)
        }
        
        if ret != nil {
            emit("data", Buffer(data: ret!))
        }
        
        return ret
    }
    
    func isPaused() -> Bool {
        return _state.flowing == false
    }
    
    func pause() -> StreamReadable {
        if _state.flowing != false {
            _state.flowing = false
            self.emit("pause")
        }
        return self
    }
    
    func resume() -> StreamReadable {
        if !_state.flowing {
            _state.flowing = true
            self.emit("resume")
            
            flow(self)
            if (_state.flowing && !_state.reading) {
                read(0)
            }
        }
        return self
    }
    
    func pipe(destination dest: StreamWritable, end: Bool = true) -> StreamWritable {
        print("Not implemented")
        return dest
    }
    
    func unpipe(destination dest: StreamWritable? = nil) -> StreamReadable {
        print("Not implemented")
        return self
    }
    
    override func on(name: String, _ emitter: Any) {
        super.on(name, emitter)
        
        if name == "data" && _state.flowing {
            resume()
        }
        
        if name == "readable" && !_state.isEndEmitted {
            _state.isReadableEmitted = false
            _state.bookEmitReadable = true
            if (!_state.reading) {
                self.read(0)
            } else if _state.length > 0 {
                emitReadable(self)
            }
        }
    }
}

func lengthToRead(n: Int = -1, state: StreamReadableState) -> Int {
    if (state.length == 0 && state.ended) {
        return 0
    }
    
    if n == -1 {
        return state.length
    } else if n < -1 || n == 0 {
        return 0
    } else {
        if (n > state.highWaterMark) {
            // max highWaterMark : 0x800000
            if (n >= 0x800000) {
                state.highWaterMark = 0x800000
            } else {
                state.highWaterMark = Int(pow(Double(n), 2.0))
            }
        }
        
        if (n > state.length) {
            if (!state.ended) {
                state.bookEmitReadable = true
                return 0
            } else {
                return state.length
            }
        }
    }
    
    return n
}

private func addChunk(stream: StreamReadable, chunk: String?, addToFront: Bool) -> Bool {
    let state = stream._state
    
    if chunk == nil {
        state.reading = false
        onEofChunk(stream)
    } else if chunk!.characters.count > 0 {
        let chunkBuf = Buffer(data: chunk!, length: chunk!.characters.count)
        
        if !addToFront {
            state.reading = false
        }
        
        if (state.flowing && state.length == 0 && !state.sync) {
            stream.emit("data", chunkBuf)
            stream.read(0)
        } else {
            state.length += chunkBuf.length
            if addToFront {
                state.buffer.push(chunkBuf)
            } else {
                state.buffer.unshift(chunkBuf)
            }
            emitReadable(stream)
        }
    } else if (!addToFront) {
        state.reading = false
    }
    
    return !state.ended &&
        (state.bookEmitReadable ||
            state.length < state.highWaterMark ||
            state.length == 0)
}

private func onEofChunk(stream: StreamReadable) {
    let state = stream._state
    
    if state.ended {
        return
    }
    state.ended = true
    emitReadable(stream)
}

private func flow(stream: StreamReadable) {
    let state = stream._state
    
    if state.flowing {
        // read buffer continuously in flowing mode.
        while let _ = stream.read() where state.flowing {
        }
    }
}

private func emitReadable(stream: StreamReadable) {
    let state = stream._state
    
    if !state.isReadableEmitted {
        state.isReadableEmitted = true
        stream.emit("readable")
        flow(stream)
    }
}

private func endReadable(stream: StreamReadable) {
    let state = stream._state
    
    if (!state.isEndEmitted) {
        state.ended = true
        if (!state.isEndEmitted && state.length == 0) {
            state.isEndEmitted = true
            stream.emit("end")
        }
    }
}