//
//  WYShareActionSheet.m
//  WYTelevision
//
//  Created by Leejun on 16/9/21.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "WYShareActionSheet.h"
#import "WYLoginManager.h"
#import "TencentOpenAPI/QQApiInterface.h"
#import "WYShareManager.h"
#import <objc/message.h>
#import <SDWebImage/SDWebImageManager.h>

#define Share_To_Item_Name @"name"
#define Share_To_Item_Icon @"icon"
#define Share_To_Item_Disabed @"disabled"
#define Share_To_Item_Icon_Hilight @"iconHighLight"
#define Share_To_Item_Action @"action"

#define showViewHeight  200

#define Share_To_Item_Base_Tag 10

@interface WYShareActionSheet ()

@property (nonatomic, strong) NSString *shareTitle;
@property (nonatomic, strong) NSString *shareDescription;
@property (nonatomic, strong) NSString *shareWebpageUrl;
@property (nonatomic, strong) UIImage *shareImage;

@property (strong, nonatomic) NSMutableArray *shareToItemArray;

@property (strong, nonatomic) UIView *markView;

@property (strong, nonatomic) UIView *showView;

@property (strong, nonatomic) UIScrollView *shareScrollView;

@property (strong, nonatomic) UIView *titleView;

@property (strong, nonatomic) UIView *cancelView;

@end

@implementation WYShareActionSheet

- (void)dealloc
{
    
}

- (id)init
{
    if (self = [super init]) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self];
        self.hidden = YES;
        
        self.backgroundColor = [UIColor clearColor];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(window);
        }];
        
        [self initShowView];
        
    }
    return self;
}

#pragma mark -
#pragma mark - Init Subview

- (void)initShowView
{
    WS(weakSelf);
    self.markView.alpha = 0;
    [self addSubview:self.markView];
    [self.markView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    [self.markView addGestureRecognizer:gestureRecongnizer];
    
    [self addSubview:self.showView];
    [self.showView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf).offset(showViewHeight);
        make.height.mas_equalTo(showViewHeight);
    }];
    
    [self.showView addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(weakSelf.showView);
        make.height.mas_offset(36);
    }];
    
    [self.showView addSubview:self.cancelView];
    [self.cancelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(weakSelf.showView);
        make.height.mas_offset(50);
    }];
    
    [self.showView addSubview:self.shareScrollView];
    [self.shareScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.showView);
        make.top.equalTo(weakSelf.titleView.mas_bottom);
        make.bottom.equalTo(weakSelf.cancelView.mas_top);
    }];
    
    self.shareToItemArray = [NSMutableArray array];
    [_shareToItemArray addObject:@{Share_To_Item_Name: @"微信", Share_To_Item_Icon:@"share_wx_circle_icon",Share_To_Item_Action:@"shareToWXSession"}];
    [_shareToItemArray addObject:@{Share_To_Item_Name: @"朋友圈", Share_To_Item_Icon:@"share_wx_friend_icon",Share_To_Item_Action:@"shareToWXTimeline"}];
    [_shareToItemArray addObject:@{Share_To_Item_Name: @"微博", Share_To_Item_Icon:@"share_sina_icon",Share_To_Item_Action:@"shareToWeiBo"}];
    if ([QQApiInterface isQQInstalled]) {
        [_shareToItemArray addObject:@{Share_To_Item_Name: @"QQ", Share_To_Item_Icon:@"share_qq_icon",Share_To_Item_Action:@"shareToQQ"}];
    }
    
    [self addShareItem];
}

- (void)addShareItem{
    
    WS(weakSelf);
    CGFloat itemWidth = 50;
    CGFloat itemHeight = 50 + 27;
    CGFloat space = (SCREEN_WIDTH-27*2-itemWidth*4)/3;
    NSInteger index = 0;
    UIView *lastItemView = nil;
    for (NSDictionary *itemDic in _shareToItemArray) {
        
        UIView *itemView = [[UIView alloc] init];
        [self.shareScrollView addSubview:itemView];
        [itemView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakSelf.shareScrollView.mas_centerY);
            if (lastItemView == nil) {
                make.left.equalTo(weakSelf.shareScrollView).offset(27);
            }else{
                make.left.equalTo(lastItemView.mas_right).offset(space);
            }
            make.width.mas_offset(itemWidth);
            make.height.mas_offset(itemHeight);
        }];
        
//        BOOL disabed = [[itemDic objectForKey:Share_To_Item_Disabed] boolValue];
        //icon
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:[itemDic objectForKey:Share_To_Item_Icon]] forState:UIControlStateNormal];
        button.tag = Share_To_Item_Base_Tag + index;
        [button addTarget:self action:@selector(itemClickBtn:) forControlEvents:UIControlEventTouchUpInside];
//        button.backgroundColor = [UIColor whiteColor];
        [itemView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(itemView);
            make.width.mas_offset(itemWidth);
            make.height.mas_offset(itemWidth);
            make.centerX.equalTo(itemView);
        }];
        
        //label
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColorHex(0x9da4ad);
        label.font = [UIFont systemFontOfSize:11];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [itemDic objectForKey:Share_To_Item_Name];
        [itemView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(itemView);
            make.height.mas_offset(14);
        }];
        
        lastItemView = itemView;
        index ++;
    }
    
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self cancelActionSheet];
}

#pragma mark
#pragma mark - Getters and Setters
- (UIView *)markView{
    if (!_markView) {
        _markView = [[UIView alloc] init];
        _markView.backgroundColor = [UIColor colorWithWhite:0.f alpha:.5f];
    }
    return _markView;
}

- (UIView *)showView{
    if (!_showView) {
        _showView = [[UIView alloc] initWithFrame:CGRectZero];
        _showView.backgroundColor = [WYStyleSheet currentStyleSheet].themeColor;
        
    }
    return _showView;
}

