//
//  LiveGiftShowNumberView.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "LiveGiftShowNumberView.h"
#import "Masonry.h"


@interface LiveGiftShowNumberView ()

@property (nonatomic ,strong) UIImageView * digitIV;
@property (nonatomic ,strong) UIImageView * ten_digitIV;
@property (nonatomic ,strong) UIImageView * hundredIV;
@property (nonatomic ,strong) UIImageView * thousandIV;

@property (nonatomic ,strong) UIImageView * xIV;

@property (nonatomic ,assign) NSInteger lastNumber;/**< 最后显示的数字 */

@property (strong, nonatomic) PresentLabel *presentLabel;



@end

@implementation LiveGiftShowNumberView

@synthesize number = _number;

- (void)setNumber:(NSInteger)number{
    self.lastNumber = number;
}

- (NSInteger)number{
    _number = self.lastNumber ;
    self.lastNumber += 1;
    return _number;
    
}

/**
 获取显示的数字
 
 @return 显示的数字
 */
- (NSInteger)getLastNumber{
    return self.lastNumber - 1;
}

/**
 改变数字显示
 
 @param numberStr 显示的数字
 */

- (void)changeNumber:(NSInteger)numberStr
{
    [self addSubview:self.presentLabel];
    
    [self.presentLabel mas_makeConstraints:^(MASConstraintMaker *make) {

        make.edges.equalTo(self);
    }];
//    self.presentLabel.size = self.size;
//    self.presentLabel.origin = CGPointMake(0, 0);
    //[self.layer addSublayer:self.presentLabel.layer];
    
    NSArray *gradientColors = @[(id)[UIColor colorWithHexString:@"ff6600"].CGColor,(id)[UIColor colorWithHexString:@"ff6600"].CGColor,(id)[UIColor colorWithHexString:@"ffff00"].CGColor];
    self.presentLabel.colors = gradientColors;
    self.presentLabel.text = [NSString stringWithFormat:@"%ld", numberStr];
}



/*
- (void)changeNumber:(NSInteger)numberStr{
    if (numberStr <= 0) {
        return;
    }
    
    NSInteger num = numberStr;
    NSInteger qian = num / 1000;
    NSInteger qianYu = num % 1000;
    NSInteger bai = qianYu / 100;
    NSInteger baiYu = qianYu % 100;
    NSInteger shi = baiYu / 10;
    NSInteger shiYu = baiYu % 10;
    NSInteger ge = shiYu;
    
    if (numberStr > 9999) {
        qian = 9;
        bai = 9;
        shi = 9;
        ge = 9;
    }
    
    
    self.digitIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",ge]];
    [self addSubview:self.digitIV];
    [self addSubview:self.xIV];
    [self.xIV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).and.offset(15);
        make.centerY.equalTo(self).and.offset(-7);
        make.width.equalTo(@23);
        make.height.equalTo(@28);
    }];
    
    [self.digitIV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.xIV.mas_right).and.offset(17);
        make.centerY.equalTo(self).and.offset(-4);
    }];

    NSInteger length = 1;
    
    if (qian > 0) {
        length = 4;
        [self addSubview:self.thousandIV];
        [self addSubview:self.hundredIV];
        [self addSubview:self.ten_digitIV];
        
        self.thousandIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",qian]];
        self.hundredIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",bai]];
        self.ten_digitIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",shi]];
        [self.xIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).and.offset(15 * length);
            make.centerY.equalTo(self).and.offset(-7);
            make.width.equalTo(@23);
            make.height.equalTo(@28);
        }];
        [self.thousandIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.hundredIV.mas_left);
            make.centerY.equalTo(self);
        }];
        
        [self.hundredIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.ten_digitIV.mas_left);
            make.centerY.equalTo(self);
        }];
        
        [self.ten_digitIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.digitIV.mas_left);
            make.centerY.equalTo(self.digitIV);
        }];
    }else if (bai > 0){
        length = 3;
        [self.thousandIV removeFromSuperview];
        [self addSubview:self.hundredIV];
        [self addSubview:self.ten_digitIV];
        
        self.hundredIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",bai]];
        self.ten_digitIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",shi]];
        [self.xIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).and.offset(15 * length);
            make.centerY.equalTo(self).and.offset(-7);
            make.width.equalTo(@23);
            make.height.equalTo(@28);
        }];
        
        [self.hundredIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.ten_digitIV.mas_left);
            make.centerY.equalTo(self);
        }];
        
        [self.ten_digitIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.digitIV.mas_left);
            make.centerY.equalTo(self.digitIV);
        }];
    }else if (shi > 0){
        length = 2;
        [self.thousandIV removeFromSuperview];
        [self.hundredIV removeFromSuperview];
        [self addSubview:self.ten_digitIV];
        [self.xIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).and.offset(15 * length);
            make.centerY.equalTo(self).and.offset(-7);
            make.width.equalTo(@23);
            make.height.equalTo(@28);
        }];
        self.ten_digitIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",shi]];
        [self.ten_digitIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.digitIV.mas_left);
            make.centerY.equalTo(self.digitIV);
        }];
    }else {
        length = 1;
        [self.thousandIV removeFromSuperview];
        [self.hundredIV removeFromSuperview];
        [self.ten_digitIV removeFromSuperview];
    }
    
    
    
    
    [self layoutIfNeeded];
}
 */

