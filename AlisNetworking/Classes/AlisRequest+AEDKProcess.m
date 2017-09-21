//
//  AlisRequest+AEDKProcess.m
//  Pods
//
//  Created by alisports on 2017/9/21.
//
//

#import "AlisRequest+AEDKProcess.h"
#import <AEDataKit/AEDataKit.h>

@implementation AlisRequest (AEDKProcess)

- (void)convertAEDKProcess:(AEDKProcess *)process{
    if (process.configuration == nil) return ;
    if (![process.configuration isKindOfClass:[AEDKHttpServiceConfiguration class]])
        return;
    
    AEDKHttpServiceConfiguration *config = (AEDKHttpServiceConfiguration *)(process.configuration);
    
   // AlisRequest *alisRequest = [[AlisRequest alloc]init];
    NSURLRequest *urlRequet = process.request;
    self.url = [urlRequet.URL absoluteString];
    self.parameters = config.requestParameter;
    self.httpMethod = [self httpMethodConverter:urlRequet.HTTPMethod];
    self.retryCount = config.retryCount;
    self.header = urlRequet.allHTTPHeaderFields;
    self.timeoutInterval = urlRequet.timeoutInterval;

    if (config.uploadDownloadConfig.type == AEDKHttpFileUpload) {
        self.requestType = AlisRequestUpload;
    }
    else if (config.uploadDownloadConfig.type == AEDKHttpFileDownload) {
        self.requestType = AlisRequestDownload;
    }
    else{
        self.requestType = AlisRequestNormal;
    }
    
    self.startBlock = ^{
        config.BeforeProcess(process);
    };
    
    self.progressBlock = ^(AlisRequest *request, long long receivedSize, long long expectedSize) {
        config.Processing(expectedSize, receivedSize, process.request);
    };
    
    self.cancelBlock = ^{
    };
    
    self.finishBlock = ^(AlisRequest *request, AlisResponse *response, AlisError *error) {
    };
    
    
    /**
     服务进程开始前，该block通知用户当前进程，如需修改则直接修改
     */
   // @property (nonatomic, copy) void (^__nullable BeforeProcess)(AEDKProcess *process);
    
    /**
     服务进程进行中
     */
   // @property (nonatomic, copy) void (^__nullable Processing)(int64_t totalAmount, int64_t currentAmount, NSURLRequest *currentRequest);

    /*
    /**
     服务进程结束前，该block通知用户当前服务的返回数据，需要用户返回解析后的数据模型
     */
   // @property (nonatomic, copy) id (^__nullable AfterProcess)(id __nullable responseData);
    
    /**
     服务进程完成后，得到执行结果。如果用户实现了AfterProcess，则返回用户解析后的数据模型，否则返回原始数据
     */
   // @property (nonatomic, copy) void (^ ProcessCompleted)(AEDKProcess *currentProcess, NSError *error, id __nullable responseModel);
    
    
    
}

- (AlisHTTPMethodType )httpMethodConverter:(NSString *)HTTPMethod{
    if ([HTTPMethod isEqualToString:@"GET"]) {
        return AlisHTTPMethodGET;
    }else if ([HTTPMethod isEqualToString:@"POST"]) {
        return AlisHTTPMethodPOST;
    }else if ([HTTPMethod isEqualToString:@"HEAD"] ) {
        return AlisHTTPMethodHEAD;
    }else if ([HTTPMethod isEqualToString:@"DELETE"]) {
        return AlisHTTPMethodDELETE;
    }else if ([HTTPMethod isEqualToString:@"PUT"]) {
        return AlisHTTPMethodPUT;
    }else if ([HTTPMethod isEqualToString:@"PATCH"]) {
        return AlisHTTPMethodPATCH;
    }
    
    return AlisHTTPMethodGET;
}


@end
