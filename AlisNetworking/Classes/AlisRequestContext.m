//
//  AlisRequestContext.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/24.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AlisRequestContext.h"
#import "AFNetworkReachabilityManager.h"

@implementation AlisRequestContext

+ (AlisRequestContext *)shareContext
{
    static id _context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _context = [[self alloc] init];
    });
    
    return _context;
}

- (instancetype)init{
    if (self = [super init]) {
        [[AFNetworkReachabilityManager  manager] startMonitoring];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkingReachabilityDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
        
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)networkingReachabilityDidChange:(NSNotification *)notification{
    NSDictionary *userinfo = notification.userInfo;
    if (!userinfo || !userinfo[AFNetworkingReachabilityNotificationStatusItem]) return;
    
    NSNumber *status = userinfo[AFNetworkingReachabilityNotificationStatusItem];
    
    self.networkReachabilityStatus = status;
    
    
    //    AFNetworkReachabilityStatus reachStatus = userinfo[AFNetworkingReachabilityNotificationStatusItem];
    //    NSLog(@"");
    
    //    AFNetworkReachabilityStatusUnknown          = -1,
    //    AFNetworkReachabilityStatusNotReachable     = 0,
    //    AFNetworkReachabilityStatusReachableViaWWAN = 1,
    //    AFNetworkReachabilityStatusReachableViaWiFi = 2,
}

@end
