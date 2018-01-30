//
//  WYLiveGameResultView.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/4/6.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYLiveGameResultView.h"
#import "WYServerNoticeAttachment.h"

@interface WYLiveGameResultView ()

@property (nonatomic, strong) UIImageView *bgImageView;

//德州、牛牛
@property (nonatomic, weak) IBOutlet UIView *oneItemView;
@property (nonatomic, weak) IBOutlet UILabel *oneResultLabel;
@property (nonatomic, weak) IBOutlet UIImageView *oneResultImageView;
@property (nonatomic, weak) IBOutlet UIView *twoItemView;
@property (nonatomic, weak) IBOutlet UILabel *twoResultLabel;
@property (nonatomic, weak) IBOutlet UIImageView *twoResultImageView;
@property (nonatomic, weak) IBOutlet UIView *threeItemView;
@property (nonatomic, weak) IBOutlet UILabel *threeResultLabel;
@property (nonatomic, weak) IBOutlet UIImageView *threeResultImageView;
@property (nonatomic, weak) IBOutlet UIView *fourItemView;
@property (nonatomic, weak) IBOutlet UILabel *fourResultLabel;

//百家乐
@property (nonatomic, weak) IBOutlet UIImageView *fourResultImageView;
@property (nonatomic, weak) IBOutlet UIImageView *fiveResultImageView;
@property (nonatomic, weak) IBOutlet UILabel *fiveResultLabel;
@property (nonatomic, weak) IBOutlet UIImageView *oneBoxImageView;
@property (nonatomic, weak) IBOutlet UIImageView *twoBoxImageView;
@property (nonatomic, weak) IBOutlet UIImageView *threeBoxImageView;
@property (nonatomic, weak) IBOutlet UIImageView *fourBoxImageView;
@property (nonatomic, weak) IBOutlet UIImageView *fiveBoxImageView;

@end

@implementation WYLiveGameResultView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        [self addSubview:_bgImageView];
        [self insertSubview:_bgImageView atIndex:0];
        [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self).offset(0);
            make.right.equalTo(self).offset(0);
        }];
    }
    return _bgImageView;
}

#pragma mark -
#pragma mark - Private Methods
- (void)setup{
//    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    
    self.bgImageView.image = [[UIImage imageNamed:@"game_result_bg"] stretchableImageWithLeftCapWidth:100 topCapHeight:30];
//    self.bgImageView.backgroundColor = [UIColor redColor];
    
//    self.oneItemView.layer.cornerRadius = 1.5;
//    self.oneItemView.layer.masksToBounds = YES;
//    [self.oneItemView.layer setBorderWidth:0.5];
//    [self.oneItemView.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
//    
//    self.twoItemView.layer.cornerRadius = 1.5;
//    self.twoItemView.layer.masksToBounds = YES;
//    [self.twoItemView.layer setBorderWidth:0.5];
//    [self.twoItemView.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
//    
//    self.threeItemView.layer.cornerRadius = 1.5;
//    self.threeItemView.layer.masksToBounds = YES;
//    [self.threeItemView.layer setBorderWidth:0.5];
//    [self.threeItemView.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
//    
//    self.fourItemView.layer.cornerRadius = 1.5;
//    self.fourItemView.layer.masksToBounds = YES;
//    [self.fourItemView.layer setBorderWidth:0.5];
//    [self.fourItemView.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
    
    self.oneResultImageView.image = nil;
    self.twoResultImageView.image = nil;
    self.threeResultImageView.image = nil;
}

- (void)afreshGameResultShow{
    self.oneResultImageView.image = nil;
    self.twoResultImageView.image = nil;
    self.threeResultImageView.image = nil;
    self.oneResultLabel.text = @"--";
    self.twoResultLabel.text = @"--";
    self.threeResultLabel.text = @"--";
    self.fourResultLabel.text = @"--";
    
    
    //百家乐相关元素
    self.fiveResultLabel.text = @"--";
    self.fourResultImageView.image = nil;
    self.fiveResultImageView.image = nil;
    
    self.oneBoxImageView.hidden = YES;
    self.twoBoxImageView.hidden = YES;
    self.threeBoxImageView.hidden = YES;
    self.fourBoxImageView.hidden = YES;
    self.fiveBoxImageView.hidden = YES;
    
    self.oneResultLabel.hidden = NO;
    self.twoResultLabel.hidden = NO;
    self.threeResultLabel.hidden = NO;
    self.fourResultLabel.hidden = NO;
    self.fiveResultLabel.hidden = NO;
}

