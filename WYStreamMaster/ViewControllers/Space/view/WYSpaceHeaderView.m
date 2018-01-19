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

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation WYSpaceHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.headerImageView.userInteractionEnabled = YES;
    self.spaceHeaderImageView.userInteractionEnabled = YES;

//    UITapGestureRecognizer *headerImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHeaderImageView)];
//    [self.headerImageView addGestureRecognizer:headerImageViewTap];
    UITapGestureRecognizer *headerViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSpaceHeaderImageView)];
    [self.spaceHeaderImageView addGestureRecognizer:headerViewTap];
    self.spaceHeaderImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.spaceHeaderImageView.clipsToBounds = YES;
//    self.backgroundImageView.layer.masksToBounds = YES;
//    self.backgroundImageView.layer.cornerRadius = (400 + kScreenWidth) / 2.0;
//    self.backgroundImageView.hidden = YES;
    
    
    CGRect rect = CGRectMake(0, 0, 400 + kScreenWidth, 400 + kScreenWidth);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake((400 + kScreenWidth) / 2.0, (400 + kScreenWidth) / 2.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    self.backgroundImageView.layer.mask = maskLayer;
}


#pragma mark 绘制圆弧
- (void)drawArc:(CGContextRef)context
{
    //1.获取上下文- 当前绘图的设备
    //    CGContextRef *context = UIGraphicsGetCurrentContext();
    //设置路径
    /*
     CGContextRef c:上下文
     CGFloat x ：x，y圆弧所在圆的中心点坐标
     CGFloat y ：x，y圆弧所在圆的中心点坐标
     CGFloat radius ：所在圆的半径
     CGFloat startAngle ： 圆弧的开始的角度  单位是弧度  0对应的是最右侧的点；
     CGFloat endAngle  ： 圆弧的结束角度
     int clockwise ： 顺时针（0） 或者 逆时针(1)
     */
    CGContextAddArc(context, 100, 100, 100, -M_PI_4, M_PI_2, 1);
    //绘制圆弧
    CGContextDrawPath(context, kCGPathStroke);
    
}

- (void)updateHeaderViewWithData:(id)data
{
    NSURL *avatarUrl = [NSURL URLWithString:[WYLoginUserManager avatar]];
    [WYCommonUtils setImageWithURL:avatarUrl setImageView:self.headerImageView placeholderImage:@"common_headImage"];}

#pragma mark
#pragma mark - IBAction
- (void)clickHeaderImageView
{
    
}

- (void)clickSpaceHeaderImageView
{
    if ([self.delegate respondsToSelector:@selector(spaceHeaderImageViewTapped)]) {
        [self.delegate spaceHeaderImageViewTapped];
    }
}

@end
