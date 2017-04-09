//
//  UIImageView+AlisRequest.h
//  Pods
//
//  Created by alisports on 2017/4/7.
//
//

#import <UIKit/UIKit.h>

@interface UIImageView (AlisRequest)

- (void)alis_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(NSUInteger)options progress:(AlisRequestProgressBlock)progressBlock completed:(AlisRequestFinishBlock)completedBlock ;    

@end
