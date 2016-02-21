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
        
        lime.use(ServeStatic(path: "/Users/zero2hex/Documents/www"))
        
        lime.use(SwiftServerPage())
        
        lime.use("/",Root())
        
        lime.use(){ req, res in
            res.status = 404
            return res.send ("404 Pages Not Found")
        }
        
        server.createServer_Test({ req, res in
            
            for (k,v) in req.header {
                print("\(k) : \(v)")
            }
            
            res.write(NSData(contentsOfFile:NSBundle.mainBundle().pathForResource("sky", ofType: "jpeg")!)!)
            res.end()
            
        
        }).listen(8080)
     
    }

    func applicationWillTerminate ( aNotification: NSNotification ) {
        // Insert code here to tear down your application
    }
}

