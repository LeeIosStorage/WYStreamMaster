//
//  WYShareActionSheet.h
//  WYTelevision
//
//  Created by Leejun on 16/9/21.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WYShareActionSheetDelegate;

@interface WYShareActionSheet : UIView

@property (nonatomic, weak) UIViewController<WYShareActionSheetDelegate> *owner;

@property (nonatomic, assign) BOOL isVideo;         //是否视频分享

@property (nonatomic, assign) BOOL isPureImage;     //是否纯图片分享

- (void) shareInfoData:(id)shareInfo;

- (void) showShareAction;

- (void) cancelActionSheet;

@end

@protocol WYShareActionSheetDelegate <NSObject>
@optional

@end
