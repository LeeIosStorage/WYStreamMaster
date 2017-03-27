//
//  WYStreamingConfig.m
//  WYStreamMaster
//
//  Created by Leejun on 2017/3/16.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYStreamingConfig.h"
#import "sys/sysctl.h"

typedef NS_ENUM(NSInteger, DeviceType) {
    iphone4 = 0 ,
    iphone5,
    iphone6,
    iphone6p,
};

@interface WYStreamingConfig ()

@property (strong, nonatomic) NSArray  *phone4Resolution;
@property (strong, nonatomic) NSArray  *phone5Resolution;
@property (strong, nonatomic) NSArray  *phone6Resolution;
@property (strong, nonatomic) NSArray  *phone6PResolution;

@property (strong, nonatomic) NSMutableArray *allDeviceResolution;

@property (assign, nonatomic) DeviceType deviceType;

@end

@implementation WYStreamingConfig

+ (instancetype)sharedConfig
{
    static WYStreamingConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[self alloc] init];
    });
    return config;
}

- (id )init
{
    self = [super init];
    if (self) {
        self.phone4Resolution = @[@{@"width":@320,@"height":@480},
                                  @{@"width":@640,@"height":@960},
                                  @{@"width":@640,@"height":@960}];
        
        self.phone5Resolution = @[@{@"width":@320,@"height":@568},
                                  @{@"width":@640,@"height":@1136},
                                  @{@"width":@640,@"height":@1136}];
        
        self.phone6Resolution = @[@{@"width":@374,@"height":@666},
                                  @{@"width":@640,@"height":@1138},
                                  @{@"width":@720,@"height":@1280}];
        
        self.phone6PResolution = @[@{@"width":@414,@"height":@736},
                                   @{@"width":@640,@"height":@1138},
                                   @{@"width":@720,@"height":@1280}];
        
        self.allDeviceResolution = [NSMutableArray array];
        [self.allDeviceResolution addObjectsFromArray:@[self.phone4Resolution,
                                                        self.phone5Resolution,
                                                        self.phone6Resolution,
                                                        self.phone6PResolution]];
        
        self.deviceType = [self devicePlatform];
    }
    
    return self;
}

- (CGSize )getResolutionWithQuality
{
    CGSize size = CGSizeZero;
    NSArray *currentDeviceResolutionArray = self.allDeviceResolution[self.deviceType];
    NSDictionary *resolutionDic = currentDeviceResolutionArray[self.videoQuality];
    NSNumber *widthNum = resolutionDic[@"width"];
    NSNumber *heightNum = resolutionDic[@"height"];
    
    size = CGSizeMake([widthNum integerValue], [heightNum integerValue]);
    
    return size;
}

- (DeviceType )devicePlatform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone3,1"])    return iphone4;
    if ([platform isEqualToString:@"iPhone3,3"])    return iphone4;
    if ([platform isEqualToString:@"iPhone4,1"])    return iphone4;
    if ([platform isEqualToString:@"iPhone5,1"])    return iphone5;
    if ([platform isEqualToString:@"iPhone5,2"])    return iphone5;
    if ([platform isEqualToString:@"iPhone5,3"])    return iphone5;
    if ([platform isEqualToString:@"iPhone5,4"])    return iphone5;
    if ([platform isEqualToString:@"iPhone6,1"])    return iphone5;
    if ([platform isEqualToString:@"iPhone6,2"])    return iphone5;
    
    return iphone6;
}

#pragma mark
#pragma mark - Getters and Setters

- (VideoQuality)videoQuality
{
    return [WYLoginUserManager videoQuality];
}

- (void)setVideoQuality:(VideoQuality)videoQuality
{
    if ([WYLoginUserManager videoQuality] != videoQuality) {
        [WYLoginUserManager setVideoQuality:videoQuality];
    }
}

@end
