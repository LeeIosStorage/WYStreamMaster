//
//  YTMineNewCell.h
//  WYTelevision
//
//  Created by zurich on 2016/12/19.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYHelpCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *styleLabel;
@property (weak, nonatomic) IBOutlet UIButton *descButton;
@property (strong, nonatomic) IBOutlet UIImageView *hotImage;

- (void)updateCell:(NSDictionary *)dic;

@end
