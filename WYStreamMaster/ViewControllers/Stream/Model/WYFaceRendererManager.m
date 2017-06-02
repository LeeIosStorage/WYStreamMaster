//
//  WYFaceRendererManager.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/5/27.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYFaceRendererManager.h"
#import "FURenderer.h"
#import "authpack.h"

#include <sys/mman.h>
#include <sys/stat.h>

#define gift_duration  6

@interface WYFaceModel : NSObject

@property (nonatomic, strong) NSString *senderId;
@property (nonatomic, strong) NSString *giftId;

@end

@implementation WYFaceModel

@end


@interface WYFaceRendererManager (){
    int _frameID;
    int _items[3];
    NSTimer *_timeTimer;
    int _waitTimeSecond;
}

@property (nonatomic, strong) WYFaceModel *currentFaceModel;
@property (nonatomic, strong) NSMutableArray *faceGiftList;

@end

@implementation WYFaceRendererManager

- (void)dealloc
{
    
}

+ (instancetype)sharedInstance{
    static WYFaceRendererManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id )init
{
    self = [super init];
    if (self) {
        
        [self setUpContext];
        [self initFaceunity];
        
        [self startTimer];
        
        self.faceGiftList = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)initFaceunity
{
//#warning faceunity全局只需要初始化一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        int size = 0;
        void *v3 = [self mmap_bundle:@"v3.bundle" psize:&size];
        
        [[FURenderer shareRenderer] setupWithData:v3 ardata:NULL authPackage:&g_auth_package authSize:sizeof(g_auth_package)];
    });
    
    //开启多脸识别（最高可设为8，不过考虑到性能问题建议设为4以内）
    fuSetMaxFaces(4);
    
    [self cleanItem];
//    [self loadFilter];
}

- (void *)mmap_bundle:(NSString *)bundle psize:(int *)psize {
    
    // Load item from predefined item bundle
    NSString *str = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundle];
    const char *fn = [str UTF8String];
    int fd = open(fn,O_RDONLY);
    
    int size = 0;
    void* zip = NULL;
    
    if (fd == -1) {
        NSLog(@"faceunity: failed to open bundle");
        size = 0;
    }else
    {
        size = [self getFileSize:fd];
        zip = mmap(nil, size, PROT_READ, MAP_SHARED, fd, 0);
    }
    
    *psize = size;
    return zip;
}

- (int)getFileSize:(int)fd
{
    struct stat sb;
    sb.st_size = 0;
    fstat(fd, &sb);
    return (int)sb.st_size;
}

#pragma -Faceunity Set EAGLContext
static EAGLContext *mcontext;
- (void)setUpContext
{
    if(!mcontext){
        mcontext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    if(!mcontext || ![EAGLContext setCurrentContext:mcontext]){
        NSLog(@"faceunity: failed to create / set a GLES2 context");
    }
    
}

// 人脸识别
- (CVPixelBufferRef)detectorFace:(CVPixelBufferRef)pixelBuffer {
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return pixelBuffer;
    }
    
//#warning 此步骤不可放在异步线程中执行
    [self setUpContext];
    
//    int curTrack = fuIsTracking();
//    WYLog(@"====================================/n================%d",curTrack);
    
    _items[1] = 0;
    
    //加载爱心道具
    if (_items[2] == 0) {
        [self loadHeart];
    }
    
    [[FURenderer shareRenderer] renderPixelBuffer:pixelBuffer withFrameId:_frameID items:_items itemCount:3 flipx:YES];//flipx 参数设为YES可以使道具做水平方向的镜像翻转
    _frameID += 1;
    
    return pixelBuffer;
}

#pragma -Faceunity Load Data
- (void)cleanItem{
    fuDestroyItem(_items[0]);
    _items[0] = 0;
}

