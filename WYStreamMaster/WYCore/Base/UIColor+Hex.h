//
//  UIColor+Hex.h
//  FunChat
//
//  Created by Feizhu Tech . on 15/5/30.
//  Copyright (c) 2015年 hanbingquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

//默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)hex withAlpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hex;
+ (UIColor *)colorWithHex:(int)hex withAlpha:(CGFloat)alpha;
+ (UIColor *)colorWithHex:(int)hex;

@end
