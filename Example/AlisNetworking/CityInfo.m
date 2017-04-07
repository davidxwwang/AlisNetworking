//
//  CityInfo.m
//  AlisNetworking
//
//  Created by alisports on 2017/4/7.
//  Copyright © 2017年 xingwang.wxw. All rights reserved.
//
#import "MJExtension.h"
#import "CityInfo.h"

@implementation CityInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        [CityInfo mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
            return @{@"cityID" : @"id",
                     @"cityName" : @"name",
                    };
        }];
    }
    return self;
}


@end
