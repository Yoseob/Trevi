//
//  SocketUtility.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 9..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Darwin

// Network data byte order functions for Swift
let isLittleEndian = Int(OSHostByteOrder()) == OSLittleEndian
public let htons = isLittleEndian ? _OSSwapInt16 : { $0 }
public let htonl  = isLittleEndian ? _OSSwapInt32 : { $0 }
public let ntohs  = htons
public let ntohl  = htonl
