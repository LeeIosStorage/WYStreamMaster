//
//  WYLoginViewController.h
//  WYRecordMaster
//
//  Created by zurich on 16/8/17.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYSuperViewController.h"

typedef void(^WYLoginSuccessBlock)(void);
typedef void(^WYLoginFailureBlock)(NSString *errorMessage);
typedef void(^WYLoginCancelBlock)(void);

@interface WYLoginViewController : WYSuperViewController
@property (assign, nonatomic) BOOL showCancelButton;

@property (nonatomic, copy) WYLoginSuccessBlock loginSuccessBlock;
@property (nonatomic, copy) WYLoginCancelBlock loginCancelBlock;
@property (nonatomic, copy) WYLoginFailureBlock loginFailureBlock;


@end
