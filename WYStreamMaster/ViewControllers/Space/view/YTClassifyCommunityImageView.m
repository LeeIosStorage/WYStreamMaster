//
//  YTClassifyCommunityImageView.m
//  WYTelevision
//
//  Created by Jyh on 2017/4/13.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTClassifyCommunityImageView.h"
#import "WYAvatarBrowser.h"
#define kImageWidth  100.f*kScreenWidth/375.f


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
            self.viewAllButton.hidden = YES;
        } else {
            self.viewAllButton.hidden = YES;
        }
        if (i > 2) {
            return;
        }
        NSString *imageStr = array[i];
//        NSString *imageCoverStr = [imageStr substringToIndex:imageStr.length - 1];
        
        NSString *imageURL = [NSString stringWithFormat:@"%@", imageStr];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = 100 + i;
        [imageView setClipsToBounds:YES];
        imageView.layer.cornerRadius = 5.0;
        [imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholder:[UIImage imageNamed:@"common_headImage"]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        // 解决图片出界之后还显示问题
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.frame = CGRectMake(12+ i * (kImageWidth + 5), 0, kImageWidth, kImageWidth);
        [self addSubview:imageView];
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(magnifyImage:)];
        UIView *singleTapView = [tap view];
        singleTapView.tag =1000 + i;
        [imageView addGestureRecognizer:tap];
    }
}

- (void)magnifyImage:(UITapGestureRecognizer *)tap
{
    NSInteger tapView = [tap view].tag;
    UIImageView *imageView = [self viewWithTag:tapView];
    NSLog(@"局部放大");
    [WYAvatarBrowser showImage:imageView]; //调用方法
}

- (UIButton *)viewAllButton {
    if (!_viewAllButton) {
        _viewAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _viewAllButton.hidden = YES;
        _viewAllButton.layer.cornerRadius = 3;
        _viewAllButton.backgroundColor = [UIColor whiteColor];
        NSAttributedString *buttonString = [[NSAttributedString alloc] initWithString:@"查看全部" attributes: @{NSFontAttributeName:[UIFont systemFontOfSize:9], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"333333"]}];
        [_viewAllButton setAttributedTitle:buttonString forState:UIControlStateNormal];
        [_viewAllButton setTitleEdgeInsets:UIEdgeInsetsMake(2, 3, 2, 3)];
    }
    
    return _viewAllButton;
}

@end
