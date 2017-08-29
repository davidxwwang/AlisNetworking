//
//  SDWebImagePlugin2.m
//  AlisNetworking
//
//  Created by alisports on 2017/8/28.
//  Copyright © 2017年 xingwang.wxw. All rights reserved.
//
#import "SDWebImageManager.h"
#import "SDWebImagePlugin2.h"

@implementation SDWebImagePlugin2

- (BOOL)canHandleProcess:(AEDKProcess *)process{
    return YES;
}

- (void)handleProcess:(AEDKProcess *)process{
    
    if (process.configuration == nil) return;
    if (![process.configuration isKindOfClass:[AEDKHttpServiceConfiguration class]])
        return;
    
    AEDKHttpServiceConfiguration *config = (AEDKHttpServiceConfiguration *)(process.configuration);
    
    if (process.configuration.BeforeProcess) {
        process.configuration.BeforeProcess(process);
    }
    
    NSURL *requestURL = process.request.URL;    
    [[SDWebImageManager sharedManager] loadImageWithURL:requestURL options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (config.Processing) {
            config.Processing(expectedSize, receivedSize, nil);
        }
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
//        if (request.finishBlock) {
//            AlisResponse *response = [self perseResponse:image request:request];
//            AlisError *_error = [self perseError:error];
//            request.finishBlock(request,response,_error);
    }];    
}

@end
