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
        let router = Trevi.sharedInstance ()

        //main Module
        let lime   = Lime ()

        //'use' func call for use middleware
        lime.use(BodyParser())
        lime.use(Favicon())
        lime.use(router)
    

        lime.use ( { req, res in
            res.status = 404
            res.bodyString = "404 Pages Not Found"
            res.send ()
            return true

        } )

        do {
            try server.createServer ( lime ).listen ( 8080 )
            
            /*
            try server.createServer( { req , res in
                res.status = 200
                res.body["name"] = "light server"
                res.send()
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

