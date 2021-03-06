//
//  YTCommunityCollectionCell.m
//  WYTelevision
//
//  Created by Jyh on 2017/4/12.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTCommunityDetailCollectionCell.h"
#import "YTClassifyBBSDetailModel.h"
#import "YTClassifyCommunityImageView.h"
#import "YTClassifyBottomView.h"
#import "WYSpaceDetailModel.h"
#import "YTInteractMessageTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVAsset.h>
#define kCommunityAvatarWidth  28

@interface YTCommunityDetailCollectionCell ()

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UIImageView *genderImageView;
//@property (strong, nonatomic) UIImageView *identiImageView;

@property (strong, nonatomic) UIImageView *videoCoverImageView;
@property (strong, nonatomic) UIImageView *videoPlayImageView;

@property (strong, nonatomic) UILabel *nickNameLabel;
@property (strong, nonatomic) UILabel *creatDateLabel;

//@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *contentLabel;

@property (strong, nonatomic) UIButton *gameCategoryButton;

@property (strong, nonatomic) YTClassifyBottomView *bottomView;
@property (strong, nonatomic) YTClassifyCommunityImageView *imagesview;
//@property (strong, nonatomic) YTInteractMessageTableViewCell *commentView;

@property (strong, nonatomic) YTClassifyBBSDetailModel *bbsInfo;
@property (strong, nonatomic) WYSpaceDetailModel *spaceModel;

@end

@implementation YTCommunityDetailCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self setupSubViews];
}

+ (CGFloat)heightWithEntity:(YTClassifyBBSDetailModel *)model
{
    if (!model) {
        return 0;
    }
    CGFloat cellHeight = 0;
    CGFloat contentTextY = 0; // 文字的y坐标
    CGFloat imageViewHeight = 100.0*kScreenWidth / 375.0;
    CGFloat videoViewHeight = 160;
    CGFloat categoryHeight = 40;
    CGFloat bottomViewHeight = 38;
    
    cellHeight = contentTextY;
    CGFloat textHeight;
    textHeight = [WYCommonUtils sizeWithText:model.content font:[UIFont systemFontOfSize:11] width:kScreenWidth - 25*2].height;
    if (textHeight > 40) {
        // 最多显示三行
        textHeight = 40;
    }
    cellHeight += textHeight;
    if (model.bbsType == YTBBSTypeText) {
        // 纯消息
        cellHeight += categoryHeight+20;
        cellHeight += bottomViewHeight;
    } else if (model.bbsType == YTBBSTypeGraphic) {
        // 图文
        cellHeight += 30;
        cellHeight += imageViewHeight;
        cellHeight += categoryHeight;
        cellHeight += bottomViewHeight;
    } else if (model.bbsType == YTBBSTypeVideo) {
        cellHeight += 30;
        cellHeight += videoViewHeight;
        cellHeight += categoryHeight;
        cellHeight += bottomViewHeight;
    }
    return ceilf(cellHeight);
}

- (void)updateCommunifyCellWithData:(YTClassifyBBSDetailModel *)model
{
    if (model) {
        _bbsInfo = model;
        NSURL *avatarUrl = [NSURL URLWithString:[WYLoginUserManager avatar]];
        [self.avatarImageView setImageWithURL:avatarUrl placeholder:[UIImage imageNamed:@"common_headImage"]];
//        [self.videoCoverImageView setImageWithURL:avatarUrl placeholder:[UIImage imageNamed:@"common_headImage"]];
        self.nickNameLabel.text = [WYLoginUserManager nickname];
        self.contentLabel.text = model.content;
        self.creatDateLabel.text = model.create_date;
//        self.nickNameLabel.text = @"爱打lol的妹子";
        if (model.bbsType == YTBBSTypeText) {
            
        } else if (model.bbsType == YTBBSTypeGraphic) {
           
        } else if (model.bbsType == YTBBSTypeVideo) {
            NSString *videosStr = model.videos[0];
            NSString *videosNewStr = [videosStr substringToIndex:[videosStr length] - 1];
            NSURL *url = [NSURL URLWithString:videosStr];
            if (!url) {
                url = [NSURL URLWithString:videosNewStr];
            }
            self.videoCoverImageView.image = [[self class] thumbnailImageForVideo:url atTime:0];
            
            self.videoCoverImageView.hidden = NO;
            self.videoPlayImageView.hidden = NO;
        }
        
        [self.imagesview updateImageViewWithArray:model.images];
        [self.bottomView updateBottomViewWithInfo:model];
    }
}

