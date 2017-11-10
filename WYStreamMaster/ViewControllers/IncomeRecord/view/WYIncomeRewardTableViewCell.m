//
//  WYIncomeRewardTableViewCell.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/11/9.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYIncomeRewardTableViewCell.h"
@interface WYIncomeRewardTableViewCell ()
@property (strong, nonatomic) IBOutlet UILabel *rewardAmountLabel;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *trailingLayoutConstraint;
@end
@implementation WYIncomeRewardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)updateCellData:(NSDictionary *)giftValue row:(NSInteger)row
{
    if (row != 0) {
        self.timeLabel.backgroundColor = [UIColor colorWithHexString:@"cccccc"];
    } else {
        self.timeLabel.backgroundColor = [UIColor colorWithHexString:@"ffcc00"];
    }
    self.rewardAmountLabel.text = giftValue[@"anchor_get_value"];
    self.timeLabel.text = giftValue[@"gift_time"];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
