//
//  WYChatUserNormalView.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/28.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYChatUserNormalView.h"

@interface WYChatUserNormalView ()

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *muteButton;
@property (nonatomic, weak) IBOutlet UIButton *setManagerButton;

@end

@implementation WYChatUserNormalView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.avatarImageView.layer.cornerRadius = 32;
    self.avatarImageView.layer.masksToBounds = YES;
    
    self.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *effe = [[UIVisualEffectView alloc]initWithEffect:blur];
    effe.frame = CGRectMake(0, 0 , self.width,self.height);
    [effe setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self insertSubview:effe atIndex:0];
    
}

- (void)updateWithMemeber:(id )member{
    
    NIMChatroomMember *roomMember = member;
    
    NSURL *avatarUrl = [NSURL URLWithString:roomMember.roomAvatar];
    [WYCommonUtils setImageWithURL:avatarUrl setImageView:self.avatarImageView placeholderImage:@""];
    self.userNameLabel.text = roomMember.roomNickname;
    
    if (roomMember.type == NIMChatroomMemberTypeManager) {
        [self.setManagerButton setTitle:@"取消房管" forState:UIControlStateNormal];
    }else if (roomMember.type == NIMChatroomMemberTypeGuest || roomMember.type == NIMChatroomMemberTypeNormal){
        [self.setManagerButton setTitle:@"设立房管" forState:UIControlStateNormal];
    }
    
//    if (roomMember.isTempMuted) {
//        //解禁言
//        [self.muteButton setTitle:@"解除禁言" forState:UIControlStateNormal];
//    }else{
//        
//    }
    //禁言
    [self.muteButton setTitle:@"禁言24h" forState:UIControlStateNormal];
    
}

#pragma mark -
#pragma mark - Action
- (IBAction)muteAction:(id)sender{
    if (_letMemberMuteBlock) {
        _letMemberMuteBlock();
    }
}

- (IBAction)managerAction:(id)sender{
    if (_letManagerBlock) {
        _letManagerBlock();
    }
}

@end
