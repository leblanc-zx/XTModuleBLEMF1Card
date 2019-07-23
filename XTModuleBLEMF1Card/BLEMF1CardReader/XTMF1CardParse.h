//
//  XTMF1CardParse.h
//  XTBLEMF1Demo
//
//  Created by apple on 2019/6/4.
//  Copyright © 2019 新天科技股份有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTMF1CardInfo.h"
#import "XTMF1WriteInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTMF1CardParse : NSObject

/**
 解析MF1读卡数据
 
 @param data 帧数据
 @param cardType 卡类型(8:计金额5阶6价、3:计量)
 @param operType 上次业务类型(1开户,2充值,3补卡,4销户,5换表,6红冲,7更正,9重写卡,10挂失,11解挂,12退费,13免费开户,14免费充值,15免费开户,16写应急卡)
 @param error 错误
 @return MF1卡信息
 */
+ (XTMF1CardInfo *)parseMF1Read:(NSData *)data cardType:(int)cardType operType:(int)operType error:(NSError **)error ;


/**
 获取写卡帧数据
 
 @param cardInfoData 读取的原始帧数据
 @param cardType 卡类型(8:计金额5阶6价、3:计量)
 @param writeInfo 写卡信息
 @param error 错误
 @return 写卡帧数据
 */
+ (NSData *)writeMF1CardWithCardInfoData:(NSData *)cardInfoData cardType:(int)cardType writeInfo:(XTMF1WriteInfo *)writeInfo error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
