#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AFNetworkingPlugin.h"
#import "AlisPluginManager.h"
#import "AlisPluginProtocol.h"
#import "AlisRequest.h"
#import "AlisRequestConfig.h"
#import "AlisRequestConst.h"
#import "AlisRequestContext.h"
#import "AlisRequestManager+AlisRequest.h"
#import "AlisRequestManager.h"
#import "AlisRequestProtocol.h"
#import "AlisServiceProxy.h"
#import "CookieManager.h"
#import "SDWebimagePlugin.h"
#import "Service.h"

FOUNDATION_EXPORT double AlisNetworkingVersionNumber;
FOUNDATION_EXPORT const unsigned char AlisNetworkingVersionString[];

