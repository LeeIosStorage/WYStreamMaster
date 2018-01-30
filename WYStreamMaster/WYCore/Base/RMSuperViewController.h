//
//  RMSuperViewController.h
//  WYRecordMaster
//
//  Created by zurich on 16/8/19.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMSuperViewController : UIViewController

@property (strong, nonatomic,readonly) UIBarButtonItem  *leftBarButtonItem;
@property (strong, nonatomic,readonly) UIBarButtonItem  *rightBarButtonItem;

///默认是返回按钮,如果需要可以设置backImage
@property (strong, nonatomic) UIImage                   *backImage;

@property (weak, nonatomic) IBOutlet UIImageView    *accountError;
@property (weak, nonatomic) IBOutlet UIImageView    *passwordError;
@property (weak, nonatomic) IBOutlet UIImageView    *verificatCodeError;

- (void)doBack;

@end
