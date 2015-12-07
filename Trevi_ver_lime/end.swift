//
//  end.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi
public class End : RouteAble{
    
    public override init() {
        super.init()
    }
    
    //if you want use user custom RouteAble Class for Routing 
    // fill prepare func like this 
    public override func prepare() {
        let index = trevi.trevi(self)
        index.get("/h222i") { req ,res in
            print("index.hi")
            return true
        }
        index.get("/hi123123") { req ,res in
            print("index.hi")
            return true
        }
    }
}