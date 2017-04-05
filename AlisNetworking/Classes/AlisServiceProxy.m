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

//  首先查找订阅的服务（网络接口）
//对资源的操作包括：
//   （1）对资源的操作。
//   （2）取消对资源的操作（资源目前的状态是操作过程中，例如：大文件的下载，上传）
//   （3）暂停对资源的操作
//APP中所有的请求服务都保存在该字典中
static NSDictionary *candidateRequestServices;

void fetchCandidateRequestServices1()
{
    if (candidateRequestServices != nil) return;
    NSString *plistPath = @"/Users/david/Documents/AlisNetworking/AlisNetworking/Classes/RequestConfig.plist";
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) return;
    
    NSDictionary *availableRequestServices = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
    candidateRequestServices = [NSDictionary dictionaryWithDictionary:availableRequestServices];
}

void requestContainer(id self, SEL _cmd) {
    //当前服务的类
    id<AlisRequestProtocol> currentServiceAgent = nil;    
    
    if ([self isKindOfClass:[AlisServiceProxy class]]) {
        currentServiceAgent = ((AlisServiceProxy *)self).currentServiceAgent;
        if (currentServiceAgent == nil) {
            NSLog(@"服务的类不存在，请检查");
            return;
        }
    }
    
    NSString *currentServiceAgentString = NSStringFromClass([currentServiceAgent class]);
    NSDictionary *agentRequestServices = candidateRequestServices[currentServiceAgentString];
    if (agentRequestServices == nil) {
        NSLog(@"plist 中没有为 配置请求服务");
        return;
    }
    // NSDictionary *requestServices = ((id<AlisRequestProtocol>)self).candidateServices;
    
    NSArray *serviceArray = [NSStringFromSelector(_cmd) componentsSeparatedByString:@"_"];
    if(serviceArray.count < 2) return;
    
    NSString *serviceAction = serviceArray[0];
    NSString *localServiceName = serviceArray[1];
    
    //如果该类的服务项目不包括该项服务,就终止请求
    //消息转发过来,如果requestServices = nil，从注册的地方在查找
    if (![[agentRequestServices allKeys] containsObject:localServiceName]){
        NSLog(@"在plist中没有为该服务配置对应的数据");
        return;
    } 
    
    //之后的AlisRequest唯一绑定一个serviceName，表示请求为这个网络请求的service服务 
    //注意：globalServiceName 为该服务的唯一全局的识别码
    NSString *globalServiceName = [NSString stringWithFormat:@"%@_%@",NSStringFromClass([currentServiceAgent class]),localServiceName];
    
    // 这个好像做成属性不太好，因为是实时变化的
    NSDictionary* serviceType = agentRequestServices[localServiceName];
    ServiceType ser= [Service convertServiceTypeFromString:serviceType[@"protocol"]];
    ServiceAction action= [Service convertServiceActionFromString:serviceAction];
    
    ((id<AlisRequestProtocol>)self).currentService = [[Service alloc]init:ser serviceName:globalServiceName serviceAction:action serviceAgent:currentServiceAgent];
    
    [[AlisRequestManager sharedManager]startRequestModel:self service: ((id<AlisRequestProtocol>)self).currentService];
    
}

@interface AlisServiceProxy ()
/**
 委托者
 */
@property(strong,nonatomic)NSMutableDictionary *serviceAgents;

@end

@implementation AlisServiceProxy

@synthesize currentService,candidateServices,businessLayer_requestFinishBlock,businessLayer_requestProgressBlock;

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
        fetchCandidateRequestServices1();
        self.serviceAgents = [NSMutableDictionary dictionary];
        __weak typeof (self) weakSelf = self;
        self.businessLayer_requestFinishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
            NSLog(@"在业务层完成了请求成功的回调");
            if (error) {
                NSLog(@"失败了:原因->");
                if ([request.context.makeRequestClass respondsToSelector:@selector(handlerServiceResponse:serviceName:error:)]) {
                    [request.context.makeRequestClass handlerServiceResponse:request serviceName:nil response:response];
                }
            }
            else{
                if ([request.context.makeRequestClass respondsToSelector:@selector(handlerServiceResponse:serviceName:response:)]) {
                    [request.context.makeRequestClass handlerServiceResponse:request serviceName:nil response:response];
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
    }
    return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    NSString *selString = NSStringFromSelector(sel);
    if ([selString containsString:@"resume_"]) {
        class_addMethod([self class], sel, (IMP)requestContainer, "@:");
        return YES;
    }
    else{
        return NO;//[super resolveInstanceMethod:sel];
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

#pragma mark -- request parameters
- (NSDictionary *)requestHead{
    return nil;
}
- (NSData *)uploadData{
    return nil;
}

- (NSDictionary *)additionalInfo:(NSString *)serviceName{
    return nil;
}

- (NSString *)fileURL{
    return nil;
}

- (NSDictionary *)requestParams{
    return nil;
}

- (NSString *)api{
    NSString *api = [self getParam:@"api"];
    if (api){
        return api;
    }
    return AlisHTTPMethodGET;
}

- (AlisRequestType)requestType:(NSString *)serviceName{
    return AlisRequestNormal;
}

- (AlisHTTPMethodType)httpMethod{
    NSString *httpMothod = [self getParam:@"httpMethod"];
    if (httpMothod) 
        return AlisHTTPMethodGET;
    
    return AlisHTTPMethodGET;
}

#pragma mark -- help
- (NSString *)getParam:(NSString *)type{
    if (type == nil) return nil;
    
    Service *service = self.currentService;
    NSArray *sep = [service.serviceName componentsSeparatedByString:@"_"];
    
    if (sep.count < 2 || sep == nil) {
        NSLog(@"service.serviceName 有问题");
        return nil;
    }
    
    NSString *agentClass = sep[0];
    NSString *agentServiceAction = sep[1];
    
    NSDictionary *agentClassKeys = candidateRequestServices[agentClass];
    NSDictionary *agentServiceActionKeys = agentClassKeys[agentServiceAction];
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

