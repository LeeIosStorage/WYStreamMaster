//
//  WYAnchorInfoView.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/20.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WYAnchorInfoViewDelegate;

@interface WYAnchorInfoView : UIView

@property (nonatomic, assign) id <WYAnchorInfoViewDelegate> delegate;

- (void)updateAnchorInfoWith:(id)anchorInfo;

@end

@protocol WYAnchorInfoViewDelegate <NSObject>

@optional
- (void)anchorInfoViewAvatarClicked;

@end
