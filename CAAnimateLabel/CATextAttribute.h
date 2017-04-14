//
//  CATextAttribute.h
//  CAAnimateLabel
//
//  Created by chenao on 17/4/7.
//  Copyright © 2017年 chenao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class CATextAttributeLayer;
@interface CATextAttribute : NSObject

@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) CFIndex lineIndex;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSAttributedString *attrString;
@property (nonatomic, assign) NSRange range;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) CATextAttributeLayer *layer;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL complete;

@end


@interface CATextAttributeLayer : CALayer
@property (nonatomic, copy) NSAttributedString *attrStr;

@end

NS_ASSUME_NONNULL_END
