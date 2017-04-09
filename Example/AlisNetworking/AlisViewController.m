//
//  AlisViewController.m
//  AlisNetworking
//
//  Created by xingwang.wxw on 04/05/2017.
//  Copyright (c) 2017 xingwang.wxw. All rights reserved.
//
#import "AlisJsonParseProtocol.h"
#import "AlisJsonParseManager.h"
#import "CityInfo.h"
#import "AlisPluginManager.h"
#import "AlisRequestManager.h"
#import "AlisServiceProxy.h"
#import "AlisViewController.h"

static NSString *testServer = @"http://baobab.wdjcdn.com";
static NSString *testApi = @"/1442142801331138639111.mp4";

@interface AlisViewController ()<AlisRequestProtocol>
@end

@implementation AlisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AlisServiceProxy shareManager] injectService:self];
    [[AlisPluginManager manager]registerALLPlugins];
    [[AlisRequestManager sharedManager] setupConfig:^(AlisRequestConfig *config) {
        config.generalServer = testServer;
        config.callBackQueue = dispatch_queue_create("david", DISPATCH_QUEUE_CONCURRENT);
        config.enableSync = NO;
        // config.generalHeader = @{@"xx":@"yy"};
        
    }];
    
   
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, 100, 50)];
    [button setTitle:@"链式请求" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(chainRequest) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button2 = [[UIButton alloc]initWithFrame:CGRectMake(100, 200, 100, 50)];
    [button2 setTitle:@"一般请求" forState:UIControlStateNormal];
    button2.backgroundColor = [UIColor redColor];
    [self.view addSubview:button2];
    [button2 addTarget:self action:@selector(normalRequest) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button3 = [[UIButton alloc]initWithFrame:CGRectMake(200, 200, 100, 50)];
    [button3 setTitle:@"取消一般请求" forState:UIControlStateNormal];
    button3.backgroundColor = [UIColor redColor];
    [self.view addSubview:button3];
    [button3 addTarget:self action:@selector(cancelNormalRequest) forControlEvents:UIControlEventTouchUpInside];

}

- (void)normalRequest{
   // resumeService(@"AskDemo");
    resumeService(@"AskCitieslist");
    // resumeService(@"uploadData");
}

- (void)cancelNormalRequest{
    suspendService(@"uploadData");
}

- (void)chainRequest{
    
    [[AlisRequestManager sharedManager]sendChainRequest:^( AlisChainRequest *manager){
        [[[manager onFirst:^(AlisRequest *request) {
            request.url = @"https://httpbin.org/get";
            request.httpMethod = AlisHTTPMethodGET;
            request.parameters = @{@"method": @"get"};            
        }] onNext:^(AlisRequest *request, id  _Nullable responseObject, AlisError *error) {
            //上一次的请求结果，在responseObject中
            NSLog(@"此时第一个请求返回结果了，可以依据它，设置第二个请求");
            request.url = @"https://httpbin.org/post";
            request.httpMethod = AlisHTTPMethodGET;
            request.parameters = @{@"method": @"post"};
        }]onNext:^(AlisRequest *request, id  _Nullable responseObject, AlisError *error) {
            //上一次的请求结果，在responseObject中
            NSLog(@"此时第一个请求返回结果了，可以依据它，设置第二个请求");
            request.url = @"https://httpbin.org/put";
            request.httpMethod = AlisHTTPMethodPUT;
            request.parameters = @{@"method": @"put"};
        }];
        
    } success:^(NSArray *__nullable responseArray) {
        NSLog(@"success");
        
    } failure:^(NSArray * __nullable errorArray) {
        NSLog(@"failure");
        
    } finish:^(NSArray * _Nonnull responseArray ,NSArray * __nullable errorArray) {
        NSLog(@"链式请求结束了 不容易啊");
    }]; 
}

#pragma mark -- http 
- (AlisRequestType)requestType:(NSString *)serviceName{
    if (ServiceEqual(serviceName, @"AskDemo")) {
        return AlisRequestNormal;
    }else if (ServiceEqual(serviceName, @"AskCitieslist")) {
        return AlisRequestNormal;
    }
    return AlisRequestDownload;
}

//- (NSString *)server:(NSString *)serviceName{
////    if (ServiceEqual(serviceName, @"AskDemo")) {
////        return @"https://httpbin.org";
////    }
//    if (ServiceEqual(serviceName, @"AskDemo")) {
//        return @"https://api-testesports.alisports.com";
//    }
//    return nil;
//}
//
//- (NSString *)api:(NSString *)serviceName{
//    if (ServiceEqual(serviceName, @"AskDemo")) {
//        return @"/v4/gym/citieslist";//@"/get";
//    }
//    return nil;
//}
//
//- (NSDictionary *)requestParams:(NSString *)serviceName{
//    if (ServiceEqual(serviceName, @"AskDemo")) {
//        return @{@"method": @"get"};
//    }
//    return nil;
//}

//- (NSData *)uploadData:(NSString *)serviceName{
//    NSData *data = [@"testdata" dataUsingEncoding:NSUTF8StringEncoding];
//    return data;
//}
//
- (NSString *)fileURL:(NSString *)serviceName{
    if (ServiceEqual(serviceName, @"AskDemo")) {
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *realPath = [NSString stringWithFormat:@"%@%@",path,@"/demo.mp4"];
        return realPath;
    }else if (ServiceEqual(serviceName, @"uploadData")) {
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *realPath = [NSString stringWithFormat:@"%@%@",path,@"/demo.mp4"];
        NSString *__path = [NSString stringWithFormat:@"%@%@",@"file://localhost/",realPath];
        return __path;
    }
    return nil;
}
//
////附加消息
//- (NSDictionary *)additionalInfo:(NSString *)serviceName{
//    return nil;
//}

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName response:(AlisResponse *)response{
    if (ServiceEqual(serviceName, @"AskDemo")) { 
    }
      request.parseClass = @"CityInfo";
    AlisJsonParseManager *manager = [AlisJsonParseManager sharedManager];
    id<AlisJsonParseProtocol> plugin = [manager plugin:@"EXTensionParse"];
    id demo = [plugin parseJsonValue:NSClassFromString(request.parseClass) jsonData:response.responseInfo ];
    NSLog(@"%@ back",serviceName);
}

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName progress:(float)progress{
    if (ServiceEqual(serviceName, @"AskDemo")) {
    }
    
    NSLog(@"%@ back",serviceName);
}

@end

