//
//  AppDelegate.swift
//  Trevi_ver_lime
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Cocoa
import Trevi
import Lime

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching ( aNotification: NSNotification ) {
        
        let server = Http ()

        let lime = Lime()
        
        #if os(Linux)
        lime.set("views", val: "\(__dirname)/views");
        #endif
        
        lime.set("view engine", val: SwiftServerPage())
        
        lime.use(Favicon())
        
        lime.use(ServeStatic(path: "\(__dirname)/public"))
        
        lime.use("/root", Root())
  
        lime.use { (req, res, next) in
            res.statusCode = 200
            res.write("404 error")
            res.end()
        }
        
        server.createServer(lime).listen(8080)

//        server.createServer({ (req, res, next) in
//            res.write("hello Trevi")
//            res.end()
//        }).listen(8080)


    }

    func applicationWillTerminate ( aNotification: NSNotification ) {
        // Insert code here to tear down your application
    }
}


