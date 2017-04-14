//
//  CAAnimateLabel+Animation.h
//  CAAnimateLabel
//
//  Created by chenao on 17/4/13.
//  Copyright © 2017年 chenao. All rights reserved.
//

#import "CAAnimateLabel.h"

@interface CAAnimateLabel (Animation)
- (void)zoomAnimationRect:(CGRect)rect textAttribute:(CATextAttribute *)textAttribute;
- (void)fallAnimationRect:(CGRect)rect textAttribute:(CATextAttribute *)textAttribute;
- (void)flewAnimationRect:(CGRect)rect textAttribute:(CATextAttribute *)textAttribute;
- (void)alphaAnimationRect:(CGRect)rect textAttribute:(CATextAttribute *)textAttribute;
- (void)springAnimationRect:(CGRect)rect textAttribute:(CATextAttribute *)textAttribute;
- (void)revealAnimationRect:(CGRect)rect textAttribute:(CATextAttribute *)textAttribute;
- (void)throwAnimationRect:(CGRect)rect textAttribute:(CATextAttribute *)textAttribute;

- (void)dashAnimationWithTextAttribute:(CATextAttribute *)textAttribute;
- (void)spinAnimationWithTextAttribute:(CATextAttribute *)textAttribute;

@end
