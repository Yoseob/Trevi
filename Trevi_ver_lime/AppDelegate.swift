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
        
        lime.use(Favicon());
        
        lime.use("/root", Root())
  
        lime.use { (req, res, next) in
            print("err")
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


