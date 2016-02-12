//
//  StreamListener.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 2. 1..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation


public typealias Listener  = (EventInfo) -> Void
public typealias Stream = ConnectedSocket

public class EventInfo{
    public init(){}
    public var stream : Stream?
    public var params : ReceivedParams?
}

//Http Server call name "data" when received Stream Data,
//So if you want custom event Listener register event name both "data"
public protocol EventListener{
    

    var eListners : [String:Listener] {get set}
    
    mutating func on(name : String, _ listener : Listener)
    
    func emit(name: String, _ arg : EventInfo)

}


public struct MainListener {
    public init(){}
    public var eListners = [String:Listener]()
}

extension MainListener : EventListener {


    public mutating func on(name: String , _ listener: Listener) {
        eListners[name] = listener
    }
    
    public func emit(name: String, _ arg : EventInfo) {
        if let listener = eListners[name]{
                listener(arg)
        }else{
            print("unKnown Listener name")
        }
    }
}




