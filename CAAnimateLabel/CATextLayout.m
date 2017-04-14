//
//  CATextLayout.m
//  CAAnimateLabel
//
//  Created by chenao on 17/4/7.
//  Copyright © 2017年 chenao. All rights reserved.
//

#import "CATextLayout.h"
#import <CoreText/CoreText.h>


@interface CATextLayout (){
    CGRect frame;
    NSArray *lines;
}

@end

@implementation CATextLayout
- (NSMutableArray<CATextAttribute *> *)textAttrs {
    if (_textAttrs == nil) {
        _textAttrs = [NSMutableArray array];
    }
    return _textAttrs;
}

- (void)proccessAttributeString:(NSAttributedString *)attrString type:(CATextLayoutType)type rect:(CGRect)rect
{
    
    NSAssert(attrString != nil, @"cann't proccess nil attribute string");
    frame = rect;
    
    NSString *string = attrString.string;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    CTFrameRef CTFrame;
    CGRect frameRect;
    CFRange range = CFRangeMake(0, string.length);
    

    CFRange fitRange;
    
    CGSize s = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, NULL, CGSizeMake(rect.size.width, MAXFLOAT), &fitRange);
    
    self.size = s;
    
    frameRect = CGRectMake(0, 0, s.width, s.height);
    CGPathRef framePath = CGPathCreateWithRect(frameRect, NULL);
    CTFrame = CTFramesetterCreateFrame(framesetter, range, framePath, NULL);
    CGPathRelease(framePath);
    
    lines = (NSArray*)CTFrameGetLines(CTFrame);
    NSUInteger lineCount = [lines count];
    
    CGPoint *lineOrigins = malloc(sizeof(CGPoint) * lineCount);
    CGRect *lineFrames = malloc(sizeof(CGRect) * lineCount);
    
    CTFrameGetLineOrigins(CTFrame, CFRangeMake(0, 0), lineOrigins);
    
    CGFloat startOffsetY = self.contentInset.top;
    
    for(CFIndex i = 0; i < lineCount; ++i) {
        
        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
        
        CFRange lineRange = CTLineGetStringRange(line);
        
        CGPoint lineOrigin = lineOrigins[i];
        CGFloat ascent, descent, leading;
        CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        BOOL useRealHeight = i < lineCount - 1;
        CGFloat neighborLineY = i > 0 ? lineOrigins[i - 1].y : (lineCount - 1 > i ? lineOrigins[i + 1].y : 0.0f);
        CGFloat lineHeight = ceil(useRealHeight ? fabs(neighborLineY - lineOrigin.y) : ascent + descent + leading);
        
        lineFrames[i].origin = lineOrigin;
        lineFrames[i].size = CGSizeMake(lineWidth, lineHeight);
        
        NSString *lineString = [string substringWithRange:NSMakeRange(lineRange.location, lineRange.length)];
        
        NSStringEnumerationOptions options = NSStringEnumerationLocalized;
        switch (type) {
            case CATextLayoutCharType:
                options = NSStringEnumerationByComposedCharacterSequences;
                break;
            case CATextLayoutWordType:
                options = NSStringEnumerationByWords;
                break;
            case CATextLayoutSentenceType:
                options = NSStringEnumerationBySentences;
                break;
            default:
                break;
        }
        
        __block CGFloat maxDescender = 0;
        __block CGFloat maxCharHeight = 0;
        [lineString enumerateSubstringsInRange:NSMakeRange(0, lineRange.length) options:options usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            NSMutableAttributedString *subLineString = [[attrString attributedSubstringFromRange:NSMakeRange(enclosingRange.location + lineRange.location, enclosingRange.length)] mutableCopy];
            UIFont *font = [subLineString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
            maxDescender = MAX(maxDescender, font.descender > 0 ? font.descender : -font.descender);
            maxCharHeight = MAX(maxCharHeight, font.xHeight + font.ascender + font.descender);
        }];
        
        [lineString enumerateSubstringsInRange:NSMakeRange(0, lineRange.length) options:options usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            
            CATextAttribute *textAttr = [[CATextAttribute alloc] init];
            textAttr.text = [lineString substringWithRange:enclosingRange];
            textAttr.range = enclosingRange;
            textAttr.lineIndex = i;
            
            NSMutableAttributedString *subLineString = [[attrString attributedSubstringFromRange:NSMakeRange(enclosingRange.location + lineRange.location, enclosingRange.length)] mutableCopy];
            [subLineString removeAttribute:NSParagraphStyleAttributeName range:NSMakeRange(0, subLineString.length)];
            UIFont *font = [subLineString attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
            
            textAttr.attrString = subLineString;
            
            CGFloat startOffset = CTLineGetOffsetForStringIndex(line, enclosingRange.location + lineRange.location, NULL);
            CGFloat endOffset = CTLineGetOffsetForStringIndex(line, enclosingRange.location + enclosingRange.length + lineRange.location, NULL);
            
            CGFloat realHeight = font.xHeight + font.ascender + font.descender;
            CGFloat absAscender = font.descender > 0 ? font.descender : -font.descender;
            CGFloat originDiff = (maxCharHeight - realHeight) - (maxDescender - absAscender);
            
            if (type == CATextLayoutSentenceType) {
                realHeight = lineHeight;
                originDiff = 0;
            }
            
            textAttr.rect = CGRectMake(startOffset + lineOrigins[i].x, startOffsetY + originDiff, endOffset - startOffset, realHeight);
            if (i == lineCount - 1 && font.descender < 0) {
                CGRect rect = textAttr.rect;
                rect.size.height += font.ascender - font.descender;
                textAttr.rect = rect;
                CGSize size = self.size;
                size.height += font.ascender - font.descender;
                self.size = size;
            }
            [self.textAttrs addObject:textAttr];
            
            if (self.layerAnimate) {
                CATextAttributeLayer *layer = [[CATextAttributeLayer alloc] init];
                layer.frame = textAttr.rect;
                layer.attrStr = subLineString;
                layer.backgroundColor = [UIColor clearColor].CGColor;
                textAttr.layer = layer;
            }
   
        }];
        
        startOffsetY += lineHeight;
    }
    
    if (lineOrigins) {
        free(lineOrigins);
    }
    if (lineFrames) {
        free(lineFrames);
    }

}

