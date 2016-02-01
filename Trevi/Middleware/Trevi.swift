//
//  Trevi.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

/*
    One of the Middleware class to the path to ensure that able to handle the user defined url
    However, it's not find the path to the running is trevi all save the path at this class when the server is starting on the go.
    This class is real class router's functioning.
*/

public struct LimeListener : EventListener {
    
    public var eListner = [String:Listener]()
    
    public mutating func on(name: String , listener: Listener) {
        eListner[name] = listener
    }
    
    public func emit(name: String, _ stream : ConnectedSocket<IPv4>) ->Int {
        if let listener = eListner[name]{
            return listener(socket: stream)
        }
        return 0
    }
}

public class Trevi : RoutAble {
    
    public  override init () {
    }

    
    
    public override func use (var path : String = "" ,  _ module : RoutAble... ) -> RoutAble {
        self.use(router)
        if path == "/"{
            path = ""
        }
        return makeChildRoute (path, module: module )
    }

    /**
     General module to use as a class module used to store, 
     and users and is not necessary.
     
     - Parameter path : User class just a collection of justice url
     
     - Returns : Self
     */
    public func store ( routeable: RoutAble ) -> RoutAble {
        return routeable
    }

}