- (PresentLabel *)presentLabel
{
    if (!_presentLabel) {
        _presentLabel = [[PresentLabel alloc] init];
        _presentLabel.font= [UIFont fontWithName:@"Arial-BoldItalicMT" size:60.0];
//        _presentLabel.textColor = [UIColor colorWithHexString:@"ff6600"];
        _presentLabel.textColor = [UIColor whiteColor];
        _presentLabel.shadowOffset = CGSizeMake(1, 1);
        _presentLabel.shadowColor = [UIColor colorWithHex:0 withAlpha:0.4];
        _presentLabel.textAlignment = NSTextAlignmentLeft;
        
        [_presentLabel sizeToFit];
    }
    return _presentLabel;
}




- (UIImageView *)xIV{
    if (!_xIV) {
        _xIV = [self creatIV];
        _xIV.image = [UIImage imageNamed:@"w_x"];
    }
    return _xIV;
}

- (UIImageView *)digitIV{
    if (!_digitIV) {
        _digitIV = [self creatIV];
    }
    return _digitIV;
}

- (UIImageView *)ten_digitIV{
    if (!_ten_digitIV) {
        _ten_digitIV = [self creatIV];
    }
    return _ten_digitIV;
}

- (UIImageView *)hundredIV{
    if (!_hundredIV) {
        _hundredIV = [self creatIV];
    }
    return _hundredIV;
}

- (UIImageView *)thousandIV{
    if (!_thousandIV) {
        _thousandIV = [self creatIV];
    }
    return _thousandIV;
}

- (UIImageView *)creatIV{
    UIImageView * iv = [[UIImageView alloc]init];
    return iv;
}

- (void)dealloc{
    NSLog(@"Delloc !!! %@",self);
}

@end

@implementation PresentLabel

//- (void)drawTextInRect:(CGRect)rect
//{
//    //[super drawTextInRect:rect];
// 
//    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName : self.font}];
//    CGRect textRect = (CGRect){0, 0, textSize};
//    
//    // 画文字(不做显示用 主要作用是设置layer的mask)
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [self.textColor set];
//    [self.text drawWithRect:rect options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.font} context:NULL];
//    
//    // 坐标 (只对设置后的画到context起作用 之前画的文字不起作用)
//    CGContextTranslateCTM(context, 0.0f, rect.size.height- (rect.size.height - textSize.height)*0.5);
//    CGContextScaleCTM(context, 1.0f, -1.0f);
//    
//    CGImageRef alphaMask = NULL;
//    alphaMask = CGBitmapContextCreateImage(context);
//    CGContextClearRect(context, rect);// 清除之前画的文字
//    
//    
//    // 设置mask
//    CGContextClipToMask(context, rect, alphaMask);
//    
//    // 画渐变色
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)self.colors, NULL);
//    CGPoint startPoint = CGPointMake(textRect.origin.x,
//                                     textRect.origin.y);
//    CGPoint endPoint = CGPointMake(textRect.origin.x ,
//                                   textRect.origin.y + textRect.size.height);
//    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
//    
//    // 释放内存
//    CGColorSpaceRelease(colorSpace);
//    CGGradientRelease(gradient);
//    CFRelease(alphaMask);
//}

- (void)startAnimationDuration:(NSTimeInterval)interval completion:(void (^)(BOOL finish))completion
{
    [UIView animateKeyframesWithDuration:interval delay:0 options:0 animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1/2.0 animations:^{
            self.transform = CGAffineTransformMakeScale(5, 5);
        }];
        [UIView addKeyframeWithRelativeStartTime:1/2.0 relativeDuration:1/2.0 animations:^{
            self.transform = CGAffineTransformMakeScale(0.8, 0.8);
        }];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
        
    }];
}

@end
