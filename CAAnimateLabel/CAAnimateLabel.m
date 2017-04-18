//
//  CAAnimateLabel.m
//  CAAnimateLabel
//
//  Created by chenao on 17/4/7.
//  Copyright © 2017年 chenao. All rights reserved.
//

#import "CAAnimateLabel.h"
#import "CAAnimateLabel+Animation.h"
#import "CAAnimateUtil.h"
@interface CAAnimateLabel (){
    dispatch_once_t _onceToken;
    CADisplayLink *_link;
    NSTimeInterval _timestamp;
    NSTimeInterval _passTime;
    NSTimeInterval _totalDuration;
    CATextLayout *_textLayout;
    NSInteger _animationCount;
    NSMutableArray *_animatedAttribute;
    NSMutableArray *_completeAnimateAttribute;
    CAAnimateLabelType _initialType;
}

@end

@implementation CAAnimateLabel

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]){
        [self _init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}

- (void)_init
{
    dispatch_once(&_onceToken, ^{
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(display:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _link.paused = YES;
    });
    
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    _textLayout = [CATextLayout new];
    _duration = 2.0;
    _restore = YES;
    _lineSpacing = 6;
    _delay = 0.2;
    _delayAfterComplete = NO;
    _textColor = [UIColor blackColor];
    _font = [UIFont systemFontOfSize:15];
    _type = CAAnimateLabelZoomType;
    _textAlignment = CATextAlignmentLeft;
    _layoutType = CATextLayoutCharType;
    _animatedAttribute = [NSMutableArray array];
    _completeAnimateAttribute = [NSMutableArray array];
}

- (void)dealloc
{
    [_link invalidate];
}

#pragma mark - getter
- (CATextLayout *)textLayout {
    return _textLayout;
}

#pragma mark - setter 

- (void)setDelayAfterComplete:(BOOL)delayAfterComplete {
    _delayAfterComplete = delayAfterComplete;
    [self updateTotalDuration];
}

- (void)setType:(CAAnimateLabelType)type {
    _type = type;
    
    if (type == CAAnimateLabelDashType || type == CAAnimateLabelSpinType) {
        _textLayout.layerAnimate = YES;
        self.layerAnimate = YES;
        
    }else {
        _textLayout.layerAnimate = NO;
        self.layerAnimate = NO;
    }
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInsets, UIEdgeInsetsZero)) {
        //force not change
        return;
    }
    if (type == CAAnimateLabelSpringType) {
        _textLayout.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    }
}

- (void)setDelegate:(id<CAAnimateLabelDelegate>)delegate {
    _delegate = delegate;
    _type = CAAnimateLabelCustomType;
}

- (void)setLayerAnimate:(BOOL)layerAnimate {
    _layerAnimate = layerAnimate;
    [self _updateText];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    _textLayout.contentInset = contentInsets;
    [self _updateText];
}

- (void)setTextAlignment:(CATextAlignment)textAlignment {
    _textAlignment = textAlignment;
    [self _updateText];
}

- (void)setLayoutType:(CATextLayoutType)layoutType {
    _layoutType = layoutType;
    [self _updateText];
}

- (void)setText:(NSString *)text {
    
    NSAssert(text != nil, @"CAAnimateLabel's text cann't be nil");
    _text = text;
    [self _updateText];
}

- (void)setTextColor:(UIColor *)textColor {
    [self removeAllTextLayer];
    NSAssert(textColor != nil, @"CAAnimateLabel's textColor cann't be nil");
    _textColor = textColor;
    if (_attributedText) {
        NSMutableAttributedString *mAttriStr = [[NSMutableAttributedString alloc]initWithAttributedString:_attributedText];
        [mAttriStr addAttribute:NSForegroundColorAttributeName value:_textColor range:NSMakeRange(0, _attributedText.length)];
        _attributedText = (NSAttributedString *)mAttriStr;
    }
    [self _updateText];
}

