//
//  YTInteractMessageTableViewCell.m
//  WYTelevision
//
//  Created by wangjingkeji on 2017/4/27.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTInteractMessageTableViewCell.h"
#import "WYSpaceDetailModel.h"
@implementation YTInteractMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 27.5;
    [self.answerButton addTarget:self action:@selector(clickAnswerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.answerButton.layer setBorderWidth:2.0]; //边框宽度
    self.answerButton.layer.borderColor=[UIColor colorWithHexString:@"1cc7ff"].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(WYSpaceDetailModel *)model
{
    _model = model;
//    [self.avatarImageView setImageWithURL:[NSURL URLWithString:model.coverImage] placeholderImage:[UIImage imageNamed:@"common_default_avatar_82"]];
//    [self.avatarImageView setImageWithURL:[NSURL URLWithString:model.coverImage] placeholder:[UIImage imageNamed:@""]];
//    self.titleLabel.text = model.onickname;
//    self.dateLabel.text = [WYCommonUtils dateDiscriptionFromNowBk:[WYCommonUtils dateFromUSDateString:model.create_date]];
//    if ([model.interactType isEqualToString:@"5"]) {
//        self.praiseImage.hidden = YES;
//        self.desLabel.text = [NSString stringWithFormat:@"评论了《%@》:%@", model.bbstitle, model.ocontent];
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.desLabel.text];
//        self.desLabel.lineBreakMode = NSLineBreakByCharWrapping;
//        NSInteger legth = [model.bbstitle length]  + 2;
//        [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorHex(0x1cc7ff) range:NSMakeRange(3, legth)];
//        self.desLabel.attributedText = attributedString;
//        self.commentLabel.hidden = YES;
//    } else if ([model.interactType isEqualToString:@"6"]) {
//        self.praiseImage.hidden = YES;
//        self.desLabel.text = [NSString stringWithFormat:@"%@", model.ocontent];
//        if ([model.replynickname length] != 0) {
//            self.commentLabel.text = [NSString stringWithFormat:@"    我评论了《%@》:回复@%@ :%@",model.bbstitle, model.replynickname, model.mcontent];
//        } else {
//            self.commentLabel.text = [NSString stringWithFormat:@"    我评论了《%@》:%@",model.bbstitle, model.mcontent];
//        }
//        NSInteger legth = [model.bbstitle length]  + 2;
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.commentLabel.text];
//        [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorHex(0x1cc7ff) range:NSMakeRange(8, legth)];
//        self.commentLabel.attributedText = attributedString;
//    } else if ([model.interactType isEqualToString:@"7"]) {
//        self.praiseImage.hidden = NO;
//        [self.answerButton setTitle:@"查看" forState:UIControlStateNormal];
//        self.answerButton.userInteractionEnabled = NO;
//        [self.answerButton.layer setBorderWidth:0.0]; //边框宽度
//        self.titleLabel.text = [NSString stringWithFormat:@"%@赞了你", model.onickname];
//        self.desLabel.text = model.bbstitle;
//        self.desLabel.numberOfLines = 1;
//        self.commentLabel.hidden = YES;
//    }
    
    if ([model.parent_id length] == 0) {
        self.commentLabel.text = [NSString stringWithFormat:@"%@ :%@", model.nickname, model.content];
        NSMutableAttributedString *commentLabelAttributedString = [[NSMutableAttributedString alloc] initWithString:self.commentLabel.text];
        [commentLabelAttributedString addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"ff9900" withAlpha:1.0]} range:NSMakeRange(0, [model.nickname length] + 2)];
        self.commentLabel.attributedText = commentLabelAttributedString;
    } else if ([model.parent_id length] != 0) {
        self.commentLabel.text = [NSString stringWithFormat:@"%@ 回复 %@:%@", model.parent_nickname, model.nickname, model.content];
        NSMutableAttributedString *commentLabelAttributedString = [[NSMutableAttributedString alloc] initWithString:self.commentLabel.text];
        [commentLabelAttributedString addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"ff9900" withAlpha:1.0]} range:NSMakeRange(0, [model.nickname length] + 4 + [model.parent_nickname length])];
        self.commentLabel.attributedText = commentLabelAttributedString;
    }
}

- (void)updateInteractMessageWithInfo:(WYSpaceDetailModel *)spaceModel
{
    if ([spaceModel.parent_id length] == 0) {
        self.commentLabel.text = [NSString stringWithFormat:@"%@ :%@", spaceModel.nickname, spaceModel.content];
        NSMutableAttributedString *commentLabelAttributedString = [[NSMutableAttributedString alloc] initWithString:self.commentLabel.text];
        [commentLabelAttributedString addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, [spaceModel.nickname length] + 2)];
        self.commentLabel.attributedText = commentLabelAttributedString;
    } else if ([spaceModel.parent_id length] != 0) {
        self.commentLabel.text = [NSString stringWithFormat:@"%@ 回复 %@:%@", spaceModel.parent_nickname, spaceModel.nickname, spaceModel.content];
    }
}

- (void)clickAnswerButton:(UIButton *)sender
{
    if (self.answerButtonBlock) {
        self.answerButtonBlock();
    }
}

@end
