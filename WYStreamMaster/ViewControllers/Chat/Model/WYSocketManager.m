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

- (void)sendData:(id)data{
    
    WEAKSELF
//    dispatch_async(self.socketQueue, ^{
//        
//    });
    if (weakSelf.webSocket != nil) {
        // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
        if (weakSelf.webSocket.readyState == SR_OPEN) {
            [weakSelf.webSocket send:data];    // 发送数据
            
        } else if (weakSelf.webSocket.readyState == SR_CONNECTING) {
            NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
            // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
            // 只要有一次状态是 SR_OPEN 的就调用 [ws.socket send:data] 发送数据
            // 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
            // 代码有点长，我就写个逻辑在这里好了
            
        } else if (weakSelf.webSocket.readyState == SR_CLOSING || weakSelf.webSocket.readyState == SR_CLOSED) {
            // websocket 断开了，调用 reConnect 方法重连
//            [ws reConnect:^{
//                NSLog(@"重连成功，继续发送刚刚的数据");
//                [ws.socket send:data];
//            }];
        }
    } else {
        NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
        NSLog(@"其实最好是发送前判断一下网络状态比较好，我写的有点晦涩，socket==nil来表示断网");
    }
}

#pragma mark -
#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    WYLog(@"SRWebSocket 收到服务器消息 = %@",message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    WYLog(@"SRWebSocket 连接成功.");
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    WYLog(@"SRWebSocket 连接失败 = %@",[error localizedDescription]);
    
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    WYLog(@"SRWebSocket 连接断开 code:%d reason:%@ wasClean:%d",(int)code,reason,wasClean);
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    WYLog(@"SRWebSocket didReceivePong = %@",pongPayload);
}

//// Return YES to convert messages sent as Text to an NSString. Return NO to skip NSData -> NSString conversion for Text messages. Defaults to YES.
//- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket{
//    
//}

@end
