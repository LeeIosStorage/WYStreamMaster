//
//  YTChatBottomView.m
//  WYTelevision
//
//  Created by zurich on 2016/10/26.
//  Copyright © 2016年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTChatBottomView.h"

@implementation YTChatBottomView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.hotWordButton setImage:[UIImage imageNamed:@"chat_hotword_pull"] forState:UIControlStateNormal];
    [self.hotWordButton setImage:[UIImage imageNamed:@"chat_hotword_down"] forState:UIControlStateSelected];
    self.hotWordButton.selected = NO;
    self.inputTF.backgroundColor = UIColorHex(0x161d24);
    [self.inputTF.layer setMasksToBounds:YES];
    [self.inputTF.layer setCornerRadius:4.0];
    [self.inputTF.layer setBorderWidth:0.5]; //边框宽度
    [self.inputTF.layer setBorderColor:UIColorHex(0x1a2a3e).CGColor];
    self.inputTF.returnKeyType = UIReturnKeyDone;

    self.inputTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    //设置显示模式为永远显示(默认不显示)
    self.inputTF.leftViewMode = UITextFieldViewModeAlways;
    
//    NSString *placeHolderString = @" 发射弹幕";
//    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc]initWithString:placeHolderString];
//    [placeholder addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, placeHolderString.length)];
//    self.inputTF.attributedPlaceholder = placeholder;
    self.inputTF.textColor = [UIColor whiteColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
