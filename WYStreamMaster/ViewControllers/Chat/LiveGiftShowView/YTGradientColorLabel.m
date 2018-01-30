//
//  YTGradientColorLabel.m
//  WYTelevision
//
//  Created by zurich on 2017/2/22.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTGradientColorLabel.h"

@implementation YTGradientColorLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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

@end
