

#import <Foundation/Foundation.h>

#import "BleComm.h"

@protocol MPayBleLibDelegate <NSObject>

@required
- (void)onMPayBleResponse_Error:(int)iErrorCode Message:(NSString*)sMessage;
- (void)onMPayBleResponse_UpdateState:(int)iStateCode Message:(NSString*)sMessage;
@optional

- (void)onMPayBleResponse_GetDevice:(BOOL)bSucceed peripheral:(CBPeripheral *)peripheral;
- (void)onMPayBleResponse_IsConnected:(BOOL)bSucceed;
- (void)onMPayBleResponse_GetVersionString:(BOOL)bSucceed sMessage:(NSString*)sMessage;
- (void)onMPayBleResponse_GiveUpAction:(BOOL)bSucceed;
- (void)onMPayBleResponse_GetBattery:(BOOL)bSucceed battery:(NSString*)sBattery;
- (void)onMPayBleResponse_SetSleepTimer:(BOOL)bSucceed;
- (void)onMPayBleResponse_GetTerminalSn:(BOOL)bSucceed sMessage:(NSString*)sMessage;
- (void)onMPayBleResponse_SetTerminalSn:(BOOL)bSucceed;

#pragma mark - Debug Delegate
- (void)onMPayBleResponse_IccSelect:(BOOL)bSucceed;
- (void)onMPayBleResponse_IccStatus:(BOOL)bSucceed isInserted:(BOOL)isInserted;
- (void)onMPayBleResponse_IccPowerOn:(BOOL)bSucceed Atr:(NSString*)sAtr;
- (void)onMPayBleResponse_IccAccess:(BOOL)bSucceed Rapdu:(NSString*)sRapdu;
- (void)onMPayBleResponse_IccPowerOff:(BOOL)bSucceed;
- (void)onMPayBleResponse_MagCardRead:(BOOL)bSucceed
                           Track1Data:(NSString*)sTrack1Data
                           Track2Data:(NSString*)sTrack2Data
                           Track3Data:(NSString*)sTrack3Data;

#pragma mark - PICC Delegate
- (void)onMPayBleResponse_PiccActivation:(BOOL)bSucceed SerialNumber:(NSString*)sSerialNumber;
- (void)onMPayBleResponse_PiccRate:(BOOL)bSucceed Ats:(NSString*)sAts;
- (void)onMPayBleResponse_PiccAccess:(BOOL)bSucceed Rapdu:(NSString*)sRapdu;
- (void)onMPayBleResponse_IccGetCardholder:(BOOL)bSucceed CardNumber:(NSString*)sCardNumber CardHolderName:(NSString*)sCardHolderName Date:(NSString*)sDate;
- (void)onMPayBleResponse_PiccDeactivation:(BOOL)bSucceed;

- (void)onMPayBleResponse_MifareAuth:(BOOL)bSucceed;
- (void)onMPayBleResponse_MifareReadBlock:(BOOL)bSucceed sData:(NSString*)sData;
- (void)onMPayBleResponse_MifareWriteBlock:(BOOL)bSucceed;
- (void)onMPayBleResponse_MifareIncrement:(BOOL)bSucceed;
- (void)onMPayBleResponse_MifareDecrement:(BOOL)bSucceed;


@end

@interface MPayBleLib : NSObject <BleCommDelegate>
{}

@property (nonatomic, retain) id<MPayBleLibDelegate> delegate;

@property (nonatomic, strong) CBPeripheral *savePeripheral; //save the last connection peripheral


#pragma mark SrLib

// Propose: get SDK version string
//
// Parameters:
//
// Return:
//      sdk version string
//
- (NSString*)mPayBle_GetSdkVersion;

// Propose: searching ble device
//
// Parameters:
//
// Return:
//      true "Success", false "Error"
// Note:
//      delegate: onMPayBleResponse_GetDevice
//
- (BOOL)mPayBle_SearchDevice;

// Propose: stop search ble device
//
// Parameters:
//
// Return:
//      true "Success", false "Error"
// Note:
//
- (BOOL)mPayBle_StopSearching;

// Propose: connected the device
//
// Parameters:
//
// Return:
//      true "Success", false "Error"
// Note:
//      delegate: onMPayBleResponse_isConnected
//
- (BOOL)mPayBle_ConnectDevice:(CBPeripheral*) peripheral;

// Propose: retrieve ble device
//
// Parameters:
//              uuid: Device's uuid
//
// Return:
//      true "Success", false "Error"
// Note:
//
- (BOOL)mPayBle_RetrieveDevice:(NSString*) uuid;

// Propose: disconnect ble device
//
// Parameters:
//
// Return:
//      true "Success", false "Error"
// Note:
//
- (BOOL)mPayBle_DisconnectDevice;

