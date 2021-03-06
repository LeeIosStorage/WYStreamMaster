//
//  YTItemView.m
//  WYTelevision
//
//  Created by zurich on 2016/10/1.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTItemView.h"

@interface YTItemView ()

@property (strong, nonatomic) UIScrollView *itemScrollView;

@property (strong, nonatomic) UIView *lineView;
@property (assign, nonatomic) CGFloat itemWidth;
@property (strong, nonatomic) UIButton *beforSeletedButton;

@property (assign, nonatomic) YTItemViewType itemViewType;

@end

@implementation YTItemView

- (instancetype)initWithFrame:(CGRect)frame Items:(NSArray *)items
{
    if (self = [super initWithFrame:frame]) {
        self.items = items;
        [self initViews];
    }
    return self;
}

- (void)initWithItems:(NSArray *)items itemType:(YTItemViewType )itemType
{
    self.items = items;
    self.itemViewType = itemType;
    [self initViews];
}

- (void)initViews
{
    [self addSubview:self.itemScrollView];
    if (self.itemViewType == YTItemViewTypeNormal) {
        self.itemScrollView.backgroundColor = [UIColor whiteColor];
    } else {
        self.itemScrollView.backgroundColor = [UIColor clearColor];
    }
    
//    [self.itemScrollView addSubview:self.lineView];
    
    for (int i = 0; i < self.items.count; i++) {
        NSString *itemTitle = self.items[i];
        UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        if (i != 1) {
//            [itemButton.layer setMasksToBounds:YES];
//            [itemButton.layer setCornerRadius:4.0]; //设置矩形四个圆角半径
//        }
        itemButton.layer.borderColor=[UIColor colorWithHexString:@"000000"].CGColor;
        //边框宽度
        [itemButton.layer setBorderWidth:1.0];
        [itemButton setTitle:itemTitle forState:UIControlStateNormal];
        [self.itemScrollView addSubview:itemButton];
        itemButton.size = CGSizeMake(self.itemWidth, self.height);
        itemButton.left = i * self.itemWidth;
        itemButton.top = 0;
        itemButton.titleLabel.font = [UIFont systemFontOfSize:13.f];
        [itemButton setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
        [itemButton addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
        itemButton.tag = 10 + i;
        if (i == 0) {
            [self setBezierPathLeft:itemButton];
            //self.lineView.centerY = itemButton.centerY;
            self.lineView.centerX = itemButton.centerX;
            self.lineView.bottom = itemButton.bottom;
            if (self.itemViewType == YTItemViewTypeBorder) {
                [itemButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
            } else {
                [itemButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
                itemButton.backgroundColor = [UIColor blackColor];
            }
            self.beforSeletedButton = itemButton;
        } else if (i == 2) {
            [self setBezierPathRight:itemButton];
        }
    }
}

- (void)toSelectedItemWithIndex:(NSInteger )itemIndex
{
    UIButton *searchButton = [self viewWithTag:10 + itemIndex];
    [self itemClicked:searchButton];
}

- (void)itemClicked:(UIButton *)button
{
    if (self.beforSeletedButton != button) {
        [self.beforSeletedButton setTitleColor:[UIColor colorWithHexString:@"333333"]  forState:UIControlStateNormal];
        self.beforSeletedButton.backgroundColor = [UIColor clearColor];
        if (self.itemViewType == YTItemViewTypeBorder) {
            [button setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
        } else {
            [button setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
            button.backgroundColor = [UIColor blackColor];
        }
        
        self.beforSeletedButton = button;
        [self lineMoveWithButton:button];
    }
    self.seletedIndex = button.tag - 10;
    if (self.itemSeletedBlock) {
        self.itemSeletedBlock(button.tag - 10);
    }
}

- (void)setBezierPathLeft:(UIButton *)button
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = button.bounds;
    maskLayer.path = maskPath.CGPath;
    button.layer.mask = maskLayer;
}

- (void)setBezierPathRight:(UIButton *)button
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = button.bounds;
    maskLayer.path = maskPath.CGPath;
    button.layer.mask = maskLayer;
}

- (void)lineMoveWithButton:(UIButton *)button
{
    [UIView animateWithDuration:.3f animations:^{
        self.lineView.centerX = button.centerX;
    }];
}

- (UIScrollView *)itemScrollView
{
    if (!_itemScrollView) {
        _itemScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(37.5, 0, self.width - 75, self.height)];
        self.itemWidth = self.width / self.items.count - 25;
        self.itemScrollView.contentSize = CGSizeMake(self.width, self.height);
        self.itemScrollView.showsVerticalScrollIndicator = NO;
        self.itemScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _itemScrollView;
}

- (UIView *)lineView
{
    if (!_lineView) {
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [WYStyleSheet defaultStyleSheet].titleLabelSelectedColor;
        if (self.itemViewType == YTItemViewTypeBorder) {
            self.lineView.size = CGSizeMake(_itemWidth, self.height);
            self.lineView.layer.masksToBounds = YES;
            self.lineView.layer.cornerRadius = 15.f;
            self.layer.masksToBounds = YES;
            self.layer.cornerRadius = 15.f;
        } else {
            self.lineView.size = CGSizeMake(50, 3);
        }
    }
    return _lineView;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
