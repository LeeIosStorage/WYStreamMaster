//
//  NSString+Value.h
//  WYTelevision
//
//  Created by Leejun on 16/8/24.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Value)

- (BOOL)isPhone;
- (BOOL)isEmail;
//检测phone是否合法
- (BOOL)isValidatePhone;
//检测email是否合法
- (BOOL)isValidateEmail;
//身份证验证
- (BOOL) validateIdentityCard;
//网址验证
- (BOOL) isValidateUrl;

//统计混编字符
- (int)      GetLength;
//计算字符宽度
- (CGFloat)  GetWidth:(CGFloat)Height Font:(UIFont *)Font;
//计算字符高度
- (CGFloat)  GetHeight:(CGFloat)Width Font:(UIFont *)Font;
//判断是否数字
- (BOOL)     GetFigure:(BOOL)Point;

//字符转换图片
- (NSData *) GetDataImage;
//字符计算时差
- (NSTimeInterval)GetTimeValue;
// 判断是否全为空格
+ (BOOL)isEmpty:(NSString *)str;

@end