- (void)updateWithGameResultInfo:(id)gameResultInfo{
    
    [self afreshGameResultShow];
    WYServerNoticeAttachment *serverNoticeAttachment = gameResultInfo;
    
    if (serverNoticeAttachment.anchorStatus == 0) {
        //不处理游戏结果
        return;
    }
    
    if (serverNoticeAttachment.gameStatus == 3) {
        NSArray *returnResult = [serverNoticeAttachment.contentData objectForKey:@"returnResult"];
        if ([WYLoginUserManager liveGameType] == LiveGameTypeTexasPoker || [WYLoginUserManager liveGameType] == LiveGameTypeTaurus) {
            [self updateTexasPokerResult:returnResult];
            
        }else if ([WYLoginUserManager liveGameType] == LiveGameTypeTiger){
            [self updateTigerResult:returnResult];
        }else if ([WYLoginUserManager liveGameType] == LiveGameTypeBaccarat){
            [self updateBaccaratResult:returnResult];
        }
    }
}

//德州和牛牛
- (void)updateTexasPokerResult:(id)returnResult{
    if ([returnResult isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in returnResult) {
            NSString *name = [dic objectForKey:@"name"];
            if ([name isEqualToString:@"闲一"]) {
                int game_result = [[dic objectForKey:@"game_result"] intValue];
                if (game_result == 0) {
                    self.oneResultImageView.image = [UIImage imageNamed:@"wy_gameresult_lose_1"];
                }else if (game_result == 1){
                    self.oneResultImageView.image = [UIImage imageNamed:@"wy_gameresult_win_1"];
                }else if (game_result == 2){
                    self.oneResultImageView.image = [UIImage imageNamed:@"wy_gameresult_he"];
                }
                self.oneResultLabel.text = [dic objectForKey:@"cardTypeDec"];
            }else if ([name isEqualToString:@"闲二"]){
                int game_result = [[dic objectForKey:@"game_result"] intValue];
                if (game_result == 0) {
                    self.twoResultImageView.image = [UIImage imageNamed:@"wy_gameresult_lose_2"];
                }else if (game_result == 1){
                    self.twoResultImageView.image = [UIImage imageNamed:@"wy_gameresult_win_2"];
                }else if (game_result == 2){
                    self.twoResultImageView.image = [UIImage imageNamed:@"wy_gameresult_he"];
                }
                self.twoResultLabel.text = [dic objectForKey:@"cardTypeDec"];
            }else if ([name isEqualToString:@"闲三"]){
                int game_result = [[dic objectForKey:@"game_result"] intValue];
                if (game_result == 0) {
                    self.threeResultImageView.image = [UIImage imageNamed:@"wy_gameresult_lose_3"];
                }else if (game_result == 1){
                    self.threeResultImageView.image = [UIImage imageNamed:@"wy_gameresult_win_3"];
                }else if (game_result == 2){
                    self.threeResultImageView.image = [UIImage imageNamed:@"wy_gameresult_he"];
                }
                self.threeResultLabel.text = [dic objectForKey:@"cardTypeDec"];
            }else if ([name isEqualToString:@"庄"]){
                self.fourResultLabel.text = [dic objectForKey:@"cardTypeDec"];
            }
        }
    }
}

