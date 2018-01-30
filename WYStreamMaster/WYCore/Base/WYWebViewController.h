//
//  WYWebViewController.h
//  WYTelevision
//
//  Created by zurich on 16/9/10.
//  Copyright © 2016年 Zurich. All rights reserved.
//


#import "WYSuperViewController.h"
@interface WYWebViewController : WYSuperViewController

@property (assign, nonatomic) BOOL canShare;

- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURLString:(NSString *)urlString;



@end
