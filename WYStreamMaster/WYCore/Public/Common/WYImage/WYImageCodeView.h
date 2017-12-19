//
//  WYImageCodeView.h
//  WangYu
//
//  Created by Leejun on 15/12/11.
//  Copyright © 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WYImageCodeViewDelegate;

@interface WYImageCodeView : UIView

@property (nonatomic, assign) id <WYImageCodeViewDelegate>delegate;
@property (nonatomic, strong) NSString *telephone;

- (id)init:(id)owner;

- (void)showAnimationWithError;

- (void)show;

- (void)dismissView;

@end

@protocol WYImageCodeViewDelegate <NSObject>

-(void)affirmImageCodeViewWithCode:(NSString*)codeText;

@end