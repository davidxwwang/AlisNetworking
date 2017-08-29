//
//  PostCodeModel.h
//  AlisNetworking
//
//  Created by alisports on 2017/8/23.
//  Copyright © 2017年 xingwang.wxw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostCodeModel : NSObject

@property(copy ,nonatomic)NSString *postCode;
@property(copy ,nonatomic)NSString *chineseName;
@property(copy ,nonatomic)NSString *higherRegionPostCode;
@property(copy ,nonatomic)NSString *pingying;
@property(copy ,nonatomic)NSString *englishName;

+ (NSArray *)allPostcode:(NSDictionary *)postcodesDic;

@end
