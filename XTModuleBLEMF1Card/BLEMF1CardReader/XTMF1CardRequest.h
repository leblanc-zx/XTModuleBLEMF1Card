//
//  XTMF1CardRequest.h
//  XTBLEMF1Demo
//
//  Created by apple on 2019/6/4.
//  Copyright © 2019 新天科技股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTMF1CardInfo.h"
#import "XTMF1WriteInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTMF1CardRequest : NSObject

+ (id)sharedManager;


/**
 读取蓝牙读卡器电压

 @param success 成功
 @param failure 失败
 */
- (void)readVoltageSuccess:(void(^)(CGFloat volgateValue))success failure:(void(^)(NSError *error))failure;

/**
 上电
 
 @param type 1读卡 2写卡 3其它
 @param success 成功
 @param failure 失败
 */
- (void)activateCardWithType:(int)type success:(void(^)(NSString *serialNumber))success failure:(void(^)(NSError *error))failure;

/**
 读取MF1卡信息
 
 @param cardType 卡类型(8:计金额5阶6价、3:计量)
 @param sector 扇区
 @param auth 秘钥
 @param operType 上次业务类型(1开户,2充值,3补卡,4销户,5换表,6红冲,7更正,9重写卡,10挂失,11解挂,12退费,13免费开户,14免费充值,15免费开户,16写应急卡)
 @param success 成功
 @param failure 失败
 */
- (void)readMF1CardWithCardType:(int)cardType sector:(int)sector auth:(NSString *)auth operType:(int)operType success:(void(^)(XTMF1CardInfo *cardInfo))success failure:(void(^)(NSError *error))failure;

/**
 写MF1卡
 
 @param cardInfoData 读到的原始帧数据
 @param cardType 卡类型(8:计金额5阶6价、3:计量)
 @param sector 扇区
 @param auth 秘钥
 @param writeInfo 写卡信息
 @param success 成功
 @param failure 失败
 */
- (void)writeMF1CardWithCardInfoData:(NSData *)cardInfoData cardType:(int)cardType sector:(int)sector auth:(NSString *)auth writeInfo:(XTMF1WriteInfo *)writeInfo success:(void (^)(XTMF1CardInfo *cardInfo))success failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