///添加subviews
- (void)setupSubViews {
    self.layer.cornerRadius = 8.0;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    // 头像
    [self addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(12);
        make.top.equalTo(self.mas_top).offset(5);
        make.width.height.mas_equalTo(kCommunityAvatarWidth);
    }];
    
    // 昵称
    [self addSubview:self.nickNameLabel];
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView.mas_top).offset(5);
        make.left.equalTo(self.avatarImageView.mas_right).offset(10);
    }];
    
    // 性别
    [self addSubview:self.genderImageView];
    [self.genderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(15, 15));
        make.centerY.equalTo(self.nickNameLabel.mas_centerY);
        make.left.equalTo(self.nickNameLabel.mas_right).offset(10);
    }];
    
    // 创建日期
    [self addSubview:self.creatDateLabel];
    [self.creatDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nickNameLabel.mas_bottom).offset(2);
        make.left.equalTo(self.avatarImageView.mas_right).offset(10);
    }];
    
    // 删除按钮
    [self addSubview:self.deleteButton];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(15);
        make.left.equalTo(self.nickNameLabel.mas_right);
        make.right.equalTo(self.mas_right).offset(-10);
        make.width.mas_equalTo(60);
    }];
    
    // 内容
    [self addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImageView.mas_left);
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(15);
        make.right.equalTo(self.mas_right).offset(-12);
        make.height.mas_lessThanOrEqualTo(45).with.priority(15);
    }];
    
    // 图片view
    [self addSubview:self.imagesview];
    [self.imagesview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(80);
    }];
    
    // 视频封面 宽高比25/14
    [self addSubview:self.videoCoverImageView];
    [self.videoCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(0);
        make.left.equalTo(@30);
        make.height.mas_equalTo(150);
        make.width.mas_equalTo(SCREEN_WIDTH - 60);
    }];
    self.videoCoverImageView.hidden = YES;
    
    // 播放按钮
    [self addSubview:self.videoPlayImageView];
    [self.videoPlayImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.videoCoverImageView);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
    }];
    self.videoPlayImageView.hidden = YES;

    // 底部操作view
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(37);
    }];
    
//    // 游戏分类label
//    [self addSubview:self.gameCategoryButton];
//    [self.gameCategoryButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.mas_top).offset(-10);
//        make.left.equalTo(self.contentLabel.mas_left);
//        make.height.mas_equalTo(18);
//        make.width.mas_lessThanOrEqualTo(200);
//    }];
    
    // 评论回复label
//    CGFloat commentHeight = [self.spaceModel getCellHeigt];
//    [self addSubview:self.commentView];
//    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.equalTo(self);
//        make.height.mas_equalTo(45);
//    }];
}

#pragma mark
#pragma mark - Private Methods
- (void)pushToPersionalVC
{
    
}

+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

#pragma mark
#pragma mark - Getters and Setters

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.layer.cornerRadius = kCommunityAvatarWidth / 2.0;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.opaque = NO;
        _avatarImageView.userInteractionEnabled = YES;
        ///先设置个默认头像
        _avatarImageView.image = [UIImage imageNamed:@"common_default_avatar_70"];
        ///添加头像点击事件
        WEAKSELF
        UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            [weakSelf pushToPersionalVC];
        }];
        [_avatarImageView addGestureRecognizer:tapAvatar];
    }
    
    return _avatarImageView;
}

- (UIImageView *)genderImageView {
    if (!_genderImageView) {
        _genderImageView = [[UIImageView alloc] init];
        _genderImageView.contentMode = UIViewContentModeScaleAspectFill;
        _genderImageView.opaque = NO;
        _genderImageView.image = [UIImage imageNamed:@"home_female_label"];
    }
    
    return _genderImageView;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"delete_talkAbout"] forState:UIControlStateNormal];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor colorWithHexString:@"838ea2"] forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _deleteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
        _deleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 43, 0, 0);
    }
    
    return _deleteButton;
}

