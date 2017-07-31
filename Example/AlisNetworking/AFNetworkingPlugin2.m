//
//  AFNetworkingPlugin2.m
//  AlisNetworking
//
//  Created by alisports on 2017/7/13.
//  Copyright © 2017年 xingwang.wxw. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import "AFNetworkingPlugin2.h"

@interface AFNetworkingPlugin2()

@property(strong,nonatomic) AFHTTPSessionManager *sessionManager;


@end

@implementation AFNetworkingPlugin2

- (AFHTTPSessionManager *)sessionManager{
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
    }
    return _sessionManager;
}

- (NSString *)plugIdentifier{
    return  NSStringFromClass([self class]);
}

- (BOOL)canHandleProcess:(AEDKProcess *)process{
    return YES;
}

- (void)handleProcess:(AEDKProcess *)process{
    NSError *error = nil;
    NSMutableURLRequest *__request = [process.request copy];
    
//    if (error && request.finishBlock) {
//        AlisError *_error = [self perseError:error];
//        request.finishBlock(request,nil,_error);
//    }
    
    NSURLSessionTask *task = [self.sessionManager dataTaskWithRequest:__request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
//        if (request.progressBlock) {
//            request.progressBlock(request,downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
//        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"finished"  );
        if (process.configuration) {
            process.configuration.ProcessCompleted(@"", @"", @"");
        }
//        if (request.finishBlock) {
//            AlisResponse *response = [self perseResponse:responseObject request:request];
//            AlisError *_error = [self parseError:error response:response];
//            request.finishBlock(request,response,_error);
//        }
    }];

// request.bindRequest = task;
    [task resume];

}

@end
