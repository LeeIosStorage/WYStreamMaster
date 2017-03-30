//
//  YTChatCell.m
//  WYTelevision
//
//  Created by zurich on 16/9/21.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTChatCell.h"

@interface YTChatCell ()

@property (strong, nonatomic) YYLabel *contentLabel;

@end

@implementation YTChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        self.contentLabel.left = 0;
        self.contentLabel.top = 0;
        self.contentLabel.width = SCREEN_WIDTH-kRoomChatViewCustomWidth;
        self.contentLabel.height = 20.f;
//        self.contentLabel.shadowOffset = CGSizeMake(1, 1);
//        self.contentLabel.shadowColor = [UIColor blackColor];
        [self.contentView addSubview:_contentLabel];
    }
    return self;
}

- (void)updateDataWithMessage:(YTChatModel *)chatModel
{
    if (chatModel.message.messageType == NIMMessageTypeCustom) {
        NSLog(@"custom");
    }
    WEAKSELF
    self.contentLabel.textTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
        if ([weakSelf judgeRange:range inRange:chatModel.nameRange]) {
            //在此范围内，可点击
            if ([weakSelf.cellDelegate respondsToSelector:@selector(tappedCellNameWithChatModel:)]) {
                [weakSelf.cellDelegate tappedCellNameWithChatModel:chatModel];
            }
        }
    };
    
    self.contentLabel.height = chatModel.chatTextLayout.textBoundingSize.height;
    self.contentLabel.textLayout = chatModel.chatTextLayout;
}

- (BOOL)judgeRange:(NSRange )range inRange:(NSRange )inRange
{
    if (range.location >= inRange.location && range.location <= (inRange.location + inRange.length)) {
        return YES;
    }
    return NO;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
