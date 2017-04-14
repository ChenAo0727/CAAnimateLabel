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

- (void)initAnimateLabel {
    self.animateLabel.type = self.animateType;
    if (self.animateType == CAAnimateLabelCustomType) {
        self.animateLabel.delayAfterComplete = YES;
    }
    self.animateLabel.layoutType = CATextLayoutSentenceType;
    self.animateLabel.lineSpacing = 10;
    self.animateLabel.textColor = [UIColor greenColor];
    self.animateLabel.textAlignment = CATextAlignmentCenter;
    self.animateLabel.font = [UIFont systemFontOfSize:18.0];
    self.animateLabel.duration = 3.0;
    self.animateLabel.delay = 0.5;
    self.animateLabel.repeatCount = 1;
    self.animateLabel.text = @"青春，是人生中最美的风景。\n青春，是一场花开的遇见；\n青春，是一场痛并快乐着的旅行；\n青春，是一场轰轰烈烈的比赛；\n青春，是一场鲜衣奴马的争荣岁月；\n青春，是一场风花雪月的光阴。";
    self.animateLabel.contentInsets = UIEdgeInsetsMake(100, 10, 10, 10);
    if (self.animateType == CAAnimateLabelCustomType) {
        self.animateLabel.delegate = self;
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
- (void)animationWillStartTextAttribute:(CATextAttribute *)textAttribute forIndex:(NSInteger)index {
    NSLog(@"%@ will start animation at index %ld",textAttribute.text,index);
}

- (void)animationDidEndTextAttribute:(CATextAttribute *)textAttribute forIndex:(NSInteger)index {
    NSLog(@"%@ did end animation at index %ld",textAttribute.text,index);
}

- (void)animationAtRect:(CGRect)rect textAttribute:(CATextAttribute *)textAttribute forIndex:(NSInteger)index {
    CGRect drawRect ;
    NSInteger i = index % 6;
    if (i == 0) {
       
       drawRect = [self.animateLabel drawRect:rect animationType:CAAnimateLabelZoomType textAttribute:textAttribute];
        [self.animateLabel zoomAnimationRect:drawRect textAttribute:textAttribute];
    }else if (i == 1) {
        drawRect = [self.animateLabel drawRect:rect animationType:CAAnimateLabelFallType textAttribute:textAttribute];
        [self.animateLabel fallAnimationRect:drawRect textAttribute:textAttribute];
    }else if (i == 2) {
        drawRect = [self.animateLabel drawRect:rect animationType:CAAnimateLabelRevealType textAttribute:textAttribute];
        [self.animateLabel revealAnimationRect:drawRect textAttribute:textAttribute];

    }else if (i == 3) {
        drawRect = [self.animateLabel drawRect:rect animationType:CAAnimateLabelThrowType textAttribute:textAttribute];
        [self.animateLabel throwAnimationRect:drawRect textAttribute:textAttribute];

    }else if (i == 4) {
        drawRect = [self.animateLabel drawRect:rect animationType:CAAnimateLabelAlphaType textAttribute:textAttribute];
        [self.animateLabel alphaAnimationRect:drawRect textAttribute:textAttribute];

    }else if (i == 5) {
        drawRect = [self.animateLabel drawRect:rect animationType:CAAnimateLabelSpringType textAttribute:textAttribute];
        [self.animateLabel springAnimationRect:drawRect textAttribute:textAttribute];
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
