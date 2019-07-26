//
//  JHNetworkSpeedFloatView.m
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

#import "JHNetworkSpeedFloatView.h"
#import "JHNetworkSpeed.h"

@interface JHNetworkSpeedFloatView()

@property (nonatomic,  strong) UILabel *uploadLabel;
@property (nonatomic,  strong) UILabel *downloadLabel;

@end

@implementation JHNetworkSpeedFloatView

#pragma mark -------------------------------------视图-------------------------------------------

+ (instancetype)shareView
{
    return [[JHNetworkSpeedFloatView alloc] initWithFrame:CGRectMake(50, 100, 50, 50)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor lightGrayColor];
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)*0.5;
    
    [self addSubview:self.uploadLabel];
    [self addSubview:self.downloadLabel];
    
    __weak typeof(self) ws = self;
    JHNetworkSpeed *speed = [JHNetworkSpeed share];
    [speed start];
    speed.speedBlock = ^(NSString * _Nonnull uploadSpeed, NSString * _Nonnull downloadSpeed) {
        ws.uploadLabel.text = [NSString stringWithFormat:@"↑%@/s",uploadSpeed];
        ws.downloadLabel.text = [NSString stringWithFormat:@"↓%@/s",downloadSpeed];
    };
}

#pragma mark -------------------------------------事件-------------------------------------------

- (void)show
{
    [[UIApplication sharedApplication].delegate.window addSubview:self];
}

#pragma mark -------------------------------------懒加载-----------------------------------------

- (UILabel *)uploadLabel{
    if (!_uploadLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, CGRectGetHeight(self.bounds)*0.5-15, CGRectGetWidth(self.bounds), 15);
        label.text = @"↑0KB/s";
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = 1;
        label.adjustsFontSizeToFitWidth = YES;
        _uploadLabel = label;
    }
    return _uploadLabel;
}

- (UILabel *)downloadLabel{
    if (!_downloadLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, CGRectGetHeight(self.bounds)*0.5, CGRectGetWidth(self.bounds), 15);
        label.text = @"↓0KB/s";
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = 1;
        label.adjustsFontSizeToFitWidth = YES;
        _downloadLabel = label;
    }
    return _downloadLabel;
}

@end
