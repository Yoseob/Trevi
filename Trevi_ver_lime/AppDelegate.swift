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
        
        lime.use(BodyParser())
        
        lime.use(Favicon())
        
        lime.use(SwiftServerPage())
        
        lime.use("/",Root())

        lime.use(ServeStatic())
        
        lime.use(){ req, res in
            res.status = 404
            return res.send ("404 Pages Not Found")
        }
        
        server.createServer({ req, res in
            res.write("hello Trevi")
            res.end()
        }).listen(8080)
     
    }

    func applicationWillTerminate ( aNotification: NSNotification ) {
        // Insert code here to tear down your application
    }
}

