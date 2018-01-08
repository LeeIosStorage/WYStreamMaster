//
//  YTClassifyBottomView.m
//  WYTelevision
//
//  Created by Jyh on 2017/4/13.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTBetRankingView.h"

@interface YTBetRankingView ()
@property (strong, nonatomic) IBOutlet UILabel *betRankingFirstLabel;
@property (strong, nonatomic) IBOutlet UILabel *betRankingSecondLabel;
@property (strong, nonatomic) IBOutlet UILabel *betRankingThirdLabel;
@property (strong, nonatomic) IBOutlet UILabel *betRankingFourthLabel;
@property (strong, nonatomic) IBOutlet UILabel *betRankingFifthLabel;
@property (strong, nonatomic) IBOutlet UILabel *betRankingSixthLabel;
@property (strong, nonatomic) IBOutlet UILabel *betRankingSeventhLabel;
@property (strong, nonatomic) IBOutlet UILabel *betRankingEighthLabel;
@property (strong, nonatomic) IBOutlet UILabel *betRankingNinthLabel;
@property (strong, nonatomic) IBOutlet UIButton *questionMarkButton;

@end

@implementation YTBetRankingView
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.betRankingFirstLabel.layer.borderColor = [UIColor colorWithHexString:@"ffcc00"].CGColor;
    self.betRankingFirstLabel.layer.borderWidth = 1.0;
    
    self.betRankingSecondLabel.layer.borderColor = [UIColor colorWithHexString:@"ffcc00"].CGColor;
    self.betRankingSecondLabel.layer.borderWidth = 1.0;
    
    self.betRankingThirdLabel.layer.borderColor = [UIColor colorWithHexString:@"ffcc00"].CGColor;
    self.betRankingThirdLabel.layer.borderWidth = 1.0;
    
    self.betRankingFourthLabel.layer.borderColor = [UIColor colorWithHexString:@"ffcc00"].CGColor;
    self.betRankingFourthLabel.layer.borderWidth = 1.0;
    
    self.betRankingFifthLabel.layer.borderColor = [UIColor colorWithHexString:@"ffcc00"].CGColor;
    self.betRankingFifthLabel.layer.borderWidth = 1.0;
    
    
    self.betRankingSixthLabel.layer.borderColor = [UIColor colorWithHexString:@"ffcc00"].CGColor;
    self.betRankingSixthLabel.layer.borderWidth = 1.0;
    
    self.betRankingSeventhLabel.layer.borderColor = [UIColor colorWithHexString:@"ffcc00"].CGColor;
    self.betRankingSeventhLabel.layer.borderWidth = 1.0;
    
    self.betRankingEighthLabel.layer.borderColor = [UIColor colorWithHexString:@"ffcc00"].CGColor;
    self.betRankingEighthLabel.layer.borderWidth = 1.0;
    
    self.betRankingNinthLabel.layer.borderColor = [UIColor colorWithHexString:@"ffcc00"].CGColor;
    self.betRankingNinthLabel.layer.borderWidth = 1.0;
}


- (void)updateBottomViewWithInfo:(YTClassifyBBSDetailModel *)data
{
    if (self.betRankingType == BetRankingSeniorType) {
        self.betMostLabel.text = @"高级场下注最多";
    } else {
        self.betMostLabel.text = @"初级场下注最多";
    }
}

- (void)onCommunityInfoShareButtonClick:(UIButton *)button
{

}

- (void)onCommunityInfoCommentButtonClick:(UIButton *)button
{
  
}

- (void)onCommunityInfoLikeButtonClick:(UIButton *)button
{

}

- (IBAction)clickQuestionMarkButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(clickQuestionMarkButton)]) {
        [self.delegate clickQuestionMarkButton];
    }
}
@end
