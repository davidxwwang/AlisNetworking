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

//网络请求三方库plugin加载
static NSMutableArray<Class> *NetworkingPluginClassArray;

void NetworkingPluginRegisterModule(Class PluginClass){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NetworkingPluginClassArray = [NSMutableArray array];
    });
    
    if (![PluginClass conformsToProtocol:@protocol(AlisPluginProtocol)]) {
        NSLog(@"%@ is not conform to \"AlisPluginProtocol\" protocol",PluginClass);
        return;
    }
    [NetworkingPluginClassArray addObject:PluginClass];
}

NSArray* GetNetworkingRegisteredPlugins(void){
    return [NetworkingPluginClassArray copy];
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
        @synchronized(self){
             self.pluginsServiceDictionary = [NSMutableDictionary dictionary];
             self.pluginsDictionary = [NSMutableDictionary dictionary];
             [self registerALLPlugins];
        }
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
    self.pluginsServiceDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"AFNetwoking":@"AFNetworkingPlugin",@"SDWebimage":@"SDWebimagePlugin"}];
    return;
    
//    self.pluginsServiceDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"AFNetwoking":@"AFNetworkingPlugin",@"SDWebimage":@"SDWebimagePlugin"}];
//    for (Class className in GetNetworkingRegisteredPlugins()) {
//        
//    }
}

- (id<AlisPluginProtocol>)plugin:(NSString *)key{
    NSAssert(key, @"key should not nil");
    //这里应该判断是否有重复的key
    if (![key isKindOfClass:[NSString class]]) {
        return nil;
    }
    @synchronized(self){
         NSArray *keys = self.pluginsDictionary.allKeys;
         if ([keys containsObject:key] && self.pluginsDictionary[key]) {
             return self.pluginsDictionary[key];
         }
         else{
             NSArray *keys = self.pluginsServiceDictionary.allKeys;
             if (![keys containsObject:key]) return nil;
        
             NSString *pluginString = self.pluginsServiceDictionary[key];
             id _object = [[NSClassFromString(pluginString) alloc] init];
             NSLog(@"生成的对象 %@ ",_object);
             if (![_object conformsToProtocol:@protocol(AlisPluginProtocol)]) {
                 NSLog(@"the plugin do not conform 'AlisPluginProtocol'");
                 return nil;
             }
       
             if (_object && key) {
                 [self.pluginsDictionary setObject:_object forKey:key];
                 return _object;
             }
         }
         return nil;
    }
}

@end





