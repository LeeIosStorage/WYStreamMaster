//
//  YTMineNewCell.m
//  WYTelevision
//
//  Created by zurich on 2016/12/19.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "WYHelpCell.h"

@implementation WYHelpCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSDictionary *)dic
{
    self.styleLabel.text = dic[@"title"];
}

- (void)setFrame:(CGRect)frame{
    frame.origin.x += 10;
//    frame.origin.y += 10;
//    frame.size.height -= 10;
    frame.size.width -= 20;
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
