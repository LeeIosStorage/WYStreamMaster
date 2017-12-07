//
//  WYIncomeRecordTableViewCell.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/28.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYIncomeRecordTableViewCell.h"
#import "WYContributionInformationModel.h"
@interface WYIncomeRecordTableViewCell ()
@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;
@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (strong, nonatomic) IBOutlet UILabel *rankingLabel;
@end

@implementation WYIncomeRecordTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCellData:(WYContributionInformationModel *)contributionInformationModel
{
    [self.headerImageView setImageWithURL:[NSURL URLWithString:contributionInformationModel.head_icon] placeholder:[UIImage imageNamed:@"common_headImage"]];
    self.nicknameLabel.text = contributionInformationModel.nickname;
    self.rankingLabel.text = [NSString stringWithFormat:@"NO.%@", contributionInformationModel.gift_value];
}

@end
