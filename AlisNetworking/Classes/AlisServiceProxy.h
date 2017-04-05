//
//  AlisServiceProxy.h
//  PluginsDemo
//
//  Created by alisports on 2017/3/21.
//  Copyright © 2017年 alisports. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "AlisRequestProtocol.h"
#import <Foundation/Foundation.h>

#define resumeService(yy) {[AlisServiceProxy shareManager].currentServiceAgent = self;\
[[AlisServiceProxy shareManager] performSelector:NSSelectorFromString([@"resume_"  stringByAppendingFormat:@"%@", yy])];}


//#define resumeService1(yy) ([[AlisServiceProxy shareManager] performSelector:NSSelectorFromString([@"resume_"  stringByAppendingFormat:@"%@", yy])])
#define cancelService(yy) ([self performSelector:NSSelectorFromString([@"cancel_"  stringByAppendingFormat:@"%@", yy])])
#define suspendService(yy) ([self performSelector:NSSelectorFromString([@"suspend_"  stringByAppendingFormat:@"%@", yy])])
#define ServiceEqual(yy,xx) ([yy isEqualToString:xx])

// VC 的service层
// 用户层指明自己遵守的协议<AlisRequestProtocol>，之后请求所需要的数据，参数都在用户层这里查找
// 网络请求成功的结果返回裸数据，用户层根据业务的不同做相应的处理
// 发出资源请求的很有可能不是VCService或其子类，有可能是其他OC对象转发给VCService的，这个需要注意
// 支持消息转发和消息继承
@protocol VCServiceProtocol <NSObject>

/**
 对对象注册服务
 @param object object description
 */
- (void)injectService:(id<AlisRequestProtocol>)object;

@end

@interface AlisServiceProxy : NSObject<AlisRequestProtocol,VCServiceProtocol>

+ (AlisServiceProxy *)shareManager;

@property(copy,nonatomic)NSString *currentServiceName;


/**
 当前服务的agent，例如AlisViewController网络请求，
 */
@property(strong,nonatomic)id<AlisRequestProtocol> currentServiceAgent;

@end

