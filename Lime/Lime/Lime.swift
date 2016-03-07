//
//  Trevi.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi


public class Lime : Routable {
    
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
    
    public func set(name: String, _ val: AnyObject){
        if setting == nil {
            setting = [String: AnyObject]()
        }
        setting[name] = val
    }
    
    public func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback?){

        var done: NextCallback? = next
        
        if next == nil{
            func finalHandler() {
                res.statusCode = 404
                let msg = "Not Found 404"
                res.write(msg)
                res.end()
            }
            done = finalHandler
            
            req.app = self
        }

        return self._router.handle(req,res: res,next: done!)
    }
}

extension Lime: ApplicationProtocol {
    public func createApplication() -> Any {
        return self.handle
    }
}

public class LimeInit {
}

public extension ServerResponse {
    public func send(data: AnyObject?, encoding: String! = nil, type: String! = ""){
        write(data, encoding: encoding, type: type)
        end()
    }
    
    public func render(path: String, args: [String:String]? = nil) {
        if let app = req.app as? Lime, let render = app.setting["view engine"] as? Renderer {
            var entirePath = path
            #if os(Linux)
            if let abpath = app.setting["views"] as? String {
                entirePath = "\(abpath)/\(entirePath)"
            }
            #else
            if let bundlePath = NSBundle.mainBundle().pathForResource(NSURL(fileURLWithPath: path).lastPathComponent!, ofType: nil) {
                entirePath = bundlePath
            }
            #endif
            
            if args != nil {
                write(render.render(entirePath, args: args!))
            } else {
                write(render.render(entirePath))
            }
        }
        end()
    }
    
    public func redirect(url: String){
        self.writeHead(302, headers: [Location:url])
        self.end()
    }
}

import Trevi


//extention incomingMessage for lime
extension IncomingMessage {
    
}