- (void)updateTigerResult:(id)returnResult{
    
    if ([returnResult isKindOfClass:[NSArray class]]) {
        //        self.oneBoxImageView.hidden = NO;
        //        self.twoBoxImageView.hidden = NO;
        //        self.threeBoxImageView.hidden = NO;
        //        self.fourBoxImageView.hidden = NO;
        //        self.fiveBoxImageView.hidden = NO;
        self.oneResultLabel.hidden = YES;
        self.twoResultLabel.hidden = YES;
        self.threeResultLabel.hidden = YES;
        self.fourResultLabel.hidden = YES;
        self.fiveResultLabel.hidden = YES;
        
        for (NSDictionary *dic in returnResult) {
            NSString *name = [dic objectForKey:@"name"];
            if ([name isEqualToString:@"龙"]) {
                int game_result = [[dic objectForKey:@"game_result"] intValue];
                if (game_result == 0) {
                    self.oneResultImageView.image = [UIImage imageNamed:@"gr_lose_icon"];
                }else if (game_result == 1){
                    self.oneResultImageView.image = [UIImage imageNamed:@"gr_win_icon"];
                }
                //                self.oneResultLabel.text = [dic objectForKey:@"cardTypeDec"];
            }else if ([name isEqualToString:@"和"]){
                int game_result = [[dic objectForKey:@"game_result"] intValue];
                if (game_result == 0) {
                    self.twoResultImageView.image = [UIImage imageNamed:@"gr_lose_icon"];
                }else if (game_result == 1){
                    self.twoResultImageView.image = [UIImage imageNamed:@"gr_win_icon"];
                }
                //                self.twoResultLabel.text = [dic objectForKey:@"cardTypeDec"];
            }else if ([name isEqualToString:@"虎"]){
                int game_result = [[dic objectForKey:@"game_result"] intValue];
                if (game_result == 0) {
                    self.threeResultImageView.image = [UIImage imageNamed:@"gr_lose_icon"];
                }else if (game_result == 1){
                    self.threeResultImageView.image = [UIImage imageNamed:@"gr_win_icon"];
                }
                //                self.threeResultLabel.text = [dic objectForKey:@"cardTypeDec"];
            }
        }
    }
    
}


- (void)updateBaccaratResult:(id)returnResult{
    
    if ([returnResult isKindOfClass:[NSArray class]]) {
        self.oneBoxImageView.hidden = NO;
        self.twoBoxImageView.hidden = NO;
        self.threeBoxImageView.hidden = NO;
        self.fourBoxImageView.hidden = NO;
        self.fiveBoxImageView.hidden = NO;
        self.oneResultLabel.hidden = YES;
        self.twoResultLabel.hidden = YES;
        self.threeResultLabel.hidden = YES;
        self.fourResultLabel.hidden = YES;
        self.fiveResultLabel.hidden = YES;
        
        for (NSDictionary *dic in returnResult) {
            NSString *name = [dic objectForKey:@"name"];
            if ([name isEqualToString:@"庄对"]) {
                int game_result = [[dic objectForKey:@"game_result"] intValue];
                if (game_result == 0) {
                    self.oneResultImageView.image = [UIImage imageNamed:@"gr_lose_icon"];
                }else if (game_result == 1){
                    self.oneResultImageView.image = [UIImage imageNamed:@"gr_win_icon"];
                }
                //                self.oneResultLabel.text = [dic objectForKey:@"cardTypeDec"];
            }else if ([name isEqualToString:@"庄"]){
                int game_result = [[dic objectForKey:@"game_result"] intValue];
                if (game_result == 0) {
                    self.twoResultImageView.image = [UIImage imageNamed:@"gr_lose_icon"];
                }else if (game_result == 1){
                    self.twoResultImageView.image = [UIImage imageNamed:@"gr_win_icon"];
                }
                //                self.twoResultLabel.text = [dic objectForKey:@"cardTypeDec"];
            }else if ([name isEqualToString:@"和"]){
                int game_result = [[dic objectForKey:@"game_result"] intValue];
                if (game_result == 0) {
                    self.threeResultImageView.image = [UIImage imageNamed:@"gr_lose_icon"];
                }else if (game_result == 1){
                    self.threeResultImageView.image = [UIImage imageNamed:@"gr_win_icon"];
                }
                //                self.threeResultLabel.text = [dic objectForKey:@"cardTypeDec"];
            }else if ([name isEqualToString:@"闲"]){
                int game_result = [[dic objectForKey:@"game_result"] intValue];
                if (game_result == 0) {
                    self.fourResultImageView.image = [UIImage imageNamed:@"gr_lose_icon"];
                }else if (game_result == 1){
                    self.fourResultImageView.image = [UIImage imageNamed:@"gr_win_icon"];
                }
                //                self.fourResultLabel.text = [dic objectForKey:@"cardTypeDec"];
            }else if ([name isEqualToString:@"闲对"]){
                int game_result = [[dic objectForKey:@"game_result"] intValue];
                if (game_result == 0) {
                    self.fiveResultImageView.image = [UIImage imageNamed:@"gr_lose_icon"];
                }else if (game_result == 1){
                    self.fiveResultImageView.image = [UIImage imageNamed:@"gr_win_icon"];
                }
                //                self.fiveResultLabel.text = [dic objectForKey:@"cardTypeDec"];
            }
        }
    }
}

@end
