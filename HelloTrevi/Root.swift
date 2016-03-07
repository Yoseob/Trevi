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
/*
class MultiParty: Middleware {
    
    var name: MiddlewareName = .Undefined
    var fileDestName: String = __dirname
    var limits: String!
    //options has limits, dest, filter
    var options: [String:String!]!

    init(options : [String:String!]! = nil){
        if let opt = options{
            self.options = opt
            if let dest = opt["dest"] {
                fileDestName = dest
            }
        }
        
    }
    func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback?) {
        
        var contentType = req.header[Content_Type]

        guard contentType?.containsString("multipart/form-data") == true else{
            return next!()
        }
        
        if req.body == nil {
            req.body = [String:String]()
        }
        if req.files == nil {
            req.files = [String:File]()
        }
        
        var chuck = ""
        var boundry: String! = nil
        
        func ondata(data: String){
            
            if boundry == nil {
                boundry = readBoundry(data)
            }
            
            let finishBoundry = boundry+"--"
            
            var bodyInfo = data.componentsSeparatedByString(CRLF)
            
            let firstBodyInfo = bodyInfo.first!
            if boundry == firstBodyInfo {
                chuck += firstBodyInfo
            }
            
            bodyInfo.removeFirst()
            var cursor = 1
            
            //remove empty charecter ("")
            for index in 1 ..< bodyInfo.count{

                if bodyInfo[index-1] == ""{
                    if bodyInfo[index] == "" {
                        continue
                    }
                    cursor += 1
                    bodyInfo[cursor] = bodyInfo[index]
                    bodyInfo[index] = ""
                }
                if bodyInfo[index] == finishBoundry {
                    break
                }
            }
            
            
            parseMultipart(bodyInfo, boundry: boundry, onFile: { file in
                req.files[file.name] = file
            }, onBody: { name, value in
                req.body[name] = value
            })
          
            
        }
        
        func onend(){
            next!()
        }
        
        req.on("data", ondata)
        req.on("end", onend)


    }
    
    private func parseMultipart(bodyInfo: [String] ,boundry: String, onFile: (File)->(), onBody: (String,String)->()){
        //test val
        var infoCount = 0
        //parsing
        var type: String
        var disposition: String
        var data: String
        
        for index in 1 ..< bodyInfo.count{
            if bodyInfo[index] == boundry || bodyInfo[index] == (boundry+"--"){
                type = "text"
                infoCount += 1
                disposition = bodyInfo[index-2]
                if disposition.containsString("Content-Disposition") == false {
                    type = disposition
                    disposition = bodyInfo[index-3]
                }
                data = bodyInfo[index-1]
                 print("info :  \(type)\n , \(disposition)\n , \(data)\n")
                

                //parsing content disposition
                if disposition.containsString("filename") == true {
                    //make file
                    
                }else{
                    //make body
                }
                
            }
        }
    }

    
    private func readBoundry(data: String) -> String{
        
        guard data.length() > 0 else{
            return ""
        }
        
        
        var index = 0
        for utfString in data.utf8 {
            if utfString == 13 {
                break
            }
            index += 1
        }
        
        return data.substring(0, length: index)
    }
}
*/
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
        /*
        router.post("double", MultiParty()) { (req, res, next) -> Void in
            res.send("multipart parser middleware")
        }
        */
        
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

