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
<<<<<<< HEAD
        lime.use(BodyParser())
        lime.use(Favicon())
        
        // it's very important used kind of RouteAble
        //register for main modle
        lime.use(lime);
        lime.use(router)
        
        lime.get("/intro") { req, res in
            let file_path = NSBundle.mainBundle().pathForResource("index", ofType: "html")
            res.data = NSData(contentsOfFile: file_path!)
            res.send()
            return false
        }
        
        lime.get("/image") { req, res in
            let file_path = NSBundle.mainBundle().pathForResource("myImage", ofType: "jpg")
            res.data = NSData(contentsOfFile: file_path!)
            res.send()
            return false
        }

        
        lime.get("/",{ req, res in
=======
        lime.use ( BodyParser () )
        lime.use ( Favicon () )
        lime.use ( SwiftServerPage () )

        // It's very important used kind of RouteAble
        // Register for main modle
        lime.use ( lime );

        lime.use ( router )

        lime.get ( "/callback" ) { req, res in
            let msg = "Hello Trevi!"
            res.send ( msg )
            return false
        }

        lime.get ( "/", { req, res in
>>>>>>> 3e1e130e7cc0e9dfddb495263cb01ea72bec7848
            return true
        }, { req, res in
            let msg = "im root"
            res.send ( msg )
            return false
        } )

        lime.use ( "/yoseob", Index () )

        // Register SSP(Swift Server Page) on '/ssp'
        if let index = NSBundle.mainBundle ().pathForResource ( "index", ofType: "ssp" ) {
            lime.get ( "/ssp" ) { req, res in
                res.render ( index )
                return false
            }
        }

        // Register SSP(Swift Server Page) on '/ssp' with arguments
        // Only string arguments allowed now..
        if let arg_test = NSBundle.mainBundle ().pathForResource ( "arg_test", ofType: "ssp" ) {
            lime.get ( "/ssp/var" ) { req, res in
                res.render ( arg_test, [ "title": "Hello World", "number": "77" ] )
                return false
            }
        }

        lime.use ( { req, res in
            res.status = 404
            res.bodyString = "404 Pages Not Found"
            res.send ()
            return true

        } )

        do {
            try server.createServer ( lime ).listen ( 8080 );
        } catch {

        }
    }

    func applicationWillTerminate ( aNotification: NSNotification ) {
        // Insert code here to tear down your application
    }
}

