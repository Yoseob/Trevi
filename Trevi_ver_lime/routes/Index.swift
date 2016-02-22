//
//  Index.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 2..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi

public class Index: RoutAble {

    public override init () {
        super.init ()
    }

    public override func prepare () {

        let index = self

        index.get ( "/", { req, res in
            return res.render(getResourcePath("index.ssp"), args: [ "title" : "Trevi" ])
        })

        index.post ("/json" ) { req, res in
            return res.send (["name":"이요섭"])
        }
        
        index.use ("/end", End())
    }
}