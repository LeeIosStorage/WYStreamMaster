//
//  WYSocketManager.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/17.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYSocketManager.h"

@interface WYSocketManager ()
<
SRWebSocketDelegate
>
{
    NSTimer * heartBeat;
    NSTimeInterval reConnectTime;
}
@property (nonatomic, strong) SRWebSocket *webSocket;

@end

@implementation WYSocketManager

+ (WYSocketManager *)sharedInstance
{
    static WYSocketManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(& onceToken,^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)initSocketURL:(NSURL *)url{
    if (url) {
        self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:url]];
        self.webSocket.delegate = self;
        [self.webSocket open];
    }
}

//关闭连接
- (void)SRWebSocketClose {
    if (self.webSocket){
        [self.webSocket close];
        self.webSocket = nil;
        //断开连接时销毁心跳
        [self destoryHeartBeat];
    }
}

//- (void)sendData:(id)data{
//    
//    WEAKSELF
////    dispatch_async(self.socketQueue, ^{
////        
////    });
//    if (weakSelf.webSocket != nil) {
//        // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
//        if (weakSelf.webSocket.readyState == SR_OPEN) {
//            [weakSelf.webSocket send:data];    // 发送数据
//            
//        } else if (weakSelf.webSocket.readyState == SR_CONNECTING) {
//            NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
//            // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
//            // 只要有一次状态是 SR_OPEN 的就调用 [ws.socket send:data] 发送数据
//            // 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
//            // 代码有点长，我就写个逻辑在这里好了
//            
//        } else if (weakSelf.webSocket.readyState == SR_CLOSING || weakSelf.webSocket.readyState == SR_CLOSED) {
//            // websocket 断开了，调用 reConnect 方法重连
////            [self reConnect:^{
////                NSLog(@"重连成功，继续发送刚刚的数据");
////                [ws.socket send:data];
////            }];
//        }
//    } else {
//        NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
//        NSLog(@"其实最好是发送前判断一下网络状态比较好，我写的有点晦涩，socket==nil来表示断网");
//    }
//}

- (void)sendData:(id)data {
    
    WEAKSELF
    dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);
    
    dispatch_async(queue, ^{
        if (weakSelf.webSocket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法，不然要崩
            if (weakSelf.webSocket.readyState == SR_OPEN) {
                [weakSelf.webSocket send:data];    // 发送数据
                
            } else if (weakSelf.webSocket.readyState == SR_CONNECTING) {
                NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
                // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
                // 只要有一次状态是 SR_OPEN 的就调用 [ws.socket send:data] 发送数据
                // 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
                [self reConnect];
                
            } else if (weakSelf.webSocket.readyState == SR_CLOSING || weakSelf.webSocket.readyState == SR_CLOSED) {
                // websocket 断开了，调用 reConnect 方法重连
                [self reConnect];
            }
        } else {
            NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
            [self SRWebSocketClose];
        }
    });
}

#pragma mark -
#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSData *data = [message dataUsingEncoding:NSASCIIStringEncoding];
    WYLog(@"SRWebSocket 收到服务器消息 = %@",message);
    NSDictionary *dic = (NSDictionary *)[self toArrayOrNSDictionary:data];
    
    if ([dic objectForKey:@"action"]) {
        if ([dic[@"action"] isEqualToString:@"wsConnect"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"此账号在其他地方登录，您已下线", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wsConnect" object:nil];
        }
    }
}

// 将JSON串转化为字典或者数组
- (id)toArrayOrNSDictionary:(NSData *)jsonData{
    NSError *error = nil;
    if (jsonData) {
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                          error:&error];
        if (jsonObject != nil && error == nil){
            return jsonObject;
        }else{
            // 解析错误
            return nil;
        }
    } else {
        return nil;
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    WYLog(@"SRWebSocket 连接成功.");
    //每次正常连接的时候清零重连时间
    reConnectTime = 0;
    //开启心跳
    [self initHeartBeat];
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    WYLog(@"SRWebSocket 连接失败 = %@",[error localizedDescription]);
    self.webSocket = nil;
    //连接失败就重连
    [self reConnect];
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    WYLog(@"SRWebSocket 连接断开 code:%d reason:%@ wasClean:%d",(int)code,reason,wasClean);
    [self SRWebSocketClose];
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    WYLog(@"SRWebSocket didReceivePong = %@",pongPayload);
}


#pragma mark - methods
//重连机制
- (void)reConnect
{
    [self SRWebSocketClose];
    //超过一分钟就不再重连 所以只会重连5次 2^5 = 64
    if (reConnectTime > 64) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.webSocket open];
    });
    
    //重连时间2的指数级增长
    if (reConnectTime == 0) {
        reConnectTime = 2;
    }else{
        reConnectTime *= 2;
    }
}

//初始化心跳
- (void)initHeartBeat
{
//    dispatch_main_async_safe(^{
//        [self destoryHeartBeat];
//        __weak typeof(self) weakSelf = self;
//        //心跳设置为3分钟，NAT超时一般为5分钟
//        heartBeat = [NSTimer scheduledTimerWithTimeInterval:20 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            NSLog(@"heart");
//            //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
//            [weakSelf sendData:@"heart"];
//        }];
//        [[NSRunLoop currentRunLoop]addTimer:heartBeat forMode:NSRunLoopCommonModes];
//    });
    
    [self destoryHeartBeat];
    __weak typeof(self) weakSelf = self;
    //心跳设置为20秒
    heartBeat = [NSTimer scheduledTimerWithTimeInterval:20 repeats:YES block:^(NSTimer * _Nonnull timer) {
        //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
        [weakSelf sendData:@"heart"];
    }];
    [[NSRunLoop currentRunLoop]addTimer:heartBeat forMode:NSRunLoopCommonModes];
}

//取消心跳
- (void)destoryHeartBeat
{
//    dispatch_main_async_safe(^{
//        if (heartBeat) {
//            [heartBeat invalidate];
//            heartBeat = nil;
//        }
//    });
    if (heartBeat) {
        [heartBeat invalidate];
        heartBeat = nil;
    }

}

//pingPong机制
- (void)ping{
    [self.webSocket sendPing:nil];
}
//// Return YES to convert messages sent as Text to an NSString. Return NO to skip NSData -> NSString conversion for Text messages. Defaults to YES.
//- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket{
//    
//}

@end
