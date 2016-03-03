//
//  main.swift
//  Trevi_ver_lime
//
//  Created by SeungHyun Lee on 2016. 03. 02..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Trevi
import Lime

let server = Http ()
let lime = Lime()

lime.use(Favicon())

lime.use("/root", Root())

lime.use { (req, res, next) in
    res.statusCode = 200
    res.write("404 error")
    res.end()
}

server.createServer(lime).listen(8080)

//        server.createServer({ (req, res, next) in
//            res.write("hello Trevi")
//            res.end()
//        }).listen(8080)