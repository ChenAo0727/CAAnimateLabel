//
//  CATextLayout.h
//  CAAnimateLabel
//
//  Created by chenao on 17/4/7.
//  Copyright © 2017年 chenao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CATextAttribute.h"
typedef NS_ENUM(NSInteger, CATextLayoutType) {
    CATextLayoutCharType,
    CATextLayoutWordType,
    CATextLayoutSentenceType,
};

typedef NS_ENUM(NSInteger,CATextAlignment) {
    CATextAlignmentLeft,
    CATextAlignmentCenter,
    CATextAlignmentRight
};

@interface CATextLayout : NSObject
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) BOOL layerAnimate;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSMutableArray <CATextAttribute *>*textAttrs;
- (void)cleanTextAttrsbute;

- (void)proccessAttributeString:(NSAttributedString *)attrString type:(CATextLayoutType)type rect:(CGRect)rect;
- (void)adjustRect:(CATextAlignment)textAlignment;
@end
