//
//  XTMF1CBPeripheral.m
//  SuntrontBlueTooth
//
//  Created by apple on 2017/7/27.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "XTMF1CBPeripheral.h"

NSString *const XTMF1CBPeripheralConnectStateChangeKey = @"XTMF1CBPeripheralConnectStateChangeKey";

@implementation XTMF1CBPeripheral

- (void)setConnectState:(XTMF1CBPeripheralConnectState)connectState {
    _connectState = connectState;
    [[NSNotificationCenter defaultCenter] postNotificationName:XTMF1CBPeripheralConnectStateChangeKey object:self];
}

@end
