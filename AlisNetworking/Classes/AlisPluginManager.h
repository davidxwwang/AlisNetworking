//
//  AlisPluginManager.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/26.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import "AlisPluginProtocol.h"
#import <Foundation/Foundation.h>

@interface AlisPluginManager : NSObject

+ (AlisPluginManager *)manager;

- (void)registerPlugin:(id<AlisPluginProtocol>)plugin key:(NSString *)key;


//在plist文件中
- (void)registerPlugin:(NSString *)key;

- (void)removePlugin:(NSString *)key;

- (void)registerALLPlugins;

//获取key对应的插件
- (id<AlisPluginProtocol>)plugin:(NSString *)key;

@end
