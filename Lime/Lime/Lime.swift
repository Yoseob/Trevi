//
//  Trevi.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi

/*
    For Trevi users, allow routing and to apply middlewares without difficulty.
*/

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
        lazyRouter()
    }
    
    private func lazyRouter(){
        guard _router == nil else {
            return
        }
        _router = Router()
        _router.use(md: Query())
    }
    
    public func use(middleware: Middleware) {
        _router.use(md: middleware)
    }
    
    #if os(Linux)
    public func set(name: String, _ val: String){
        if setting == nil {
            setting = [String: AnyObject]()
        }
        setting[name] = StringWrapper(string: val)
    }
    #endif
    
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

// Needed to activate lime in the Trevi Fountain.
extension Lime: ApplicationProtocol {
    public func createApplication() -> Any {
        return self.handle
    }
}



// For Lime extension ServerResponse
extension ServerResponse {
    
    // Lime recommend using that send rather than using write
    public func send(data: String, encoding: String! = nil, type: String! = ""){
        write(data, encoding: encoding, type: type)
        endReuqstAndClean()
    }
    
    public func send(data: NSData, encoding: String! = nil, type: String! = ""){
        write(data, encoding: encoding, type: type)
        endReuqstAndClean()
    }
    
    public func send(data: [String : String], encoding: String! = nil, type: String! = ""){
        write(data, encoding: encoding, type: type)
        endReuqstAndClean()
    }
    
    private func endReuqstAndClean(){
        end()
        if req.files != nil {
            for file in self.req.files.values{
                FSBase.unlink(path: file.path)
            }
        }
    }
    
    public func render(path: String, args: [String:String]? = nil) {
        if let app = req.app as? Lime, let render = app.setting["view engine"] as? Render {
            var entirePath = path
            #if os(Linux)
            if let abpath = app.setting["views"] as? StringWrapper {
                entirePath = "\(abpath.string)/\(entirePath)"
            }
            #else
            if let bundlePath = NSBundle.mainBundle().pathForResource(NSURL(fileURLWithPath: path).lastPathComponent!, ofType: nil) {
                entirePath = bundlePath
            }
            #endif
            
            if args != nil {
                render.render(entirePath, args: args!) { data in
                    self.write(data)
                }
            } else {
                render.render(entirePath) { data in
                    self.write(data)
                }
            }
        }
        end()
    }
    
    public func redirect(url: String){
        self.writeHead(302, headers: [Location:url])
        self.end()
    }
}




//extention incomingMessage for lime
extension IncomingMessage {
    
}



