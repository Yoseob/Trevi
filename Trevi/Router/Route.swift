//
//  Route.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Route {

    public var path: String!
    public var regex: String!
    var method: HTTPMethodType!
    var callbacks = [ CallBack ]!()
    var params    = [ String : String ]()
    var paramsPos = [ String : Int ]()

    init () {
        self.method = .UNDEFINED
    }
    
    init ( method: HTTPMethodType, _ path: String, _ callback: [CallBack] ) {
        self.method = method
        self.path = path
        self.callbacks = callback

        parsePath()
    }
    
    init ( method: HTTPMethodType, path: String, routeAble: RoutAble... ) {
        self.method = method
        self.path = path
//        self.callback.append(callback);
        
        parsePath()
    }
    
    private final func parsePath() {
        regex = "^\(path)(/|$)"
        
        if path.length() < 2 {
            return
        }
        
        let pathComponent = path.componentsSeparatedByString("/")
        
        for param in searchWithRegularExpression(path, pattern: ":([\(unreserved)\(gen_delims)\(sub_delims)]*?)(/|$)") {
            // get regular expression for routing
            regex = regex.stringByReplacingOccurrencesOfString ( ":\(param["$1"]!.text)", withString: "([\(unreserved)\\:\\?\\#\\[\\]\\@\(sub_delims);]*)" )
            
            // get path parameter
            params.updateValue( "", forKey: param["$1"]!.text )
            for idx in 0 ..< pathComponent.count where idx != 0 && pathComponent[idx] == ":\(param["$1"]!.text)" {
                paramsPos.updateValue(idx - 1, forKey: param["$1"]!.text)
            }
        }
    }
}