//
//  JHNetworkSpeed.m
//  JHNetworkSpeed
//
//  Created by HaoCold on 2019/7/25.
//  Copyright © 2019 HaoCold. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2019 xjh093
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "JHNetworkSpeed.h"
#include <net/if.h>
#include <ifaddrs.h>


@interface JHNetworkSpeed()

@property (nonatomic,    copy) NSString *uploadSpeed;
@property (nonatomic,    copy) NSString *downloadSpeed;

@property (nonatomic,  strong) NSTimer *timer;

@property (nonatomic,  assign) uint32_t  inBytes;
@property (nonatomic,  assign) uint32_t  outBytes;

@end

@implementation JHNetworkSpeed

+ (instancetype)share
{
    static JHNetworkSpeed *speed;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        speed = [[JHNetworkSpeed alloc] init];
    });
    return speed;
}

- (void)fetchInterfaceBytes
{
    struct ifaddrs *ifaddrs_list = 0;
    if (getifaddrs(&ifaddrs_list) == -1) {
        _uploadSpeed = @"0B";
        _downloadSpeed = @"0B";
        return;
    }
    
    uint32_t inBytes = 0;
    uint32_t outBytes = 0;
    struct ifaddrs *ifaddrs;
    for (ifaddrs = ifaddrs_list; ifaddrs; ifaddrs = ifaddrs->ifa_next) {
        if (AF_LINK != ifaddrs->ifa_addr->sa_family) {
            continue;
        }
        
        if (!(IFF_UP & ifaddrs->ifa_flags) &&
            !(IFF_RUNNING & ifaddrs->ifa_flags)) {
            continue;
        }
        
        if (ifaddrs->ifa_data == 0) {
            continue;
        }
        NSLog(@"name:%s",ifaddrs->ifa_name);
        if (strncmp(ifaddrs->ifa_name, "lo", 2)) {
            struct if_data *if_data = (struct if_data *)ifaddrs->ifa_data;
            inBytes += if_data->ifi_ibytes;
            outBytes += if_data->ifi_obytes;
        }
    }
    freeifaddrs(ifaddrs_list);
    
    if (_inBytes != 0) {
        _downloadSpeed = [self bytesToString:inBytes-_inBytes];
    }
    _inBytes = inBytes;
    
    if (_outBytes != 0) {
         _uploadSpeed = [self bytesToString:outBytes-_outBytes];
    }
    _outBytes = outBytes;
    
    NSLog(@"up:%@,down:%@",_uploadSpeed,_downloadSpeed);
    
    if (_speedBlock) {
        _speedBlock(_uploadSpeed,_downloadSpeed);
    }
}

- (NSString *)bytesToString:(uint32_t)bytes
{
    if (bytes < 1024) {
        return [NSString stringWithFormat:@"%dB", bytes];
    }
    else if(bytes >= 1024 && bytes < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1fKB", (double)bytes / 1024];
    }
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2fMB", (double)bytes / (1024 * 1024)];
    }
    else{
        return [NSString stringWithFormat:@"%.3fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(fetchInterfaceBytes) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)start
{
    [self stop];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stop
{
    [_timer invalidate];
    _timer = nil;
}

@end
