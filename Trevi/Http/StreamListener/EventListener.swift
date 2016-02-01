//
//  StreamListener.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 2. 1..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation


public typealias Listener  = (socket : ConnectedSocket<IPv4>) -> Int



public protocol EventListener{
    
    var eListner : [String:Listener] {get set}
    
    //Http Server call name "data" when received Stream Data,
    //So if you want custom event Listener register event name both "data" and "end"
    
    mutating func on(name : String, listener : Listener)
    
    func emit(name: String, _ stream : ConnectedSocket<IPv4>) -> Int
}



public struct MainListener : EventListener {
    
    public var eListner = [String:Listener]()

    public mutating func on(name: String , listener: Listener) {
        eListner[name] = listener
    }
    
    //emit(name: String, data: ReceivedParams , socket : ConnectedSocket<IPv4>)
    public func emit(name: String, _ stream : ConnectedSocket<IPv4>) ->Int {
        if let listener = eListner[name]{
            return listener(socket: stream)
        }
        return 0
    }
}
