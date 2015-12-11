//
//  end.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi

public class End: RouteAble {

    public override init () {
        super.init ()
    }

    //if you want use user custom RouteAble Class for Routing 
    // fill prepare func like this 
    public override func prepare () {
        let index = trevi.store ( self )
        index.get ( "/1" ) {
            req, res in
            res.bodyString = "im " + req.path
            res.send ()
            return false
        }
        index.get ( "/2" ) {
            req, res in
            res.bodyString = "im " + req.path
            res.send ()
            return false

        }

        index.get ( "/3" ) {
            req, res in
            res.bodyString = "im " + req.path
            res.send ()
            return false

        }

    }
}