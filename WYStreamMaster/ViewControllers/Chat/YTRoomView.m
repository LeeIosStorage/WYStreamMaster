//
//  YTRoomView.m
//  WYRecordMaster
//
//  Created by zurich on 2016/11/21.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "YTRoomView.h"
#import "YTChatModel.h"
#import "YTChatCell.h"
#import "YTChatBottomView.h"
#import <UserNotifications/UserNotifications.h>
#import "RMPushUtils.h"
#import "YTMessageConverter.h"
#import "YTGiftAttachment.h"
#import "ZYGiftListModel.h"
#import "UserModel.h"
#import "LiveGiftShowModel.h"
#import "LiveGiftShow.h"

#define ChatData_MaxCount 100

@interface YTRoomView ()<UITableViewDelegate,UITableViewDataSource,YTChatControlDelegate,CellDelegate>

@property (strong, nonatomic) UIButton          *scrollNewMessageButton;
@property (assign, nonatomic) BOOL              autoScroll;
@property (assign, nonatomic) CGFloat           lastContentOffset;
@property (strong, nonatomic) NSMutableArray    *dataArray;
@property (strong, nonatomic) UITableView       *chatTable;

@property (strong, nonatomic) YTChatBottomView  *bottomView;

@property (strong, nonatomic) LiveGiftShow *giftShow;

@end

@implementation YTRoomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)roomViewPrepare
{
    //默认自动滚动
    self.autoScroll = YES;
    
    self.chatroomControl = [[YTChatRoomControl alloc] init];
  
    self.chatroomControl.delegate = self;
    
    [self initData];
    [self initSubViews];
    [self prepare];
}

- (void)prepare
{
    //获取到房间id之后执行进入房间，获取数据
    [self.chatroomControl chatPrepare];
}

- (void)initSubViews
{
    self.backgroundColor = [UIColor clearColor];
    WEAKSELF
    [self addSubview:self.chatTable];
    [self.chatTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf);
        make.top.equalTo(weakSelf);
        make.width.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf);
    }];
    
    [self addSubview:self.scrollNewMessageButton];
    [self.scrollNewMessageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf).and.offset(-30);
        make.bottom.equalTo(weakSelf.chatTable).and.offset(-5);
        make.size.mas_equalTo(CGSizeMake(30, 20));
    }];
    
//    [self addSubview:self.bottomView];
//    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self);
//        make.height.mas_equalTo(@50);
//        make.bottom.equalTo(self);
//    }];
    
    [self addSubview:self.giftShow];
    [self.giftShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@244);
        make.height.equalTo(@50);
        make.left.equalTo(self.mas_left).offset(-5);
        make.bottom.equalTo(self.mas_top);
    }];
}

- (void)initData
{
    self.dataArray = [NSMutableArray arrayWithCapacity:0];
    
    //[self getGiftListData];
}

#pragma mark -
#pragma mark - Public
- (void)sendMessageWithText:(NSString *)text
{
    //[self.liveRoomVC.bottomView.inputTF resignFirstResponder];
    if (!self.itSelf.isTempMuted) {
        NIMMessage *message = [YTMessageConverter messageWithText:text];
        [self.chatroomControl sendWithMessage:message];
    } else {
        [MBProgressHUD showAlertMessage:@"您已经被禁言" toView:self];
    }
}

- (void)startPresentAnimationWithChatModel:(YTChatModel *)chatModel
{
    YTGiftAttachment *giftAttachment = ((NIMCustomObject *)chatModel.message.messageObject).attachment;
    UserModel *userModel = [[UserModel alloc] init];
    userModel.name = giftAttachment.senderName;
    userModel.iconUrl = @"";
    
    ZYGiftListModel *giftListModel = [[ZYGiftListModel alloc] init];
    giftListModel.type = [NSString stringWithFormat:@"%@_%@",giftAttachment.senderID,giftAttachment.giftID];
    giftListModel.goldCount = giftAttachment.giftNum;
    if (![giftAttachment.giftShowImage hasPrefix:@"http://"]) {
        giftAttachment.giftShowImage = [NSString stringWithFormat:@"%@/%@",[WYAPIGenerate sharedInstance].baseImgUrl,giftAttachment.giftShowImage];
    }
    giftListModel.rewardMsg = [NSString stringWithFormat:@"送 %@",giftAttachment.giftName];
    
    giftListModel.picUrl = giftAttachment.giftShowImage;
    
    LiveGiftShowModel *showListModel = [LiveGiftShowModel giftModel:giftListModel userModel:userModel];
    [self.giftShow addGiftListModel:showListModel];
}

