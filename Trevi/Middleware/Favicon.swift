//
//  Favicon.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Favicon : Middleware{
    
    
    
    public override init(){
        super.init()
        name = .Favicon
    }
    
    public override func operateCommand(obj: AnyObject...) ->Bool {
    
        return true
    }
}