- (void)loadItem
{
    
    [self setUpContext];
    
    int size = 0;
    
    NSString *bundle = [self currentGiftBundle];
    if (bundle.length == 0) {
        [self cleanItem];
        return;
    }
    // 先创建再释放可以有效缓解切换道具卡顿问题
    void *data = [self mmap_bundle:bundle psize:&size];
    
    int itemHandle = fuCreateItemFromPackage(data, size);
    
    if (_items[0] != 0) {
        NSLog(@"faceunity: destroy item");
        fuDestroyItem(_items[0]);
    }
    
    _items[0] = itemHandle;
    
    NSLog(@"faceunity: load item");
}

- (void)loadHeart
{
    [self setUpContext];
    
    int size = 0;
    
    void *data = [self mmap_bundle:@"heart_v2.bundle" psize:&size];
    
    _items[2] = fuCreateItemFromPackage(data, size);
}


- (NSString *)currentGiftBundle{
    NSString *bundle = @"";
    if (!_currentFaceModel || _currentFaceModel.giftId.length == 0) {
        return bundle;
    }
    if ([_currentFaceModel.giftId isEqualToString:@"1"]) {
        bundle = [@"Cat" stringByAppendingString:@".bundle"];
    }else if ([_currentFaceModel.giftId isEqualToString:@"2"]) {
        bundle = [@"ColorCrown" stringByAppendingString:@".bundle"];
    }else if ([_currentFaceModel.giftId isEqualToString:@"3"]) {
        bundle = [@"Deer" stringByAppendingString:@".bundle"];
    }else if ([_currentFaceModel.giftId isEqualToString:@"4"]) {
        bundle = [@"HappyRabbi" stringByAppendingString:@".bundle"];
    }else if ([_currentFaceModel.giftId isEqualToString:@"5"]) {
        bundle = [@"hartshorn" stringByAppendingString:@".bundle"];
    }else if ([_currentFaceModel.giftId isEqualToString:@"6"]) {
        bundle = [@"YellowEar" stringByAppendingString:@".bundle"];
    }else if ([_currentFaceModel.giftId isEqualToString:@"7"]) {
        bundle = [@"Mood" stringByAppendingString:@".bundle"];
    }else if ([_currentFaceModel.giftId isEqualToString:@"8"]) {
        bundle = [@"PrincessCrown" stringByAppendingString:@".bundle"];
    }
    return bundle;
}

- (void)addGiftModel:(YTGiftAttachment *)giftModel{
    
    WYFaceModel *faceModel = [[WYFaceModel alloc] init];
    faceModel.giftId = giftModel.giftID;
    faceModel.senderId = giftModel.senderID;
    
    if (!_faceGiftList) {
        _faceGiftList = [[NSMutableArray alloc] init];
    }
    [_faceGiftList addObject:faceModel];
    
}

- (void)stopTimer{
    if(_timeTimer){
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    [_faceGiftList removeAllObjects];
}

- (void)startTimer{
    
    if (!_timeTimer) {
        _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(waitTimerInterval:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timeTimer forMode:NSRunLoopCommonModes];
        _waitTimeSecond = 0;
        [self waitTimerInterval:_timeTimer];
    }
}

- (void)waitTimerInterval:(NSTimer *)aTimer{
    WYLog(@"a Timer with WYFaceRendererManager waitTimerInterval = %d",_waitTimeSecond);
    if (_waitTimeSecond <= 0){
        _waitTimeSecond = 0;
        
        //先remove掉上一个FaceModel
        for (WYFaceModel *faceModel in _faceGiftList) {
            if ([faceModel.senderId isEqualToString:_currentFaceModel.senderId] && [faceModel.giftId isEqualToString:_currentFaceModel.giftId]) {
                [_faceGiftList removeObject:faceModel];
                break;
            }
        }
        //再去取下一个展示
        if (_faceGiftList.count > 0) {
            _currentFaceModel = [_faceGiftList objectAtIndex:0];
            _waitTimeSecond = gift_duration;
        }else{
            _currentFaceModel = nil;
        }
        
        [self loadItem];
        return;
    }
    _waitTimeSecond--;
    
//    [self loadItem];
}

@end
