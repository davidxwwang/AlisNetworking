//
//  service.h
//  PluginsDemo
//
//  Created by alisports on 2017/3/4.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import "AlisRequestProtocol.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ServiceAction) {
    Resume,
    Cancel
};

typedef NS_ENUM(NSInteger, ServiceType) {
    HTTP,
    LocalData
};

/**
 定义了一种服务，在
 表示此时此刻 需要服务的名称，一个类中很可能有好几个不同值。使用“类名／服务名” 区别不同类中有相同的服务
 */

@interface Service : NSObject<NSCopying>

+ (ServiceType)convertServiceTypeFromString:(NSString *)yy;
+ (ServiceAction)convertServiceActionFromString:(NSString *)yy;

- (instancetype)init:(ServiceType)serviceType serviceName:(NSString *)serviceName serviceAction:(ServiceAction)serviceAction serviceAgent:(id)serviceAgent;

/**
 服务的名称
 */
@property(copy,nonatomic,readonly)NSString *serviceName;

/**
 服务的类型，例如http等，后期改为枚举类型
 */
@property(assign,nonatomic,readonly)ServiceType serviceType;

/**
 服务的行为，例如resume开始，cancel取消,增加，删除等
 */
@property(assign,nonatomic,readonly)ServiceAction serviceAction;

/**
 服务的类
 */
@property(strong,nonatomic,readonly)id serviceAgent;




@end
