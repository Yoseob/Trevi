//
//  Lime.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 1..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi

public class Lime: RouteAble {
    override init () {
        super.init ()

    }

    public override func prepare() {
        let lime = trevi.store(self)
        
        lime.get("/intro") { req, res in
            let file_path = NSBundle.mainBundle().pathForResource("intro", ofType: "ssp")
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
        
        
        lime.get ( "/callback" ) { req, res in
            let msg = "Hello Trevi!"
            res.send ( msg )
            return false
        }
        
        lime.get ( "/", { req, res in
            return true
            }, { req, res in
                let msg = "im root"
                res.send (msg)
                return false
        } )
        
        lime.use ( "/yoseob", Index () )
        // Register SSP(Swift Server Page) on '/ssp'
        if let index = NSBundle.mainBundle().pathForResource( "index", ofType: "ssp" ) {
            lime.get( "/ssp" ) {
                req, res in
                res.render( index )
                return false
            }
        }
        
        // Register SSP(Swift Server Page) on '/ssp/var' with arguments
        // Only string arguments allowed now..
        if let arg_test = NSBundle.mainBundle().pathForResource( "arg_test", ofType: "ssp" ) {
            lime.get( "/ssp/var" ) {
                req, res in
                
                let date = NSDate();
                let dateFormatter = NSDateFormatter()
                dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
                dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                dateFormatter.timeZone = NSTimeZone()
                let localDate = dateFormatter.stringFromDate( date )
                
                res.render( arg_test, [ "title": "Hello World", "number": "77", "time": localDate ] )
                return false
            }
        }
        
        lime.get( "/ssp/:name/:arg/tjssm", { req, res in
            var msg = "Request path : \(req.path)<br>"
            msg += "Found parameter : <br>\(req.params)"
            res.send ( msg )
            return false
        } )
        
        lime.get( "/ssp/:arg", { req, res in
            var msg = "Request path : \(req.path)<br>"
            msg += "Found parameter : <br>\(req.params)"
            res.send ( msg )
            return false
        } )


    }
}
