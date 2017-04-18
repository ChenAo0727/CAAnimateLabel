//
//  CAAnimateLabel.h
//  CAAnimateLabel
//
//  Created by chenao on 17/4/7.
//  Copyright © 2017年 chenao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CATextLayout.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, CAAnimateLabelType) {
    CAAnimateLabelZoomType,
    CAAnimateLabelFallType,
    CAAnimateLabelFlewType,
    CAAnimateLabelAlphaType,
    CAAnimateLabelSpringType,
    CAAnimateLabelDashType,
    CAAnimateLabelSpinType,
    CAAnimateLabelRevealType,
    CAAnimateLabelThrowType,
    CAAnimateLabelCustomType
};

@protocol CAAnimateLabelDelegate;

@interface CAAnimateLabel : UIView
/**
 One TextAttribute animation time. Default is 2.0
 */
@property (nonatomic, assign) NSTimeInterval duration;
/**
 The delay time is two textAttribute animation interval time. Default is 0.2
 */
@property (nonatomic, assign) NSTimeInterval delay;

/**
If Yes, set the delay time between last textAttribute complete and next textAttribute start. Dafault is NO.
 */
@property (nonatomic, assign) BOOL delayAfterComplete;
/**
 The Animation count. 0 means infinite (default is 0)
 */
@property (nonatomic, assign) NSInteger repeatCount;
/**
 The textLayout save all textAttribute.
 */
@property (nonatomic,strong, readonly) CATextLayout *textLayout;
/**
 The delegate provide some methods for customized animation
 */
@property (nonatomic, weak) id<CAAnimateLabelDelegate> delegate;
/**
 Set contentInsets to change text layout area. some animation type change contentInsets to get a better animation effects 
 */
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/**
  restore text display when animation complete or init display. Defalut is YES
 */
@property (nonatomic, assign) BOOL restore;
/**
 CAAnimateLabelDashType CAAnimateLabelSpinType is layer animation.
 */
@property (nonatomic, assign) BOOL layerAnimate;

/**
 The font of the text. Default is 15-point system font.
 */
@property (nonatomic, strong) UIFont *font;
/**
 The lineSpacing of the text. Default is 6
 */
@property (nonatomic, assign) CGFloat lineSpacing;

@property (nonatomic, strong) UIColor *textColor;//Default is black color
/**
 The text displayed by the label. Default is nil.
 Set a new value to this property will replaces the text in `attributedString`.
 Get the value returns the plain text in `attributedString`.
 */
@property (nonatomic, copy) NSString *text;
/**
 The attributed text displayed by the label.
 Set a new value to this property also ignore the value of the `text`, `font`, `textColor`,
 `lineSpacing`,`textAlignment`.
 */
@property (nonatomic, strong) NSAttributedString *attributedText;

@property (nonatomic, assign) CAAnimateLabelType type;//Default is CAAnimateLabelZoomType
@property (nonatomic, assign) CATextAlignment textAlignment;//Default is CATextAlignmentLeft
@property (nonatomic, assign) CATextLayoutType layoutType;//Default is CATextLayoutCharType

- (CGRect)drawRect:(CGRect)rect animationType:(CAAnimateLabelType)type textAttribute:(CATextAttribute *)textAttr;

- (void)startAnimation;
- (void)stopAnimationRestore:(BOOL)restore;
- (void)removeAllTextLayer;
@end


@protocol CAAnimateLabelDelegate <NSObject>

- (void)animationWillStartTextAttribute:(CATextAttribute *)textAttribute forIndex:(NSInteger)index;
- (void)animationDidEndTextAttribute:(CATextAttribute *)textAttribute forIndex:(NSInteger)index;
- (CGRect)animationDrawRectForTextAttribute:(CATextAttribute *)textAttribute forIndex:(NSInteger)index;
- (void)animationAtRect:(CGRect)rect ForTextAttribute:(CATextAttribute *)textAttribute forIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
