//
//  NSString+help.m
//  Pods
//
//  Created by alisports on 2017/4/5.
//
//

#import "NSString+help.h"

@implementation NSString (help)

/**
 全局serviceName变为local的serviceName 
 @param globalServiceName 全局serviceName
 @return local的serviceName
 */
- (NSString *)toLocalServiceName{//:(NSString *)globalServiceName{
    if (self == nil) return nil;
    NSArray *serviceArray = [self componentsSeparatedByString:@"_"];
    if (serviceArray.count == 2) {
        return serviceArray[1];
    }
    return nil;
}


@end
