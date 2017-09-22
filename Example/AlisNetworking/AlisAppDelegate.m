//
//  AlisAppDelegate.m
//  AlisNetworking
//
//  Created by xingwang.wxw on 04/05/2017.
//  Copyright (c) 2017 xingwang.wxw. All rights reserved.
//

//#import "AlisServicesManager.h"
#import "AlisAppDelegate.h"
//#import "AlisHttpServiceItem.h"
#import <MJExtension/MJExtension.h>
//#import <AEDataKit/AEDataKit.h>

@implementation AlisAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
   /* NSString *plistPath = @"/Users/david/Documents/AlisNetworking/AlisNetworking/Classes/RequestConfig.plist";
    
    NSDictionary *availableRequestServices = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
    NSDictionary *candidateRequestServices = [NSDictionary dictionaryWithDictionary:availableRequestServices];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [candidateRequestServices enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSDictionary *_obj = (NSDictionary *)obj;
        AlisHttpServiceItem *item = [AlisHttpServiceItem mj_objectWithKeyValues:_obj];
        if (item) {
              [dic setObject:item forKey:key];
        }
    }];
    
    [[AlisServicesManager sharedManager]registerServices:dic];
    */
    /*
    AEDKHttpServiceConfiguration *httpConfiguration = [[AEDKHttpServiceConfiguration alloc]init];
    httpConfiguration.mimeType = AEDKHttpServiceMimeTypeText;
    AEDKHttpUploadDownloadConfiguration *uploadDownloadConfig = [[AEDKHttpUploadDownloadConfiguration alloc]initWithType:AEDKHttpFileUpload accociatedFilePath:@"/temp/xyz"];
    httpConfiguration.uploadDownloadConfig = uploadDownloadConfig;
    
    
    AEDKService *service = [[AEDKService alloc]initWithName:@"AskPostCodes" protocol:kAEDKServiceProtocolHttp domain:@"olympic-public.oss-cn-shanghai.aliyuncs.com" path:@"/api/address/addr_4_1111_1_amap.json" serviceConfiguration:httpConfiguration];//[AEDKServiceConfiguration defaultConfiguration]]
    [[AEDKServer server] registerService:service];
    
*/
    return YES;
}

@end
