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
    
    /**
     * Factory Methed to make reqeust and response
     *
     *
     * @param { TreviSocket} socket
     * @return {( Request, Response )}
     * @private
     */
    func prepareReqAndRes ( socket: TreviSocket ) -> ( Request, Response ) {
        let req = setupRequest();
        let res = setupResponse(socket)
        res.method = req.method
        return (req,res)
    }

    private func setupRequest () -> Request {
        return requestFactory ( requestdata )
    }

    private func requestFactory ( data: NSData ) -> Request {
        return Request( data )
    }

    private func setupResponse ( socket: TreviSocket ) -> Response {
        return Response( socket: socket )
    }

}
