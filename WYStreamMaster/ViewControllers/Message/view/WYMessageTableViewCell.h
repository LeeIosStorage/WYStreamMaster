//
//  WYMessageTableViewCell.h
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/27.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WYMessageModel;
@interface WYMessageTableViewCell : UITableViewCell
- (void)updateMessageCellData:(WYMessageModel *)messageModel;
@end
