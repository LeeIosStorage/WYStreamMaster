//
//  WYDataMemoryManager.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/4/12.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYDataMemoryManager.h"
#import "WYGiftContributionModel.h"

@interface WYDataMemoryManager ()
{
    NSTimer *_currentTimer;
}
@property (nonatomic, strong) NSMutableArray *grossContributionList;

@end

@implementation WYDataMemoryManager

+ (WYDataMemoryManager *)sharedInstance
{
    static WYDataMemoryManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(& onceToken,^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)login{
    [self startTimer];
}

#pragma mark -
#pragma mark - Server
- (void)refreshGiftRecordList{
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"gift_ranking"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchor_user_code"];
    
    WEAKSELF
    [[WYNetWorkManager sharedManager] GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        
        if (requestType == WYRequestTypeSuccess) {
            
            weakSelf.grossContributionList = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [dataObject objectForKey:@"total"]) {
                
                WYGiftContributionModel *giftContributionModel = [[WYGiftContributionModel alloc] init];
                [giftContributionModel modelSetWithDictionary:dic];
                [weakSelf.grossContributionList addObject:giftContributionModel];
            }
            
        }else{
//            [MBProgressHUD showError:message toView:nil];
        }
        
    } failure:^(id responseObject, NSError *error) {
//        [MBProgressHUD showAlertMessage:@"请求失败，请检查您的网络设置后重试" toView:nil];
    }];
    
}

#pragma mark -
#pragma mark - Method

- (void)startTimer{
    if(_currentTimer){
        [_currentTimer invalidate];
        _currentTimer = nil;
    }
    
    _currentTimer = [NSTimer scheduledTimerWithTimeInterval:60.0*5 target:self selector:@selector(waitTimerInterval:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_currentTimer forMode:NSRunLoopCommonModes];
    [self waitTimerInterval:_currentTimer];
}

- (void)stopTimer{
    if(_currentTimer){
        [_currentTimer invalidate];
        _currentTimer = nil;
    }
}

- (void)waitTimerInterval:(NSTimer *)aTimer{
    WYLog(@"==============waitTimerInterval aTimer");
    [self refreshGiftRecordList];
}


- (NSString *)getContributionFirstUserId{
    NSString *userId = @"";
    if (self.grossContributionList.count > 0) {
        WYGiftContributionModel *giftContributionModel = [self.grossContributionList objectAtIndex:0];
        if (giftContributionModel.sendUserId.length > 0) {
            userId = giftContributionModel.sendUserId;
        }
    }
    return userId;
}

- (NSString *)getContributionSecondUserId{
    NSString *userId = @"";
    if (self.grossContributionList.count > 1) {
        WYGiftContributionModel *giftContributionModel = [self.grossContributionList objectAtIndex:1];
        if (giftContributionModel.sendUserId.length > 0) {
            userId = giftContributionModel.sendUserId;
        }
    }
    return userId;
}

- (NSString *)getContributionThirdUserId{
    NSString *userId = @"";
    if (self.grossContributionList.count > 2) {
        WYGiftContributionModel *giftContributionModel = [self.grossContributionList objectAtIndex:2];
        if (giftContributionModel.sendUserId.length > 0) {
            userId = giftContributionModel.sendUserId;
        }
    }
    return userId;
}

@end
