//
//  AppDelegate.swift
//  EchoTest
//
//  Created by JangTaehwan on 2016. 2. 13..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Trevi
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let port : Int32 = 1337
        
        let server : Net = Net(port: port)
        server.startServer()
        
//        let server: ListenSocket? = ListenSocket(address: IPv4(port: port))
//        
//        guard server != nil else {
//            print("Server did not created")
//            return
//        }
//        
//        let tid : mach_port_t = pthread_mach_thread_np(pthread_self())
//        print("Main thread: \(tid)")
//        
//        server!.listenClientEvent(){
//            client in
//            
//            let tid : mach_port_t = pthread_mach_thread_np(pthread_self())
//            print("Read thread: \(tid)")
//            print("")
//            
//            let (buffer, length) = client.read()
//                        
//            print("length: \(length)")
//            print(blockToString(buffer, length: length))
//            
//            return length
//        
//        }

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

