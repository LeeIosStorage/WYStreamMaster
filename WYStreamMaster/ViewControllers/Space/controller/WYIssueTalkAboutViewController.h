//
//  CommentSubmitViewController.h
//  WangYu
//
//  Created by miqu on 16/8/11.
//  Copyright © 2016年 KID. All rights reserved.
//

#import "WYSuperViewController.h"
//#import "WYAmuseCommentInfo.h"

typedef enum SubmitType_{
    SubmitType_CommentRoom = 7,               //主播间评论
    SubmitType_CommentVideo = 8,              //视频评论
    
}SubmitType;

@protocol CommentSubmitViewControllerDelegate;

@interface WYIssueTalkAboutViewController : WYSuperViewController

@property (nonatomic, strong) NSString *bountyId;

@property (nonatomic, assign) SubmitType submitType;

@property (weak, nonatomic) id <CommentSubmitViewControllerDelegate> delegate;

@end

@protocol CommentSubmitViewControllerDelegate <NSObject>
@optional
//- (void)submitRequestSucceedWithCommentInfo:(WYAmuseCommentInfo *)commentInfo;

@end
