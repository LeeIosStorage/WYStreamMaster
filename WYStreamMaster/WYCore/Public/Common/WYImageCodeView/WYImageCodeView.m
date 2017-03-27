//
//  WYImageCodeView.m
//  WangYu
//
//  Created by Leejun on 15/12/11.
//  Copyright © 2015年 KID. All rights reserved.
//

#import "WYImageCodeView.h"
#import "WYAPIGenerate.h"
#import "UIImageView+WebCache.h"
#import "WYCommonUtils.h"

@interface WYImageCodeView () <UITextFieldDelegate>

@property (nonatomic, strong) UIWindow *oldWindow;
@property (nonatomic, strong) UIWindow *showWindow;

@property (nonatomic ,strong) IBOutlet UITextField *codeTextField;
@property (nonatomic, strong) IBOutlet UIImageView *codeImageView;
@property (nonatomic, strong) IBOutlet UIButton *resetButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *affirmButton;

- (IBAction)resetAction:(id)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)clickAction:(id)sender;

@end

@implementation WYImageCodeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)init:(id)owner{
    self = [[[NSBundle mainBundle] loadNibNamed:@"WYImageCodeView" owner:nil options:nil] objectAtIndex:0];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"%@ dealloc!!!",NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup{
    
    self.backgroundColor = [UIColor colorWithHexString:@"323A43"];
    
//    NSString *placeholder = @"输入图片验证码";
//    self.codeTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[UIFont systemFontOfSize:14] color:[UIColor colorWithHexString:@"8E8E9A"]];
    
    self.codeTextField.textColor = [UIColor colorWithHexString:@"8E8E9A"];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    
    [self.codeTextField.layer setMasksToBounds:YES];
    [self.codeTextField.layer setCornerRadius:2.5];
    [self.codeTextField.layer setBorderWidth:1]; //边框宽度
    [self.codeTextField.layer setBorderColor:[UIColor colorWithHexString:@"575d65"].CGColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

#pragma mark - NSNotification
-(void) keyboardWillShow:(NSNotification *)note{
    
    if (!self) {
        return;
    }
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [_oldWindow convertRect:keyboardBounds toView:nil];
    
//    [self setMaxViewHeight:(self.bounds.size.height - keyboardBounds.size.height - 35)];
    
    // get a rect for the textView frame
    CGRect toolbarFrame = self.frame;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    toolbarFrame.origin.y = _oldWindow.frame.size.height - keyboardBounds.size.height - toolbarFrame.size.height-10;
    self.frame = toolbarFrame;
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    if (!self) {
        return;
    }
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    
//    CGRect toolbarFrame = self.frame;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
//    toolbarFrame.origin.y = self.bounds.size.height - toolbarFrame.size.height;
//    self.frame = toolbarFrame;
    
    self.center = _oldWindow.center;
    
    // commit animations
    [UIView commitAnimations];
}

- (void)show{
    
    _oldWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect frame = [UIScreen mainScreen].bounds;
    _showWindow = [[UIWindow alloc] initWithFrame:frame];
    _showWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    frame = self.frame;
    frame.origin.x = (_showWindow.frame.size.width-frame.size.width)/2;
    frame.origin.y = (_showWindow.frame.size.height-frame.size.height)/2;
    self.frame = frame;
    
    [_showWindow addSubview:self];
    _showWindow.windowLevel = UIWindowLevelAlert;
    [_showWindow makeKeyAndVisible];
    
    [self resetAction:nil];
    
    [self.codeTextField becomeFirstResponder];
}

- (IBAction)resetAction:(id)sender{
    
//    [self.codeImageView setImageURL:nil];
    NSString *imageUrl = [NSString stringWithFormat:@"%@/checkCode?phone=%@",[WYAPIGenerate sharedInstance].baseURL,_telephone];
    [self.codeImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
//    [self.codeImageView setImageWithURL:[NSURL URLWithString:imageUrl] options:YYWebImageOptionRefreshImageCache];
}

- (IBAction)dismiss:(id)sender {
    [self dismissView];
}

- (IBAction)clickAction:(id)sender {
    NSString *codeText = [_codeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (codeText.length == 0) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(affirmImageCodeViewWithCode:)]) {
        [self.delegate affirmImageCodeViewWithCode:codeText];
    }
//    [self dismissView];
    self.affirmButton.enabled = NO;
}

- (void)dismissView{
    [self.oldWindow makeKeyAndVisible];
    [self.layer removeAllAnimations];
    [self removeFromSuperview];
    if (self.oldWindow) {
        self.oldWindow = nil;
        self.showWindow.hidden = YES;
        self.showWindow = nil;
    }
}

- (void)showAnimationWithError{
    [self.codeTextField.layer setBorderColor:[WYStyleSheet currentStyleSheet].titleLabelSelectedColor.CGColor];
    self.affirmButton.enabled = NO;
    [WYCommonUtils shakeAnimationForView:self.codeTextField];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    [self.codeTextField.layer setBorderColor:[UIColor colorWithHexString:@"575d65"].CGColor];
    self.affirmButton.enabled = YES;
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    [self.codeTextField.layer setBorderColor:[UIColor colorWithHexString:@"575d65"].CGColor];
    self.affirmButton.enabled = YES;
    return YES;
}

@end
