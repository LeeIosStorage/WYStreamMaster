//
//  YTChatCell.h
//  WYTelevision
//
//  Created by zurich on 16/9/21.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YTChatModel.h"

@protocol CellDelegate <NSObject>

- (void)tappedCellNameWithChatModel:(YTChatModel *)model;

@end

@interface YTChatCell : UITableViewCell

@property (strong, nonatomic) YTChatModel *chatModel;
@property (weak, nonatomic) id <CellDelegate> cellDelegate;

- (void)updateDataWithMessage:(YTChatModel *)chatModel;



@end
