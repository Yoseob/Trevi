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
        
        
        server.get("/callback") { req, res, next in
            let msg = "hello iwas"
            res.send(msg)
            next(true)
        }
        server.post("/yoseob") { request, response , _ in
            
        }
        
        server.use({ req , res , _ in
            res.statusCode = 404;
            res.bodyString = "not Found"
            res.send("hahah")
        })
        
        do {
            try server.serveHTTP(port: 8080)
        }catch {
            
        }
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

