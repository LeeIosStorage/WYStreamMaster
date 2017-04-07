//
//  WYAnchorInfoView.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/20.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYAnchorInfoView.h"

@interface WYAnchorInfoView ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *anchorImageView;
@property (nonatomic, strong) UILabel *anchorNameLabel;
@property (nonatomic, strong) UIImageView *hotImageView;
@property (nonatomic, strong) UILabel *hotNumLabel;

@property (nonatomic, strong) UIImageView *onLineImageView;
@property (nonatomic, strong) UILabel *onLineNumLabel;

@end

@implementation WYAnchorInfoView

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
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(40);
    }];
    
    [self addSubview:self.anchorImageView];
    [self.anchorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(1);
        make.top.equalTo(self).offset(1);
        make.bottom.equalTo(self.bgImageView.mas_bottom).offset(-1);
        make.width.equalTo(self.anchorImageView.mas_height);
    }];
    
    UIButton *anchorAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:anchorAvatarButton];
    [anchorAvatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.anchorImageView);
    }];
    [anchorAvatarButton addTarget:self action:@selector(anchorAvatarClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.anchorNameLabel];
    [self.anchorNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.anchorImageView.mas_right).offset(8);
        make.top.equalTo(self.anchorImageView).offset(4);
        make.right.equalTo(self).offset(-4);
        make.height.mas_equalTo(15);
    }];
    
    [self addSubview:self.hotImageView];
    [self.hotImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.anchorImageView.mas_right).offset(8);
        make.bottom.equalTo(self.bgImageView.mas_bottom).offset(-4);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    [self addSubview:self.hotNumLabel];
    [self.hotNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hotImageView.mas_right).offset(3);
        make.bottom.equalTo(self.bgImageView.mas_bottom).offset(-4);
        make.right.equalTo(self).offset(-4);
    }];
    
//    [self addSubview:self.onLineImageView];
//    [self.onLineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(6);
//        make.bottom.equalTo(self).offset(0);
//        make.size.mas_equalTo(CGSizeMake(20, 20));
//    }];
//    
//    [self addSubview:self.onLineNumLabel];
//    [self.onLineNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.onLineImageView.mas_right).offset(9);
//        make.bottom.equalTo(self).offset(-2);
//        make.right.equalTo(self);
//    }];
}

- (void)updateAnchorInfoWith:(id)anchorInfo{
    
    NSURL *avatarUrl = [NSURL URLWithString:[WYLoginUserManager avatar]];
    [WYCommonUtils setImageWithURL:avatarUrl setImageView:self.anchorImageView placeholderImage:@""];
    
    self.anchorNameLabel.text = [WYLoginUserManager nickname];
    self.hotNumLabel.text = @"230001";
    self.onLineNumLabel.text = @"1000000";
}

#pragma mark -
#pragma mark - Button Clicked
- (void)anchorAvatarClicked:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(anchorInfoViewAvatarClicked)]) {
        [self.delegate anchorInfoViewAvatarClicked];
    }
}

#pragma mark -
#pragma mark - Getters and Setters
- (UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
//        _bgImageView.image = [[UIImage imageNamed:@"wy_anchor_info_bg"] stretchableImageWithLeftCapWidth:90 topCapHeight:0];
        _bgImageView.layer.cornerRadius = 20;
        _bgImageView.layer.masksToBounds = YES;
        [_bgImageView.layer setBorderWidth:0.5];
        [_bgImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
        _bgImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _bgImageView;
}

- (UIImageView *)anchorImageView{
    if (!_anchorImageView) {
        _anchorImageView = [[UIImageView alloc] init];
        _anchorImageView.layer.masksToBounds = YES;
        _anchorImageView.layer.cornerRadius = 19.0f;
    }
    return _anchorImageView;
}

- (UILabel *)anchorNameLabel{
    if (!_anchorNameLabel) {
        _anchorNameLabel = [[UILabel alloc] init];
        _anchorNameLabel.textColor = [UIColor whiteColor];
        _anchorNameLabel.font = [UIFont boldSystemFontOfSize:12];
    }
    return _anchorNameLabel;
}

- (UIImageView *)hotImageView{
    if (!_hotImageView) {
        _hotImageView = [[UIImageView alloc] init];
        _hotImageView.image = [UIImage imageNamed:@"wy_live_online_num_icon"];//15x15
    }
    return _hotImageView;
}

- (UILabel *)hotNumLabel{
    if (!_hotNumLabel) {
        _hotNumLabel = [[UILabel alloc] init];
        _hotNumLabel.textColor = [UIColor colorWithHexString:@"fff000"];
        _hotNumLabel.font = [UIFont boldSystemFontOfSize:8];
    }
    return _hotNumLabel;
}

- (UIImageView *)onLineImageView{
    if (!_onLineImageView) {
        _onLineImageView = [[UIImageView alloc] init];
        _onLineImageView.image = [UIImage imageNamed:@"wy_live_online_num_icon"];
    }
    return _onLineImageView;
}

- (UILabel *)onLineNumLabel{
    if (!_onLineNumLabel) {
        _onLineNumLabel = [[UILabel alloc] init];
        _onLineNumLabel.textColor = [UIColor whiteColor];
        _onLineNumLabel.font = [UIFont boldSystemFontOfSize:8];
    }
    return _onLineNumLabel;
}

@end