- (UIImageView *)videoCoverImageView {
    if (!_videoCoverImageView) {
        _videoCoverImageView = [[UIImageView alloc] init];
        _videoCoverImageView.contentMode = UIViewContentModeScaleAspectFit;
        _videoCoverImageView.opaque = NO;
        _videoCoverImageView.clipsToBounds = YES;
        _videoCoverImageView.image = [UIImage imageNamed:@"common_list_placehoder_image"];
    }
    
    return _videoCoverImageView;
}

- (UIImageView *)videoPlayImageView {
    if (!_videoPlayImageView) {
        _videoPlayImageView = [[UIImageView alloc] init];
        _videoPlayImageView.contentMode = UIViewContentModeScaleAspectFit;
        _videoPlayImageView.opaque = NO;
        _videoPlayImageView.clipsToBounds = YES;
        _videoPlayImageView.image = [UIImage imageNamed:@"play_button_image"];
    }
    
    return _videoPlayImageView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.backgroundColor = [UIColor clearColor];
        _nickNameLabel.numberOfLines = 1;
        _nickNameLabel.font = [UIFont systemFontOfSize:13];
//        _nickNameLabel.text = @"一人我饮酒醉，醉把家人成双对";
        _nickNameLabel.textColor = [UIColor colorWithHexString:@"666666"];
        _nickNameLabel.userInteractionEnabled = YES;
        WEAKSELF
        UITapGestureRecognizer *tapNickname = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            [weakSelf pushToPersionalVC];
        }];
        [_nickNameLabel addGestureRecognizer:tapNickname];
    }
    
    return _nickNameLabel;
}

- (UILabel *)creatDateLabel {
    if (!_creatDateLabel) {
        _creatDateLabel = [[UILabel alloc] init];
        _creatDateLabel.backgroundColor = [UIColor clearColor];
        _creatDateLabel.font = [UIFont systemFontOfSize:10];
        _creatDateLabel.textColor = [UIColor colorWithHexString:@"999999"];
    }
    return _creatDateLabel;
}

//- (UILabel *)titleLabel {
//    if (!_titleLabel) {
//        _titleLabel = [[UILabel alloc] init];
//        _titleLabel.backgroundColor = [UIColor clearColor];
//        _titleLabel.font = [UIFont systemFontOfSize:11];
//        _titleLabel.textColor = [UIColor colorWithHexString:@"333333"];
////        _titleLabel.text = @"王者农药，天上天下，唯朕独尊";
//    }
//    
//    return _titleLabel;
//}


- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.numberOfLines = 3;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.font = [UIFont systemFontOfSize:11];
        _contentLabel.textColor = [UIColor colorWithHexString:@"666666"];
//        _contentLabel.text = @"由于此次为不停机更新，维护时登入游戏，将收到“游戏维护中”的提示，维护完毕后即可正常进入；维护时已经登入游戏的玩家不受任何影响。更新结束后请各位在线的召唤师，切记退出游戏重新登录更新。以免遇到部分素材、资源等无法刷出的异常，影响大家的体验。";
    }
    return _contentLabel;
}

- (UIButton *)gameCategoryButton {
    if (!_gameCategoryButton) {
        _gameCategoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _gameCategoryButton.layer.cornerRadius = 3;
        _gameCategoryButton.layer.borderWidth = 1;
        _gameCategoryButton.layer.borderColor = [UIColor colorWithHexString:@"00A3FF"].CGColor;
    }
    return _gameCategoryButton;
}

//- (YTInteractMessageTableViewCell *)commentView {
//    if (!_commentView) {
//        _commentView = [[[NSBundle mainBundle] loadNibNamed:@"YTInteractMessageTableViewCell" owner:self options:nil] objectAtIndex:0];
//    }
//    return _commentView;
//}

- (YTClassifyBottomView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[[NSBundle mainBundle] loadNibNamed:@"YTClassifyBottomView" owner:self options:nil] objectAtIndex:0];
    }
    return _bottomView;
}

- (YTClassifyCommunityImageView *)imagesview
{
    if (!_imagesview) {
        _imagesview = [[[NSBundle mainBundle] loadNibNamed:@"YTClassifyCommunityImageView" owner:self options:nil] objectAtIndex:0];
    }
    return _imagesview;
}
@end
