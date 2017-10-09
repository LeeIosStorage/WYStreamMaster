//
//  YTClassifyBBSDetailModel.m
//  WYTelevision
//
//  Created by Jyh on 2017/4/11.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTClassifyBBSDetailModel.h"

@implementation YTClassifyBBSDetailModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"commentNumber"   : @"comment_num",
             @"createDate"      : @"create_date",
             @"gameName"        : @"game_name",
             @"postsID"         : @"id",
             @"videoID"         : @"video_id",
             @"isCertificate"   : @"is_certificate",
             @"isAttention"     : @"is_concern",
             @"isPraise"        : @"is_praise",
             @"isFemale"        : @"sex",
             @"nickName"        : @"nickname",
             @"praiseNumber"    : @"praise_num",
             @"userID"          : @"user_id",
             @"bbsType"         : @"type",
             @"videoImage"      : @"video_img"};
}

- (NSURL *)avatarImageURL
{
    NSURL *imageURL;
    if ([self.icon hasPrefix:@"http"]) {
        imageURL = [NSURL URLWithString:self.icon];
    } else {
        imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[WYAPIGenerate sharedInstance].baseImgUrl,self.icon]];
    }
    
    return imageURL;
}

- (NSURL *)coverImageURL
{
    NSURL *imageURL;
    if ([self.videoImage hasPrefix:@"http://"] || [self.videoImage hasPrefix:@"https://"]) {
        imageURL = [NSURL URLWithString:self.videoImage];
    } else {
        imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[WYAPIGenerate sharedInstance].baseImgUrl,self.videoImage]];
    }
    
    return imageURL;
}

- (NSMutableArray *)imagesArray
{
    NSMutableArray *newArray =[[NSMutableArray alloc] initWithCapacity:1];
    if (self.imgs) {
        NSArray *array = [self.imgs componentsSeparatedByString:@","];
        for (int i = 0; i < [array count]; i ++) {
            NSString *tempString = [NSString stringWithFormat:@"%@",array[i]];
            
            if ([tempString hasPrefix:@"http"]) {
                
            } else {
                tempString = [NSString stringWithFormat:@"%@/%@",[WYAPIGenerate sharedInstance].baseImgUrl,array[i]];
            }
    
            [newArray addObject:tempString];
        }
    }
    
    return newArray;
}

@end
