//
//  WYSpaceHeaderView.h
//  WYTelevision
//
//  Created by Jyh on 2017/4/5.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYSpaceHeaderView : UICollectionReusableView

@property (strong, nonatomic) IBOutlet UIImageView *spaceHeaderImageView;
- (void)updateHeaderViewWithData:(id)data;

@end
