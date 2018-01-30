//
//  WYCustomAlertView.m
//  WYTelevision
//
//  Created by zurich on 16/9/8.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYCustomAlertView.h"

typedef NS_ENUM(NSInteger, WYAlertType) {
    WYAlertNormalType,
    WYAlertCustomType
};

@interface WYCustomAlertView ()

@property (strong, nonatomic) UIView    *showView;

@property (assign, nonatomic) CGFloat   showHeight;
@property (assign, nonatomic) CGFloat   showWidth;

@property (strong, nonatomic) NSString  *titleString;
@property (strong, nonatomic) NSString  *messageString;
@property (strong, nonatomic) NSString  *cancelTitleString;
@property (strong, nonatomic) NSString  *otherTitleString;


@property (assign, nonatomic) BOOL showSingleButton;
@property (copy, nonatomic) AlertButtonClickedBlock alertButtonClickedBlock;

@property (assign, nonatomic) WYAlertType   type;

@end

@implementation WYCustomAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCustomAlertSize:(CGSize )alertSize;
{
    if (self = [self init]) {
        self.type = WYAlertCustomType;
        
        self.showHeight = alertSize.height;
        self.showWidth = alertSize.width;
        
        [self initShowView];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(nullable NSString *)message cancelTitle:(nullable NSString *)cancelTitle otherTitle:(nullable NSString *)otherTitle alertActionBlock:(AlertButtonClickedBlock)alertActionBlock
{
    
    self = [self init];
    self.type = WYAlertNormalType;
    self.showHeight = ShowViewDefualtHeight;
    self.showWidth = ShowViewDefualtWidth;
    self.titleString = title;
    self.messageString = message;
    self.cancelTitleString = cancelTitle;
    self.otherTitleString = otherTitle;
    self.alertButtonClickedBlock = alertActionBlock;
    
    if (cancelTitle && otherTitle) {
        self.showSingleButton = NO;
    } else if (cancelTitle == nil || otherTitle == nil) {
        self.showSingleButton = YES;
    }
    [self initShowView];
    [self initNormalAlertView];
    return self;
}

- (id)init
{
    if (self = [super init]) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self];
        self.hidden = YES;
        
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:.4f];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(window);
        }];
        
    }
    return self;
}

#pragma mark -
#pragma mark - Init Subview

- (void)initShowView
{
    self.showView = [[UIView alloc] initWithFrame:CGRectZero];
    self.showView.layer.masksToBounds = YES;
    self.showView.layer.cornerRadius = 10.f;
    self.showView.backgroundColor = [UIColor colorWithHexString:@"323A43"];
    [self addSubview:_showView];
    [self.showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(self.showWidth);
        make.height.mas_equalTo(self.showHeight);
    }];
}

- (void)initNormalAlertView
{
    WEAKSELF
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:17.f];
    titleLabel.textColor = [UIColor colorWithHexString:@"FF3366"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.showView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@20);
        make.left.equalTo(self.showView);
        make.right.equalTo(self.showView);
        make.height.mas_equalTo(@15);
    }];
    
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.numberOfLines = 0;
    messageLabel.font = [UIFont systemFontOfSize:13.f];
    messageLabel.textColor = [UIColor colorWithHexString:@"465667"];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [self.showView addSubview:messageLabel];
    //假设只考虑单行
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).and.offset(25.f);
        make.left.equalTo(self.showView);
        make.right.equalTo(self.showView);
        make.height.mas_equalTo(@14);
    }];
    
    CGFloat buttonWidth = 110.f;
    CGFloat space = (ShowViewDefualtWidth - buttonWidth * 2 ) / 3;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.titleLabel.textColor = [UIColor colorWithHexString:@"8E8E9A"];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_button"] forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.f]];
    cancelButton.tag = 0;
    [cancelButton addTarget:self action:@selector(clickeAlertButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.showView addSubview:cancelButton];
    
 
    
    UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    otherButton.titleLabel.textColor = [UIColor colorWithHexString:@"FFFFFF"];
    [otherButton setBackgroundImage:[UIImage imageNamed:@"ensure_button"] forState:UIControlStateNormal];
    [otherButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.f]];
    otherButton.tag = 1;
    [otherButton addTarget:self action:@selector(clickeAlertButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.showView addSubview:otherButton];
    
    if (!self.showSingleButton) {
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(messageLabel.mas_bottom).and.offset(10);
            make.left.mas_equalTo(space);
            make.size.mas_equalTo(CGSizeMake(buttonWidth, 60));
        }];
        
        [otherButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cancelButton);
            make.left.equalTo(cancelButton.mas_right).and.offset(space);
            make.size.mas_equalTo(CGSizeMake(buttonWidth, 60));
        }];
    } else {
        [otherButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(messageLabel.mas_bottom).and.offset(10);
            make.centerX.equalTo(weakSelf.showView);
            make.size.mas_equalTo(CGSizeMake(buttonWidth, 60));
        }];
    }
  
    
    titleLabel.text = self.titleString;
    messageLabel.text = self.messageString;
    [cancelButton setTitle:self.cancelTitleString forState:UIControlStateNormal];
    [otherButton setTitle:self.otherTitleString forState:UIControlStateNormal];
}

- (void)initCloseButton
{
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setImage:[UIImage imageNamed:@"bomb_box_delete"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeShowView) forControlEvents:UIControlEventTouchUpInside];
    [self.showView addSubview:_closeButton];
    [self.showView bringSubviewToFront:_closeButton];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.showView).and.offset(0);
        make.top.mas_equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
}

#pragma mark -
#pragma mark - Public Method

- (void)showWithView:(UIView *)view
{
    [self.showView addSubview:view];
    if (self.type == WYAlertCustomType) {
        //防止关闭按钮被遮挡
        self.showView.backgroundColor = [UIColor clearColor];
        [self initCloseButton];
    }
    self.hidden = NO;
    [self showAnimation];
}

- (void)showWithHUDView:(UIView *)view
{
    [self.showView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.showView);
    }];
    //self.backgroundColor = [UIColor clearColor];
 
    self.hidden = NO;
    [self showAnimation];
}

#pragma mark -
#pragma mark - Action

- (void)showAnimation
{
    if (self.showView) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values = @[@(0.8), @(1.05), @(1.1), @(1)];
        animation.keyTimes = @[@(0), @(0.3), @(0.5), @(1.0)];
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        animation.duration = .2f;
        [self.showView.layer addAnimation:animation forKey:@"bouce"];
    }
}

- (void)dissmiss
{
    [self dismissAnimation];
}

- (void)dismissAnimation
{
    CGFloat duration = .2f;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.showView.alpha = 0;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.showView.transform = CGAffineTransformMakeScale(0.4, 0.4);
    } completion:^(BOOL finished) {
        self.showView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)closeShowView
{
    [self dissmiss];
}

- (void)clickeAlertButton:(UIButton *)button
{
    [self dissmiss];
//    if (button.tag == 0) {
//        [self dissmiss];
//    }
    if (self.alertButtonClickedBlock) {
        self.alertButtonClickedBlock(button.tag);
    }
    
}

@end
