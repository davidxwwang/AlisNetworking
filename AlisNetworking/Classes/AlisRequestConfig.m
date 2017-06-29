//
//  AlisRequestConfig.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/23.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AlisRequestConfig.h"

@implementation AlisRequestConfig

- (instancetype)init{
    if (self == [super init]) {
        self.callBackQueue = dispatch_queue_create("AlisRequest", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)setApplicationCircumstance:(ApplicationServiceType)applicationCircumstance{
    _applicationCircumstance = applicationCircumstance;

}

@end

@implementation AlisResponse

- (instancetype)initWithInfo:(NSDictionary *)info{
    if (self == [super init]) {
        //todo 适配型
        self.responseCode = [info[@"res_code"] integerValue];
        self.responseMSG =  info[@"res_msg"];
        self.responseInfo = info[@"data"];
    }
    return self;
}

@end


@implementation AlisError

@end

