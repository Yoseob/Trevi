//
//  Utility.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public enum Handler{
    case Send
    case Next
}

public typealias Next = (Bool) ->()
public typealias CallBack = (Request , Response , Next) -> Void


public enum HTTPMethodType: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case HEAD = "HEAD"
    case UNDEFINED = "UNDEFINED"
}



extension String{
    func length() -> Int{
        return self.characters.count;
    }
    

}