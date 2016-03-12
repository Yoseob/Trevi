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



/*
    This class is an asynchronous data it uses to communicate, and passed to register and invokes the event.
    But now, because there is a limit of the type of all can't transmit the data. Will quickly change to have it
*/

public class EventEmitter{
    
    var events = [String:Any]()
    
    init(){
    
    }
    
    deinit{
        
    }
    
    //register event function with name
    func on(name: String, _ emitter: Any){

        guard events[name] == nil  else{
            print("already contain event")
            return
        }
        
        events[name] = emitter
    }
    
    func removeEvent(name: String){
        events.removeValueForKey(name)
    }
    
    //invoke registed event with Parameters
    func emit(name: String, _ arg : AnyObject...){

        
        guard let emitter = events[name]  else{
            print("called emitter")
            return
        }
        
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




