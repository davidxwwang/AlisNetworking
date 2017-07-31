//
//  AlisPluginProtocol.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//  定义了每个模块可以提供什么样的服务和能力

#import <Foundation/Foundation.h>

//AlisRequest 自定义的request
//AlisResponse 自定义的response
@class AlisRequest,AlisResponse,AlisError,AlisRequestConfig;

@protocol AlisPluginProtocol <NSObject>

/**
 *  配置公共的请求config，eg：server等。
 *
 *  @param requestConfig  公共配置项。
 *
 */
- (void)perseConfig:(AlisRequestConfig *)requestConfig;
/**
 *  将我们自定义的reqeust转换为可以真正发出网络请求的reqeust。
 *
 *  @param request     请求（可能需要请求的一些参数来生成响应，如responseClass等）。
 *
 */
- (void)perseRequest:(AlisRequest *)request config:(AlisRequestConfig *)config;

- (id)start_Request:(AlisRequest *)request config:(AlisRequestConfig *)config;
/**
 *  解析接口返回的remoteResponse，得到我们想要的数据。
 *
 *  @param remoteResponse 服务器的响应
 *  @param request     请求（可能需要请求的一些参数来生成响应，如responseClass等）。
 *
 *  @return 响应 AlisResponse。
 */
- (AlisResponse *)perseResponse:(id)remoteResponse request:(AlisRequest *)request;

/**
 *  解析接口返回的错误信息。
 *
 *  @param remoteError 服务器的错误响应
 *
 *  @return 响应 AlisResponse。
 */

- (AlisError *)perseError:(id)remoteError;

@required
/**
 *  定义可以提供的服务，例如 本地缓存,图片下载，一般的下载， 同步下载等。方便manager判断
 */
- (NSArray *)supportSevervice;

@end
