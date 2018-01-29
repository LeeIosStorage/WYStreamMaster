//
//  YTClassifyBottomView.m
//  WYTelevision
//
//  Created by Jyh on 2017/4/13.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTPrimaryBetRankingView.h"
#import "WYBetStarModel.h"
@interface YTPrimaryBetRankingView ()
@property (strong, nonatomic) IBOutlet UILabel *betRankingFirstLabel;
@property (strong, nonatomic) IBOutlet UILabel *betRankingSecondLabel;
@property (strong, nonatomic) IBOutlet UILabel *betRankingThirdLabel;
@property (strong, nonatomic) IBOutlet UIButton *questionMarkButton;

@end

@implementation YTPrimaryBetRankingView
- (void)awakeFromNib
{
    [super awakeFromNib];
}


- (void)updateBottomViewWithInfo:(NSMutableArray *)infoArray
{
    [self updateViewWithInfo:infoArray];
}

- (void)updateViewWithInfo:(NSMutableArray *)infoArray
{
    if (infoArray.count == 0) {
        self.betRankingSecondLabel.text = @"暂无人投注，您可以口播鼓励大家投注!";
        self.betRankingSecondLabel.textColor = [UIColor whiteColor];
        self.betRankingSecondLabel.backgroundColor = [UIColor clearColor];
        [self.betRankingSecondLabel setTextAlignment:NSTextAlignmentCenter];
        self.betRankingSecondLabel.font = [UIFont systemFontOfSize:15.0f];
        self.betRankingFirstLabel.hidden = YES;
        self.betRankingThirdLabel.hidden = YES;
    } else {
        self.betRankingSecondLabel.hidden = YES;
    }
    for (int i = 0; i < 3; i++) {
        if (infoArray.count > i) {
            WYBetStarModel *model = infoArray[i];
            NSString *contentString = [NSString stringWithFormat:@"    %@  在您的房间赢取高额的奖励 ", model.userNickName];
            NSRange nameRane = [contentString rangeOfString:[NSString stringWithFormat:@"    %@  ", model.userNickName]];
            NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] initWithString:contentString];
            [contentAttributedString setColor:[UIColor whiteColor] range:nameRane];
            
            switch (i) {
                case 0:
                    self.betRankingFirstLabel.hidden = NO;
                    self.betRankingFirstLabel.text = contentString;
                    self.betRankingFirstLabel.attributedText = contentAttributedString;
                    break;
                case 1:
                    self.betRankingSecondLabel.hidden = NO;
                    [self.betRankingSecondLabel setTextAlignment:NSTextAlignmentLeft];
                    self.betRankingSecondLabel.backgroundColor = [UIColor colorWithHexString:@"F89903"];
                    self.betRankingSecondLabel.font = [UIFont systemFontOfSize:12.0f];
                    self.betRankingSecondLabel.text = contentString;
                    self.betRankingSecondLabel.attributedText = contentAttributedString;
                    break;
                case 2:
                    self.betRankingThirdLabel.hidden = NO;
                    self.betRankingThirdLabel.text = contentString;
                    self.betRankingThirdLabel.attributedText = contentAttributedString;
                    break;
                    
                default:
                    break;
            }
        }
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
