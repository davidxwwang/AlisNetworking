//
//  AlisRequestConfig.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/23.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AlisRequestConfig.h"

@implementation AlisRequestConfig

@end

@implementation AlisResponse

- (instancetype)initWithInfo:(NSDictionary *)info
{
    if (self == [super init]) {
        self.responseInfo = info;
    }
    
    return self;
}
@end


@implementation AlisError

@end

