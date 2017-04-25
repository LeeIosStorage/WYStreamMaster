//
//  LiveGiftShowView.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "LiveGiftShowView.h"
#import "ZYGiftListModel.h"
#import "YTGradientColorLabel.h"
#import "Masonry.h"
//#import "HexColor.h"

static CGFloat const kNameLabelFont = 12.f;//送礼者
#define kNameLabelTextColor [UIColor colorWithHexString:@"000000"]//送礼者颜色

static CGFloat const kGiftLabelFont = 12.0;//送出礼物寄语  字体大小
#define kGiftLabelTextColor [UIColor colorWithHexString:@"000000"]//礼物寄语 字体颜色

static CGFloat const kGiftNumberWidth = 15.0;

static NSInteger const kTimeOut = 3;/**< 超时移除时长 */
static CGFloat const kRemoveAnimationTime = 0.5;/**< 移除动画时长 */
static CGFloat const kNumberAnimationTime = 0.25;/**< 数字改变动画时长 */

@interface LiveGiftShowView ()<CAAnimationDelegate>

@property (nonatomic ,weak) UIImageView * backIV;/**< 背景图 */
@property (nonatomic ,weak) UIImageView * iconIV;/**< 头像 */
@property (nonatomic ,weak) UILabel * nameLabel;/**< 名称 */
@property (nonatomic ,weak) UILabel * sendLabel;/**< 送出 */
@property (nonatomic ,weak) UIImageView * giftIV;/**< 礼物图片 */

@property (nonatomic ,strong) NSTimer * liveTimer;/**< 定时器控制自身移除 */
@property (nonatomic ,assign) NSInteger liveTimerForSecond;

@property (nonatomic ,assign) BOOL isSetNumber;

@property (strong, nonatomic) YTGradientColorLabel *multiplyLabel;

@end

@implementation LiveGiftShowView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, kViewWidth, kViewHeight)];
    if (self) {
        self.liveTimerForSecond = 0;
        [self setupContentContraints];

    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.liveTimerForSecond = 0;
        [self setupContentContraints];
    }
    return self;
}

- (void)setModel:(LiveGiftShowModel *)model{
    if (!model) {
        return;
    }
    _model = model;
    
    self.nameLabel.text = model.user.name;
    
    //[self.iconIV setImageURL:[NSURL URLWithString:model.user.iconUrl]];
    
    self.sendLabel.text = model.giftModel.rewardMsg;
    [self.giftIV setImageWithURL:[NSURL URLWithString:model.giftModel.picUrl] placeholder:[UIImage imageNamed:@"wy_common_placehoder_image"]];
    
}

/**
 重置定时器和计数
 
 @param number 计数
 */
- (void)resetTimeAndNumberFrom:(NSInteger)number{
    self.numberView.number = number;
    [self addGiftNumberFrom:number];
}

/**
 获取用户名

 @return 获取用户名
 */
- (NSString *)getUserName{
    return self.nameLabel.text;
}

/**
 礼物数量自增1使用该方法

 @param number 从多少开始计数
 */
- (void)addGiftNumberFrom:(NSInteger)number{
    
    if (!self.isSetNumber) {
        self.numberView.number = number;
        self.isSetNumber = YES;
    }
    //每调用一次self.numberView.number get方法 自增1
    NSInteger num = self.numberView.number;
    [self.numberView changeNumber:num];
    [self handleNumber:num];
}

/**
 设置任意数字时使用该方法

 @param number 任意数字 >9999 则显示9999
 */
- (void)changeGiftNumber:(NSInteger)number{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.numberView changeNumber:number];
        [self handleNumber:number];
    });
}

#pragma mark - Private
- (void)handleNumber:(NSInteger )number{
    self.liveTimerForSecond = 0;
    
//    NSString * numStr = [NSString stringWithFormat:@"%zi",number];
//    CGFloat giftRight = numStr.length * kGiftNumberWidth + kGiftNumberWidth;
//    
//    [self.giftIV mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.mas_right).offset(-kGiftNumberWidth - giftRight);
//    }];
//    
//    if (numStr.length >= 4) {
//        [self.giftIV mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(self.mas_right).offset(-kGiftNumberWidth * 6);
//        }];
//    }
    WEAKSELF
//    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    basicAnimation.duration = kNumberAnimationTime;
//    basicAnimation.repeatCount = 1;
//    basicAnimation.autoreverses = YES;
//    basicAnimation.delegate = self;
//    basicAnimation.fromValue = [NSNumber numberWithInt:1.0];
//    basicAnimation.toValue = [NSNumber numberWithInt:1.5];
//    [self.numberView.layer addAnimation:basicAnimation forKey:@"scale-layer"];
    //self.numberView.backgroundColor = [UIColor redColor];
    

//     [self.numberView.layer setAnchorPoint:CGPointMake(0.0, 0.5)];
    [UIView animateWithDuration:kNumberAnimationTime animations:^{
        weakSelf.numberView.transform = CGAffineTransformMakeScale(2,2);
    } completion:^(BOOL finished) {
        if (finished) {
            weakSelf.numberView.transform = CGAffineTransformIdentity;
        }
    }];
    
    [self.liveTimer setFireDate:[NSDate date]];
}

