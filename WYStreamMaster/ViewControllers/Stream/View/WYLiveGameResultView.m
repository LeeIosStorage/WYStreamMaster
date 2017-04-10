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

@end

@implementation WYLiveGameResultView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

#pragma mark -
#pragma mark - Private Methods
- (void)setup{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    
    self.oneItemView.layer.cornerRadius = 1.5;
    self.oneItemView.layer.masksToBounds = YES;
    [self.oneItemView.layer setBorderWidth:0.5];
    [self.oneItemView.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
    
    self.twoItemView.layer.cornerRadius = 1.5;
    self.twoItemView.layer.masksToBounds = YES;
    [self.twoItemView.layer setBorderWidth:0.5];
    [self.twoItemView.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
    
    self.threeItemView.layer.cornerRadius = 1.5;
    self.threeItemView.layer.masksToBounds = YES;
    [self.threeItemView.layer setBorderWidth:0.5];
    [self.threeItemView.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
    
    self.fourItemView.layer.cornerRadius = 1.5;
    self.fourItemView.layer.masksToBounds = YES;
    [self.fourItemView.layer setBorderWidth:0.5];
    [self.fourItemView.layer setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
    
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
}

- (void)updateWithGameResultInfo:(id)gameResultInfo{
    
    [self afreshGameResultShow];
    WYServerNoticeAttachment *serverNoticeAttachment = gameResultInfo;
    
    if (serverNoticeAttachment.gameStatus == 3) {
        NSArray *returnResult = [serverNoticeAttachment.contentData objectForKey:@"returnResult"];
        if ([returnResult isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in returnResult) {
                NSString *name = [dic objectForKey:@"name"];
                if ([name isEqualToString:@"福"]) {
                    int game_result = [[dic objectForKey:@"game_result"] intValue];
                    if (game_result == 0) {
                        self.oneResultImageView.image = [UIImage imageNamed:@"wy_gameresult_lose_1"];
                    }else if (game_result == 1){
                        self.oneResultImageView.image = [UIImage imageNamed:@"wy_gameresult_win_1"];
                    }
                    self.oneResultLabel.text = [dic objectForKey:@"cardTypeDec"];
                }else if ([name isEqualToString:@"禄"]){
                    int game_result = [[dic objectForKey:@"game_result"] intValue];
                    if (game_result == 0) {
                        self.twoResultImageView.image = [UIImage imageNamed:@"wy_gameresult_lose_2"];
                    }else if (game_result == 1){
                        self.twoResultImageView.image = [UIImage imageNamed:@"wy_gameresult_win_2"];
                    }
                    self.twoResultLabel.text = [dic objectForKey:@"cardTypeDec"];
                }else if ([name isEqualToString:@"寿"]){
                    int game_result = [[dic objectForKey:@"game_result"] intValue];
                    if (game_result == 0) {
                        self.threeResultImageView.image = [UIImage imageNamed:@"wy_gameresult_lose_3"];
                    }else if (game_result == 1){
                        self.threeResultImageView.image = [UIImage imageNamed:@"wy_gameresult_win_3"];
                    }
                    self.threeResultLabel.text = [dic objectForKey:@"cardTypeDec"];
                }else if ([name isEqualToString:@"庄"]){
                    self.fourResultLabel.text = [dic objectForKey:@"cardTypeDec"];
                }
            }
        }
    }
}

@end
