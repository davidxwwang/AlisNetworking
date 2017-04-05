//
//  AFNetworkingPlugin.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/24.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AFNetworkingPlugin.h"
#import "AFNetworking.h"
#import "AlisRequest.h"
#import "AlisRequestConfig.h"

@interface AFNetworkingPlugin ()

@property(strong,nonatomic) AFHTTPSessionManager *sessionManager;
@property(strong,nonatomic) AFHTTPSessionManager *securitySessionManager;

@end

@implementation AFNetworkingPlugin

- (void)perseRequest:(AlisRequest *)request config:(AlisRequestConfig *)config{
    [self startRequest:request config:config];
}

- (void)uploadData:(AlisRequest *)request config:(AlisRequestConfig *)config{
    __block NSError *serializationError = nil;
    NSMutableURLRequest *urlRequest = [_sessionManager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:request.url parameters:request.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [request.uploadFormDatas enumerateObjectsUsingBlock:^(AlisUpLoadFormData *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.fileData) {
                [formData appendPartWithFormData:obj.fileData name:obj.name];
            }
            else if (obj.fileURL){
                NSError *fileError = nil;
                [formData appendPartWithFileURL:obj.fileURL name:obj.name error:&fileError];
                if (fileError) {
                    serializationError = fileError;
                    *stop = YES;
                }
            }
        }];
    } error:&serializationError];

    NSURLSessionTask *task2 = [_sessionManager dataTaskWithRequest:urlRequest uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        if (request.progressBlock) {
            request.progressBlock(request,downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"finished"  );
        if (request.finishBlock) {
            AlisResponse *response = [self perseResponse:responseObject request:request];
            AlisError *_error = [self perseError:error];
            request.finishBlock(request,response,_error);
    }}];

    request.bindRequest = task2;
    [task2 resume];

}

- (void)download:(AlisRequest *)request config:(AlisRequestConfig *)config{
    NSString *httpMethod = [self httpMethodConverter:request.httpMethod];
    NSAssert(httpMethod, @"httpMethod can not be nil");
    
    NSError *error = nil;
    NSMutableURLRequest *__request = [_sessionManager.requestSerializer requestWithMethod:httpMethod URLString:request.url parameters:request.parameters error:&error];
    __request.timeoutInterval = request.timeoutInterval;
    __request.allHTTPHeaderFields = request.header;
    
    NSURLSessionDownloadTask *downloadtask = [_sessionManager downloadTaskWithRequest:__request progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *__path = [NSString stringWithFormat:@"%@%@",@"file://localhost/",request.downloadPath];
        return [NSURL URLWithString:__path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
    }];
    
    request.bindRequest = downloadtask;
    [downloadtask resume];
    
}

- (void)normalRequest:(AlisRequest *)request config:(AlisRequestConfig *)config{
    NSString *httpMethod = [self httpMethodConverter:request.httpMethod];
    NSAssert(httpMethod, @"httpMethod can not be nil");
    
    NSError *error = nil;
    NSMutableURLRequest *__request = [_sessionManager.requestSerializer requestWithMethod:httpMethod URLString:request.url parameters:request.parameters error:&error];
    __request.timeoutInterval = request.timeoutInterval;
    __request.allHTTPHeaderFields = request.header;

    
    if (error && request.finishBlock) {
        AlisError *_error = [self perseError:error];
        request.finishBlock(request,nil,_error);
    }
    
    NSURLSessionTask *task = [_sessionManager dataTaskWithRequest:__request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        if (request.progressBlock) {
            request.progressBlock(request,downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"finished"  );
        if (request.finishBlock) {
            AlisResponse *response = [self perseResponse:responseObject request:request];
            AlisError *_error = [self perseError:error];
            request.finishBlock(request,response,_error);
        }
        
    }];
    
    request.bindRequest = task;
    [task resume];

}

