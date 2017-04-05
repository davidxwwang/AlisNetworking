//
//  AlisRequest.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//。 问题？不指定具体的请求插件，自动判断

#import <Foundation/Foundation.h>
#import "AlisRequestProtocol.h"
#import "AlisRequestConst.h"
#import "AlisRequestContext.h"

@class AlisRequest,AlisResponse,AlisError,AlisUpLoadFormData;


typedef void(^AlisRequestStartRequest) (void);
typedef void(^AlisRequestCancelRequest) (void);
typedef void(^AlisRequestFinishRequest) (AlisRequest *request ,AlisResponse *response ,AlisError *error);
typedef void(^AlisRequestProgressRequest)(AlisRequest *request ,long long receivedSize, long long expectedSize);

@interface AlisRequest : NSObject

+ (AlisRequest *)request;

//请求所处的上下文，先假定为发出请求的类，也可以新增属性：例如->网络环境，电量，内存状况等。
//方便后期的回调
@property(strong,nonatomic) AlisRequestContext *context;

//在业务层绑定的requestModel
@property(strong,nonatomic,nullable) id<AlisRequestProtocol> bindRequestModel;
//服务的名称 = <bindRequestModel + “／” + service名称（plist中定义的）>
@property(strong,nonatomic,nullable) NSString *serviceName;

//绑定真正的网络请求
@property(copy,nonatomic,nullable) id bindRequest;

//唯一的标示值
@property(copy,nonatomic,nullable) NSString *identifier;

//服务器地址
@property(copy,nonatomic,nullable) NSString *server;
//path
@property(copy,nonatomic,nullable) NSString *api;

//由server和api组成，，首先server，其次是url,generalServer最低
@property(copy,nonatomic,nullable) NSString *url;

//请求参数
@property(strong,nonatomic,nullable) NSDictionary<NSString *,id> *parameters;

//请求头
@property(strong,nonatomic,nullable) NSDictionary<NSString *,NSString *> *header;

//超时时间
@property(nonatomic,assign)NSInteger timeoutInterval;
/**
 请求类型: Normal, Upload or Download, `Normal` by default.
 */
@property (nonatomic, assign) AlisRequestType requestType;

/**
 请求的HTTP方法, 默认`AlisHTTPMethodPOST`
 */
@property (nonatomic, assign) AlisHTTPMethodType httpMethod;

//重试次数
@property(assign,nonatomic)NSInteger retryCount;

//是否使用公共server，当request的server设置为nil情况，默认为yes
@property (nonatomic, assign) BOOL useGeneralServer;
//是否添加公共header，默认为yes
@property (nonatomic, assign) BOOL useGeneralHeaders;
//是否添加公共parameter，默认为yes
@property (nonatomic, assign) BOOL useGeneralParameters;


@property(copy,nonatomic,nullable) AlisRequestStartRequest startBlock;
@property(copy,nonatomic,nullable) AlisRequestCancelRequest cancelBlock;
@property(copy,nonatomic,nullable) AlisRequestFinishRequest finishBlock;
@property(copy,nonatomic,nullable) AlisRequestProgressRequest progressBlock;


- (void)addFormDataWithName:(NSString *)name fileData:(NSData *)fileData;
- (void)addFormDataWithName:(NSString *)name fileURL:(NSString *)fileURL;

@property(strong,nonatomic)NSMutableArray<AlisUpLoadFormData *> *uploadFormDatas;

/**
 下载路径
 */
@property(copy,nonatomic)NSString *downloadPath;

@end


//上传文件，都需要以下信息
@interface AlisUpLoadFormData : NSObject

@property(copy,nonatomic)NSString *name;
@property(copy,nonatomic,nullable)NSString *fileName;

//fileData优先级更高一些
@property(copy,nonatomic,nullable)NSData *fileData;
@property(copy,nonatomic,nullable)NSURL *fileURL;

@property(copy,nonatomic,nullable)NSString *mimeType;

+ (instancetype)formUploadDataWithName:(NSString *)name fileData:(NSData *)fileData;
+ (instancetype)formUploadDataWithName:(NSString *)name fileURL:(NSURL *)fileURL;

@end
