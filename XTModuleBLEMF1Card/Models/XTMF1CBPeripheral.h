//
//  XTMF1CBPeripheral.h
//  SuntrontBlueTooth
//
//  Created by apple on 2017/7/27.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString *const XTMF1CBPeripheralConnectStateChangeKey;

typedef NS_ENUM(NSUInteger, XTMF1CBPeripheralConnectState) {
    XTMF1CBPeripheralNotConnected = 0,         //未连接
    XTMF1CBPeripheralConnecting = 1,           //连接中
    XTMF1CBPeripheralConnectingCanceled = 2,   //连接中被取消
    XTMF1CBPeripheralConnectFailed = 3,        //连接失败
    XTMF1CBPeripheralConnectTimeOut = 4,       //连接超时
    XTMF1CBPeripheralConnectSuccess = 5,       //连接成功
    XTMF1CBPeripheralDidDisconnect = 6,        //连接成功后断开连接
};

@interface XTMF1CBPeripheral : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, assign) XTMF1CBPeripheralConnectState connectState;
@property (nonatomic, strong) NSDictionary *advertisementData;
@property (nonatomic, strong) NSNumber *RSSI;

@end
