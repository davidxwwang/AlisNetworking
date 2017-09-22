//
//  PostCodeModel.m
//  AlisNetworking
//
//  Created by alisports on 2017/8/23.
//  Copyright © 2017年 xingwang.wxw. All rights reserved.
//

#import "PostCodeModel.h"

@implementation PostCodeModel

+ (NSArray *)allPostcode:(NSDictionary *)postcodesDic{
    if (postcodesDic == nil || ![postcodesDic isKindOfClass:[NSDictionary class]]) return NULL;
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in postcodesDic.allKeys) {
        PostCodeModel *model = [[PostCodeModel alloc]init];
        NSArray *value = postcodesDic[key];
        
        model.postCode = key;
        model.chineseName = value[0];
        model.higherRegionPostCode = value[1];
        model.pingying = value[2];
        model.englishName = value[3];
        [array addObject:model];
    }
    return [array copy];
    
}

@end
