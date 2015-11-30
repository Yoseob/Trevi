//
//  AppDelegate.swift
//  Trevi_ver_lime
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Cocoa
import Trevi
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let server = Server()

        //use func call for use middleware 
        
        server.use(BodyParser())
        
        
        server.get("/callback") { req, res  in
            let msg = "hello iwas"
            print(req.path)
            res.sender(msg)

        }
        server.post("/yoseob") { Request, Response in

        }
        
        do {
            try server.serveHTTP(port: 8080)
        }catch {
            
        }
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

