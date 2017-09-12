//
//  SDWebImagePlugin2.m
//  AlisNetworking
//
//  Created by alisports on 2017/8/28.
//  Copyright © 2017年 xingwang.wxw. All rights reserved.
//
#import "SDWebImageManager.h"
#import "SDWebImagePlugin2.h"

@implementation SDWebImagePlugin2

- (BOOL)canHandleProcess:(AEDKProcess *)process{
//    AEDKHttpServiceConfiguration *config = (AEDKHttpServiceConfiguration *)(process.configuration);
//    if (config.mimeType == AEDKHttpServiceMimeTypeImage) {
//        return YES;
//    }
    
    return NO;
}

- (void)handleProcess:(AEDKProcess *)process{
}

- (void)imageWithUrl:(NSURL * __nullable)url
            progress:(void(^ __nullable)(int64_t totalAmount, int64_t currentAmount))progress
           completed:(void(^ __nullable)(NSURL *__nullable imageUrl, UIImage *__nullable image, NSError *__nullable error))completedBlock{
        [[SDWebImageManager sharedManager] loadImageWithURL:url options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            if (progress) {
                progress(expectedSize ,receivedSize);
            }
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (completedBlock) {
                completedBlock(imageURL ,image ,error);
            }
        }];    
}

- (void)setImageForImageView:(UIImageView *)imageView
                     withURL:(NSURL * __nullable)url
            placeholderImage:(UIImage * __nullable)placeholder
                    progress:(void(^ __nullable)(int64_t totalAmount, int64_t currentAmount))progress
                   completed:(void(^ __nullable)(NSURL *__nullable imageUrl, UIImage *__nullable image, NSError *__nullable error))completedBlock{
    if (imageView) {
        imageView.image = placeholder;
    }
    [[SDWebImageManager sharedManager] loadImageWithURL:url options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (progress) {
            progress(expectedSize ,receivedSize);
        }
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (completedBlock) {
            imageView.image = image;
        }
    }];    
}

@end
