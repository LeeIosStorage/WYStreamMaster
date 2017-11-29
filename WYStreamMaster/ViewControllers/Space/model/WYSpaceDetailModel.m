//
//  WYSpaceDetailModel.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/11/24.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYSpaceDetailModel.h"

@implementation WYSpaceDetailModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"commentId":@"id",
             @"coverImage":@"icon",
             @"interactType":@"atype",
             };
}

- (CGFloat)getCellHeigt
{
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:12.f]};
    NSString *content;
    CGSize size;
    if ([self.parent_id length] == 0) {
        content = [NSString stringWithFormat:@"%@ :%@", self.nickname, self.content];
        size = [content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 60, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]} context:nil].size;
    } else if ([self.parent_id length] != 0) {
        NSString *content = [NSString stringWithFormat:@"%@ 回复 %@:%@", self.parent_nickname,self.nickname, self.content];

        size = [content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 60, CGFLOAT_MAX) options:options attributes:dic context:nil].size;
        
//        CGSize msize = [self.content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 138, CGFLOAT_MAX) options:options attributes:dic context:nil].size;
        return ceil(size.height);
    }
    return ceil(size.height);
}
@end
