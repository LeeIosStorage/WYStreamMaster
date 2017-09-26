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
//#import "YTChatBottomView.h"
#import <UserNotifications/UserNotifications.h>
#import "RMPushUtils.h"
#import "YTMessageConverter.h"
#import "YTGiftAttachment.h"
#import "ZYGiftListModel.h"
#import "UserModel.h"
#import "LiveGiftShowModel.h"
#import "LiveGiftShow.h"
#import "NSString+YTChatRoom.h"
#import "WYChatUserNormalView.h"
#import "WYCustomAlertView.h"
#import "WYCustomActionSheet.h"
#import "WYLiveViewController.h"
#import "WYGiftAnimationManager.h"
#import "WYFaceRendererManager.h"

#define ChatData_MaxCount 100

@interface YTRoomView ()<UITableViewDelegate,UITableViewDataSource,YTChatControlDelegate,CellDelegate>

@property (strong, nonatomic) WYNetWorkManager  *networkManager;

@property (strong, nonatomic) UIButton          *scrollNewMessageButton;
@property (assign, nonatomic) BOOL              autoScroll;
@property (assign, nonatomic) CGFloat           lastContentOffset;
@property (strong, nonatomic) NSMutableArray    *dataArray;
@property (strong, nonatomic) UITableView       *chatTable;

//@property (strong, nonatomic) YTChatBottomView  *bottomView;

@property (strong, nonatomic) LiveGiftShow *giftShow;

@property (strong, nonatomic) WYGiftAnimationManager *giftAnimationManager;

@property (weak, nonatomic) WYLiveViewController  *liveRoomVC;

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
    self.chatroomControl.chatRoomView = self;
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
    
    //大礼物动画处理
    [self.giftAnimationManager startPlaySystemSoundWithVibrate:giftAttachment];
    
    
    //脸部动画
//    [[WYFaceRendererManager sharedInstance] addGiftModel:giftAttachment];
    
    
    UserModel *userModel = [[UserModel alloc] init];
    userModel.name = giftAttachment.senderName;
    userModel.iconUrl = @"";
    
    ZYGiftListModel *giftListModel = [[ZYGiftListModel alloc] init];
    giftListModel.type = [NSString stringWithFormat:@"%@_%@",giftAttachment.senderID,giftAttachment.giftID];
    giftListModel.goldCount = giftAttachment.giftNum;
//    if (![giftAttachment.giftShowImage hasPrefix:@"http://"]) {
//        giftAttachment.giftShowImage = [NSString stringWithFormat:@"%@/%@",[WYAPIGenerate sharedInstance].baseImgUrl,giftAttachment.giftShowImage];
//    }
    giftListModel.rewardMsg = [NSString stringWithFormat:@"送 %@",giftAttachment.giftName];
    giftAttachment.giftShowImage = [NSString stringWithFormat:@"https://www.legend8888.com%@", giftAttachment.giftShowImage];

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
    
    NSString *userId = model.message.from;
    BOOL giftMessage = NO;
    if (model.message.messageType == NIMMessageTypeCustom) {
        id attachment = ((NIMCustomObject *)model.message.messageObject).attachment;
        if ([attachment isKindOfClass:[YTGiftAttachment class]]) {
            giftMessage = YES;
            YTGiftAttachment *giftAttachment = attachment;
            userId = giftAttachment.senderID;
        }
    }
    
    if ([model.message.from isSelf] && !giftMessage) {
        return;
    }
//    [self getMemberInfoWithUserId:[model.message.from realUserId]];
    
    
    NIMChatroomMembersByIdsRequest *request = [[NIMChatroomMembersByIdsRequest alloc] init];
    request.roomId = [WYLoginUserManager chatRoomId];
    request.userIds = @[userId];
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembersByIds:request completion:^(NSError * _Nullable error, NSArray<NIMChatroomMember *> * _Nullable members) {
        
        if (members.count == 0) {
//            [MBProgressHUD showAlertMessage:MemberLeaveRoom toView:weakSelf];
            return;
        }
        
        if (!error) {
            NIMChatroomMember *member = members[0];
            
            [weakSelf showNormalCarViewWithMember:member];
            if (!member.roomAvatar) {
//                [MBProgressHUD showAlertMessage:MemberLeaveRoom toView:weakSelf];
                return;
            }
            
//            [weakSelf showRoomManagerCarViewWithMember:member];
    
        }
    }];
    
}

