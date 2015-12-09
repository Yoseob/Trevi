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
        
        //Trevi is used routor like nodejs express
        let router = Trevi.sharedInstance()
        
        //main Module
        let lime = Lime()

        //'use' func call for use middleware
        lime.use(BodyParser())
        lime.use(Favicon())
        
        lime.use(SwiftServerPage())
        
        // It's very important used kind of RouteAble
        // Register for main modle
        lime.use(lime);
        
        lime.use(router)
        
        lime.get("/callback") { req, res in
            let msg = "Hello Trevi!"
            res.statusCode = 200
            res.send(msg)
            return false
        }
        
        lime.get("/",{ req, res in
            return true
        },{ req, res in
            
            let msg = "im root"
            res.send(msg)
            return false
        })
        
        lime.use("/yoseob", Index())
        
        // Register SSP(Swift Server Page) on '/ssp'
        if let index = NSBundle.mainBundle().pathForResource("index", ofType:"ssp") {
            lime.get("/ssp") { req, res in
                res.statusCode = 200
                res.render(index)
                return false
            }
        }
        
        // Register SSP(Swift Server Page) on '/ssp' with arguments
        // Only string arguments allowed now.. 
        if let arg_test = NSBundle.mainBundle().pathForResource("arg_test", ofType:"ssp") {
            lime.get("/ssp/var") { req, res in
                res.statusCode = 200
                res.render(arg_test, ["title":"Hello World", "number":"77"])
                return false
            }
        }
        
        lime.use({ req , res in
            res.statusCode = 404;
            res.bodyString = "404 Pages Not Found"
            res.send()
            return true
            
        })
        
        do {
            try server.createServer(lime).listen(8080);
        }catch {
            
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

