//
//  WYSpaceHeaderView.m
//  WYTelevision
//
//  Created by Jyh on 2017/4/5.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "WYSpaceHeaderView.h"

@interface WYSpaceHeaderView ()

@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;


@end

@implementation WYSpaceHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    UITapGestureRecognizer *headerImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHeaderImageView)];
    [self.headerImageView addGestureRecognizer:headerImageViewTap];
}

- (void)updateHeaderViewWithData:(id)data
{
   
}

#pragma mark
#pragma mark - IBAction
- (void)clickHeaderImageView
{
    
}

@end
