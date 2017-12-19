//
//  WYLiveEndViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/12/7.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYLiveEndViewController.h"
#import "WYHomePageViewController.h"
@interface WYLiveEndViewController ()
@property (nonatomic, assign) NSInteger liveDurationTime;
@property (strong, nonatomic) IBOutlet UIImageView *headerimageView;
@property (strong, nonatomic) IBOutlet UILabel *anchorNicknameLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong, nonatomic) IBOutlet UIImageView *bagroundImageView;
@property (strong, nonatomic) IBOutlet UIImage *liveEndImage;

@end

@implementation WYLiveEndViewController
- (instancetype)init:(NSInteger)durationTime liveEndImage:(UIImage *)liveEndImage
{
    if (self = [super init]) {
        self.liveDurationTime = durationTime;
        self.liveEndImage = liveEndImage;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupView];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - setup
- (void)setupView
{
    self.bagroundImageView.image = self.liveEndImage;
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effe = [[UIVisualEffectView alloc]initWithEffect:blur];
    effe.frame = CGRectMake(0, 0 , SCREEN_WIDTH, SCREEN_HEIGHT);
    [effe setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    effe.alpha = 0.7;
    [self.bagroundImageView insertSubview:effe atIndex:0];
    [self.bagroundImageView addSubview:effe];
}
- (void)setupData
{
    NSURL *avatarUrl = [NSURL URLWithString:[WYLoginUserManager avatar]];
    [WYCommonUtils setImageWithURL:avatarUrl setImageView:self.headerimageView placeholderImage:@"common_headImage"];
    self.anchorNicknameLabel.text = [WYLoginUserManager nickname];
    int seconds = self.liveDurationTime % 60;
    int minutes = (self.liveDurationTime / 60) % 60;
    long int hours = self.liveDurationTime / 3600;
    self.durationTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", hours, minutes, seconds];
    
}
- (IBAction)clickConfirmAction:(UIButton *)sender {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[WYHomePageViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
