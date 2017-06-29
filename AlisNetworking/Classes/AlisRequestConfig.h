//
//  AlisRequestConfig.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/23.
//  Copyright © 2017年 alisports. All rights reserved.
//
//测试／发布环境等
typedef enum {
    ApplicationServiceTypeDevelop,
    ApplicationServiceTypeTest,
    ApplicationServiceTypeDistribution
}ApplicationServiceType;

#ifdef DEBUG
//#define API_SERVER_PROTOCAL  (@"http")
#define API_SERVER_PROTOCAL  (@"https")
#else
#define API_SERVER_PROTOCAL  (@"https")
#endif

#define COOKIE_DOMAIN  (@".alisports.com")


//#define API_HOST_DEV    (@"api-testesports.alisports.com")
#define API_HOST_DEV    (@"api-beyond.alisports.com")
#define API_HOST_TEST   (@"api-testesports.alisports.com")
//#define API_HOST_DIS    (@"api-testesports.alisports.com")
#define API_HOST_DIS    (@"api-beyond.alisports.com")


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

/**
 测试／发布环境
 */
@property(assign,nonatomic)ApplicationServiceType applicationCircumstance;

@end

@interface AlisResponse : NSObject

@property(assign,nonatomic)NSInteger responseCode;
@property(copy  ,nonatomic)NSString  * _Nullable responseMSG;
@property(strong,nonatomic)NSDictionary * _Nullable responseInfo;

- (instancetype)initWithInfo:(NSDictionary *_Nullable)info;

@end



@interface AlisError : NSObject

@property(copy,nonatomic)NSString *name;
@property(copy,nonatomic)NSDictionary *userInfo;
@property(assign,nonatomic)NSInteger code;
@property(copy,nonatomic)NSString *detailInfo;

@end

