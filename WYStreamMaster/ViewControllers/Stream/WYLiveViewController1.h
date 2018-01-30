//
//  WYLiveViewController.h
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/10.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYSuperViewController.h"
#import "YTRoomView1.h"

@interface WYLiveViewController1 : WYSuperViewController

@property (strong, nonatomic) YTRoomView1 *roomView;//chatView

@property (nonatomic, strong) NSString *streamURL;


//@property (nonatomic, assign)BOOL isNewSocket;

@end
