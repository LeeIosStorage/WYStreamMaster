//
//  WYStyleSheet.h
//  WYTelevision
//
//  Created by zurich on 16/8/23.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIEStyleSheetDummyObject : NSObject

@property (strong, nonatomic) id firstHelper;
@property (strong, nonatomic) id secondHelper;

@end

@interface WYStyleSheet : NSObject

+ (instancetype)defaultStyleSheet;
+ (instancetype)currentStyleSheet;

#pragma mark
#pragma mark - App Theme Style

@property (strong, nonatomic) UIColor *themeColor;
@property (strong, nonatomic) UIColor *themeBackgroundColor;

#pragma mark
#pragma mark - Tabbar Style

@property (strong, nonatomic) UIColor *tabBarSelectedTextColor;
@property (strong, nonatomic) UIColor *tabBarBackgroundColor;
@property (strong, nonatomic) UIColor *tabBarTextColor;
@property (strong, nonatomic) UIColor *tabBarShadowColor;

#pragma mark
#pragma mark - Navigation Style

@property (strong, nonatomic) UIFont *navTitleFont;
@property (strong, nonatomic) UIColor *navTextColor;

#pragma mark
#pragma mark - Banner Style
@property (strong, nonatomic) UIColor *pageControlNormalColor;
@property (strong, nonatomic) UIColor *currentPageColor;

#pragma mark 
#pragma mark - Label Style
@property (strong, nonatomic) UIColor *subheadLabelColor;
@property (strong, nonatomic) UIFont *subheadLabelFont;

@property (strong, nonatomic) UIColor *titleLabelColor;
@property (strong, nonatomic) UIColor *titleLabelSelectedColor;
@property (strong, nonatomic) UIColor *subtitleLabelColor;

#pragma mark
#pragma mark - Button Style
@property (strong, nonatomic) UIColor *normalButtonColor;
@property (strong, nonatomic) UIColor *selectedButtonColor;
@property (strong, nonatomic) UIColor *successLabelColor;       // 26d58d

@end
