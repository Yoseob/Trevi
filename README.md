
![Trevi?] (./index.png)

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms OS X ](https://img.shields.io/badge/Platforms-OS%20X-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

## Trevi
Fast, light web application server framwork for Swift. Trevi uses an event-driven, non-blocking I/O model based on libuv (https://github.com/libuv/libuv).<br>
Trevi refers to node.js core modules and makes Trevi core modules similary to support node.js features. Trevi also hopes that node.js developers easily use and develop Trevi. <br><br>
Lime is improved web framework for Trevi, and Lime refers to express. (Lime does not support many core modules in express yet.)


## Build Instructions

### OS X (recommended)
For Debug builds (recommended) run:
```
$ make all
```

For Release builds run:
```
$ make all COMPILE_MODE=Release
```

### Ubuntu
Trevi is not working on ubuntu yet, but it can be build soon.

### Running tests
For testing Trevi, use Xcode and build the project


## Examples
```swift
let server = Http ()

server.createServer({ (req, res, next) in

    var chuck = ""
    func ondata(c: String){
        chuck += c
    }

    func onend(){
        res.write(chuck)
        res.end()

    }

    req.on("data", ondata)
    req.on("end", onend)

}).listen(8080)

```

OR

```swift

let server = Http ()

let lime = Lime()


lime.set("views", "\(__dirname)/views");

lime.set("view engine", SwiftServerPage())

lime.use(Favicon())

lime.use(ServeStatic(path: "\(__dirname)/public"))

lime.use(BodyParser())

lime.use("/", Root())

lime.use { (req, res, next) in
    res.statusCode = 404
    res.send("404 error")
}

server.createServer(lime).listen(8080)

```

lime class 
```swift

import Foundation
import Lime

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

        router.post("/index") { req , res , next in
            print("\(req.json["name"])")
            res.send("index post")
        }

        router.get("/lime") { req , res , next in
            res.write("lime get")
            res.end()
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

```

### CocoaPods 
### Carthage
### Youtube
[![Youtube](./screenshot.png)](https://www.youtube.com/watch?v=v7O5dq4_s2Q)

https://youtu.be/W6hPkevipX4

