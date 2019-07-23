//
//  mPayLibComm.h
//
//  Created by Singular-RD on 2014/11/1.
//  Copyright (c) 2014年 singular. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BleCommDelegate <NSObject>

@optional

- (void)onBleComm_Error:(int)iErrorCode Message:(NSString*)sMessage;
- (void)onBleComm_UpdateState:(int)iStateCode State:(NSString*)sState;
- (void)onBleComm_GetDevice:(BOOL)bSucceed Peripheral:(CBPeripheral *)peripheral;
- (void)onBleComm_IsConnected:(BOOL)bSucceed;
- (void)onBleComm_DataComming:(BOOL)bSucceed Data:(NSString*)sData;

@end

@interface BleComm : NSObject <BleCommDelegate, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate>
{}

@property (nonatomic, retain) id<BleCommDelegate> delegate;

// 宣告 CBCentralManager，這物件用來管理在Central模式時，也提供 Bluetooth 狀態及一些功能
@property (nonatomic, strong) CBCentralManager *centralManager;

// 宣告 CBPeripheral，這物件用來管理連接的Peripheral裝置，也提供 Bluetooth 狀態及一些功能
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;

// 暫存連接裝置的 Characteristic 物件
@property (nonatomic, retain) CBCharacteristic *_readCharacteristic;
@property (nonatomic, retain) CBCharacteristic *_writeCharacteristic;
@property (nonatomic, retain) CBCharacteristic *_notifyCharacteristic;

- (void)bleComm_StartSearch;
- (void)bleComm_StopSearching;
- (void)bleComm_Connect:(CBPeripheral *)peripheral;
- (CBPeripheral *)bleComm_GetConnectedDevice;
- (BOOL)bleComm_Retrieve:(NSString*)uuid;
- (void)bleComm_Disconnect;
- (void)bleComm_SendCommand:(NSString*)sBasic sData:(NSString*)sData;

@end