- (void)setFont:(UIFont *)font {
    
    [self removeAllTextLayer];
    NSAssert(font != nil, @"CAAnimateLabel's font cann't be nil");
    _font = font;
    if (_attributedText) {
        NSMutableAttributedString *mAttriStr = [[NSMutableAttributedString alloc]initWithAttributedString:_attributedText];
        [mAttriStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, _attributedText.length)];
        _attributedText = mAttriStr;
    }
    [self _updateText];
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    [self removeAllTextLayer];
    NSAssert(lineSpacing >= 0, @"lineSpacing cann't less then zero");
    _lineSpacing = lineSpacing;
    if (_attributedText) {
        NSMutableAttributedString *mAttriStr = [[NSMutableAttributedString alloc]initWithAttributedString:_attributedText];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing = lineSpacing;
        [mAttriStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _attributedText.length)];
        _attributedText = mAttriStr;
    }
    [self _updateText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    
    NSAssert(attributedText != nil, @"CAAnimateLabel's attributedString cann't be nil");
    _attributedText = attributedText;
    NSDictionary *attributes = [attributedText attributesAtIndex:0 effectiveRange:NULL];
    UIFont *font = [attributes objectForKey:NSFontAttributeName];
    if (font) {
        _font = font;
    }
    UIColor *textClolor = [attributes objectForKey:NSForegroundColorAttributeName];
    if(textClolor){
        _textColor = textClolor;
    }
   NSParagraphStyle *style = [attributes objectForKey:NSParagraphStyleAttributeName];
    if (style.lineSpacing) {
        _lineSpacing = style.lineSpacing;
    }
    if (style.alignment) {
        switch (style.alignment) {
            case NSTextAlignmentLeft:
                _textAlignment = CATextAlignmentLeft;
                break;
            case NSTextAlignmentCenter:
                _textAlignment = CATextAlignmentCenter;
                break;
            case NSTextAlignmentRight:
                _textAlignment = CATextAlignmentRight;
                break;
            default:
                _textAlignment = CATextAlignmentLeft;
                break;
        }
    }
     [self _updateText];
}

#pragma mark - private method
- (void)_updateText {
    [_textLayout cleanTextAttrsbute];
    if (!_attributedText) {
        if (!_text) {
            return;
        }
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
        style.lineSpacing = _lineSpacing;
        _attributedText = [[NSAttributedString alloc] initWithString:_text attributes:@{NSFontAttributeName : _font,NSForegroundColorAttributeName:_textColor,NSParagraphStyleAttributeName:style}];
    }
    CGRect frame = CGRectZero;
    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        if (self.superview) {
            frame = self.superview.frame;
            self.frame = self.superview.frame;
        }
    }else {
        frame = self.frame;
    }
    
    if (self.layerAnimate) {
        [self removeAllTextLayer];
    }
    [_textLayout proccessAttributeString:_attributedText type:self.layoutType rect:frame];
    [self preTextAttributes];
    [self updateTotalDuration];
    [_textLayout adjustRect:self.textAlignment];
}

- (void)updateTotalDuration {
    if (_delayAfterComplete) {
        _totalDuration = MAX(_textLayout.textAttrs.count - 1, 0) * self.delay + self.duration * _textLayout.textAttrs.count;
    }else {
        _totalDuration = MAX(_textLayout.textAttrs.count - 1, 0) * self.delay + self.duration;
    }

}

- (void)preTextAttributes {
    if (!self.layerAnimate || (self.type != CAAnimateLabelSpinType && self.type != CAAnimateLabelDashType)) {
        return;
    }
    [_textLayout.textAttrs enumerateObjectsUsingBlock:^(CATextAttribute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (self.type == CAAnimateLabelDashType) {
            CATextAttributeLayer *layer = obj.layer;
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            layer.backgroundColor = [UIColor clearColor].CGColor;
            [layer setNeedsDisplay];
            layer.opacity = 0;
            layer.anchorPoint = CGPointMake(0, 0);
            layer.position = CGPointMake(self.bounds.size.width, obj.layer.position.y);
            [CATransaction commit];
            
        }else if (self.type == CAAnimateLabelSpinType) {
            
            CATextAttributeLayer *layer = obj.layer;
            
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            
            layer.backgroundColor = [UIColor clearColor].CGColor;
            layer.transform = CATransform3DMakeRotation((M_PI / 2), 0, 1, 0);
            [layer setNeedsDisplay];
            layer.anchorPoint = CGPointMake(0, 0.5);
            layer.position = CGPointMake(layer.position.x - CGRectGetWidth(obj.rect)/2, layer.position.y);
            [CATransaction commit];

        }
            [self.layer addSublayer:obj.layer];
    }];

}

