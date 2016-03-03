//
//  Trevi.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi


public class Lime : Routable{
    
    public var setting: [String: AnyObject]!
    
    public var router: Router{
        let r = self._router
        if let r = r {
            return r
        }
        return Router()
    }
    
    public override init () {
        super.init()
    }
    
    private func lazyRouter(){
        guard _router == nil else {
            return
        }
        _router = Router()
        _router.use(md: Query())
    }
    
    public func use(middleware: Middleware) {
        lazyRouter()
        _router.use(md: middleware)
    }
    
    public func set(name: String, val: AnyObject){
        if setting == nil {
            setting = [String: AnyObject]()
        }
        setting[name] = val
    }
    
    public func handle(req: IncomingMessage,res: ServerResponse,next: NextCallback?){
        
        var done: NextCallback? = next
        
        if next == nil{
            func finalHandler() {
                res.statusCode = 404
                let msg = "Not Found 404"
                res.write(msg)
                res.end()
            }
            done = finalHandler
        }

        return self._router.handle(req,res: res,next: done!)
    }
}

extension Lime: ApplicationProtocol{
    public func createApplication() -> Any {
        return self.handle
    }
}

public class LimeInit{


    
}


public extension ServerResponse{
    public func send(data: AnyObject?, encoding: String! = nil, type: String! = ""){
        write(data, encoding: encoding, type: type)
        end()
    }
}
//extention incomingMessage for lime
extension IncomingMessage {
    
}



