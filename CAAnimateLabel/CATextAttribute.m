//
//  CATextAttribute.m
//  CAAnimateLabel
//
//  Created by chenao on 17/4/7.
//  Copyright © 2017年 chenao. All rights reserved.
//

#import "CATextAttribute.h"


@implementation CATextAttributeLayer

- (instancetype) init {
    if (self = [super init]) {
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {

    UIGraphicsPushContext(ctx);
    CGContextSaveGState(ctx);
    [self.attrStr drawInRect:self.bounds];
    UIGraphicsPopContext();
}

@end

@implementation CATextAttribute
- (void)setAttrString:(NSAttributedString *)attrString {
    _attrString = attrString;
    _font = [attrString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    _textColor = [attrString attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    NSMutableAttributedString *mAttr = [_attrString mutableCopy];
    [mAttr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, _attrString.string.length)];
    _attrString = mAttr;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    NSMutableAttributedString *mAttr = [_attrString mutableCopy];
    [mAttr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, _attrString.string.length)];
    _attrString = mAttr;
}
@end
