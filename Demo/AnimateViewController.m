//
//  AnimateViewController.m
//  CAAnimateLabel
//
//  Created by chenao on 17/4/7.
//  Copyright © 2017年 chenao. All rights reserved.
//

#import "AnimateViewController.h"
#import "CAAnimateLabel+Animation.h"
@interface AnimateViewController ()<CAAnimateLabelDelegate>
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@property (weak, nonatomic) IBOutlet UILabel *delayLabel;
@property (weak, nonatomic) IBOutlet UILabel *fontLabel;

@property (weak, nonatomic) IBOutlet UIView *editView;
@property (nonatomic, strong) CAAnimateLabel *animateLabel;
@end

@implementation AnimateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.animation;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit:)];
    self.editView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.editView.frame));
    
    self.animateLabel = [CAAnimateLabel new];
    self.animateLabel.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view insertSubview:self.animateLabel atIndex:0];
    
    [self initAnimateLabel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.animateLabel.animating) {
        [self.animateLabel stopAnimationRestore:YES];
    }
}

- (void)initAnimateLabel {
    self.animateLabel.type = self.animateType;
    
    self.animateLabel.layoutType = CATextLayoutSentenceType;
    self.animateLabel.lineSpacing = 10;
    self.animateLabel.textColor = [UIColor greenColor];
    self.animateLabel.textAlignment = CATextAlignmentCenter;
    self.animateLabel.font = [UIFont systemFontOfSize:18.0];
    self.animateLabel.duration = 3.0;
    self.animateLabel.delay = 0.5;
    self.animateLabel.repeatCount = 2;
    
    //animate part of label will be ignore if implement prepareTextAttributes
    self.animateLabel.animateRange = NSMakeRange(10, 10);
    
    self.animateLabel.text = @"青春，是人生中最美的风景。\n青春，是一场花开的遇见；\n青春，是一场痛并快乐着的旅行；\n青春，是一场轰轰烈烈的比赛；\n青春，是一场鲜衣奴马的争荣岁月；\n青春，是一场风花雪月的光阴。";
    self.animateLabel.contentInsets = UIEdgeInsetsMake(100, 10, 10, 10);
    if (self.animateType == CAAnimateLabelCustomType) {
        self.animateLabel.layerAnimate = YES;
        self.animateLabel.delegate = self;
        self.animateLabel.restore = NO;
    }

    /**
     //Set attributedText
     NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
     style.lineSpacing = 20;
     style.alignment = NSTextAlignmentRight;
     
     NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:self.animateLabel.text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:20], NSParagraphStyleAttributeName : style, NSForegroundColorAttributeName : [UIColor redColor]}];
     self.animateLabel.attributedText = attrStr;
    */
    
}

- (void)dealloc {
    self.animateLabel = nil;
}

- (IBAction)changeDuration:(id)sender {
    [self.animateLabel stopAnimationRestore:NO];
    UISlider *slider = (UISlider *)sender;
    self.durationLabel.text = [NSString stringWithFormat:@"%.1f",slider.value];
    self.animateLabel.duration = slider.value;
}

- (IBAction)changeDelay:(id)sender {
    [self.animateLabel stopAnimationRestore:YES];
    UISlider *slider = (UISlider *)sender;
    self.delayLabel.text = [NSString stringWithFormat:@"%.1f",slider.value];
    self.animateLabel.delay = slider.value;
}

- (IBAction)changeFont:(id)sender {
    [self.animateLabel stopAnimationRestore:YES];
    UISlider *slider = (UISlider *)sender;
    self.fontLabel.text = [NSString stringWithFormat:@"%.1f",slider.value];
    self.animateLabel.font = [UIFont systemFontOfSize:slider.value];
}

- (IBAction)changeLayoutType:(id)sender {
    [self.animateLabel stopAnimationRestore:YES];
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    self.animateLabel.layoutType = segment.selectedSegmentIndex;
}

- (IBAction)changeTextAliment:(id)sender {
    [self.animateLabel stopAnimationRestore:YES];
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    self.animateLabel.textAlignment = segment.selectedSegmentIndex;
}

- (IBAction)startAnimation:(id)sender {
    if (self.animateLabel.type == CAAnimateLabelCustomType) {
        self.animateLabel.layerAnimate = !self.animateLabel.layerAnimate;
    }
    NSMutableArray <CATextAttribute *>*textAttr = self.animateLabel.textLayout.textAttrs;
    textAttr[0].animate = NO;
    [self.animateLabel startAnimation];
}

- (IBAction)stopAnimation:(id)sender {
    [self.animateLabel stopAnimationRestore:NO];
}

- (void)edit:(UIBarButtonItem *)item {
    [UIView animateWithDuration:0.2 animations:^{
        if (CGAffineTransformIsIdentity(self.editView.transform)) {
            
            self.editView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.editView.frame));
        }else {
            self.editView.transform = CGAffineTransformIdentity;
        }
     }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self edit:nil];
}


