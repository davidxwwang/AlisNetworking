//
//  AlisRequestConfig.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/23.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlisRequestConfig : NSObject

//公共的server地址,有可能是测试的
@property(copy,nonatomic,nullable)NSString *generalServer;

//公共的header
@property(copy,nonatomic,nullable)NSDictionary<NSString *,NSString *> *generalHeader;

//公共的paramters
@property(copy,nonatomic,nullable)NSDictionary<NSString *,id> *generalParamters;

//回调的queue
@property(strong,nonatomic,nullable)dispatch_queue_t callBackQueue;

//是否同步请求，默认为NO
@property(assign,nonatomic)BOOL enableSync;

@end

@interface AlisResponse : NSObject

- (instancetype)initWithInfo:(NSDictionary *)info;

@property(strong,nonatomic)NSDictionary *responseInfo;

@end



@interface AlisError : NSObject

@property(copy,nonatomic)NSString *name;
@property(copy,nonatomic)NSDictionary *userInfo;
@property(assign,nonatomic)NSInteger code;
@property(copy,nonatomic)NSString *detailInfo;

@end