#pragma mark
#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //defualt
    YTChatModel *model = self.dataArray[indexPath.row];
    CGFloat space = 5.f;
    if (model.chatTextLayout.textBoundingSize.height <= 20.f) {
        return 20.f + space;
    }
    return model.chatTextLayout.textBoundingSize.height + space;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cell";
    YTChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[YTChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    YTChatModel *model = self.dataArray[indexPath.row];
    [cell updateDataWithMessage:model];
    cell.cellDelegate = self;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGPoint off = scrollView.contentOffset;
    CGFloat offSize = off.y + scrollView.bounds.size.height + scrollView.contentInset.bottom;
    if (offSize >= scrollView.contentSize.height) {
        self.autoScroll = YES;
    } else {
        self.autoScroll = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint off = scrollView.contentOffset;
    CGFloat offSize = off.y + scrollView.bounds.size.height + scrollView.contentInset.bottom;
    if (offSize == scrollView.contentSize.height) {
        self.scrollNewMessageButton.hidden = YES;
    }
}

#pragma mark
#pragma mark - CellDelegate

- (void)tappedCellNameWithChatModel:(YTChatModel *)model
{
    WEAKSELF

    /*
    NIMChatroomMembersByIdsRequest *request = [[NIMChatroomMembersByIdsRequest alloc] init];
    request.roomId = [WYLoginUserManager chatRoomId];
    request.userIds = @[model.message.from];
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembersByIds:request completion:^(NSError * _Nullable error, NSArray<NIMChatroomMember *> * _Nullable members) {
        
        if (members.count == 0) {
            [MBProgressHUD showAlertMessage:MemberLeaveRoom toView:weakSelf];
            return;
        }
        
        if (!error) {
            NIMChatroomMember *member = members[0];
            
            if (!member.roomAvatar) {
                [MBProgressHUD showAlertMessage:MemberLeaveRoom toView:weakSelf];
                return;
            }
            
            //[weakSelf showRoomManagerCarViewWithMember:member]
    
        }
    }];
     */
}

- (void)showRoomManagerCarViewWithMember:(NIMChatroomMember *)member
{
    //点击人员信息卡片显示，可能现在不用
    /*
    YTRoomManagerCarView *managerView = [[NSBundle mainBundle] loadNibNamed:@"YTRoomManagerCarView" owner:self options:nil].lastObject;
    WYCustomAlertView *alert = [[WYCustomAlertView alloc] initWithCustomAlertSize:managerView.size];
    [managerView updateWithMemeber:member roomID:self.roomInfo.chatRoomId];
    [alert showWithView:managerView];
    WEAKSELF
    managerView.gotoHomePageBlock = ^{
        [alert closeShowView];
        [weakSelf gotoHomePageWithMember:member];
    };
    //禁言回调
    managerView.letMemberMuteBlcok = ^{
        [alert closeShowView];
        [MBProgressHUD showSuccess:MemberMute];
    };
     */
}


#pragma mark
#pragma mark - YTChatControlDelegate

- (void)addMessageInRowWithMesssage:(NIMMessage *)message
{
    NSLog(@"12313====%@",message);
    YTChatModel *chatModel = [YTChatModel createChatModelWithMessage:message];
    NSString *messageFromID = nil;
    if ([message isKindOfClass:[NIMMessage class]]) {
        messageFromID = ((NIMMessage *)message).from;
    }
    
    chatModel.isAnchor = YES;
    [self dataProcessing];
    [self.dataArray addObject:chatModel];
    
    if (chatModel.chatMessageType == ChatMessageTypeGift) {
        [self startPresentAnimationWithChatModel:chatModel];
    }
    
    
    NSUInteger row = [self.dataArray indexOfObject:chatModel];
    
    [self.chatTable insertRow:row inSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self scrollToNewMessage];
}

- (void)receiveMessageWith:(YTChatModel *)chatModel
{
    if (!chatModel.chatTextLayout) {
        return;
    }
    [self dataProcessing];
    [self.dataArray addObject:chatModel];
    if (chatModel.message.messageType == NIMMessageTypeText || chatModel.chatMessageType == ChatMessageTypeGift) {
        if (chatModel.chatMessageType == ChatMessageTypeGift) {
            [self startPresentAnimationWithChatModel:chatModel];
        }
    }
    NSUInteger row = [self.dataArray indexOfObject:chatModel];
    [self.chatTable insertRow:row inSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
    [self scrollToNewMessage];
    if (chatModel.contentString && ![WYLoginUserManager localNotificationToClose]) {
        [self sendLocalNoticationWithMessage:chatModel.contentString];
    }
}

#pragma mark
#pragma mark - Action

- (void)scrollToNewMessage
{
    if (self.chatTable.contentSize.height > (self.height - 50)) {
        //当超过table高度
        if (self.autoScroll) {
            NSUInteger row = self.dataArray.count - 1;
            [self.chatTable scrollToRow:row inSection:0 atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        } else {
            self.scrollNewMessageButton.hidden = NO;
        }
    }
}

- (void)showNewMessageClicked
{
    self.autoScroll = YES;
    self.scrollNewMessageButton.hidden = YES;
    [self scrollToNewMessage];
}

- (void)dataProcessing
{
    //如果聊天数组超过100个则需要加头去尾
    if (self.dataArray.count >= ChatData_MaxCount) {
        //从第二个才是正式的数据
        [self.dataArray removeObjectAtIndex:2];
        [self.chatTable deleteRow:2 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)sendLocalNoticationWithMessage:(NSString *)message {
    
    return;
    UILocalNotification *localNotification = [RMPushUtils setLocalNotification:[NSDate date] alertBody:message badge:1 alertAction:@"查看" identifierKey:nil userInfo:nil soundName:nil];
    
    // 注册本地通知
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void)closeLocalNotification
{
    
}


#pragma mark 
#pragma mark - Getter

- (UITableView *)chatTable
{
    if (!_chatTable) {
        self.chatTable = [[UITableView alloc] init];
        self.chatTable.backgroundColor = [UIColor clearColor];
        self.chatTable.backgroundView = nil;
        [self.chatTable setDelegate:self];
        [self.chatTable setDataSource:self];
        self.chatTable.tableFooterView = [[UIView alloc] init];
        self.chatTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.chatTable.showsVerticalScrollIndicator = NO;
        //上面溜出来10px空隙
        self.chatTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    }
    return _chatTable;
}


- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[NSBundle mainBundle] loadNibNamed:@"YTChatBottomView" owner:self options:nil].lastObject;

    }
    return _bottomView;
}

- (LiveGiftShow *)giftShow{
    if (!_giftShow) {
        _giftShow = [[LiveGiftShow alloc] init];
//        _giftShow.backgroundColor = [UIColor whiteColor];
    }
    return _giftShow;
}

@end
