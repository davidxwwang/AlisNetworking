//
//  AlisViewController.m
//  AlisNetworking
//
//  Created by xingwang.wxw on 04/05/2017.
//  Copyright (c) 2017 xingwang.wxw. All rights reserved.
//
//#import "AlisJsonParsePluginProtocol.h"
/*#import "AlisJsonParseManager.h"
#import "CityInfo.h"
#import "AlisPluginManager.h"
#import "AlisRequestManager.h"
#import "AlisServiceProxy.h"

#import "AlisJsonParserProtocol.h"
#import "UIImageView+AlisRequest.h"
#import "AlisJsonModel.h"
//#import <AEDataKit/AEDataKit.h>
//#import "AEDatakit.h"
#import "PostCodeModel.h"
*/

#import <AlisNetworking/AlisNetworking.h>


#import "AlisViewController.h"

static NSString *testServer = @"http://baobab.wdjcdn.com";
static NSString *testApi = @"/1442142801331138639111.mp4";

@interface AlisViewController ()//<AlisRequestProtocol,AlisJsonParserProtocol>
@end

@implementation AlisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    AEDKHttpServiceConfiguration *config = [AEDKHttpServiceConfiguration defaultConfiguration];
    AEDKService *service = [[AEDKService alloc] initWithName:@"askCityList" protocol:@"http" domain:@"test.alisports.com" path:@"/v4/gym/citieslist" serviceConfiguration:config];
    [[AEDKServer server] registerService:service];
    */
//    [[AlisServiceProxy shareManager] injectService:self];
//    //[[AlisPluginManager manager]registerALLPlugins];
//    NSDictionary *plugins = @{@"AFNetwoking":@"AFNetworkingPlugin",@"SDWebimage":@"SDWebimagePlugin"};
//    [[AlisPluginManager manager]registerPlugins:plugins];
//    [[AlisRequestManager sharedManager] setupConfig:^(AlisRequestConfig *config) {
//        config.generalServer = testServer;
//        config.enableSync = NO;
//        // config.generalHeader = @{@"xx":@"yy"};
//    }];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, 100, 50)];
    [button setTitle:@"链式请求" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(chainRequest) forControlEvents:UIControlEventTouchUpInside];//batchRequest
    
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

- (void)testImageView{
  /*  AEDKWebImageLoader *loader = [[AEDKWebImageLoader alloc]init]; 
    UIImageView *imageView = [[UIImageView alloc] init];
    [loader setImageForImageView:imageView withURL:[NSURL URLWithString:@"http://img3.redocn.com/tupian/20150312/haixinghezhenzhubeikeshiliangbeijing_3937174.jpg"] placeholderImage:nil progress:^(int64_t totalAmount, int64_t currentAmount) {
        
    } completed:^(NSURL * _Nullable imageUrl, UIImage * _Nullable image, NSError * _Nullable error) {
         NSLog(@"请求完全结束");
        
    }];
*/
}

- (void)normalRequest{
   // [self testImageView];return;
   // resumeService(@"AskDemo");
//    resumeService(@"AskCitieslist");
//    resumeService(@"uploadData");
    /*
    AEDKProcess *process = [[AEDKServer server] requestServiceWithName:@"AskPostCodes"];
    process.configuration.BeforeProcess = ^(AEDKProcess * _Nonnull process) {
//        if ([process.configuration isKindOfClass:[AEDKHttpServiceConfiguration class]]) {
//            AEDKHttpServiceConfiguration *config = (AEDKHttpServiceConfiguration *)(process.configuration);
//            config.requestParameter = @{@"f":@"f"};
//        }
    };
    process.configuration.Processing = ^(int64_t totalAmount, int64_t currentAmount, NSURLRequest * _Nonnull currentRequest) {
    };
    process.configuration.AfterProcess = ^id _Nonnull(id  _Nullable responseData) {
        NSArray *modelArray = [PostCodeModel allPostcode:(NSDictionary *)responseData];
        return modelArray;
    };
    process.configuration.ProcessCompleted = ^(AEDKProcess * _Nonnull currentProcess, NSError * _Nonnull error, id  _Nullable responseModel) {
       // final result
        NSLog(@"请求完全结束");
    };
    [process start];*/
}

- (void)cancelNormalRequest{
    [self testImageView];return;
    suspendService(@"uploadData");
    UIImageView *image = [[UIImageView alloc]init];
    [image alis_setImageWithURL:@"https://oneimg.oss-cn-hangzhou.aliyuncs.com/xu01_test/20161207/1481090430466.jpg" whichPlugin:^NSString *(NSArray *plugins) {
        return @"SDWebimage";
        
    } placeholderImage:nil options:0 progress:^(AlisRequest *request, long long receivedSize, long long expectedSize) {
        
    } completed:^(AlisRequest *request, AlisResponse *response, AlisError *error) {
         NSLog(@"finished");
    }];
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

- (void)batchRequest{
    [[AlisRequestManager sharedManager]sendBatchRequest:^(AlisBatchRequest * _Nonnull batchRequest) {
        AlisRequest *request1 = [AlisRequest request];
        request1.url = @"https://httpbin.org/get";
        request1.httpMethod = AlisHTTPMethodGET;
        request1.parameters = @{@"method": @"get"};
        
        AlisRequest *request2 = [AlisRequest request];
        request2.url = @"https://httpbin.org/post";
        request2.httpMethod = AlisHTTPMethodPOST;
        request2.parameters = @{@"method": @"post"};
        
        [batchRequest.requestArray addObject:request1];
        [batchRequest.requestArray addObject:request2];
        
    } onSuccess:^(NSArray * _Nullable responseArray) {
        
    } onFailure:^(NSArray * _Nullable errorArray) {
        NSLog(@"batch请求 failure");
        
    } onFinished:^(NSArray * _Nonnull responseArray, NSArray * _Nullable errorArray) {
        NSLog(@"batch请求结束了 不容易啊");
        
    }];
    
}

/*
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

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName response:(id)response{
    if (ServiceEqual(serviceName, @"AskDemo")) {
    }
    
    NSLog(@"%@ back",serviceName);
}

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName progress:(float)progress{
    if (ServiceEqual(serviceName, @"AskDemo")) {
    }
    
    NSLog(@"%@ back",serviceName);
}

//- (AlisJsonModel *)parserBaseJsonValue:(NSDictionary *)jsonData{
//    NSAssert(jsonData, @"JSON 数据为空");
//    AlisJsonModel *jsonModel = [[AlisJsonModel alloc]init];
//    jsonModel.resMsg = jsonData[@"xx"];
//    jsonModel.resCode = 0;
//    jsonModel.data = jsonData[@"data"];
//    
//    return jsonModel;
//}

*/
@end

