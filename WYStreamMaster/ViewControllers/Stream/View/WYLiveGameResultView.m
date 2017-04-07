//
//  WYLiveGameResultView.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/4/6.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYLiveGameResultView.h"

@interface WYLiveGameResultView ()

@property (nonatomic, weak) IBOutlet UIView *oneItemView;
@property (nonatomic, weak) IBOutlet UILabel *oneResultLabel;
@property (nonatomic, weak) IBOutlet UIImageView *oneResultImageView;
@property (nonatomic, weak) IBOutlet UIView *twoItemView;
@property (nonatomic, weak) IBOutlet UILabel *twoResultLabel;
@property (nonatomic, weak) IBOutlet UIImageView *twoResultImageView;
@property (nonatomic, weak) IBOutlet UIView *threeItemView;
@property (nonatomic, weak) IBOutlet UILabel *threeResultLabel;
@property (nonatomic, weak) IBOutlet UIImageView *threeResultImageView;
@property (nonatomic, weak) IBOutlet UIView *fourItemView;
@property (nonatomic, weak) IBOutlet UILabel *fourResultLabel;

@end

@implementation WYLiveGameResultView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

#pragma mark -
#pragma mark - Private Methods
- (void)setup{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    
    self.oneItemView.layer.cornerRadius = 1.5;
    self.oneItemView.layer.masksToBounds = YES;
    [self.oneItemView.layer setBorderWidth:0.5];
    [self.oneItemView.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
    
    self.twoItemView.layer.cornerRadius = 1.5;
    self.twoItemView.layer.masksToBounds = YES;
    [self.twoItemView.layer setBorderWidth:0.5];
    [self.twoItemView.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
    
    self.threeItemView.layer.cornerRadius = 1.5;
    self.threeItemView.layer.masksToBounds = YES;
    [self.threeItemView.layer setBorderWidth:0.5];
    [self.threeItemView.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
    
    self.fourItemView.layer.cornerRadius = 1.5;
    self.fourItemView.layer.masksToBounds = YES;
    [self.fourItemView.layer setBorderWidth:0.5];
    [self.fourItemView.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
    
}

- (void)updateWithGameResultInfo:(id)gameResultInfo{
    
    self.oneResultImageView.image = [UIImage imageNamed:@"wy_gameresult_win_1"];
    self.oneResultLabel.text = @"皇家同花顺";
    
    self.twoResultImageView.image = [UIImage imageNamed:@"wy_gameresult_win_2"];
    self.twoResultLabel.text = @"同花顺";
    
    self.threeResultImageView.image = [UIImage imageNamed:@"wy_gameresult_lose_3"];
    self.threeResultLabel.text = @"葫芦";
    
    self.fourResultLabel.text = @"三条";
}

@end
