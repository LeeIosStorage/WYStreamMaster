//
//  YTInteractMessageTableViewCell.h
//  WYTelevision
//
//  Created by wangjingkeji on 2017/4/27.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WYSpaceDetailModel;
@interface YTInteractMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *isReadMessageImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *praiseImage;

@property (copy, nonatomic) void(^answerButtonBlock)(void);

@property (nonatomic, strong) WYSpaceDetailModel *model;
@end
