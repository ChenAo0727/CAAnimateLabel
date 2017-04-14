//
//  CAAnimateUtil.h
//  CAAnimateLabel
//
//  Created by chenao on 17/4/7.
//  Copyright © 2017年 chenao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@interface CAAnimateUtil : NSObject

+ (CGFloat)bounceWithStartValue:(CGFloat)start
                       endValue:(CGFloat)end
                      stiffness:(CGFloat)stiffness
                numberOfBounces:(CGFloat)numberOfBounces
                           progress:(CGFloat)progress
                          shake:(BOOL)shake
                shouldOvershoot:(BOOL)shouldOvershoot;

+ (CGFloat)easeInWithStartValue: (CGFloat) startValue endValue: (CGFloat) endValue progress:(CGFloat) progress;
+ (CGFloat)easeOutWithStartValue: (CGFloat) startValue endValue: (CGFloat) endValue progress:(CGFloat) progress;
+ (CGFloat)easeInBounceStartValue: (CGFloat) startValue endValue: (CGFloat) endValue progress: (CGFloat) progress;
+ (CGFloat)easeOutBounceStartValue: (CGFloat) startValue endValue: (CGFloat) endValue progress: (CGFloat) progress;
+ (CGFloat)easeOutBackStartValue: (CGFloat) startValue endValue: (CGFloat) endValue progress: (CGFloat) progress;
+ (CGFloat)easeInBackStartValue: (CGFloat) startValue endValue: (CGFloat) endValue progress: (CGFloat) progress;
@end
