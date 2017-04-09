//
//  AlisServiceProxy.m
//  PluginsDemo
//
//  Created by alisports on 2017/3/21.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AlisServiceProxy.h"
#import <objc/runtime.h>
#import "AlisRequestManager.h"
#import "service.h"
#import "NSString+help.h"

#define ResumeResource @"resume"
#define CancelResource @"cancel"
#define SuspendResource @"suspend"

//  首先查找订阅的服务（网络接口）
//对资源的操作包括：
//   （1）对资源的操作。
//   （2）取消对资源的操作（资源目前的状态是操作过程中，例如：大文件的下载，上传）
//   （3）暂停对资源的操作
//APP中所有的请求服务都保存在该字典中
static NSDictionary *candidateRequestServices;

void fetchCandidateRequestServices()
{
    if (candidateRequestServices != nil) return;
    NSString *plistPath = @"/Users/david/Documents/AlisNetworking/AlisNetworking/Classes/RequestConfig.plist";
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) return;
    
    NSDictionary *availableRequestServices = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
    candidateRequestServices = [NSDictionary dictionaryWithDictionary:availableRequestServices];
}

void requestContainer(id self, SEL _cmd) {

    NSArray *serviceArray = [NSStringFromSelector(_cmd) componentsSeparatedByString:@"_"];
    if(serviceArray.count != 3){
        NSLog(@"注意：对资源的访问格式有问题");
        return;
    } 
    
    NSString *serviceAction = serviceArray[0];
    NSString *localServiceName = serviceArray[1];
    NSString *currentServiceAgentString = serviceArray[2];
    
    NSDictionary *requestServiceInfo = candidateRequestServices[localServiceName];
    if (requestServiceInfo == nil) {
        NSLog(@"plist 中没有为该服务配置请求服务");
        return;
    }
    //之后的AlisRequest唯一绑定一个serviceName，表示请求为这个网络请求的service服务 
    //注意：globalServiceName 为该服务的唯一全局的识别码
    NSString *globalServiceName = [NSString stringWithFormat:@"%@_%@",currentServiceAgentString,localServiceName];
    
    ServiceType ser= [Service convertServiceTypeFromString:requestServiceInfo[@"protocol"]];
    ServiceAction action= [Service convertServiceActionFromString:serviceAction];
    
    NSDictionary *cc = ((AlisServiceProxy *)self).serviceAgents;
    id currentServiceAgent = cc[currentServiceAgentString];
    
    if( currentServiceAgent == nil){
        NSLog(@"%@ 没有注册服务，请先调用 'injectService' 方法注册服务",currentServiceAgentString);
    }
    
    Service *currentService = [[Service alloc]init:ser serviceName:globalServiceName serviceAction:action serviceAgent:currentServiceAgent];
    
    if (globalServiceName && currentService) {
        ((id<AlisRequestProtocol>)self).currentServeContainer[globalServiceName] = currentService;
    }
    [[AlisRequestManager sharedManager]startRequestModel:self service:currentService];
    
}

@interface AlisServiceProxy ()
@end

@implementation AlisServiceProxy

@synthesize currentServeContainer,candidateServices,businessLayer_requestFinishBlock,businessLayer_requestProgressBlock;

+ (AlisServiceProxy *)shareManager{
    static AlisServiceProxy *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[AlisServiceProxy alloc]init];
        
    });
    return _manager;
}

