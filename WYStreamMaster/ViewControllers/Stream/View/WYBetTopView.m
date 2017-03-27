//
//  WYBetTopView.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/24.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYBetTopView.h"

#define offset_tag 202

@interface WYBetTopView ()

@property (nonatomic, strong) UIView *addSupView;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) NSMutableArray *betTopList;

@end

@implementation WYBetTopView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark -
#pragma mark - Private Methods
- (void)setup{
    
    self.betTopList = [NSMutableArray array];
    
    self.backgroundColor = [UIColor colorWithHex:0 withAlpha:0.5];
    self.layer.cornerRadius = 20;
    self.layer.masksToBounds = YES;
    [self.layer setBorderWidth:0.5];
    [self.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [self addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(40);
    }];
    [self.closeButton addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    
    for (int index = 0; index < 3; index ++) {
        [self addItemWithIndex:index];
    }
    
}

- (UIView *)addItemWithIndex:(NSInteger)index{
    UIView *view = [[UIView alloc] init];
    view.tag = offset_tag + index;
    [self addSubview:view];
    CGFloat top = 60+index*(50+6);
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(top);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    UIImageView *avatarImageView = [[UIImageView alloc] init];
    avatarImageView.layer.cornerRadius = 20;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.tag = 0;
    [view addSubview:avatarImageView];
    [avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(view);
        make.height.mas_equalTo(40);
    }];
    
    UIImageView *rankImageView = [[UIImageView alloc] init];
    rankImageView.tag = 1;
    [view addSubview:rankImageView];
    [rankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view);
        make.top.equalTo(view).offset(-4);
        make.size.mas_equalTo(CGSizeMake(19, 19));
    }];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.tag = 2;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:10];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(view);
        make.top.equalTo(avatarImageView.mas_bottom).offset(1);
    }];
    
    return view;
}

- (void)updateBetTopData{
    self.betTopList = [NSMutableArray array];
    [self.betTopList addObject:@""];
    [self.betTopList addObject:@""];
    [self.betTopList addObject:@""];
    
    for (int index = 0; index < 3; index ++) {
        UIView *view = [self viewWithTag:offset_tag+index];
        if (index >= self.betTopList.count) {
            view.hidden = YES;
            continue;
        }
        view.hidden = NO;
        UIImageView *avatarImageView = [view viewWithTag:0];
        UIImageView *rankImageView = [view viewWithTag:1];
        UILabel *nameLabel = [view viewWithTag:2];
        NSURL *avatarUrl = [NSURL URLWithString:@"https://imgsa.baidu.com/baike/c0%3Dbaike180%2C5%2C5%2C180%2C60/sign=e6c6c4a53ddbb6fd3156ed74684dc07d/b64543a98226cffca90bcfecbd014a90f603ea4f.jpg"];
        [WYCommonUtils setImageWithURL:avatarUrl setImageView:avatarImageView placeholderImage:@""];
        UIImage *rankImage = [UIImage imageNamed:@"wy_betTop_1_icon"];
        if (index == 1) {
            rankImage = [UIImage imageNamed:@"wy_betTop_2_icon"];
        }else if (index == 2){
            rankImage = [UIImage imageNamed:@"wy_betTop_3_icon"];
        }
        [rankImageView setImage:rankImage];
        nameLabel.text = @"Carlos";
    }
}

- (void)show:(UIView *)supView{
    
    if ((![self superview] || self.hidden) && supView) {
        _addSupView = supView;
        [supView addSubview:self];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(supView).offset(70);
            make.right.equalTo(supView).offset(-10);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(0);
        }];
        
        [supView layoutIfNeeded];
        
        [UIView animateWithDuration:0.3f animations:^{
            [self setHidden:NO];
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(245);
            }];
            [supView layoutIfNeeded];
        }];
    }
}

- (void)hide
{
    if ([self superview]) {
        [UIView animateWithDuration:0.3f animations:^{
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            [_addSupView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self setHidden:YES];
        }];
    }
}

#pragma mark -
#pragma mark - Server

#pragma mark -
#pragma mark - Button Clicked
- (void)closeClick
{
    [self hide];
}

#pragma mark -
#pragma mark - Getters and Setters
- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"wy_betTop_icon"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

@end
