//
//  UnixBridge.c
//  Trevi
//
//
//  Created by JangTaehwan on 2015. 12. 9..
//  Copyright © 2015년 JangTaehwan. All rights reserved.
//

#include <fcntl.h>

int swift_fcntl(int fd, int cmd, int arg) {
    return fcntl(fd, cmd, arg);
}
