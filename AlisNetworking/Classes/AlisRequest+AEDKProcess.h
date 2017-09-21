//
//  AlisRequest+AEDKProcess.h
//  Pods
//
//  Created by alisports on 2017/9/21.
//
//

//#import <AlisNetworking/AlisNetworking.h>
#import "AlisRequest.h"

@class AEDKProcess;

@interface AlisRequest (AEDKProcess)

- (void)convertAEDKProcess:(AEDKProcess *)process;

@end