// Propose: release ble devic
//
// Parameters:
//
// Return:
//      
// Note:
//
- (void)mPayBle_Release;

// Propose: get reader version string
//
// Parameters:
//
// Return:
//      true "Success", false "Error"
// Note:
//      delegate: onMPayAudioResponse_GetVersionString
//
- (BOOL)mPayBle_GetReaderVersion;

// Propose: give up transaction
//
// Parameters:
//
// Return:
//      true "Success", false "Error"
// Note:
//      delegate: onMPayAudioResponse_GiveUpAction
//
- (BOOL)mPayBle_GiveUpAction;

// Detect battery energy
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response(1byte): battery energy, 0~3(full).
//
- (BOOL)mPayBle_GetBattery;

// Set Sleep Mode Timmer
//
// input
//      sTimer(1byte): into Sleep Timmer, 0~255.
// output
//      status: "Success" OR "Fail"
//
- (BOOL)mPayBle_SetSleepTimer:(NSString*)sTimer;

// Get Terminal Serial Number
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//
- (BOOL)mPayBle_GetTerminalSn;

// Set Terminal Serial Number
//
// input
//      sSn(16byte): serial number.
// output
//      status: "Success" OR "Fail"
//
- (BOOL)mPayBle_SetTerminalSn:(NSString*)sSn;

// Ready to read magnetic Card
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response: Card Unique Serial Number
//
- (BOOL)mPayBle_MagSwipe;

// Select ICC slot
//
// input
//      slot: 0:ICC 1:SAM
// output
//      status: "Success" OR "Fail"
//      response:
- (BOOL)mPayBle_IccSelect:(int)slot;

// Detect ICC Inserte or Not
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response:
- (BOOL)mPayBle_IccDetect;

// Smart Card Power On
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response: answer to reset
//
- (BOOL)mPayBle_IccPowerOn;

// Smart Card Power Off
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//
- (BOOL)mPayBle_IccPowerOff;

// Access Smart Card
//
// input
//      sData: C-APDU
// output
//      status: "Success" OR "Fail"
//      response: R-APDU
//
- (BOOL)mPayBle_IccAccess:(NSString*)sAPDU; // sData = A0 B1 C2 D3 ... (MAX:300 Byte)

//
//******************** RF Card Command ********************
//

// Initialization RF Equipment
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response: Card Unique Serial Number
//
- (BOOL)mPayBle_RfActivateCard;

// Deinitialization RF Equipment
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//
- (BOOL)mPayBle_RfDeactivateCard;

// Rate RF Card
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response: Answer to Select
//
- (BOOL)mPayBle_RfRateCard;

// Access RF Card
//
// input
//      sData: C-APDU
// output
//      status: "Success" OR "Fail"
//      response: R-APDU
//
- (BOOL)mPayBle_RfAccessCard:(NSString*)sData; // sData = A0 B1 C2 D3 ... (MAX:300 Byte)

// Get Cardholder Information
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response: Cardholder Information, include card name/number/exp.
//
- (BOOL)mPayBle_IccGetCardHolder;

// Authentication RF Card
//
// input:
//      sType(1byte):   Mifare Key Type 'A' OR 'B'
//      sBlock(1byte):  Mifare Card Block Number
//      sKey(6byte):    Mifare Key
// output:
//      Fail OR Success
//
- (BOOL)mPayBle_RfMifareAuthCard:(NSString*)sType sData:(NSString*)sBlock sData:(NSString*)sKey;


// Read RF Card
//
// input
//      sBlock(1byte): Mifare Card Block Number
// output
//      status: "Success" OR "Fail"
//      response(16byte): Block data
//
- (BOOL)mPayBle_RfMifareReadBlock:(NSString*)sBlock; // sData = 00 ~ 3F

// Write RF Card
//
// input
//      sBlock(1byte): Mifare Card Block Number
//      sData(16byte): Mifare Card Write data
// output
//      status: "Success" OR "Fail"
//
- (BOOL)mPayBle_RfMifareWriteBlock:(NSString*)sBlock sData:(NSString*)sData; // sData = 00 ~ 3F + 16 Byte Data

// Increment Value To RF Card
//
// input
//      sBlock(1byte): Mifare Card Block Number
//  output
//      status: "Success" OR "Fail"
//      response: Value in Card
//
- (BOOL)mPayBle_RfMifareIncrement:(NSString*)sBlock sData:(NSString*)sData; // sData = 4 Byte Data

// Decrement Value To RF Card
//
//  input
//      sBlock(1byte):
//      sData(4byte):
//  output
//      status: "Success" OR "Fail"
- (BOOL)mPayBle_RfMifareDecrement:(NSString*)sBlock sData:(NSString*)sData; // sData = 4 Byte Data


@end