- (void)removeAllTextLayer {
    NSMutableArray *toDelete = [NSMutableArray array];
    for (CALayer *layer in self.layer.sublayers) {
        [toDelete addObject:layer];
    }
    
    for (CALayer *layer in toDelete) {
        [layer removeFromSuperlayer];
    }
}

#pragma mark - CADisplayLink
- (void)display:(CADisplayLink *)link {

    _timestamp = link.timestamp;
    _passTime += link.duration;
    
    NSInteger i = 0;
    if (_delayAfterComplete) {
        i =  _passTime / (self.delay + self.duration);
    }else {
        i = _passTime / self.delay;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(animationWillStartTextAttribute:forIndex:)] && i < _textLayout.textAttrs.count && i >= _animatedAttribute.count) {
        [_animatedAttribute addObject:@(i)];
        [self.delegate animationWillStartTextAttribute:[_textLayout.textAttrs objectAtIndex:i] forIndex:i];
    }
    
    if (_passTime >= self.duration) {
        
        NSInteger completeIndex = (_passTime - self.duration) / (_delayAfterComplete ? (self.delay + self.duration) : self.delay);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(animationDidEndTextAttribute:forIndex:)] && completeIndex < _textLayout.textAttrs.count && completeIndex >= _completeAnimateAttribute.count) {
            [_completeAnimateAttribute addObject:@(completeIndex)];
            [self.delegate animationDidEndTextAttribute:[_textLayout.textAttrs objectAtIndex:completeIndex] forIndex:completeIndex];
        }
    }
    
    if (_link.paused) {
        self.type = _initialType;
        return;
    }
    
    if (_passTime > _totalDuration) {

        _passTime -= _totalDuration;
        _animationCount ++;
        if (self.layerAnimate) {
            
            if (self.repeatCount != _animationCount) {
                [self preTextAttributes];
            }
            
        } else {
            [self setNeedsDisplay];
        }
        if (_animationCount == self.repeatCount) {
            _link.paused = YES;
            if (_type != _initialType) {
                _type = _initialType;
            };
            _restore = YES;
            if (!self.layerAnimate ) {
                
                [self setNeedsDisplay];
            }
            return;
        }
    }
    
    [_textLayout.textAttrs enumerateObjectsUsingBlock:^(CATextAttribute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTimeInterval timePass;
        if (_delayAfterComplete) {
            timePass = _passTime - idx * (self.delay + self.duration);
        }else {
            timePass = _passTime - idx * self.delay;
        }
        
        obj.progress = MAX(0, MIN(1, timePass / _duration));
        
        if (obj.progress == 1) {
            obj.complete = YES;
        }
        if (obj.progress == 1) {
            return ;
        }
        
        if (self.layerAnimate) {
            [self layerAnimateWithTextAttribute:obj forIndex:idx];
        }else {
            CGRect drawRect;
            if (self.delegate && [self.delegate respondsToSelector:@selector(animationDrawRectForTextAttribute:forIndex:)]) {
                
                drawRect = [self.delegate animationDrawRectForTextAttribute:obj forIndex:idx];
            }else {
                drawRect = [self drawRect:self.bounds ForAttribute:obj];
            }
            [self setNeedsDisplayInRect:drawRect];
        }
    }];
}

#pragma mark - Animation
- (void)startAnimation {
    [self removeAllTextLayer];
    [self resetAnimation];
    [self _updateText];
    [self setNeedsDisplay];
    _link.paused = NO;
}

