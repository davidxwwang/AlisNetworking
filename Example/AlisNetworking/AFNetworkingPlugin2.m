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
    AEDKHttpServiceConfiguration *config = (AEDKHttpServiceConfiguration *)(process.configuration);
    if (! (config.mimeType == AEDKHttpServiceMimeTypeImage)) {
        return YES;
    }
    return NO;
}

- (void)handleProcess:(AEDKProcess *)process{
   
    if (process.configuration == nil) return;
    if (![process.configuration isKindOfClass:[AEDKHttpServiceConfiguration class]])
        return;
    
    AEDKHttpServiceConfiguration *config = (AEDKHttpServiceConfiguration *)(process.configuration);
    
    if (process.configuration.BeforeProcess) {
        process.configuration.BeforeProcess(process);
    }
    AEDKHttpUploadDownloadConfiguration *uploadDownloadConfiguration = config.uploadDownloadConfig;
    
    if (uploadDownloadConfiguration == nil) {
        [self configSessionManager:process];
        NSURLRequest *__request = [self finalURLRequest:process];
        [self normalRequest:process finalRequest:__request];
    }
    else if(uploadDownloadConfiguration.type == AEDKHttpFileUpload) {
        [self upload:uploadDownloadConfiguration process:process];
    }else if (uploadDownloadConfiguration.type == AEDKHttpFileDownload) {
        [self download:uploadDownloadConfiguration process:process];
    }else{
    //todo
    }
    
}

- (void)upload:(AEDKHttpUploadDownloadConfiguration *)uploadConfiguration process:(AEDKProcess *)process{
    
    NSURL *filePath = [NSURL URLWithString:uploadConfiguration.associatedFilePath];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:process.request.URL];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:^(NSProgress *downloadProgress){
        process.configuration.Processing(downloadProgress.totalUnitCount, downloadProgress.completedUnitCount, request);
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
        }
    }];
    [uploadTask resume];
    
}

- (void)download:(AEDKHttpUploadDownloadConfiguration *)downloadConfiguration process:(AEDKProcess *)process{
    NSURL *downloadPath = [NSURL URLWithString:downloadConfiguration.associatedFilePath];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:process.request.URL];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress){
        process.configuration.Processing(downloadProgress.totalUnitCount, downloadProgress.completedUnitCount, request);
    }  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return downloadPath;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
    
    }];
    [downloadTask resume];

}

- (void)normalRequest:(AEDKProcess *)process finalRequest:(NSURLRequest *)finalRequest{
    if (process == nil || finalRequest == nil) return;
    
    NSURLSessionTask *task = [self.sessionManager dataTaskWithRequest:finalRequest uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"finished"  );
        if (process.configuration) {
            id sth =process.configuration.AfterProcess(responseObject);
            process.configuration.ProcessCompleted(process, @"", sth);
        }
    }];
    
    [task resume];
}

- (void)configSessionManager:(AEDKProcess *)process{
    NSMutableURLRequest *__request = [process.request mutableCopy];
    AEDKHttpServiceConfiguration *config = (AEDKHttpServiceConfiguration *)(process.configuration);
    self.sessionManager.requestSerializer.stringEncoding = config.stringEncoding;
    _sessionManager.requestSerializer.timeoutInterval = __request.timeoutInterval;
    _sessionManager.requestSerializer.networkServiceType = __request.networkServiceType;
    _sessionManager.requestSerializer.cachePolicy = __request.cachePolicy;
    NSDictionary *headerInfo = [__request allHTTPHeaderFields];
    if ([headerInfo count] > 0) {
        for (NSString *key in [headerInfo allKeys]) {
            NSString *value = [headerInfo objectForKey:key];
            if (value && [value isKindOfClass:[NSString class]]) {
                [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:key];
            }
        }
    }
}

- (NSURLRequest *)finalURLRequest:(AEDKProcess *)process{
    
    NSMutableURLRequest *__request = [process.request mutableCopy];
    AEDKHttpServiceConfiguration *config = (AEDKHttpServiceConfiguration *)(process.configuration);
    NSError *error = nil;
    NSMutableURLRequest *urlRequest = [_sessionManager.requestSerializer requestWithMethod:__request.HTTPMethod URLString:[[__request URL] absoluteString] parameters:config.requestParameter error:&error];
//    if (error && failure) {
//        failure(urlRequest, error);
//    }
    urlRequest.timeoutInterval = __request.timeoutInterval;
    urlRequest.networkServiceType = urlRequest.networkServiceType;
    urlRequest.cachePolicy = urlRequest.cachePolicy;
    urlRequest.allHTTPHeaderFields = __request.allHTTPHeaderFields;
    //response
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/xml", @"text/html", @"text/plain",nil];
   // [_sessionManager.responseSerializer setRemovesKeysWithNullValues:YES];


    return urlRequest;
}

@end
