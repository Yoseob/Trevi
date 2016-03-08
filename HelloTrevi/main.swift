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

lime.set("views", "\(__dirname)/views")

lime.set("view engine", SwiftServerPage())

lime.use(Logger(format: "default"))

lime.use(Favicon())

lime.use(ServeStatic(path: "\(__dirname)/public"))

lime.use(BodyParser.json())

lime.use(BodyParser.urlencoded())

lime.use("/", Root())

lime.use { (req, res, next) in
    res.statusCode = 404
    res.send("404 error")
}

server.createServer(lime).listen(8080)

//        server.createServer({ (req, res, next) in
//            res.write("hello Trevi")
//            res.end()
//        }).listen(8080)