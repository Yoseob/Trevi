//
//  Lime.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 1..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Lime

/*
    Cookie parser 
    Chunk encoding
    response refactoring (etag)
    mime type 


    all(get,post,put)

*/

import Trevi
class MultiParty: Middleware {
    var name: MiddlewareName = .Undefined
    init(){}
    func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback?) {
        if req.body == nil {
            req.body = [String:String]()
        }

        var chuck = ""
        func ondata(c: String){
            chuck += c
        }
        func onend(){
            next!()
        }
        req.on("data", ondata)
        req.on("end", onend)


    }
}

public class Root{
    
    private let lime = Lime()
    private var router: Router!
    
    public init(){
        
        router = lime.router
        
        router.get("/") { req , res , next in
            res.render("index.ssp", args: ["title":"Trevi"])
        }
        
        router.get("/index") { req , res , next in
            res.write("index get")
            res.end()
        }
        
        router.post("double", MultiParty()) { (req, res, next) -> Void in
            res.send("multipart parser middleware")
        }
        
        router.post("/index") { req , res , next in
            print("\(req.body["name"])")
            res.send("index post")
        }
        
        router.get("/redir") { req , res , next in
            res.redirect("http://127.0.0.1:8080/")
        }
        
        router.get("/trevi/:param1") { req , res , next in
            print("[GET] /trevi/:praram")
        }
    }
}

extension Root: Require{
    public func export() -> Router {
        return self.router
    }
}

