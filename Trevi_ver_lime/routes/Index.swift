//
//  Index.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 2..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi

public class Index: RouteAble {

    public override init () {
        super.init ()


    }

    public override func prepare () {
        let index = trevi.store ( self )

        index.get ( "/" ) { ( req, res ) -> Bool in
            return res.send ("im " + req.path)
        }

        index.get("/lee") { req ,res in
            return res.send("im " + req.path)
        }
        index.get ( "/hi" ) {
            req, res in
            return res.send ("im " + req.path)
        }
        index.post ( "/json" ) { req, res in
            return res.send (["name":"이요섭"])
        }
        index.use ( "/end", End () )
    }
}