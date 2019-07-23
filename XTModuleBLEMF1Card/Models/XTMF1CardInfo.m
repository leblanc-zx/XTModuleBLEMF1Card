//
//  XTMF1CardInfo.m
//  XTBLEMF1Demo
//
//  Created by apple on 2019/6/4.
//  Copyright © 2019 新天科技股份有限公司. All rights reserved.
//

#import "XTMF1CardInfo.h"
#import <objc/runtime.h>

@implementation XTMF1CardInfo

@end

//计量卡信息
@implementation XTMF1CardInfo (Amount)
@dynamic remainedCount;
@dynamic warnCount;
@dynamic overCount;

- (void)setRemainedCount:(long)remainedCount {
    objc_setAssociatedObject(self, @selector(remainedCount), @(remainedCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)remainedCount {
    return [objc_getAssociatedObject(self, @selector(remainedCount)) longLongValue];
}

- (void)setWarnCount:(long)warnCount {
    objc_setAssociatedObject(self, @selector(warnCount), @(warnCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)warnCount {
    return [objc_getAssociatedObject(self, @selector(warnCount)) longLongValue];
}

- (void)setOverCount:(long)overCount {
    objc_setAssociatedObject(self, @selector(overCount), @(overCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)overCount {
    return [objc_getAssociatedObject(self, @selector(overCount)) longLongValue];
}

@end

//计金额卡信息
@implementation XTMF1CardInfo (Money)
@dynamic remainedMoney;
@dynamic warnMoney;
@dynamic overMoney;
@dynamic price1;
@dynamic price2;
@dynamic price3;
@dynamic price4;
@dynamic price5;
@dynamic price6;
@dynamic devideCount1;
@dynamic devideCount2;
@dynamic devideCount3;
@dynamic devideCount4;
@dynamic devideCount5;
@dynamic brushTime;


- (void)setRemainedMoney:(long)remainedMoney {
    objc_setAssociatedObject(self, @selector(remainedMoney), @(remainedMoney), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)remainedMoney {
    return [objc_getAssociatedObject(self, @selector(remainedMoney)) longLongValue];
}

- (void)setWarnMoney:(long)warnMoney {
    objc_setAssociatedObject(self, @selector(warnMoney), @(warnMoney), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)warnMoney {
    return [objc_getAssociatedObject(self, @selector(warnMoney)) longLongValue];
}

- (void)setOverMoney:(long)overMoney {
    objc_setAssociatedObject(self, @selector(overMoney), @(overMoney), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)overMoney {
    return [objc_getAssociatedObject(self, @selector(overMoney)) longLongValue];
}

- (void)setPrice1:(long)price1 {
    objc_setAssociatedObject(self, @selector(price1), @(price1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)price1 {
    return [objc_getAssociatedObject(self, @selector(price1)) longLongValue];
}

- (void)setPrice2:(long)price2 {
    objc_setAssociatedObject(self, @selector(price2), @(price2), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)price2 {
    return [objc_getAssociatedObject(self, @selector(price2)) longLongValue];
}

- (void)setPrice3:(long)price3 {
    objc_setAssociatedObject(self, @selector(price3), @(price3), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)price3 {
    return [objc_getAssociatedObject(self, @selector(price3)) longLongValue];
}

- (void)setPrice4:(long)price4 {
    objc_setAssociatedObject(self, @selector(price4), @(price4), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)price4 {
    return [objc_getAssociatedObject(self, @selector(price4)) longLongValue];
}

- (void)setPrice5:(long)price5 {
    objc_setAssociatedObject(self, @selector(price5), @(price5), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)price5 {
    return [objc_getAssociatedObject(self, @selector(price5)) longLongValue];
}

- (void)setPrice6:(long)price6 {
    objc_setAssociatedObject(self, @selector(price6), @(price6), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)price6 {
    return [objc_getAssociatedObject(self, @selector(price6)) longLongValue];
}

- (void)setDevideCount1:(long)devideCount1 {
    objc_setAssociatedObject(self, @selector(devideCount1), @(devideCount1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)devideCount1 {
    return [objc_getAssociatedObject(self, @selector(devideCount1)) longLongValue];
}

- (void)setDevideCount2:(long)devideCount2 {
    objc_setAssociatedObject(self, @selector(devideCount2), @(devideCount2), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)devideCount2 {
    return [objc_getAssociatedObject(self, @selector(devideCount2)) longLongValue];
}

- (void)setDevideCount3:(long)devideCount3 {
    objc_setAssociatedObject(self, @selector(devideCount3), @(devideCount3), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)devideCount3 {
    return [objc_getAssociatedObject(self, @selector(devideCount3)) longLongValue];
}

- (void)setDevideCount4:(long)devideCount4 {
    objc_setAssociatedObject(self, @selector(devideCount4), @(devideCount4), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)devideCount4 {
    return [objc_getAssociatedObject(self, @selector(devideCount4)) longLongValue];
}

- (void)setDevideCount5:(long)devideCount5 {
    objc_setAssociatedObject(self, @selector(devideCount5), @(devideCount5), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)devideCount5 {
    return [objc_getAssociatedObject(self, @selector(devideCount5)) longLongValue];
}

- (void)setBrushTime:(NSString *)brushTime {
    objc_setAssociatedObject(self, @selector(brushTime), brushTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)brushTime {
    return objc_getAssociatedObject(self, @selector(brushTime));
}

@end
