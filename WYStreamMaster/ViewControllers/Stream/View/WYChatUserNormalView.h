//
//  WYChatUserNormalView.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/28.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYChatUserNormalView : UIView

@property (copy, nonatomic) void (^letMemberMuteBlock)(void);
@property (copy, nonatomic) void (^letManagerBlock)(void);

- (void)updateWithMemeber:(id)member;

@end
