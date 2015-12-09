//
//  SwiftServerPage.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class SwiftServerPage : Middleware {
    
    public var name : MiddlewareName;
    
    public init(){
        name = .SwiftServerPage
    }
    
    public func operateCommand(obj: AnyObject...) -> Bool {
        let req : Request = obj[0] as! Request;
        let res : Response = obj[1] as! Response
        return true
    }
}