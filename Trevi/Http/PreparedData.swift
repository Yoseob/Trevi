//
//  PreparedData.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 24..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

/*

    PreparedData is just Factory

*/
class PreparedData {

    var requestdata: NSData!
    
    init ( requestData: NSData ) {
        self.requestdata = requestData;
    }

    func prepareReqAndRes ( socket: TreviSocket ) -> ( Request, Response ) {
        return (setupRequest (), setupResponse ( socket ))
    }

    private func setupRequest () -> Request {
        let resultRequest: Request = requestFactory ( requestdata )
        return resultRequest
    }

    private func requestFactory ( data: NSData ) -> Request {
        return Request( data )
    }

    private func setupResponse ( socket: TreviSocket ) -> Response {
        return Response( socket: socket )
    }

}