- (void)adjustRect:(CATextAlignment)textAlignment {

   __block CFIndex lineIndex;
   __block NSInteger count;
    [self.textAttrs enumerateObjectsUsingBlock:^(CATextAttribute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (lineIndex != obj.lineIndex) {
            count = 0;
            lineIndex = obj.lineIndex;
        }else {
            count ++;
        }
        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:lineIndex];
        CGFloat ascent, descent, leading;
        CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGRect rect = obj.rect;
        
        
        if (textAlignment == CATextAlignmentLeft) {
            
            if (count == 0) {
                rect.origin.x = self.contentInset.left;
            } else {
            
                rect.origin.x = self.contentInset.left;
            for (NSInteger i = 0; i < idx; i++) {
                CATextAttribute *attri = [self.textAttrs objectAtIndex:MAX(0, MIN(self.textAttrs.count - 1, i))];
                if (attri && attri.lineIndex == obj.lineIndex) {
                    rect.origin.x += attri.rect.size.width;
                }
            }
            }
            obj.rect = rect;
            
        }else if (textAlignment == CATextAlignmentRight) {
            rect.origin.x = frame.size.width - rect.size.width - self.contentInset.right;
            for (NSInteger i = idx + 1; i < self.textAttrs.count; i++) {
                CATextAttribute *attri = [self.textAttrs objectAtIndex:MAX(0, MIN(self.textAttrs.count - 1, i))];
                if (attri && attri.lineIndex == obj.lineIndex) {
                    rect.origin.x -= attri.rect.size.width;
                }
                if (rect.origin.x <= 0) {
                    rect.origin.x = 0;
                    break;
                }
            }
            obj.rect = rect;
        }else {
            
            if (count == 0) {
                rect.origin.x = (frame.size.width - lineWidth) / 2;
            } else {
                
                rect.origin.x = (frame.size.width - lineWidth) / 2;
                for (NSInteger i = 0; i < idx; i++) {
                    CATextAttribute *attri = [self.textAttrs objectAtIndex:MAX(0, MIN(self.textAttrs.count - 1, i))];
                    if (attri && attri.lineIndex == obj.lineIndex) {
                        rect.origin.x += attri.rect.size.width;
                    }
                }
            }
            obj.rect = rect;
        }
    
    }];
    
    if (self.layerAnimate) {
        
        [self.textAttrs enumerateObjectsUsingBlock:^(CATextAttribute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CATextAttributeLayer *layer =  obj.layer;
            layer.frame =  obj.rect;
        }];
    }
    
}

- (void)cleanTextAttrsbute {
    [self.textAttrs removeAllObjects];
}

@end
