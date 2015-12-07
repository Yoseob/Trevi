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
        let trevi = Trevi.sharedInstance()
        
        //main
        let lime = Lime()
        //routeAble 


        //'use' func call for use middleware
        lime.use(BodyParser)
        lime.use(Favicon)
        // it's very important used kind of RouteAble
        lime.use(lime);
        lime.use(trevi)
        
        lime.get("/callback") { req, res in
            let msg = "hello iwas"
            res.send(msg)
            return false
        }
        
        lime.get("/",{ req, res in
            print("first root");
            return true
        },{ req, res in
            let msg = "im root"
            res.send(msg)
            print("second root");
            return false
        })
        
        lime.get("/yoseob" ,Index())

        
        for r in trevi.router.routeTable.keys{
            print(r)
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

