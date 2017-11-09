//
//  WYMessageTableViewCell.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/27.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYMessageTableViewCell.h"
#import "WYMessageModel.h"
@interface WYMessageTableViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@end
@implementation WYMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)updateMessageCellData:(WYMessageModel *)messageModel
{
    self.titleLabel.text = messageModel.title;
    self.contentLabel.text = messageModel.content;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
