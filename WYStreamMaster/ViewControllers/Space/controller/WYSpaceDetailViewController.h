//
//  WYSpaceDetailViewController.h
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/11/10.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYBaseCollectionController.h"
@class YTClassifyBBSDetailModel;
@interface WYSpaceDetailViewController : WYBaseCollectionController
@property (nonatomic, copy) NSString *topicId;
@property (nonatomic, assign) BOOL isClickCommentBtn;
- (instancetype)init:(YTClassifyBBSDetailModel *)spaceListModel;
@end
