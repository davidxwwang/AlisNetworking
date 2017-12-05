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

- (void)registerPlugins:(NSDictionary *)pluginsDic;

- (void)removePlugin:(NSString *)key;

- (void)registerALLPlugins;

- (NSArray *)allPlugins;

//获取key对应的插件
- (id<AlisPluginProtocol>)plugin:(NSString *)key;

/**
 根据请求的资源类型，返回合适的plugin
 @param mimeType 资源类型，包括图片，字符等类型
 */
- (id<AlisPluginProtocol>)pluginWithMimeType:(AlisHttpRequestMimeType)mimeType;

@end