- (void)liveTimerRunning{
    self.liveTimerForSecond += 1;
    if (self.liveTimerForSecond > kTimeOut) {
        if (self.isAnimation == YES) {
            self.isAnimation = NO;
            return;
        }
        self.isAnimation = YES;
        [UIView animateWithDuration:kRemoveAnimationTime delay:kNumberAnimationTime options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.transform = CGAffineTransformTranslate(self.transform, [UIScreen mainScreen].bounds.size.width, 0);
        } completion:^(BOOL finished) {
            if (finished) {
                if (self.liveGiftShowViewTimeOut) {
                    self.liveGiftShowViewTimeOut(self);
                }
                [self removeFromSuperview];
            }
        }];
        
        [self stopTimer];
    }
}


- (void)setupContentContraints{
    [self.backIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    [self.iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@6);
        make.width.height.equalTo(@30);
        make.centerY.equalTo(self);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(4);
        make.left.equalTo(self.mas_left).offset(12);
        make.width.equalTo(@80);
        make.height.mas_equalTo(@14);
    }];
    
    [self.sendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(2);
        make.left.equalTo(self.nameLabel);
        make.width.mas_equalTo(120);
    }];
    
    [self.giftIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).offset(10);//-25
        make.width.equalTo(@60);//94
        make.height.equalTo(@60);//94
//        make.top.equalTo(self).and.offset(-10);
        make.centerY.equalTo(self);
    }];
    
//    self.multiplyLabel.backgroundColor = [UIColor whiteColor];
    [self.multiplyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.giftIV.mas_right).offset(5);
        make.bottom.equalTo(self).offset(-3);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];

//    self.numberView.backgroundColor = [UIColor redColor];
    [self.numberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.multiplyLabel.mas_right).offset(-5);
//        make.left.equalTo(self.multiplyLabel).offset(-15);
        make.bottom.equalTo(self).offset(-1);
        make.size.mas_equalTo(CGSizeMake(120, 44));
    }];

//    CGPoint layerPosition = CGPointMake(235, 0);
//    [self.numberView.layer setPosition:layerPosition];
//    self.numberView.layer.size = CGSizeMake(90, 37);
//    [self.numberView.layer setAnchorPoint:CGPointMake(0.0, 0.5)];
}

- (UILabel *)multiplyLabel
{
    if (!_multiplyLabel) {
        _multiplyLabel = [[YTGradientColorLabel alloc] init];
        _multiplyLabel.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:20.0];
        _multiplyLabel.text = @"X";
        _multiplyLabel.textColor = [UIColor whiteColor];
        _multiplyLabel.shadowOffset = CGSizeMake(1, 1);
        _multiplyLabel.shadowColor = [UIColor colorWithHex:0 withAlpha:0.4];
        
//        _multiplyLabel.textColor = [UIColor colorWithHexString:@"ff6600"];
//        NSArray *gradientColors = @[(id)[UIColor colorWithHexString:@"ff6600"].CGColor,(id)[UIColor colorWithHexString:@"ff6600"].CGColor,(id)[UIColor colorWithHexString:@"ffff00"].CGColor];
//        _multiplyLabel.colors = gradientColors;
        //[_multiplyLabel sizeToFit];
        [self addSubview:_multiplyLabel];
    }
    return _multiplyLabel;
}

- (UIImageView *)backIV{
    if (!_backIV) {
        _backIV = [self creatIV];
        _backIV.image = [UIImage imageNamed:@"w_liveGiftBack"];
    }
    return _backIV;
}

- (UIImageView *)iconIV{
    if (!_iconIV) {
        _iconIV = [self creatIV];
        _iconIV.layer.cornerRadius = 15;
        _iconIV.layer.masksToBounds = YES;
    }
    return _iconIV;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [self creatLabel];
        _nameLabel.textColor = kNameLabelTextColor;
        _nameLabel.font = [UIFont systemFontOfSize:kNameLabelFont];
    }
    return _nameLabel;
}

- (UILabel *)sendLabel{
    if (!_sendLabel) {
        _sendLabel = [self creatLabel];
        _sendLabel.font = [UIFont systemFontOfSize:kGiftLabelFont];
        _sendLabel.textColor = kGiftLabelTextColor;
    }
    return _sendLabel;
}


- (UIImageView *)giftIV{
    if (!_giftIV) {
        _giftIV = [self creatIV];
    }
    return _giftIV;
}

- (LiveGiftShowNumberView *)numberView{
    if (!_numberView) {
        LiveGiftShowNumberView * nv = [[LiveGiftShowNumberView alloc]init];
        [self addSubview:nv];
        _numberView = nv;
    }
    return _numberView;
}

- (UIImageView *)creatIV{
    UIImageView * iv = [[UIImageView alloc]init];
    [self addSubview:iv];
    return iv;
}

- (UILabel * )creatLabel{
    UILabel * label = [[UILabel alloc]init];
    [self addSubview:label];
    return label;
}

- (NSTimer *)liveTimer{
    if (!_liveTimer) {
        _liveTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(liveTimerRunning) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_liveTimer forMode:NSRunLoopCommonModes];
    }
    return _liveTimer;
}

- (void)stopTimer{
    if (_liveTimer) {
        [_liveTimer invalidate];
        _liveTimer = nil;
    }
}


- (void)dealloc{
//    NSLog(@"已然释放了我 %@",self);
}

@end
