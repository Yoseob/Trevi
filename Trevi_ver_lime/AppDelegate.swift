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

    func applicationDidFinishLaunching ( aNotification: NSNotification ) {
              
        let server = Http ()

        //Trevi is used routor like nodejs express
        let trevi = Trevi.sharedInstance ()
        //main Module
        let lime = Lime ()
        
        //'use' func call for use middleware
        lime.use(BodyParser())
        
        lime.use(Favicon())
        
        lime.use(SwiftServerPage())
        
        lime.use(ServeStatic()) // it is important to routing
        
        lime.use(trevi) // it is important to routing
        
        lime.use(){ req, res in
            res.status = 404
            return res.send ("404 Pages Not Found")
        }
        

        do {
            try server.createServer ( lime ).listen (8080)
            
            //If you want to make light Server. use it
            /*
            try server.createServer( { req , res in
                var dic = [String : AnyObject]()
                dic["name"] = "im yoseob";
                res.send(dic)
                return true
                }).listen(8080)

            */
        } catch {

        }
    }

    func applicationWillTerminate ( aNotification: NSNotification ) {
        // Insert code here to tear down your application
    }
}