- (void)stopAnimationRestore:(BOOL)restore {
    [self resetAnimation];
    _restore = restore;
    if (restore) {
        [self setNeedsDisplay];
    }
}

- (void)resetAnimation {
    if (_animationCount == 0) {
        _initialType = self.type;
    }
    _link.paused = YES;
    [_animatedAttribute removeAllObjects];
    [_completeAnimateAttribute removeAllObjects];
    _passTime = 0;
    _timestamp = 0;
    _animationCount = 0;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [_textLayout.textAttrs enumerateObjectsUsingBlock:^(CATextAttribute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (_link.isPaused) {
            if (_restore) {
                [obj.attrString drawInRect:obj.rect];
            }
        }else {
            [self drawInRect:rect withTextAttribute:obj forIndex:idx];
        
        }
    }];
}

#pragma mark - private drawing

- (CGRect)drawRect:(CGRect)rect ForAttribute:(CATextAttribute *)textAttr {
    return [self drawRect:rect animationType:self.type textAttribute:textAttr];
}

- (CGRect)drawRect:(CGRect)rect animationType:(CAAnimateLabelType)type textAttribute:(CATextAttribute *)textAttr {
    
    if (type == CAAnimateLabelZoomType) {
        return textAttr.rect;
    }else if (type == CAAnimateLabelFallType) {
        CGRect rect = textAttr.rect;
        return CGRectMake(0, rect.origin.y - textAttr.font.pointSize * 5, CGRectGetWidth(self.frame), rect.size.height + textAttr.font.pointSize * 5);
    }else if (type == CAAnimateLabelFlewType) {
        CGRect attrRect = textAttr.rect;
        return CGRectMake(0, attrRect.origin.y, rect.size.width, rect.size.height - attrRect.origin.y);
    }else if (type == CAAnimateLabelSpringType) {
        CGRect rect = textAttr.rect;
        rect.origin.y -= CGRectGetHeight(rect) / 2;
        rect.size.height += CGRectGetHeight(rect);
        return rect;
    } else if (type == CAAnimateLabelThrowType) {
        
        return CGRectMake(0, 0, CGRectGetMaxX(textAttr.rect), CGRectGetMaxY(textAttr.rect));
    }

    return  textAttr.rect;
}

- (void)drawInRect:(CGRect)rect withTextAttribute:(CATextAttribute *)attrText forIndex:(NSInteger)index{
    
    if (attrText.progress <= 0 ) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(animationAtRect:ForTextAttribute:forIndex:)]) {
        [self.delegate animationAtRect:rect ForTextAttribute:attrText forIndex:index];
        return;
    }
    
    switch (self.type) {
        case CAAnimateLabelZoomType:
            
            [self zoomAnimationRect:rect textAttribute:attrText];
            break;
            
        case CAAnimateLabelFallType:
            [self fallAnimationRect:rect textAttribute:attrText];
            break;

        case CAAnimateLabelFlewType:
            [self flewAnimationRect:rect textAttribute:attrText];
            break;
            
        case CAAnimateLabelAlphaType:
            [self alphaAnimationRect:rect textAttribute:attrText];
            break;
            
        case CAAnimateLabelSpringType:
            [self springAnimationRect:rect textAttribute:attrText];
            break;
        case CAAnimateLabelRevealType:
            [self revealAnimationRect:rect textAttribute:attrText];
            break;
        case CAAnimateLabelThrowType:
            [self throwAnimationRect:rect textAttribute:attrText];
            break;
        default:
            break;
    }
}

- (void)layerAnimateWithTextAttribute:(CATextAttribute *)textAttribute forIndex:(NSInteger)index{
    if (textAttribute.progress <= 0 ) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(animationAtRect:ForTextAttribute:forIndex:)]) {
        [self.delegate animationAtRect:textAttribute.rect ForTextAttribute:textAttribute forIndex:index];
        return;
    }
    if (self.type == CAAnimateLabelDashType) {
        [self dashAnimationWithTextAttribute:textAttribute];
    }else if (self.type == CAAnimateLabelSpinType) {
        [self spinAnimationWithTextAttribute:textAttribute];
    }
}

@end
