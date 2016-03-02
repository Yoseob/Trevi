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
        
        if let regex: NSRegularExpression = try? NSRegularExpression ( pattern: "[&\\?](.+?)=([\(unreserved)\(gen_delims)\\!\\$\\'\\(\\)\\*\\+\\,\\;]*)", options: [ .CaseInsensitive ] ) {
            for match in regex.matchesInString ( url, options: [], range: NSMakeRange( 0, url.length() ) ) {
                let keyRange   = match.rangeAtIndex( 1 )
                let valueRange = match.rangeAtIndex( 2 )
                let key   = url.substring ( keyRange.location, length: keyRange.length )
                let value = url.substring ( valueRange.location, length: valueRange.length )
                req.query.updateValue ( value.stringByRemovingPercentEncoding!, forKey: key.stringByRemovingPercentEncoding! )
            }
        }
        
        next!()
    }
}
