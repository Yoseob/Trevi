//
//  StreamListener.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 2. 1..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation

public typealias emitable = (AnyObject) -> Void

public typealias noParamsEvent = (Void) -> Void

public typealias oneStringeEvent = (String) -> Void

public typealias oneDataEvent = (NSData) -> Void

typealias EmiiterType = ((AnyObject) -> Void)?


public class EventEmitter{
    
    var events = [String:Any]()
    
    init(){}
    deinit{
        
    }
    
    func on(name: String, _ emitter: Any){
        events[name] = emitter
    }
    
    func removeEvent(name: String){
        events.removeValueForKey(name)
    }
    
    func emit(name: String, _ arg : AnyObject...){
        let emitter = events[name]
        
        switch emitter {
        case let cb as HttpCallback:
            
            if arg.count == 2{
                let req = arg[0] as! IncomingMessage
                let res = arg[1] as! ServerResponse
                cb(req,res, nil)
            }
            break
        case let cb as emitable:
            if arg.count == 1 {
                cb(arg.first!)
            }else {
                #if os(Linux)
                    cb(arg as! AnyObject)
                #else
                    cb(arg)
                #endif
            }
            break
        case let cb as oneStringeEvent:
            if arg.count == 1 {
                #if os(Linux)
                    let str = arg.first as! StringWrapper
                    cb(str.string)
                #else
                    cb(arg.first as! String)
                #endif
            }
            break
        case let cb as oneDataEvent:
            if arg.count == 1 {
                cb(arg.first as! NSData)
            }
            break

        case let cb as noParamsEvent:
            cb()
            break
            
            
        default:
            break
        }
    }
}




