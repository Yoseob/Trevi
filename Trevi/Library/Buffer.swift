//
//  Buffer.swift
//  Trevi
//
//  Created by SeungHyunLee on 2/22/16.
//  Copyright © 2016 LeeYoseob. All rights reserved.
//

public class Buffer {
    var data: [Int8]
    var length: Int {
        get {
            return data.count
        }
    }
    
    init() {
        self.data = [Int8]()
    }
    
    init(capacity: Int) {
        self.data = [Int8](count: capacity, repeatedValue: 0)
    }
    
    init(data: [Int8]) {
        self.data = data
    }
    init(data: String) {
        self.data = Array(UnsafeBufferPointer(start: data, count: data.characters.count))
    }
    
    init(data: UnsafePointer<Int8>, length: Int) {
        self.data = Array(UnsafeBufferPointer(start: data, count: length))
    }
    
    func push(data: Int8) {
        self.data.append(data)
    }
    
    func push(data: Buffer) {
        self.data.appendContentsOf(data.data)
    }
    
    func push(data: [Int8]) {
        self.data.appendContentsOf(data)
    }
    
    func push(data: UnsafePointer<Int8>, length: Int) {
        self.data.appendContentsOf(Array(UnsafeBufferPointer(start: data, count: length)))
    }
    
    func unshift(data: Int8) {
        self.data.append(data)
    }
    
    func unshift(data: Buffer) {
        self.data.insertContentsOf(data.data, at: 0)
    }
    
    func unshift(data: [Int8]) {
        self.data.insertContentsOf(data, at: 0)
    }
    
    func unshift(data: UnsafePointer<Int8>, length: Int) {
        self.data.insertContentsOf(Array(UnsafeBufferPointer(start: data, count: length)), at: 0)
    }
    
    func truncate() {
        data.removeAll()
    }
}