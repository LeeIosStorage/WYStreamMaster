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

- (NSString *)coverImage
{
    return _coverImage;
}

- (CGFloat)getCellHeigt
{
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:12.f]};
    NSString *content;
    CGSize size;
    if ([self.interactType isEqualToString:@"5"]) {
        
        content = [NSString stringWithFormat:@"评论了 %@ :%@", self.bbstitle, self.ocontent];
        size = [content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 138, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]} context:nil].size;
    } else if ([self.interactType isEqualToString:@"6"]) {
        NSString *content;
        if ([self.replynickname length] != 0) {
            content = [NSString stringWithFormat:@"    我评论了 %@ :回复@%@ :%@",self.bbstitle, self.replynickname, self.mcontent];
        } else {
            content = [NSString stringWithFormat:@"    我评论了 %@ :%@",self.bbstitle, self.mcontent];
        }
        size = [content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 83, CGFLOAT_MAX) options:options attributes:dic context:nil].size;
        if (size.height < 30) {
            size.height = 35;
        }
        CGSize msize = [self.ocontent boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 138, CGFLOAT_MAX) options:options attributes:dic context:nil].size;
        return ceil(size.height + msize.height);
    }
    return ceil(size.height);
}
@end
