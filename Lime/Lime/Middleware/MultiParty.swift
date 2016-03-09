//
//  MultiParty.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 3. 9..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi 
//dev module

public class DevFile {
    //dev
    var rs: FileSystem.WriteStream!
    
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

public class MultiParty: Middleware {
    
    public var name: MiddlewareName = .Undefined
    var fileDestName: String = __dirname
    var limits: String!
    
    
    //options has limits, dest, filter
    
    var options: [String:String!]!

    
    public init(options : [String:String!]! = nil){
        if let opt = options{
            self.options = opt
            if let dest = opt["dest"] {
                fileDestName = dest
            }
        }
        
    }
    public func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback?) {
        
        var contentType = req.header[Content_Type]
        
        guard contentType?.containsString("multipart/form-data") == true else{
            return next!()
        }
        
        if req.body == nil {
            req.body = [String:String]()
        }
        if req.files == nil {
            req.files = [String:AnyObject]()
        }

        var boundry: String! = nil
        var processingFileName: String!
        
        func ondata(data: String){
            
            if boundry == nil {
                boundry = readBoundry(data)
            }
            
            var bodyInfo = data.componentsSeparatedByString(CRLF)
            
            let firstBodyInfo = bodyInfo.first!
            if boundry != firstBodyInfo {
                
                var fillterFlag = false
                //filltering pre Request Data
                
                bodyInfo = bodyInfo.filter({ body in
                    if body == boundry {
                        fillterFlag = true
                    }
                    if fillterFlag == true && body == "" {
                        return false
                    }
                    if fillterFlag == false {
                        if let processingFileName = processingFileName{
                            let lastFile: DevFile = req.files[processingFileName] as! DevFile
                            writefile(body, file: lastFile)
                        }
                    }
                    return  fillterFlag
                })
                
                guard bodyInfo.count > 0 else {
                    return
                }
            }else{
                if processingFileName != nil {
                    if let processingFileName = processingFileName{
                        let lastFile: DevFile = req.files[processingFileName] as! DevFile
                        lastFile.isFinished = true
                        lastFile.rs.close()
                        lastFile.rs = nil
                    }
                    processingFileName = nil
                }
            }
            
            bodyInfo = bodyInfo.filter({ body in
                if body == "" {
                    return false
                }
                return true
            })
            
            //insert "" becouse finish noboundry data
            bodyInfo.append("")
            
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
        
        func onCompliteParse(file: DevFile){
        
            if let _ = file.path {
                if file.isFinished == true {
                    file.rs.close()
                    file.rs = nil
                }
                onFile(file)
            }else{
                onBody(file.name,file.value)
            }
        }
        
        //parsing
        var disposition: String
        var file: DevFile!
        
        var readLine = ""
        for index in 1 ..< bodyInfo.count{
            
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
                            file.path = "\(self.fileDestName)/\(filename)"
                            file.rs = FileSystem.WriteStream(path: file.path)
                        }
                    })
                    continue
                    
                }else if readLine.containsString("Content-Type:") == true {
                    if let file = file {
                        file.type = readLine.componentsSeparatedByString(": ").last!
                    }
                    continue
                }else {
                    if let file = file ,let _ = file.fileName {
                        writefile(readLine, file: file)
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
            
            return result(removePrefixFuxfix(resultList[0]),removePrefixFuxfix(resultList[1]))
        }
        
        result(removePrefixFuxfix(resultList[0]),nil)
    }
    
    private func removePrefixFuxfix(src: String) ->String{
        var str = src
        if str.hasPrefix("\"") {
            str.removeAtIndex(str.startIndex)
        }
        if str.hasSuffix("\"") {
            str.removeAtIndex(str.endIndex.predecessor())
        }
        return str
    }
    
    private func writefile(data: String, file: DevFile){
//        print(data)
        let sendData = data.dataUsingEncoding(NSUTF8StringEncoding)!
        
        file.rs.writeData(sendData)
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
