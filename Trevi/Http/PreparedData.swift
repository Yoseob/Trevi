//
//  PreparedData.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 24..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

public typealias ReceivedParams = (buffer: UnsafeMutablePointer<CChar>, length: Int)
import Foundation

/*

    PreparedData is make request and response after read all of data from client

*/
public class PreparedData {
    
    //The content-length of the body
    private var content_length = 0
    
    private var req : Request?
    
    private var filemanager  = File()
    
    private var traceBodyString : String = ""
    
    
    var boundryCount = 0
    var bodyBuff = ""
    private var boundry : String?
    
    init(){
    }
    
    /**
     Functions that can make with one request a function been divided into several
     
     - Parameter path: Data received and length
     
        Examples:
            public func operateCommand ( params: MiddlewareParams ) -> Bool {
                return false
             }

     - Returns: {(Int,Int)} content-length,header-length

     */
    func appendReadData(params : ReceivedParams) -> (Int,Int){

        let (strData,_) = String.fromCStringRepairingIllFormedUTF8(params.buffer)
        var data = strData! as String
        var headerLength = 0;
        
        //header
        if data.containsString("HTTP/1."){
            req = nil
            req = setupRequest(data)
            
            if let contentLength = req?.header[Content_Length]{
                content_length =  Int(contentLength)!
                headerLength = params.length
            }
            
            if req!.header[Content_Length] != nil  {
                let headerList = req!.headerString.componentsSeparatedByString(CRLF)
                var buff = String()
                var flag = false
                
                for line in headerList{
                    if line.length() == 0 {
                        flag = true
                    }
                    if flag && line.length() > 0{
                        buff += line
                        buff += CRLF
                    }
                }
                data = buff
            }
        }
        
        if(data.length() > 0){
            dispatchBodyData(data)
        }
    
        return (content_length,headerLength)
    }
    
    
    /**
     Function with which to data rather than parsing through
     Should be writed File
     
     First Seperation based on boundry and Check Content-Dispostion
     
     - Parameter path: At the request of a string body
     
     - Returns: Void
     
     */
    func dispatchBodyData(bodyFragment : String){
        
        guard  bodyFragment.length() > 0 else{
            return
        }
        
        if boundry == nil || boundry?.length() == 0{
            let characters = bodyFragment.characters
            for Character in characters{
                if Character == "\r\n"{
                    let index = characters.indexOf(Character)
                    boundry = bodyFragment.substringToIndex(index!)
                    break;
                }
            }
        }
        
        var bodys = bodyFragment.componentsSeparatedByString(CRLF);
        
        if bodys.first! != boundry {
            let temp = traceBodyString
            traceBodyString += bodys.first!
            if traceBodyString == boundry{
                bodyBuff = bodyBuff.stringByReplacingOccurrencesOfString(temp, withString: "")
                bodys.removeFirst()
                bodys.insert(boundry!, atIndex: 0)
            }
        }

        let tailBoundary = boundry! + "--"
        for  str in bodys{
            if str.length() == 0 {
                continue
            }
            if boundry! == str || tailBoundary == str{
                boundryCount++
                traceBodyString = ""
                if boundryCount == 2{
                    boundryCount--;
                    //move file IO connector
                    bodyBuff = ""
                }
            }else{
                if(str != CRLF){
                    bodyBuff += str
                    bodyBuff += CRLF
                }
            }
        }
        traceBodyString = bodys.last!;
    }
    
    func tempWriteFunction(date : String){
    //test
        filemanager.createFile("user_ip_body_\(bodyBuff.substring(20, length: 20))")
        
    }
    
    /**
     Running time with response to complete function to listen to the data of the request.

     
     - Parameter path: A socket for response
     
     - Returns: Void
     
     */
    func handleRequest(socket : ClientSocket ) -> (Request , Response){
        let res = setupResponse(socket)
        return (self.req!,res)
    }
    
    func dInit(){
        boundry = ""
        bodyBuff = "" 
        traceBodyString = ""
        boundryCount = 0
        content_length = 0
    }
 
    /**
     * Factory Methed to make reqeust and response
     *
     *
     * @param { TreviSocket} socket
     * @return {( Request, Response )}
     * @private
     */

    private func setupRequest ( hData: String ) -> Request {
        return Request( hData )
    }

    private func setupResponse ( socket: ClientSocket ) -> Response {
        let res = Response( socket: socket )
        res.method = self.req!.method
        //connection header
        if let connection = req?.header[Connection]{
            res.header[Connection] = connection
        }
        
        return res
    }

}
