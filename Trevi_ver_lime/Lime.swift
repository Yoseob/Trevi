//
//  Lime.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 1..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi

public class Lime: RoutAble {

    override init () {
        super.init ()
    }

    public override func prepare() {
        let lime = trevi.store(self)

        
        lime.use ("/", Index ())
        
        lime.get ( "/trevi" ) { req, res in
            let msg = "Hello Trevi!"
            return res.send ( msg )
        }
        
        lime.get( "/param/:arg", { req, res in
            var msg = "Request path : \(req.path)<br>"
            msg += "Found parameter : <br>\(req.params)"
            return res.send ( msg )

        })
        
        lime.get("/redir"){ req , res in
            return res.redirect(url: "http://127.0.0.1:8080/trevi")
        }
        
        lime.post("/post") { (req, res) -> Bool in
            return res.send("post data")
        }
    }
}
