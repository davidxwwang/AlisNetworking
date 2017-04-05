//
//  AlisRequestManager+AlisRequest.m
//  PluginsDemo
//
//  Created by alisports on 2017/3/24.
//  Copyright © 2017年 alisports. All rights reserved.
//

/**
 按照转过来的参数，组装AlisRequest

 @param AlisRequest 
 @return 
 
 */
#import "Service.h"
#import "AlisRequestManager+AlisRequest.h"

@implementation AlisRequestManager (AlisRequest)

- (AlisRequest *)adapteAlisRequest:(AlisRequest *)request requestModel:(id<AlisRequestProtocol>)requestModel service:(Service *)service{
    //设置请求的上下文
    request.context.makeRequestClass = service.serviceAgent;
    request.context.serviceName = service.serviceName;
    
    // NSAssert([requestModel respondsToSelector:@selector(api)], @"request API should not nil");
    /***************************设置请求类型（上传／下载等）**************************/
    if ([service.serviceAgent respondsToSelector:@selector(requestType)]) {
        request.requestType = [service.serviceAgent requestType];
    }
    
    if (request.requestType == AlisRequestUnknow) {
        if ([requestModel respondsToSelector:@selector(requestType)]) {
            request.requestType = [requestModel requestType];
        }else{
            NSLog(@"'requestType' 没有设置，默认在AlisRequest中设置");
        }
    }
    
    /***************************为上传，下载配置下载存储／上传源地址，数据）**************************/
    if (request.requestType == AlisRequestDownload) {
        if ([service.serviceAgent respondsToSelector:@selector(fileURL)]) {
            request.downloadPath = [service.serviceAgent fileURL];
        }else if ([requestModel respondsToSelector:@selector(fileURL)]) {
            request.downloadPath = [requestModel fileURL];
        }
        if(request.downloadPath == nil){
            NSLog(@"下载任务，没有设置下载的路径!!!");
        }
    }
    else if (request.requestType == AlisRequestUpload) {
        if ([service.serviceAgent respondsToSelector:@selector(fileURL)]) {
            [request addFormDataWithName:@"test1" fileURL:[service.serviceAgent fileURL]];
        }
        
        if ([service.serviceAgent respondsToSelector:@selector(uploadData)]) {
            if ([service.serviceAgent uploadData] != nil) {
               [request addFormDataWithName:@"test2" fileData:[service.serviceAgent uploadData]];
            }
        }
        
        if(request.uploadFormDatas.count == 0){
            NSLog(@"上传任务，上传的内容为空!!!");
        }
    }
    
    /***************************设置请求http方法：get/post etc）**************************/
    if ([service.serviceAgent respondsToSelector:@selector(httpMethod)]) {
        request.httpMethod = [service.serviceAgent httpMethod];
    }
    
    if ((request.httpMethod == AlisHTTPMethodUnknow)) {
        if ([requestModel respondsToSelector:@selector(httpMethod)]) {
            request.httpMethod = [requestModel httpMethod];
        }else{
            NSLog(@"'httpMethod' 没有设置，默认在AlisRequest中设置");
        }
        
    }
    
    /***************************设置请求URL**************************/
    /************************由域名和相对路径组成**********************/
    if ([service.serviceAgent respondsToSelector:@selector(api)]) {
        request.api = [service.serviceAgent api];
    }
    
    if (request.api == nil) {
        if ([requestModel respondsToSelector:@selector(api)]) {
            request.api = [requestModel api];
        }else{
            NSLog(@"'api' 没有设置，这个必须手动设置");
        }
    }
    /***************************设置请求类型（上传／下载等）**************************/
    if ([service.serviceAgent respondsToSelector:@selector(server)]) {
        request.server = [service.serviceAgent server];
    }
    
    if (request.server == nil) {
        if ([requestModel respondsToSelector:@selector(server)]) {
            request.server = [requestModel server];
        }else if (request.useGeneralServer == YES){
            request.server = self.config.generalServer;
        }else{
            NSLog(@"'server' 没有设置，这个必须手动设置");
        }
    }

    NSString *urlString = [NSString stringWithFormat:@"%@%@",request.server,request.api];
    NSAssert(urlString, @"url should not nil");
    request.url = urlString;//[requestModel url];
    
    /***************************设置请求头**************************/
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    if ([service.serviceAgent respondsToSelector:@selector(requestHead)]) {
        if ([service.serviceAgent requestHead]) {
            [header addEntriesFromDictionary:[service.serviceAgent requestHead]];
        }
    }
    if ([requestModel respondsToSelector:@selector(requestHead)]) {
        if ([requestModel requestHead]){ 
            [header addEntriesFromDictionary:[requestModel requestHead]];
        }
    }
    if (request.useGeneralHeaders) {
        if (self.config.generalHeader) {
            [header addEntriesFromDictionary:self.config.generalHeader];
        }
    }
    if (header == nil || header.count == 0){
        NSLog(@"'head' 一无所有");
    }
    request.header = header;
    
    /***************************设置请求参数**************************/
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if ([service.serviceAgent respondsToSelector:@selector(requestParams)]) {
        NSDictionary *params = [service.serviceAgent requestParams];
        if(params){
            [header addEntriesFromDictionary:params];
        }
    }
    if ([requestModel respondsToSelector:@selector(requestParams)]) {
        NSDictionary *params = [requestModel requestParams];
        if(params){
            [header addEntriesFromDictionary:params];
        }
    }
    if (request.useGeneralParameters) {
        NSDictionary *params = self.config.generalParamters;
        if(params){
            [header addEntriesFromDictionary:params];
        }
    }
    if (parameters == nil || parameters.count == 0) {
        NSLog(@"'head' 一无所有");
    }
    request.parameters = parameters;
    
    /***************************设置请求的回调**************************/
    request.finishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
        if(self.config.enableSync){
            dispatch_semaphore_signal(self.semaphore);
        }
        //各个业务层的回调
        if (error) {
            [self failureWithError:error withRequest:request];
        }
        else{
            [self successWithResponse:response withRequest:request];
        }
    };
    
    __weak typeof (request) weakRequest = request;
    request.progressBlock = ^(AlisRequest *request,long long receivedSize, long long expectedSize){
        //各个业务层的回调
        weakRequest.bindRequestModel.businessLayer_requestProgressBlock(request,receivedSize,expectedSize);
    };
    return request;
}
@end
