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

        getRegex()
    }
    
    init ( method: HTTPMethodType, path: String, routeAble: RouteAble... ) {
        self.method = method
        self.path = path
//        self.callback.append(callback);
        
        getRegex()
    }
    
    private final func getRegex() {
        if self.path.length() == 1 {
            self.regex = "^/$"
            return
        }
        
        if let regex: NSRegularExpression = try? NSRegularExpression ( pattern: ":([\(unreserved)\(gen_delims)\(sub_delims)]*?)(/|$)", options: [ .CaseInsensitive ] ) {
            self.regex = "^\(self.path)/$"
            for match in regex.matchesInString ( self.path, options: [], range: NSMakeRange( 0, self.path.length() ) ) {
                let paramNameRange = match.rangeAtIndex ( 1 )
                let paramName = self.path.substring(paramNameRange.location, length: paramNameRange.length)
                self.regex = self.regex.stringByReplacingOccurrencesOfString ( ":\(paramName)", withString: "([\(unreserved)\\:\\?\\#\\[\\]\\@\(sub_delims);]*)" )
                self.params.updateValue( "", forKey: paramName )
            }
        }
        
        let elements = self.path.componentsSeparatedByString ( "/" )
        for key in params.keys {
            for idx in 0 ..< elements.count where elements[idx] == ":\(key)" {
                paramsPos.updateValue( idx, forKey: key)
            }
        }
    }
}