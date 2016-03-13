//
//  AppDelegate.swift
//  HelloTrevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//
//  # Notice
//  Trevi now open a [Trevi Community](https://github.com/Trevi-Swift).
//  Yoseob/Trevi project split up into respective Trevi, lime, middlewares and sys packages at our community.
//
//  If you want to build or test all projects at Xcode, please check out [Trevi-Dev](https://github.com/Trevi-Swift/Trevi-Dev).
//  Otherwise, you can build Trevi, lime and other packages by using Swift Package manager.
//  [Here](https://github.com/Trevi-Swift/example-trevi-lime) are an example and it now runs on Linux.
//
//  Hope Trevi interests you.


import Cocoa
import Trevi
import Lime


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching ( aNotification: NSNotification ) {
        
        let server = Http ()

        let lime = Lime()
        
        lime.set("views", "\(__dirname)/views")
        
        lime.set("view engine", SwiftServerPage())
        
        lime.use(Logger(format: "default"))
        
        lime.use(Favicon())
        
        lime.use(BodyParser.json())
        
        lime.use(BodyParser.urlencoded())
        
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