- (void)initSessionManager:(AlisRequest *)request{
    
    AFHTTPSessionManager *sessionManager = [self getSessionmanager:request];
     
    sessionManager.requestSerializer.timeoutInterval = request.timeoutInterval;
    sessionManager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    
    //response
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/xml", @"text/html", @"text/plain",@"video/mp4",nil];
    [(AFJSONResponseSerializer *)sessionManager.responseSerializer setRemovesKeysWithNullValues:YES];

    NSDictionary *headerInfo = request.header;
    if ([headerInfo count] > 0) {
        for (NSString *key in [headerInfo allKeys]) {
            NSString *value = [headerInfo objectForKey:key];
            if (value && [value isKindOfClass:[NSString class]]) {
                [sessionManager.requestSerializer setValue:value forHTTPHeaderField:key];
            }
        }
    }
    
   self.sessionManager = sessionManager;
}

- (void)startRequest:(AlisRequest *)request config:(AlisRequestConfig *)config
{
    [self initSessionManager:request];
    //上传任务 下载任务 一般任务
    if (request.requestType == AlisRequestUpload) {
        [self uploadData:request config:config];
    }else if (request.requestType == AlisRequestDownload) {
        [self download:request config:config];
    }else if (request.requestType == AlisRequestNormal) {
        [self normalRequest:request config:config];
    }
}

- (AlisResponse *)perseResponse:(id)rawResponse request:(AlisRequest *)request
{
    if ( !rawResponse ) {
        return nil;
    }
    NSDictionary *data = (NSDictionary *)rawResponse;
    AlisResponse *response = [[AlisResponse alloc]initWithInfo:data];
    return response;

//    if ( !rawResponse || ![rawResponse isKindOfClass:[UIImage class]]) {
//        return nil;
//    }
//    NSDictionary *data = @{@"image":rawResponse};
//    AlisResponse *response = [[AlisResponse alloc]initWithInfo:data];
//    return response;
}

- (AlisError *)perseError:(id)rawError
{
    if (!rawError || ![rawError isKindOfClass:[NSError class]]) {
        return nil;
    }
    
    AlisError *_error = [[AlisError alloc]init];
    _error.code = ((NSError *)rawError).code;
    _error.name = ((NSError *)rawError).domain;
    _error.userInfo = ((NSError *)rawError).userInfo;
    return _error;
}

#pragma mark -- help
- (NSString *)httpMethodConverter:(AlisHTTPMethodType)HTTPMethodType{
    if (HTTPMethodType == AlisHTTPMethodGET) {
        return @"GET";
    }else if (HTTPMethodType == AlisHTTPMethodPOST) {
        return @"POST";
    }else if (HTTPMethodType == AlisHTTPMethodGET) {
        return @"GET";
    }else if (HTTPMethodType == AlisHTTPMethodHEAD) {
        return @"HEAD";
    }else if (HTTPMethodType == AlisHTTPMethodDELETE) {
        return @"DELETE";
    }else if (HTTPMethodType == AlisHTTPMethodPUT) {
        return @"PUT";
    }else if (HTTPMethodType == AlisHTTPMethodPATCH) {
        return @"PATCH";
    }
    
    return nil;
}

- (BOOL)shouleSSLPinningWithURL:(NSString *)url{
    return NO;
}

- (AFHTTPSessionManager *)getSessionmanager:(AlisRequest *)request{
    if ([self shouleSSLPinningWithURL:request.url]) {
        return self.securitySessionManager;
    }
    else{
        return self.sessionManager;
    }
}


- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
//        _sessionManager.requestSerializer = self.afHTTPRequestSerializer;
//        _sessionManager.responseSerializer = self.afHTTPResponseSerializer;
        _sessionManager.operationQueue.maxConcurrentOperationCount = 5;
   //     _sessionManager.completionQueue = xm_request_completion_callback_queue();
    }
    return _sessionManager;
}

- (AFHTTPSessionManager *)securitySessionManager {
    if (!_securitySessionManager) {
        _securitySessionManager = [AFHTTPSessionManager manager];
//        _securitySessionManager.requestSerializer = self.afHTTPRequestSerializer;
//        _securitySessionManager.responseSerializer = self.afHTTPResponseSerializer;
        _securitySessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        _securitySessionManager.operationQueue.maxConcurrentOperationCount = 5;
   //     _securitySessionManager.completionQueue = xm_request_completion_callback_queue();
    }
    return _securitySessionManager;
}


@end



