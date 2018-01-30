//
//  WYSpaceHeaderView.h
//  WYTelevision
//
//  Created by Jyh on 2017/4/5.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WYSpaceImageViewDelegate <NSObject>

-(void)spaceHeaderImageViewTapped;

@end
@interface WYSpaceHeaderView : UICollectionReusableView
@property (nonatomic, weak) id <WYSpaceImageViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *spaceHeaderImageView;
- (void)updateHeaderViewWithData:(id)data;

@end
