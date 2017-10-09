//
//  YTClassifyCommunityImageView.m
//  WYTelevision
//
//  Created by Jyh on 2017/4/13.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTClassifyCommunityImageView.h"

#define kImageWidth  75.f*kScreenWidth/375.f


@interface YTClassifyCommunityImageView ()

@property (strong, nonatomic) UIButton *viewAllButton;

@end

@implementation YTClassifyCommunityImageView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
}
- (void)updateImageViewWithArray:(NSMutableArray *)array
{
    kImageWidth > 75 ? 75 : kImageWidth;
    [self removeAllSubviews];
    for (int i = 0; i < [array count]; i ++) {
        
        if (i == 3) {
            [self addSubview:self.viewAllButton];
            self.viewAllButton.frame = CGRectMake(kImageWidth * 3 + 27, kImageWidth - 20, 45, 16);
            self.viewAllButton.hidden = NO;
        } else {
            self.viewAllButton.hidden = YES;
        }
        
        if (i > 2) {
            return;
        }
        
        NSString *imageURL = [NSString stringWithFormat:@"%@",array[i]];
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholder:[UIImage imageNamed:@"common_default_avatar_100"]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        // 解决图片出界之后还显示问题
        imageView.clipsToBounds = YES;

        imageView.frame = CGRectMake(12+ i * (kImageWidth + 5), 0, kImageWidth, kImageWidth);
        [self addSubview:imageView];
    }
}

- (UIButton *)viewAllButton {
    if (!_viewAllButton) {
        _viewAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _viewAllButton.layer.cornerRadius = 3;
        _viewAllButton.backgroundColor = [UIColor whiteColor];
        NSAttributedString *buttonString = [[NSAttributedString alloc] initWithString:@"查看全部" attributes: @{NSFontAttributeName:[UIFont systemFontOfSize:9], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"333333"]}];
        [_viewAllButton setAttributedTitle:buttonString forState:UIControlStateNormal];
        [_viewAllButton setTitleEdgeInsets:UIEdgeInsetsMake(2, 3, 2, 3)];
    }
    
    return _viewAllButton;
}

@end
