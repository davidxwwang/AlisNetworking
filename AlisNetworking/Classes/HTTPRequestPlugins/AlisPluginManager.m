//
//  AlisPluginManager.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/26.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AlisPluginManager.h"


BOOL MSIsFileExistAtPath(NSString *filePath){
    NSFileManager *fileManager = [NSFileManager defaultManager];
    const bool isExist = [fileManager fileExistsAtPath:filePath];
    
    if (!isExist){
        NSLog(@"%@ not exist!", filePath);
    }
    
    return isExist;
}

NSString* MSPathForBundleResource(NSBundle* bundle, NSString* relativePath) {
    NSString* resourcePath = [(nil == bundle ? [NSBundle mainBundle] : bundle) resourcePath];
    return [resourcePath stringByAppendingPathComponent:relativePath];
}


# pragma mark -
# pragma mark Read and write plist file

NSArray* MSArrayFromMainBundle(NSString *filename){
    NSArray *arrayForReturn = nil;
    NSString *path = MSPathForBundleResource(nil, filename);
    
    if (MSIsFileExistAtPath(path)){
        arrayForReturn = [NSArray arrayWithContentsOfFile:path];
    }
    return arrayForReturn;
}

@interface AlisPluginManager ()

//提供服务的plugin  <value = NSString>
@property(strong,nonatomic)NSMutableDictionary *pluginsServiceDictionary;

//real plugin <value = class>
@property(strong,nonatomic)NSMutableDictionary *pluginsDictionary;

@end

@implementation AlisPluginManager

+ (AlisPluginManager *)manager{
    static id _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    
    return _manager;
}

- (instancetype)init{
    if (self = [super init]) {
        self.pluginsServiceDictionary = [NSMutableDictionary dictionary];
        self.pluginsDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark -- plugin
- (void)registerPlugin:(id<AlisPluginProtocol>)plugin key:(NSString *)key{
    NSAssert(key, @"key should not nil");
    NSAssert(self.pluginsDictionary  || self.pluginsDictionary.count > 0, @"pluginsDictionary has problems");
    
    if (plugin == nil) return;
    //这里应该判断是否有重复的key
    self.pluginsServiceDictionary[key] = plugin;
}

- (void)registerPlugins:(NSDictionary *)pluginsDic{
    if (pluginsDic == nil) return;
    [self.pluginsServiceDictionary addEntriesFromDictionary:pluginsDic];
}

- (void)registerPlugin:(NSString *)key{
}

- (void)removePlugin:(NSString *)key{
    NSParameterAssert(key);
    //[self.pluginsDictionary removeObjectForKey:pluginList];
}

- (NSArray *)allPlugins{
    return [self.pluginsServiceDictionary copy];
}

- (void)registerALLPlugins{
    NSArray *array = MSArrayFromMainBundle(@"plugins.plist");

    NSString *plistPath =  @"/Users/david/Documents/AlisNetworking/AlisNetworking/Classes/plugins.plist";
    
    //NSString *plistPath =  @"../../AlisNetworking/Classes/plugins.plist";
    NSString *plistPath2 = [[NSBundle mainBundle] pathForResource:@"plugins" ofType:@"plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        return;
    }
    
    NSDictionary *pluginList = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    [self.pluginsServiceDictionary addEntriesFromDictionary:pluginList];
    
}

- (id<AlisPluginProtocol>)plugin:(NSString *)key{
    NSAssert(key, @"key should not nil");
    NSAssert(self.pluginsDictionary  || self.pluginsDictionary.count > 0, @"pluginsDictionary has problems");
    //这里应该判断是否有重复的key
    NSArray *keys = self.pluginsDictionary.allKeys;
    
    if ([keys containsObject:key]) {
        if (self.pluginsDictionary[key]) {
            return self.pluginsDictionary[key];
        }
    }
    else{
        NSArray *keys = self.pluginsServiceDictionary.allKeys;
        if (![keys containsObject:key]) return nil;
        
        NSString *pluginString = self.pluginsServiceDictionary[key];
        Class class = NSClassFromString(pluginString);
        id _object = [[class alloc] init];
        
        NSAssert([_object conformsToProtocol:@protocol(AlisPluginProtocol)], @"the plugin do not conform 'AlisPluginProtocol'");
        [self.pluginsDictionary setObject:_object forKey:key];

        return _object;
    }
   
    return nil;
}

@end





