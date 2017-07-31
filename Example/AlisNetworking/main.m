//
//  main.m
//  AlisNetworking
//
//  Created by xingwang.wxw on 04/05/2017.
//  Copyright (c) 2017 xingwang.wxw. All rights reserved.
//

@import UIKit;
#import "AlisAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AlisAppDelegate class]));
    }
}

//
//所有的请求都看成资源的请求
//注意点：最好每个plugin的协议也是plugin本身定义的，这样利于扩展
//
//
//对于在VCService这一层，每个网络请求使用 “VCService名称 + api” 命名，用来标示该类型的资源请求。
//后改为每个网络请求使用 “api” 用来标示该类型的资源请求，应该AlisRequest中bindRequestModel已经
//标识了VCService。
//
//
//对于一个VCService一个类，就是一个requestModel,但可能对应好几个AlisRequest
//
//AlisRequest除了有一般网络请求的参数，还有几个比较重要的属性：
//（1）identifer（唯一标示）
//（2）bindRequestModel（绑定的requestModel），后来回调用
//(3) bindRequest 真正的网络请求的类实例
//
//(requestModel + serviceName) <--->AliRequest <----> thirdPartyRequest(Plugin)
//
//
//关键点：每个请求资源需要的参数是自己配置的，
//
//关于配置的设置和读取：
//
//首先：读取代码中的
//再次：读取plist文件中的
//再次：读取公共设置的
//
//如果优先级高的有值，就直接忽略低优先级的
//
//请求--: id<AlisRequestProtocol> -----> AlisServiceProxy ----> AlisRequestManager ----> AlisPluginManager ---->plugin
//
