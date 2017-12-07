//
//  WYStyleSheet.m
//  WYTelevision
//
//  Created by zurich on 16/8/23.
//  Copyright © 2016年 Zurich. All rights reserved.
//

#import "WYStyleSheet.h"

@implementation NIEStyleSheetDummyObject

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.firstHelper respondsToSelector:aSelector]) {
        return self.firstHelper;
    } else if ([self.secondHelper respondsToSelector:aSelector]) {
        return self.secondHelper;
    } else {
        return [super forwardingTargetForSelector:aSelector];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.firstHelper respondsToSelector:aSelector] || [self.secondHelper respondsToSelector:aSelector] || [super respondsToSelector:aSelector];
}

@end

@implementation WYStyleSheet

+ (instancetype)defaultStyleSheet {
    static dispatch_once_t DispatchOnce;
    static NSMutableDictionary *StyleSheets;
    dispatch_once(&DispatchOnce, ^{
        StyleSheets = [NSMutableDictionary dictionary];
    });
    @synchronized(self) {
        if (![StyleSheets objectForKey:self]) {
            NIEStyleSheetDummyObject *dummy = [[NIEStyleSheetDummyObject alloc] init];
            if ([[self superclass] respondsToSelector:@selector(defaultStyleSheet)]) {
                dummy.firstHelper = [[self superclass] defaultStyleSheet];
            } else {
                dummy.firstHelper = nil;
            }
            dummy.secondHelper = [[self alloc] init];
            [StyleSheets setObject:dummy forKey:(id<NSCopying>)self];
        }
    }
    return StyleSheets[self];
}

+ (instancetype)currentStyleSheet {
    return [self defaultStyleSheet];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tabBarTextColor = [UIColor colorWithHexString:@"CECFD2"];
        self.tabBarSelectedTextColor = [UIColor colorWithHexString:@"FF3366"];
        self.tabBarBackgroundColor = [UIColor colorWithHexString:@"1C232D"];
        
        self.themeColor = [UIColor colorWithHexString:@"FFB82F"];
        self.themeBackgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
        
        self.navTitleFont = [UIFont fontWithName:@"Helvetica" size:15.f];
        self.navTextColor = [UIColor colorWithHexString:@"FFFFFF"];
        
        self.pageControlNormalColor = [UIColor colorWithHexString:@"B3B3B3"];
        
        self.currentPageColor = [UIColor colorWithHexString:@"FF3366"];
        
        self.subheadLabelColor = [UIColor colorWithHexString:@"8E8E9A"];
        self.subheadLabelFont = [UIFont systemFontOfSize:13];
        
        self.titleLabelColor = [UIColor colorWithHexString:@"D0D1D2"];
        self.titleLabelSelectedColor = [UIColor colorWithHexString:@"FF3366"];
        self.subtitleLabelColor = [UIColor colorWithHexString:@"465667"];
        
        self.normalButtonColor = [UIColor colorWithHexString:@"FF3366"];
        self.selectedButtonColor = [UIColor colorWithHexString:@"445162"];
        self.successLabelColor = [UIColor colorWithHexString:@"26d58d"];

    }
    return self;
}


@end
