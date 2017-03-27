//
//  WYAnchorManageView.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/23.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYAnchorManageView.h"
#import <GMGridView/GMGridViewCell+Extended.h>
#import <GMGridView/GMGridViewLayoutStrategies.h>
#import <BlocksKit/BlocksKit+UIKit.h>

@interface WYAnchorManageView ()
<
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
UITextViewDelegate,
GMGridViewDataSource,
GMGridViewActionDelegate
>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, weak) IBOutlet UIView *headContainerView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nickNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *roomNumLabel;
@property (nonatomic, weak) IBOutlet UITextField *roomNameTextField;
@property (nonatomic, weak) IBOutlet UITextView *noticeTextView;
@property (nonatomic, weak) IBOutlet UILabel *textViewplaceholderLabel;

@property (nonatomic, strong) NSMutableArray *roomManagerList;
@property (nonatomic, weak) IBOutlet GMGridView *gridView;

@end

@implementation WYAnchorManageView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

#pragma mark -
#pragma mark - Private Methods
- (void)setup{
    
    self.roomManagerList = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    [self addGestureRecognizer:gestureRecongnizer];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effe = [[UIVisualEffectView alloc]initWithEffect:blur];
    effe.frame = CGRectMake(0, 0 , self.width,self.height);
    [effe setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self insertSubview:effe atIndex:0];
    
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = [UIColor whiteColor];
    self.topView.alpha = 0.07;
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(36);
    }];
    
    self.avatarImageView.layer.cornerRadius = 33;
    self.avatarImageView.layer.masksToBounds = YES;
    [self.avatarImageView.layer setBorderWidth:1];
    [self.avatarImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    self.roomNameTextField.enabled = NO;
    NSString *placeholder = @"修改房间名字";
    self.roomNameTextField.attributedPlaceholder = [WYCommonUtils stringToColorAndFontAttributeString:placeholder range:NSMakeRange(0, placeholder.length) font:[UIFont systemFontOfSize:12] color:UIColorHex(0xcacaca)];
    self.roomNameTextField.text = [WYLoginUserManager roomNameTitle];
    
    
    _gridView.style = GMGridViewStyleSwap;
    _gridView.itemSpacing = 15;
    _gridView.minEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _gridView.centerGrid = NO;
    _gridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];
    _gridView.actionDelegate = self;
    _gridView.showsHorizontalScrollIndicator = NO;
    _gridView.showsVerticalScrollIndicator = NO;
    _gridView.dataSource = self;
//    _gridView.scrollsToTop = NO;
    _gridView.delegate = self;
    
    
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.topView.mas_bottom);
        make.bottom.equalTo(self).offset(-125);
    }];
    
//    self.headContainerView.height = 399.5f;
    self.tableView.tableHeaderView = self.headContainerView;
    
    [self updateHeadViewData];
    
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self.roomNameTextField resignFirstResponder];
    [self.noticeTextView resignFirstResponder];
}

- (void)updateHeadViewData{
    
    NSURL *avatarUrl = [NSURL URLWithString:@"https://imgsa.baidu.com/baike/c0%3Dbaike180%2C5%2C5%2C180%2C60/sign=e6c6c4a53ddbb6fd3156ed74684dc07d/b64543a98226cffca90bcfecbd014a90f603ea4f.jpg"];
    [WYCommonUtils setImageWithURL:avatarUrl setImageView:self.avatarImageView placeholderImage:@""];
    
    self.nickNameLabel.text = [WYLoginUserManager nickname];
    self.roomNumLabel.text = [WYLoginUserManager roomId];
    
}

#pragma mark -
#pragma mark - Server
- (void)refreshRoomManagerList{
    self.roomManagerList = [[NSMutableArray alloc] init];
    [self.roomManagerList addObject:@""];
    [self.roomManagerList addObject:@""];
    [self.roomManagerList addObject:@""];
    [self.roomManagerList addObject:@""];
    
    [self.gridView reloadData];
}

#pragma mark -
#pragma mark - Button Clicked
- (IBAction)closeAction:(id)sender{
    [self onBgClick];
}

- (void)onBgClick
{
    [self endEditing:YES];
    [self hide];
}

- (void)show
{
    if (![self superview] || self.hidden) {
        
        [self refreshRoomManagerList];
        [UIView animateWithDuration:0.3f animations:^{
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo([UIApplication sharedApplication].keyWindow);
            }];
            [self setHidden:NO];
        }];
    }
}

- (void)hide
{
    if ([self superview]) {
        [UIView animateWithDuration:0.3f animations:^{
            [self setHidden:YES];
            [self endEditing:YES];
        }];
    }
}


#pragma mark - GMGridViewDataSource
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return self.roomManagerList.count;
    
}
- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return CGSizeMake(45 , 60);
}

static int avatarImageView_tag = 201,nameLabel_tag = 202;
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    static NSString *cellWithIdentifier = @"applyGridViewIdentifier";
    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:cellWithIdentifier];
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        
        UIView *supView = [[UIView alloc] init];
        cell.contentView = supView;
        
        UIImageView *avatarImageView = [[UIImageView alloc] init];
        avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        avatarImageView.clipsToBounds = YES;
        avatarImageView.layer.cornerRadius = 22.5;
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.tag = avatarImageView_tag;
        [supView addSubview:avatarImageView];
        
        UIImageView *deleteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wy_delete_icon"]];
//        deleteImageView.frame = CGRectMake(45-15,45-15, 15, 15);
        [supView addSubview:deleteImageView];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.textColor = [UIColor colorWithHexString:@"c7c7c7"];
        nameLabel.font = [UIFont systemFontOfSize:10];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.tag = nameLabel_tag;
        [supView addSubview:nameLabel];
        
        [avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(supView);
            make.size.mas_equalTo(CGSizeMake(45, 45));
        }];
        
        [deleteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(avatarImageView);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
        
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(supView);
        }];
        
    }
    UIView* supView = (UIView* )cell.contentView;
    UIImageView *avatarImageView = [supView viewWithTag:avatarImageView_tag];
    UILabel *nameLabel = [supView viewWithTag:nameLabel_tag];
    
    NSURL *avatarUrl = [NSURL URLWithString:@"https://imgsa.baidu.com/baike/c0%3Dbaike180%2C5%2C5%2C180%2C60/sign=e6c6c4a53ddbb6fd3156ed74684dc07d/b64543a98226cffca90bcfecbd014a90f603ea4f.jpg"];
    [WYCommonUtils setImageWithURL:avatarUrl setImageView:avatarImageView placeholderImage:@""];
    nameLabel.text = @"大乔&小乔";
    
    return cell;
}
#pragma mark GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    //    WYLog(@"Did tap at index %ld", position);
    WEAKSELF
    UIAlertView *alertView = [UIAlertView bk_showAlertViewWithTitle:@"确定要取消TA的管理员吗？" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
        }
    }];
    
    [alertView show];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -
#pragma mark - Getters and Setters
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _tableView;
}

#pragma mark -
#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView{
    //公告结束编辑  发送请求
    
}

- (void)textViewDidChange:(UITextView *)textView{
    
    self.textViewplaceholderLabel.hidden = NO;
    if (textView.text.length > 0) {
        self.textViewplaceholderLabel.hidden = YES;
    }
}

@end
