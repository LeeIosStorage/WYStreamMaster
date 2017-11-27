//
//  YTClassifyBottomView.m
//  WYTelevision
//
//  Created by Jyh on 2017/4/13.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTClassifyBottomView.h"
#import "YTClassifyBBSDetailModel.h"
//#import "WYNewVideoDetailViewController.h"
#import "WYShareActionSheet.h"
#import "WYNetWorkManager.h"
#import "WYLoginManager.h"
#import "WYSpaceDetailViewController.h"
@interface YTClassifyBottomView ()

@property (strong, nonatomic) YTClassifyBBSDetailModel *bbsDetail;

@property (strong, nonatomic) WYShareActionSheet *shareAction;

@end

@implementation YTClassifyBottomView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.bottomLikeButton setImage:[UIImage imageNamed:@"video_detail_buttom_liked"] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    
    [self.bottomShareButton addTarget:self action:@selector(onCommunityInfoShareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomCommentButton addTarget:self action:@selector(onCommunityInfoCommentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomLikeButton addTarget:self action:@selector(onCommunityInfoLikeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)updateBottomViewWithInfo:(YTClassifyBBSDetailModel *)data
{
    if ([data isKindOfClass:[YTClassifyBBSDetailModel class]]) {
        self.bbsDetail = (YTClassifyBBSDetailModel *)data;
        if ([self.bbsDetail.comment integerValue] > 0) {
            [self.bottomCommentButton setTitle:[NSString stringWithFormat:@"%@", self.bbsDetail.comment] forState:UIControlStateNormal];
            [self.bottomCommentButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
        } else {
            [self.bottomCommentButton setTitle:nil forState:UIControlStateNormal];
            [self.bottomCommentButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        
        if ([self.bbsDetail.praiseNumber integerValue] > 0) {
            [self.bottomLikeButton setTitle:[NSString stringWithFormat:@"%@", self.bbsDetail.praiseNumber] forState:UIControlStateNormal];
            [self.bottomLikeButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
        } else {
            [self.bottomLikeButton setTitle:nil forState:UIControlStateNormal];
            [self.bottomLikeButton setImageEdgeInsets:UIEdgeInsetsZero];
        }
        
        self.bottomLikeButton.selected = self.bbsDetail.isPraise;
//        [self.bottomCommentButton setTitle:@"892" forState:UIControlStateNormal];
//        [self.bottomLikeButton setTitle:@"7277" forState:UIControlStateNormal];
    }
}

- (void)onCommunityInfoShareButtonClick:(UIButton *)button
{
//    WYSuperViewController *currentVC = (WYSuperViewController *)[WYCommonUtils getCurrentVC];
//    
//    self.shareAction = [[WYShareActionSheet alloc] init];
//    self.shareAction.owner = currentVC;
//    
//    [self.shareAction shareInfoData:self.bbsDetail];
//    [self.shareAction showShareAction];    
//    
//    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"share_statistics"];
//    
//    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
//    [paramsDic setObject:self.bbsDetail.postsID forKey:@"id"];
//    // 帖子 1  资讯 2
//    [paramsDic setValue:@"1" forKey:@"type"];
//    WYNetWorkManager *networkManager = [[WYNetWorkManager alloc] init];
//    [networkManager GET:requestUrl needCache:NO caCheKey:nil parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
//        
//        if (requestType == WYRequestTypeSuccess) {
//            
//        }
//    } failure:^(id responseObject, NSError *error) {
//        
//    }];
}

- (void)onCommunityInfoCommentButtonClick:(UIButton *)button
{
    WYSuperViewController *currentVC = (WYSuperViewController *)[WYCommonUtils getCurrentVC];
    if (currentVC) {
        
        if (self.bbsDetail.bbsType == YTBBSTypeVideo) {
//            WYNewVideoDetailViewController *vc = [[WYNewVideoDetailViewController alloc] init];
//            vc.videoId = self.bbsDetail.videoID;
//            [currentVC.navigationController pushViewController:vc animated:YES];
        } else {
            WYSpaceDetailViewController *vc = [[WYSpaceDetailViewController alloc] init:self.bbsDetail];
            vc.hidesBottomBarWhenPushed = YES;
            [currentVC.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)onCommunityInfoLikeButtonClick:(UIButton *)button
{
    WEAKSELF
    if (button.selected) {
        return;
    }
    button.selected = !button.selected;
    if (button.selected) {
        self.bbsDetail.praiseNumber = [NSString stringWithFormat:@"%d",([self.bbsDetail.praiseNumber intValue] + 1)];
        self.bbsDetail.isPraise = YES;
        [self.bottomLikeButton setTitle:self.bbsDetail.praiseNumber forState:UIControlStateNormal];
    }
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"upvote_blog"];
    
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:self.bbsDetail.identity forKey:@"blog_id"];
    [paramsDic setValue:[WYLoginUserManager userID] forKey:@"user_code"];
    [paramsDic setValue:self.bbsDetail.upvote_id forKey:@"upvote_id"];

     WYNetWorkManager *networkManager = [[WYNetWorkManager alloc] init];
    [networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        STRONGSELF
        if (requestType == WYRequestTypeSuccess) {
            // 点赞成功
        } else {
            button.selected = NO;
            strongSelf.bbsDetail.praiseNumber = [NSString stringWithFormat:@"%d",([strongSelf.bbsDetail.praiseNumber intValue] - 1)];
            strongSelf.bbsDetail.isPraise = NO;
            [strongSelf.bottomLikeButton setTitle:[NSString stringWithFormat:@"%d", [strongSelf.bbsDetail.praiseNumber intValue]] forState:UIControlStateNormal];
            [MBProgressHUD showError:message];
        }
    } failure:^(id responseObject, NSError *error) {
        
    }];
}

@end
