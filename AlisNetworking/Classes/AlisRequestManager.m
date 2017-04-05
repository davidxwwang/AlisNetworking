//
//  AlisRequestManager.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "AlisRequestManager.h"
#import "AlisRequestContext.h"
#import "AlisRequestConfig.h"
#import "AlisPluginManager.h"
#import "AlisRequestConst.h"
#import "Service.h"
#import "AlisRequestManager+AlisRequest.h"

#define ALIS_SAFE_BLOCK(BlockName, ...) ({ !BlockName ? nil : BlockName(__VA_ARGS__); })

@interface AlisRequestManager ()

@property(weak,nonatomic) id<AlisRequestProtocol>requestModel;

@property(strong,nonatomic)AlisPluginManager *pluginManager;

@end

@implementation AlisRequestManager

+ (AlisRequestManager *)sharedManager
{
    static id _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    
    return _manager;
}

+ (AlisRequestManager *)manager{
    return [[[self class]alloc] init];
}

- (instancetype)init{
    if (self = [super init]) {
        self.requestContext = [AlisRequestContext shareContext];
        self.pluginManager = [AlisPluginManager manager];
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

#pragma mark -- config
- (void)setupConfig:(void (^)(AlisRequestConfig *config))block
{
    AlisRequestConfig *__config = [[AlisRequestConfig alloc]init];
    block(__config);
    self.config = __config;
    
}

- (void)startRequest:(AlisRequest *)request
{
    id<AlisPluginProtocol> plugin = [self.pluginManager plugin:@"AFNetwoking"];
    if (plugin == nil) {
        NSLog(@"对应的插件不存在！");
        return;
    }
    
    //在这里解析两部分，一部分是公共的--AlisRequestConfig，一部分是自己的,
    [plugin perseRequest:request config:_config];
    //设置请求的MD5值。注：可以有其他方式
    request.identifier = [self md5WithString:request.url];
    NSString *requestIdentifer = request.context.serviceName;
    if (requestIdentifer) {
        (self.requestSet)[requestIdentifer] = request;
    }
    else{
        NSLog(@"warning: 请求资源的名称不能为空");
    }
}

- (void)startRequestModel:(id<AlisRequestProtocol>)requestModel{
    // if (![self canRequest:requestModel]) return;
    //request 请求的回调都在该类中
    ServiceAction serviceAction = requestModel.currentService.serviceAction;
    if (serviceAction == Resume) {
        [self start_Request:^(AlisRequest *request) {
            request.bindRequestModel = requestModel; //绑定业务层对应的requestModel
            request.serviceName = requestModel.currentService.serviceName;
            [self prepareRequest:request requestModel:requestModel];
            //如果是同步请求
            if (self.config.enableSync) {
                dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
            }
            
        }];
    }
    else if (serviceAction == Cancel){
        [self cancelRequestByIdentifier:requestModel.currentService.serviceName];
    }
}

- (void)startRequestModel:(id<AlisRequestProtocol>)requestModel service:(Service *)service{
    // if (![self canRequest:requestModel]) return;
    //request 请求的回调都在该类中
    ServiceAction serviceAction = service.serviceAction;
    if (serviceAction == Resume) {
        [self start_Request:^(AlisRequest *request) {
            request.bindRequestModel = requestModel; //绑定业务层对应的requestModel
            request.serviceName = service.serviceName;
            [self prepareRequest:request requestModel:requestModel service:service];
            //如果是同步请求
            if (self.config.enableSync) {
                dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
            }
        }];
    }
    else if (serviceAction == Cancel){
        [self cancelRequestByIdentifier:service.serviceName];
    }
}

- (void)start_Request:(AlisRequestConfigBlock)requestConfigBlock{
    AlisRequest *request = [[AlisRequest alloc]init];
    requestConfigBlock(request);
    [self startRequest:request];
}

- (NSMutableDictionary *)requestSet{
    if (_requestSet == nil) {
        _requestSet = [NSMutableDictionary dictionary];
    }
    return _requestSet;
}

- (void)cancelRequest:(AlisRequest *)request{
    if (request == nil)  return;
    if(request.bindRequest){
        [request.bindRequest cancel];
        [self.requestSet removeObjectForKey:request.bindRequestModel.currentService.serviceName];
    }    
}

- (void)cancelRequestByIdentifier:(NSString *)requestIdentifier{
    if (requestIdentifier == nil)  return;
    AlisRequest *request = _requestSet[requestIdentifier];
    [self cancelRequest:request];
    
}

#pragma mark ---
//访问网络前的最后准备，准备好请求地址，头head，参数parameters，body，url，回调方法等等
- (void)prepareRequest:(AlisRequest *)request requestModel:(id<AlisRequestProtocol>)requestModel service:(Service *)service{
    [self adapteAlisRequest:request requestModel:requestModel service:service];
}

//访问网络前的最后准备，准备好请求地址，头head，参数parameters，body，url，回调方法等等
- (void)prepareRequest:(AlisRequest *)request requestModel:(id<AlisRequestProtocol>)requestModel{
    
    // NSAssert([requestModel respondsToSelector:@selector(api)], @"request API should not nil");
    
    if ([requestModel respondsToSelector:@selector(requestType)]) {
        request.requestType = [requestModel requestType];
    }
    
    if ([requestModel respondsToSelector:@selector(httpMethod)]) {
        request.httpMethod = [requestModel httpMethod];
    }
    
    NSString *urlString = nil;//[NSMutableString string];
    if (request.server) {
        if ([requestModel respondsToSelector:@selector(api)]) {
            urlString = [NSString stringWithFormat:@"%@%@",request.server,[requestModel api]];
        }
    }else if (request.useGeneralServer == YES){
        if ([requestModel respondsToSelector:@selector(api)]) {
            urlString = [NSString stringWithFormat:@"%@%@",_config.generalServer,[requestModel api]];
        }
    }else if(request.url){
        urlString = request.url;
    }
    
    NSAssert(urlString, @"url should not nil");
    request.url = urlString;//[requestModel url];
    
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    
    if ([requestModel respondsToSelector:@selector(requestHead)]) {
        [header addEntriesFromDictionary:[requestModel requestHead]];
    }
    if (request.useGeneralHeaders) {
        [header addEntriesFromDictionary:self.config.generalHeader];
    }
    
    
    if ([requestModel respondsToSelector:@selector(requestParams)]) {
        [parameters addEntriesFromDictionary:[requestModel requestParams]];
    }
    if (request.useGeneralParameters) {
        [parameters addEntriesFromDictionary:self.config.generalParamters];
    }
    
    request.header = header;
    request.parameters = parameters;
    
    //请求的回调
    request.finishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
        if(self.config.enableSync){
            dispatch_semaphore_signal(_semaphore);
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
}


- (void)failureWithError:(AlisError *)error withRequest:(AlisRequest *)request{
    __weak typeof (request) weakRequest = request;
    if (self.config.callBackQueue) {
        dispatch_async(self.config.callBackQueue, ^{
            weakRequest.bindRequestModel.businessLayer_requestFinishBlock(request,nil,error);
        });
    } 
    else {
        weakRequest.bindRequestModel.businessLayer_requestFinishBlock(request,nil,error);
    }
    
    if (request.retryCount > 0 ) {
        request.retryCount --;
        [self startRequest:request];
    }
    
}

- (void)successWithResponse:(AlisResponse *)response withRequest:(AlisRequest *)request
{
    __weak typeof (request) weakRequest = request;
    if (self.config.callBackQueue) {
        dispatch_async(self.config.callBackQueue, ^{
            weakRequest.bindRequestModel.businessLayer_requestFinishBlock(request,response,nil);
        });
    } 
    else{
        weakRequest.bindRequestModel.businessLayer_requestFinishBlock(request,response,nil);
    }
    
    // [self clearBlocks:request];
    //请求成功，删除请求
    [self.requestSet removeObjectForKey:request.bindRequestModel.currentService.serviceName];
}

- (void)clearBlocks:(AlisRequest *)request{
    request.finishBlock = nil;
    request.progressBlock = nil;
    request.cancelBlock = nil;
    request.startBlock = nil;
}
#pragma mark -- help
//如果网络出现问题，返回失败
- (BOOL)canRequest:(id<AlisRequestProtocol>)requestModel{
    
    if (self.requestContext.networkReachabilityStatus == AlisNetworkReachabilityStatusNotReachable) {
        AlisError *_error = [[AlisError alloc]init];
        _error.name = @"NO_Network";
        _error.detailInfo = @"无网络连接";
        requestModel.businessLayer_requestFinishBlock(nil,nil,_error);
        return NO;
    }
    
    return YES;
}

/**
 计算MD5
 
 @param string string description
 @return return value description
 */
- (NSString *)md5WithString:(NSString *)string {
    NSAssert(string, @"string should not nil");
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (unsigned int) strlen(cStr), result);
    
    NSString *md5String = [NSString stringWithFormat:
                           @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    
    return md5String;
}

#pragma mark -- https
- (void)addSSLPinningURL:(NSString *)url {
    NSParameterAssert(url);
    
//    if ([url hasPrefix:@"https"]) {
//        NSString *rootDomainName = [self xm_rootDomainNameFromURL:url];
//        if (rootDomainName && ![self.sslPinningHosts containsObject:rootDomainName]) {
//            [self.sslPinningHosts addObject:rootDomainName];
//        }
//    }
}

- (void)addSSLPinningCert:(NSData *)cert {
    NSParameterAssert(cert);
    
//    NSMutableSet *certSet;
//    if (self.securitySessionManager.securityPolicy.pinnedCertificates.count > 0) {
//        certSet = [NSMutableSet setWithSet:self.securitySessionManager.securityPolicy.pinnedCertificates];
//    } else {
//        certSet = [NSMutableSet set];
//    }
//    [certSet addObject:cert];
//    [self.securitySessionManager.securityPolicy setPinnedCertificates:certSet];
}

#pragma mark -- chainRequest
- (void)sendChainRequest:(AlisChainRConfigBlock )chainRequestConfigBlock success:(AlisChainRSucessBlock)success failure:(AlisChainRFailBlock)failure finish:(AlisChainRFinishedBlock)finish{
    
    AlisChainRequest *chainRequest = [[AlisChainRequest alloc]initWithBlocks:success failure:failure finish:finish];
    if (chainRequestConfigBlock) {
        //设置chainRequest
        chainRequestConfigBlock(chainRequest);
    }
    [self sendChainRequest:chainRequest];
}


/**
 该方法负责将AlisRequest一个一个发送
 @param chainRequest  chainRequest
 */
- (void)sendChainRequest:(AlisChainRequest *)chainRequest{
    if (chainRequest.runningRequest) {
        id<AlisPluginProtocol> plugin = [self.pluginManager plugin:@"AFNetwoking"];
        //在这里解析两部分，一部分是公共的--AlisRequestConfig，一部分是自己的,
        __weak AlisRequestManager *weakSelf = self;
        [self prepareRequest:chainRequest.runningRequest onProgress:^(AlisRequest *request, long long receivedSize, long long expectedSize) {
        } onSuccess:nil 
          onFailure:^(AlisRequest *request, AlisResponse *response, AlisError *error) {
              [weakSelf handerResponse:chainRequest request:request response:response error:error];      
        } onFinished:^(AlisRequest *request, AlisResponse *response, AlisError *error) {
             [weakSelf handerResponse:chainRequest request:request response:response error:error]; 
        }];
        
        //在这里解析两部分，一部分是公共的--AlisRequestConfig，一部分是自己的,
        [plugin perseRequest:chainRequest.runningRequest config:_config];
        //设置请求的MD5值。注：可以有其他方式
        chainRequest.runningRequest.identifier = [self md5WithString:chainRequest.runningRequest.url];
        NSString *requestIdentifer = chainRequest.runningRequest.context.serviceName;
//        if (requestIdentifer) {
//            (self.requestSet)[requestIdentifer] = request;
//        }
//        else{
//            NSLog(@"warning: 请求资源的名称不能为空");
//        }

    }
}

/**
 AlisRequest 请求回来的处理
 @param chainRequest chainRequest
 @param request 单个请求
 @param response 单个请求的回复
 @param error 单个请求回复的错误
 */
- (void)handerResponse:(AlisChainRequest *)chainRequest request:(AlisRequest *)request response:(AlisResponse *)response error:(AlisError *)error{
    if([chainRequest onFinishedOneRequest:request response:response error:error]){
        NSLog(@"AlisChainRequest中单个AlisRequest请求成功");
        //请求全部完成
    }
    else{
         NSLog(@"AlisChainRequest中单个AlisRequest请求失败");
        //请求还没有完全完成
        if(chainRequest.runningRequest){
            [self sendChainRequest:chainRequest];
        }
    }  
}

- (void)prepareRequest:(AlisRequest *)request
            onProgress:(AlisRequestProgressRequest)progressBlock
             onSuccess:(AlisRequestFinishRequest)successBlock
             onFailure:(AlisRequestFinishRequest)failureBlock
            onFinished:(AlisRequestFinishRequest)finishedBlock {
    
    if (progressBlock) {
        request.progressBlock = progressBlock;
    }
    
    if (failureBlock) {
        request.finishBlock = failureBlock;
    }
    
    if (finishedBlock) {
        request.finishBlock = finishedBlock;
    }
}

@end

#pragma mark -- AlisChainRequest

@interface AlisChainRequest()
{
    //当前请求的 index
    NSInteger _chainIndex;
}

/**
 得到的response数组
 */
@property(strong,nonatomic)NSMutableArray *responseArray;

/**
 保存下次请求的block，以便前一次请求完成后，设置第二次请求。
 */
@property(strong,nonatomic)NSMutableArray *nextRequestArray;

@property(strong,nonatomic)AlisRequest *runningRequest;


/**
 finish 表示整个请求都结束，success 表示部分成功
 */
@property (nonatomic, copy) AlisChainRSucessBlock chainSuccessBlock;
@property (nonatomic, copy) AlisChainRFailBlock chainFailureBlock;
@property (nonatomic, copy) AlisChainRFinishedBlock chainFinishedBlock;

@end

@implementation AlisChainRequest

- (instancetype)initWithBlocks:(AlisChainRSucessBlock)success
               failure:(AlisChainRFailBlock)failure
                finish:(AlisChainRFinishedBlock)finish{
    self = [super init];
    if (self) {
        _chainIndex = 0;
        _responseArray = [NSMutableArray array];
        _nextRequestArray = [NSMutableArray array];
        
        _chainSuccessBlock = success? success:nil;
        _chainFailureBlock = failure? failure:nil;
        _chainFinishedBlock = finish? finish :nil; 
    }
    return self;
}

- (AlisChainRequest *)onFirst:(AlisRequestConfigBlock)firstBlock{
    NSAssert(firstBlock, @"firstBlock cannot be nil");
    NSAssert(self.nextRequestArray , @"");
    [_responseArray addObject:[NSNull null]];
    _runningRequest = [[AlisRequest alloc]init];
    firstBlock(_runningRequest);
    return self;
}

- (AlisChainRequest *)onNext:(AlisChainNextRBlock)nextBlock{
    NSAssert(nextBlock, @"firstBlock cannot be nil");
    NSAssert(self.nextRequestArray, @"");
    [_responseArray addObject:[NSNull null]];
    [_nextRequestArray addObject:nextBlock];
    return self;
}
/**
 chainRequest每项请求完成都回调
 
 @param request 完成的AlisRequest
 @param responseObject  收到的数据
 @param error error description
 @return YES:表示chain请求全部完成请求， NO:表示还没有都完成
 */
- (BOOL)onFinishedOneRequest:(AlisRequest *)request response:(nullable id)responseObject error:(nullable AlisError *)error{
    BOOL isFinished = NO;
    if (responseObject) {
        //得到第_chainIndex个请求的结果
        [_responseArray replaceObjectAtIndex:_chainIndex withObject:responseObject];
        
        if (_chainIndex < _nextRequestArray.count) {
            _runningRequest = [AlisRequest request];
            AlisChainNextRBlock nextBlock = _nextRequestArray[_chainIndex];
            //设置下一个请求参数
            nextBlock(_runningRequest,responseObject,error);
            
            if (!error) {
                ALIS_SAFE_BLOCK(_chainSuccessBlock,_responseArray);
            }
            else{
                ALIS_SAFE_BLOCK(_chainFailureBlock,_responseArray);
            }
            isFinished = NO;
        }
        else{
            ALIS_SAFE_BLOCK(_chainSuccessBlock,_responseArray);
            ALIS_SAFE_BLOCK(_chainFinishedBlock,_responseArray,nil);
            isFinished = YES;
        }
    }
    else{
        if(error){
            [_responseArray replaceObjectAtIndex:_chainIndex withObject:error];
        }
        if (_chainIndex < _nextRequestArray.count) {
            _runningRequest = [AlisRequest request];
            AlisChainNextRBlock nextBlock = _nextRequestArray[_chainIndex];
            //设置下一个请求参数
            nextBlock(_runningRequest,responseObject,error);
            
            if (!error) {
                ALIS_SAFE_BLOCK(_chainSuccessBlock,_responseArray);
            }
            else{
                ALIS_SAFE_BLOCK(_chainFailureBlock,_responseArray);
            }

            isFinished = NO;
        }
        else{
            ALIS_SAFE_BLOCK(_chainSuccessBlock,_responseArray);
            ALIS_SAFE_BLOCK(_chainFinishedBlock,_responseArray,nil);            
            isFinished = YES;
        }
    }
    
    _chainIndex++;
    return isFinished;
}

@end

