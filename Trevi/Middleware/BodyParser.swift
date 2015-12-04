//
//  BodyParser.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation


public class BodyParser : Middleware{
    

    
    public override init(){
        super.init()
        name = .BodyParser
    }
    
    public override func operateCommand(obj: AnyObject...) {
        
        var req : Request = obj[0] as! Request;
//        let r : Route = obj[1] as! Route
//        parserBody(&req,r)
    }
    public func parserBody(inout req : Request , _ route : Route){
        // fill request.params use route.regExp and Params
    }
    
}