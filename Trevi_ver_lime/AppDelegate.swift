//
//  AppDelegate.swift
//  Trevi_ver_lime
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Cocoa
import Trevi

public enum Meothd: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case HEAD = "HEAD"
    case UNDEFINED = "UNDEFINED"
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let server = Server()

        let lime = Lime()
        //use func call for use middleware
        lime.use(BodyParser())
        
        
        lime.all("/",{ req, res, next in
            let msg = "hello iwas"
            res.send(msg)
            next(true)
            },
            { req, res, next in
                let msg = "hello iwas"
                res.send(msg)
                next(true)
        })
        

        lime.get("/callback") { req, res, next in
            let msg = "hello iwas"
            res.send(msg)
            next(true)
        }.post("/") { req , res , _ -> Void in
            
        }
        
        
        lime.post("/yoseob") { request, response , _ in
            
        }
        
        lime.use({ req , res , next in
            res.statusCode = 404;
            res.bodyString = "not Found"
            res.send("hahah")
        } as CallBack)
        
        
        
        
        do {
            try server.createServer(lime).listen(8080);
        }catch {
            
        }
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