- (UIScrollView *)shareScrollView{
    if (!_shareScrollView) {
        _shareScrollView = [[UIScrollView alloc] init];
        _shareScrollView.backgroundColor = [UIColor clearColor];
    }
    return _shareScrollView;
}

- (UIView *)titleView{
    if (!_titleView) {
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = [UIColor clearColor];
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"分享到";
        titleLabel.textColor = UIColorHex(0x9da4ad);
        titleLabel.font = [UIFont systemFontOfSize:13];
        [_titleView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleView).offset(13);
            make.top.bottom.equalTo(_titleView);
            make.right.equalTo(_titleView).offset(-13);
        }];
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.backgroundColor = UIColorHex(0x141A20);
        [_titleView addSubview:lineImageView];
        [lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(_titleView);
            make.height.mas_offset(0.5);
        }];
    }
    return _titleView;
}

- (UIView *)cancelView{
    if (!_cancelView) {
        _cancelView = [[UIView alloc] init];
        _cancelView.backgroundColor = [UIColor clearColor];
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.layer.cornerRadius = 5;
        cancelButton.layer.masksToBounds = YES;
        cancelButton.backgroundColor = [WYStyleSheet currentStyleSheet].titleLabelSelectedColor;
        [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [cancelButton addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelView addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_offset(CGSizeMake(60, 25));
            make.centerX.centerY.equalTo(_cancelView);
        }];
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.backgroundColor = UIColorHex(0x141A20);
        [_cancelView addSubview:lineImageView];
        [lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(_cancelView);
            make.height.mas_offset(0.5);
        }];
    }
    return _cancelView;
}

#pragma mark - custom

- (void)shareInfoData:(id)shareInfo{
    // 标题
    self.shareTitle = @"手游直播就上娱儿直播！";
    // 内容
    self.shareDescription = @"我在娱儿直播开播啦，求抱抱求围观求投食！";
    // 链接
    if ([WYLoginManager sharedManager].loginModel.shareUrl) {
        self.shareWebpageUrl = [WYLoginManager sharedManager].loginModel.shareUrl;
    }
    // icon
    NSURL *smallImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [WYLoginUserManager avatar]]];
    UIImage *imageFromDisk = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[smallImageURL absoluteString]];
    self.shareImage = imageFromDisk;

    
    //图片分享
    if ([shareInfo isKindOfClass:[UIImage class]]) {
        self.shareImage = shareInfo;
    }
    
//    if (!self.shareTitle) {
//        NSString *appBundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
//        self.shareTitle = [NSString stringWithFormat:@"精彩视频尽在%@",appBundleName];
//    }
//    if (!self.shareDescription) {
//        self.shareDescription = @"不容错过的年度最佳手游直播平台";
//    }
    if (!self.shareWebpageUrl) {
        self.shareWebpageUrl = Sina_RedirectURL;
    }
    if (!self.shareImage) {
        self.shareImage = [UIImage imageNamed:@"login_logo_icon"];
    }
}

- (void) showShareAction{
    self.hidden = NO;
    [self showAnimation];
}

- (void) cancelActionSheet{
    [self dissmiss];
}

- (void)showAnimation{
    
    WS(weakSelf);
    
    [self.showView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf).offset(showViewHeight);
        make.height.mas_equalTo(showViewHeight);
    }];
    [self.showView.superview layoutIfNeeded];
    
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.markView.alpha = 1.0;
        [weakSelf.showView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf).offset(0);
        }];
        [weakSelf.showView.superview layoutIfNeeded];
    }];
}

- (void)cancelClick:(id)sender{
    [self cancelActionSheet];
}

- (void)dissmiss
{
    WS(weakSelf);
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.markView.alpha = 0;
        [weakSelf.showView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf).offset(showViewHeight);
        }];
        [weakSelf.showView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)itemClickBtn:(id)sender{
    
    [self cancelActionSheet];
    NSInteger tag = ((UIButton *)sender).tag;
    NSIndexPath *indexPath;
    indexPath = [NSIndexPath indexPathForRow:tag%10 inSection:tag/10];
    if (indexPath.section == 1) {
        NSString *action = [[self.shareToItemArray objectAtIndex:indexPath.row] objectForKey:Share_To_Item_Action];
        if (action) {
            SEL opAction = NSSelectorFromString(action);
            if ([self respondsToSelector:opAction]) {
                objc_msgSend(self, opAction);
                return;
            }
        }
    }
}

#pragma mark 
#pragma mark - msgSend Action
- (void)shareToWXSession{
    [self shareToWX:WXSceneSession];
}

- (void)shareToWXTimeline{
    [self shareToWX:WXSceneTimeline];
}

-(void)shareToWX:(int)scene{
    if (self.isPureImage) {
        [[WYShareManager shareInstance] shareToWXWithImage:self.shareImage scene:scene];
        return;
    }
    [[WYShareManager shareInstance] shareToWXWithScene:scene title:self.shareTitle description:self.shareDescription webpageUrl:self.shareWebpageUrl image:self.shareImage isVideo:_isVideo];
}

- (void)shareToWeiBo{
    [[WYShareManager shareInstance] shareToWb:^(WBSendMessageToWeiboResponse *response) {
        
    } title:self.shareTitle description:self.shareDescription webpageUrl:self.shareWebpageUrl image:self.shareImage VC:_owner isVideo:_isVideo];
}

- (void)shareToQQ{
    if (self.isPureImage) {
        [[WYShareManager shareInstance] shareToQQWithImage:self.shareImage];
        return;
    }
    [[WYShareManager shareInstance] shareToQQTitle:self.shareTitle description:self.shareDescription webpageUrl:self.shareWebpageUrl image:self.shareImage isVideo:_isVideo];
}

@end