- (void)getMemberInfoWithUserId:(NSString *)userID{
    
}

- (void)showNormalCarViewWithMember:(id)member
{
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    for (UIView *subView in window.subviews) {
//        if ([subView isKindOfClass:[WYChatUserNormalView class]]) {
//            return;
//        }
//    }
    WYChatUserNormalView *normalCarView = [[NSBundle mainBundle] loadNibNamed:@"WYChatUserNormalView" owner:self options:nil].lastObject;
    WYCustomAlertView *alert = [[WYCustomAlertView alloc] initWithCustomAlertSize:normalCarView.size];
    [normalCarView updateWithMemeber:member];
    [alert showWithView:normalCarView];
    
    
//    NIMChatroomMember *roomMember = member;
    WEAKSELF
    normalCarView.letMemberMuteBlock = ^{
//        if (roomMember.isTempMuted) {
//            //解禁言
//            [weakSelf requestMemberMuteWithMember:member alertView:alert];
//        }else{
//            
//        }
        
        //禁言
        WYCustomActionSheet *actionSheet = [[WYCustomActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [weakSelf requestMemberMuteWithMember:member alertView:alert];
            }
            
        } cancelButtonTitle:@"取消" destructiveButtonTitle:@"禁言" otherButtonTitles:nil];
        [actionSheet showInView:self.liveRoomVC.view];
        
    };
    normalCarView.letManagerBlock = ^{
        //设立取消房管
        [weakSelf requestMemberManagerWithMember:member alertView:alert];
        
    };
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

#pragma mark - 
#pragma mark - Server
- (void)requestMemberMuteWithMember:(id)member alertView:(WYCustomAlertView *)alertView{
    
    NIMChatroomMember *roomMember = member;
    
    WEAKSELF
    /***********************
    //////////云信的禁言解禁接口
    [alertView closeShowView];
    NIMChatroomMemberUpdateRequest *request = [[NIMChatroomMemberUpdateRequest alloc] init];
    request.roomId = [WYLoginUserManager chatRoomId];
    request.userId = roomMember.userId;
    if (roomMember.isTempMuted) {
        //解禁言
        request.enable = NO;
    }else{
        //禁言
        request.enable = YES;
    }
    
    unsigned long long duration = 60*60*24;
    [[NIMSDK sharedSDK].chatroomManager updateMemberTempMute:request duration:duration completion:^(NSError * _Nullable error) {
        if (!error) {
            if (roomMember.isTempMuted) {
                [MBProgressHUD showAlertMessage:[NSString stringWithFormat:@"%@ 已解除禁言",roomMember.roomNickname] toView:nil];
            }else{
                [MBProgressHUD showAlertMessage:[NSString stringWithFormat:@"%@ 已被禁言",roomMember.roomNickname] toView:nil];
            }
        }
    }];
    //////////NIMSDK
    return;
    ***********************/
    
    
    //////////自己的服务器禁言接口
    unsigned long long duration = 60*60*24;
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"temporaryMute"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[NSNumber numberWithLongLong:duration] forKey:@"muteDuration"];
    [paramsDic setObject:roomMember.userId forKey:@"target"];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"operator"];
    [paramsDic setObject:[WYLoginUserManager chatRoomId] forKey:@"roomid"];
    
    
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        [alertView closeShowView];
        if (requestType == WYRequestTypeSuccess) {
            //[weakSelf letMemberMuteInNimSDK];
//            if (roomMember.isTempMuted) {
//                [MBProgressHUD showAlertMessage:[NSString stringWithFormat:@"%@ 已解除禁言",roomMember.roomNickname] toView:nil];
//            }else{
//                
//            }
            [MBProgressHUD showAlertMessage:[NSString stringWithFormat:@"%@ 已被禁言24小时",roomMember.roomNickname] toView:nil];
            
        } else {
            [MBProgressHUD showAlertMessage:message toView:nil];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:@"连接失败，请检查您的网络设置后重试" toView:nil];
    }];
    
}

