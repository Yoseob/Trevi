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

//dev module 

public class DevFile {
    
    //public
    public var name: String!
    public var type: String = "text"
    
    //file
    public var fileName: String! = nil
    public var path: String! = nil
    
    //body
    public var value: String! = nil
    
    public var isFinished: Bool = false
    
    public init(){}
}

//

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
        var processingFileName: String!
        
        func ondata(data: String){
            
            if boundry == nil {
                boundry = readBoundry(data)
            }
            
            let finishBoundry = boundry+"--"
            
            var bodyInfo = data.componentsSeparatedByString(CRLF)
            
            let firstBodyInfo = bodyInfo.first!
            if boundry != firstBodyInfo {
                
                if let processingFileName = processingFileName{
                    let lastFile: DevFile = req.files[processingFileName] as! DevFile
                    writefile(firstBodyInfo, path: lastFile.path)
                }

                bodyInfo.removeFirst()
            }else{
                if processingFileName != nil {
                    if let processingFileName = processingFileName{
                        let lastFile: DevFile = req.files[processingFileName] as! DevFile
                        lastFile.isFinished = true
                    }

                    processingFileName = nil
                }
            }
            
            
            
            //remove first boundry
            if bodyInfo.count > 1 {
                bodyInfo.removeFirst()
            }
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
                if file.isFinished == false{
                    processingFileName = file.name
                }
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
    
    private func parseMultipart(bodyInfo: [String] ,boundry: String, onFile: (DevFile)->(), onBody: (String,String)->()){

        var testArr = [DevFile]()
        func onCompliteParse(file: DevFile){
            testArr.append(file)
            if let _ = file.path {
                onFile(file)
            }else{
                onBody(file.name,file.value)
            }
        }
    
        //parsing
        var disposition: String
        var file: DevFile!
        
        var readLine = ""
        for index in 0 ..< bodyInfo.count{
            
            readLine = bodyInfo[index]
            if readLine == boundry{
                file.isFinished = true
                onCompliteParse(file)
                file = nil
                
            }else if readLine == (boundry+"--"){
                file.isFinished = true
                onCompliteParse(file)
                file = nil
                break
            }else if readLine == "" {
                file.isFinished = false
                onCompliteParse(file)
                break
            }else{
                if readLine.containsString("Content-Disposition:") == true {
                    disposition = readLine
                    
                    getComponent(disposition, result: { name, filename in
                        file = DevFile()
                        file.name = name
                        
                        if let filename = filename{
                            file.fileName = filename
                            file.path = "\(self.fileDestName)/\(name)/\(filename)"
                        }
                    })
                    continue
                    
                }else if readLine.containsString("Content-Type:") == true {
                    if let file = file {
                        file.type = readLine.componentsSeparatedByString(": ").last!
                    }
                    continue
                }else {
                    if let file = file, let filename = file.fileName {
                        writefile(readLine, path: filename)
                    }else{
                        file.value = readLine
                    }
                    continue
                }
            }
        }
    }

    
    private func getComponent(data: String , result: (String,String!)->()){
        let dispositionComponents = data.componentsSeparatedByString("; ")

        var resultList = [String]()
        
        for index in 1 ..< dispositionComponents.count{
            let str = dispositionComponents[index]
            resultList.append(str.componentsSeparatedByString("=").last!)
        }
        

        if resultList.count > 1 {
            return result(resultList[0],resultList[1])
        }
        
        result(resultList[0],nil)

    }
    
    private func writefile(data: String, path: String){
        print("path : \(path) , data : \(data)")
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