#pragma mark - CAAnimateLabelDelegate
- (void)prepareTextAttributes:(NSMutableArray<CATextAttribute *> *)textAttrs {
    for (CATextAttribute *attr in textAttrs) {
        if (attr.lineIndex % 2 == 1) {
            attr.animate = NO;
        }
    }
}

- (void)animationWillStartTextAttribute:(CATextAttribute *)textAttribute forIndex:(NSInteger)index {
    NSLog(@"%@ will start animation at index %ld",textAttribute.text,index);
}

- (void)animationDidEndTextAttribute:(CATextAttribute *)textAttribute forIndex:(NSInteger)index {
    NSLog(@"%@ did end animation at index %ld",textAttribute.text,index);
}

- (void)prepareLayerByTextAttribute:(CATextAttribute *)textAttribute forIndex:(NSInteger)index {
        //Layer Animation
    if (textAttribute.lineIndex % 2 == 1) {
        CATextAttributeLayer *layer = textAttribute.layer;
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        layer.backgroundColor = [UIColor clearColor].CGColor;
        [layer setNeedsDisplay];
        layer.opacity = 0;
        layer.anchorPoint = CGPointMake(0, 0);
        layer.position = CGPointMake(self.animateLabel.bounds.size.width, textAttribute.layer.position.y);
        [CATransaction commit];

    }else {
        CATextAttributeLayer *layer = textAttribute.layer;
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
        layer.backgroundColor = [UIColor clearColor].CGColor;
        layer.transform = CATransform3DMakeRotation((M_PI / 2), 0, 1, 0);
        [layer setNeedsDisplay];
        layer.anchorPoint = CGPointMake(0, 0.5);
        layer.position = CGPointMake(layer.position.x - CGRectGetWidth(textAttribute.rect)/2, layer.position.y);
        [CATransaction commit];

    }
}

- (CGRect)animationDrawRectForTextAttribute:(CATextAttribute *)textAttribute forIndex:(NSInteger)index {
        //Draw Animation
    if (textAttribute.lineIndex == 0) {
        
        return [self.animateLabel drawRect:self.animateLabel.bounds animationType:CAAnimateLabelZoomType textAttribute:textAttribute];
        
    }else if (textAttribute.lineIndex == 1) {
        
        return [self.animateLabel drawRect:self.animateLabel.bounds animationType:CAAnimateLabelFallType textAttribute:textAttribute];
        
    }else if (textAttribute.lineIndex == 2) {
        
       return [self.animateLabel drawRect:self.animateLabel.bounds animationType:CAAnimateLabelThrowType textAttribute:textAttribute];
        
    } else if (textAttribute.lineIndex == 3) {
        
        return [self.animateLabel drawRect:self.animateLabel.bounds animationType:CAAnimateLabelRevealType textAttribute:textAttribute];
        
    }else if (textAttribute.lineIndex == 4) {
        
        return [self.animateLabel drawRect:self.animateLabel.bounds animationType:CAAnimateLabelAlphaType textAttribute:textAttribute];
        
    }else if (textAttribute.lineIndex == 5) {
        
        return [self.animateLabel drawRect:self.animateLabel.bounds animationType:CAAnimateLabelSpringType textAttribute:textAttribute];
    }
    return textAttribute.rect;
}

- (void)animationAtRect:(CGRect)rect ForTextAttribute:(CATextAttribute *)textAttribute forIndex:(NSInteger)index {
    
        //Layer Animation
    if (self.animateLabel.layerAnimate) {
        
    if (textAttribute.lineIndex % 2 == 1) {
        [self.animateLabel dashAnimationWithTextAttribute:textAttribute];
    }else {
    
        [self.animateLabel spinAnimationWithTextAttribute:textAttribute];
    }
    
    }else {
        //Draw Animation
    
    if (textAttribute.lineIndex == 0) {
       
        [self.animateLabel zoomAnimationRect:rect textAttribute:textAttribute];
        
    }else if (textAttribute.lineIndex == 1) {
        
        [self.animateLabel fallAnimationRect:rect textAttribute:textAttribute];
        
    }else if (textAttribute.lineIndex == 2) {
        
       [self.animateLabel throwAnimationRect:rect textAttribute:textAttribute];

    } else if (textAttribute.lineIndex == 3) {

        [self.animateLabel revealAnimationRect:rect textAttribute:textAttribute];

    }else if (textAttribute.lineIndex == 4) {

        [self.animateLabel alphaAnimationRect:rect textAttribute:textAttribute];

    }else if (textAttribute.lineIndex == 5) {

        [self.animateLabel springAnimationRect:rect textAttribute:textAttribute];
    }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
