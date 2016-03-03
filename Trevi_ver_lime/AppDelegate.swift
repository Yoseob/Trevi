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
        

        lime.set("views", "\(__dirname)/views");

        lime.set("view engine", SwiftServerPage())
        
        lime.use(Favicon())
        
        lime.use(ServeStatic(path: "\(__dirname)/public"))
        
        lime.use(BodyParser())
        
        lime.use("/", Root())
  
        lime.use { (req, res, next) in
            res.statusCode = 404
            res.send("404 error")
        }
        
        server.createServer(lime).listen(8080)
        /*
        server.createServer({ (req, res, next) in
            
            var chuck = ""
            func ondata(c: String){
                chuck += c
            }
            func onend(){
                print("end")
                res.write(chuck)
                res.end()

            }
            req.on("data", ondata)
            req.on("end", onend)
            
        }).listen(8080)
        */

    }

    func applicationWillTerminate ( aNotification: NSNotification ) {
        // Insert code here to tear down your application
    }
}


