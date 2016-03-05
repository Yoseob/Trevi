//
//  Query.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 3. 2..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi

//defualt middleware
class Query: Middleware {
    var  name: MiddlewareName = .Query
    init(){
    }
    
    func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback?) {
        // Parsing url query by using regular expression.
        let url = req.url
        queryParse(url) { query in
            req.query = query

            req.url = (url.componentsSeparatedByString( "?" ) as [String])[0]
            
            
            next!()
        }
    }
}
public func queryParse(src: String , cb: ([ String: String ])->()) {
    
    var result = [String: String]()
    if let regex: NSRegularExpression = try? NSRegularExpression ( pattern: "[&\\?](.+?)=([\(unreserved)\(gen_delims)\\!\\$\\'\\(\\)\\*\\+\\,\\;]*)", options: [ .CaseInsensitive ] ) {
        
        for match in regex.matchesInString ( src, options: [], range: NSMakeRange( 0, src.length() ) ) {
            let keyRange   = match.rangeAtIndex( 1 )
            let valueRange = match.rangeAtIndex( 2 )
            let key   = src.substring ( keyRange.location, length: keyRange.length )
            let value = src.substring ( valueRange.location, length: valueRange.length )
            result.updateValue ( value.stringByRemovingPercentEncoding!, forKey: key.stringByRemovingPercentEncoding! )
        }
    }
    
    return cb(result)
    
}