- (void)requestMemberManagerWithMember:(id)member alertView:(WYCustomAlertView *)alertView{
    
    NIMChatroomMember *roomMember = member;
    
    /**********************
    //////////云信的设置管理员接口
    [alertView closeShowView];
    NIMChatroomMemberUpdateRequest *request = [[NIMChatroomMemberUpdateRequest alloc] init];
    request.roomId = [WYLoginUserManager chatRoomId];
    request.userId = roomMember.userId;
    if (roomMember.type == NIMChatroomMemberTypeManager) {
        //取消管理员
        request.enable = NO;
    }else if (roomMember.type == NIMChatroomMemberTypeGuest || roomMember.type == NIMChatroomMemberTypeNormal){
        //设置管理员
        request.enable = YES;
    }else if (roomMember.type == NIMChatroomMemberTypeLimit){
        [MBProgressHUD showAlertMessage:@"受限用户暂不可操作" toView:nil];
        return;
    }
    
    [[NIMSDK sharedSDK].chatroomManager markMemberManager:request completion:^(NSError * _Nullable error) {
        if (!error) {
            if (roomMember.type == NIMChatroomMemberTypeManager) {
                [MBProgressHUD showSuccess:[NSString stringWithFormat:@"已取消 %@ 的房管",roomMember.roomNickname] toView:nil];
            }else if (roomMember.type == NIMChatroomMemberTypeGuest || roomMember.type == NIMChatroomMemberTypeNormal){
                [MBProgressHUD showSuccess:[NSString stringWithFormat:@"已设置 %@ 为房管",roomMember.roomNickname] toView:nil];
            }
        }
    }];
    //////////NIMSDK
    return;
    **********************/
    
    WEAKSELF
    //////////自己的服务器设置房管接口
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"save_room_management"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
//    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"anchor_user_code"];
    [paramsDic setObject:roomMember.userId forKey:@"user_code"];
    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"operator"];
    [paramsDic setObject:[WYLoginUserManager chatRoomId] forKey:@"roomid"];
    
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [alertView closeShowView];
        if (requestType == WYRequestTypeSuccess) {
            
            NSDictionary *dic = (NSDictionary *)dataObject;
            NSInteger operation = [[dic objectForKey:@"operation"] integerValue];
            if (operation == -1) {
                [MBProgressHUD showSuccess:[NSString stringWithFormat:@"已取消 %@ 的房管",roomMember.roomNickname] toView:nil];
            }else if (operation == 1){
                [MBProgressHUD showSuccess:[NSString stringWithFormat:@"已设置 %@ 为房管",roomMember.roomNickname] toView:nil];
            }
        }else{
            [MBProgressHUD showError:message toView:nil];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_server_request_errer_tip"] toView:nil];
    }];
    
}

- (WYLiveViewController *)getLiveRoomViewController
{
    id responder = [[self.superview superview] nextResponder];
    if ([responder isKindOfClass:[WYLiveViewController class]]) {
        WYLiveViewController *liveRoomVC = (WYLiveViewController *)responder;
        return liveRoomVC;
    }
    return nil;
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


- (WYNetWorkManager *)networkManager
{
    if (!_networkManager) {
        _networkManager = [[WYNetWorkManager alloc] init];
    }
    return _networkManager;
}

- (LiveGiftShow *)giftShow{
    if (!_giftShow) {
        _giftShow = [[LiveGiftShow alloc] init];
//        _giftShow.backgroundColor = [UIColor whiteColor];
    }
    return _giftShow;
}

- (WYGiftAnimationManager *)giftAnimationManager{
    if (!_giftAnimationManager) {
        _giftAnimationManager = [[WYGiftAnimationManager alloc] init];
    }
    return _giftAnimationManager;
}

- (WYLiveViewController *)liveRoomVC
{
    if (!_liveRoomVC) {
        _liveRoomVC = [self getLiveRoomViewController];
    }
    return _liveRoomVC;
}

@end
