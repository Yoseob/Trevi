//
//  LibuvUtility.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 17..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//


import Libuv

public typealias uv_handle_ptr = UnsafeMutablePointer<uv_handle_t>

public typealias uv_loop_ptr = UnsafeMutablePointer<uv_loop_t>
public typealias uv_poll_ptr = UnsafeMutablePointer<uv_poll_t>
public typealias uv_buf_ptr = UnsafeMutablePointer<uv_buf_t>
public typealias uv_stream_ptr = UnsafeMutablePointer<uv_stream_t>
public typealias uv_write_ptr = UnsafeMutablePointer<uv_write_t>
public typealias uv_connect_ptr = UnsafeMutablePointer<uv_connect_t>
public typealias uv_pipe_ptr = UnsafeMutablePointer<uv_pipe_t>
public typealias uv_tcp_ptr = UnsafeMutablePointer<uv_tcp_t>
public typealias uv_shutdown_ptr = UnsafeMutablePointer<uv_shutdown_t>

public typealias uv_buf_const_ptr = UnsafePointer<uv_buf_t>
