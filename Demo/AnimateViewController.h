//
//  AnimateViewController.h
//  CAAnimateLabel
//
//  Created by chenao on 17/4/7.
//  Copyright © 2017年 chenao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAAnimateLabel.h"
@interface AnimateViewController : UIViewController
@property (nonatomic, assign) CAAnimateLabelType animateType;
@property (nonatomic, copy) NSString *animation;
@end