- (instancetype)init{
    if (self = [super init]) {
        fetchCandidateRequestServices();
        self.serviceAgents = [NSMutableDictionary dictionary];
        __weak typeof (self) weakSelf = self;
        self.businessLayer_requestFinishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
            NSLog(@"在业务层完成了请求成功的回调");
            if (error) {
                NSLog(@"失败了:原因->");
                [weakSelf handlerServiceResponse:request serviceName:request.serviceName error:error];
            }
            else{
                if ([request.context.makeRequestClass respondsToSelector:@selector(handlerServiceResponse:serviceName:response:)]) {
                    NSString *name = request.serviceName;
                    
                    [request.context.makeRequestClass handlerServiceResponse:request serviceName:[request.serviceName toLocalServiceName] response:response];
                }
            }
        };
        
        self.businessLayer_requestProgressBlock = ^(AlisRequest *request ,long long receivedSize, long long expectedSize){
            float progress = (float)(receivedSize)/expectedSize;
            NSLog(@"下载／上传进度---->%f",progress);
            if ([request.context.makeRequestClass respondsToSelector:@selector(handlerServiceResponse:serviceName:progress:)]) {
                [request.context.makeRequestClass handlerServiceResponse:request serviceName:[request.serviceName toLocalServiceName] progress:progress];
            }
        };
        
        self.currentServeContainer = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    NSString *selString = NSStringFromSelector(sel);
    NSString *resourceAction = [selString resourceAction];//对资源的操作
    if (resourceAction ) {
        NSArray *resourceActions = @[ResumeResource,CancelResource,SuspendResource];
        if ([resourceActions containsObject:resourceAction]) {
            class_addMethod([self class], sel, (IMP)requestContainer, "@:");
            return YES;
        }
        else{
            return NO;//[super resolveInstanceMethod:sel];
        }
    }
   
    return NO;//[super resolveInstanceMethod:sel];
}

- (void)injectService:(id<AlisRequestProtocol>)object{
    NSParameterAssert(object);
    NSAssert([object conformsToProtocol:@protocol(AlisRequestProtocol)], @"'object' 需要服从协议");
    
    NSString *classString = NSStringFromClass([object class]);
    _serviceAgents[classString] = object;
}

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName response:(AlisResponse *)response{
}

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName progress:(float)progress{
}

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName error:(AlisError *)error{
}

#pragma mark -- request parameters
- (NSDictionary *)requestHead:(NSString *)serviceName{
    return nil;
}

- (NSData *)uploadData:(NSString *)serviceName{
    return nil;
}

- (NSDictionary *)additionalInfo:(NSString *)serviceName{
    return nil;
}

- (NSString *)fileURL:(NSString *)serviceName{
    return nil;
}

- (NSDictionary *)requestParams:(NSString *)serviceName{
    return nil;
}

- (NSString *)api:(NSString *)serviceName{
    NSString *api = [self getParam:@"api" serviceName:serviceName];
    if (api){
        return api;
    }
    return nil;
}

- (NSString *)server:(NSString *)serviceName{
    NSString *server = [self getParam:@"server" serviceName:serviceName];
    if (server){
        return server;
    }
    return nil;
}


- (AlisRequestType)requestType:(NSString *)serviceName{
    return AlisRequestNormal;
}

- (AlisHTTPMethodType)httpMethod:(NSString *)serviceName{
    NSString *httpMothod = [self getParam:@"httpMethod" serviceName:serviceName];
    if (httpMothod) 
        return AlisHTTPMethodGET;
    
    return AlisHTTPMethodGET;
}

#pragma mark -- help
- (NSString *)getParam:(NSString *)type serviceName:(NSString *)globalServiceName{
    NSParameterAssert(type && globalServiceName);
    
    Service *service = self.currentServeContainer[globalServiceName];
    NSArray *sep = [globalServiceName componentsSeparatedByString:@"_"];
    
    if (sep.count < 2 || sep == nil) {
        NSLog(@"service.serviceName 有问题");
        return nil;
    }
    
    NSString *resourceName = sep[1];
    
    NSDictionary *agentServiceActionKeys = candidateRequestServices[resourceName];
    NSString *value = agentServiceActionKeys[type];
    return value;
    
}

#pragma mark --
//- (id)forwardingTargetForSelector:(SEL)aSelector
//{
//    return nil;
//}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    //    NSString *selString = NSStringFromSelector(sel);
    //    if ([selString containsString:@"resume_"]) {
    //        class_addMethod([self class], sel, (IMP)requestContainer1, "@:");
    //        
    //    }
    //
    //    for (id object in self.agents) {
    //        if ([object respondsToSelector:sel]) {
    //            return [object methodSignatureForSelector:sel];
    //        }
    //    }
    return [super methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    //    for (id object in self.agents) {
    //        if ([object respondsToSelector:invocation.selector]) {
    //            [invocation invokeWithTarget:object];
    //            return;
    //        }
    //    }
    [super forwardInvocation:invocation];
}


@end

