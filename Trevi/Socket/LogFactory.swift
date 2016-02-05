//
//  LogFactory.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

public let log : LogFactory = LogFactory.sharedInstance

public class LogFactory{
    
    static private let sharedInstance = LogFactory()
    
    private init() {}
    
    func info(message: String){
        print("Info : " + message)
    }
    
    func error(message: String){
        print("Error : " + message)
    }
    
    func debug(message: String){
        debugPrint("Debug : " + message)
    }
    
    func tLog(message: String){
        let tid : mach_port_t = pthread_mach_thread_np(pthread_self())
        print(message + " from thread: \(tid)")
    }
}
