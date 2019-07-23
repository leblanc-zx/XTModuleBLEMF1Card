//
//  XTMF1CardParse.m
//  XTBLEMF1Demo
//
//  Created by apple on 2019/6/4.
//  Copyright © 2019 新天科技股份有限公司. All rights reserved.
//

#import "XTMF1CardParse.h"
#import "XTUtils.h"
#import "XTUtils+Date.h"

@interface NSData (replace)

- (NSData *)dataByReplacingCharactersInRange:(NSRange)range withData:(NSData *)data;

@end

@implementation NSData (replace)

- (NSData *)dataByReplacingCharactersInRange:(NSRange)range withData:(NSData *)data {
    NSString *hexStr = [XTUtils hexStringWithData:self];
    NSRange newRange = NSMakeRange(range.location * 2, range.length * 2);
    NSString *newStr = [hexStr stringByReplacingCharactersInRange:newRange withString:[XTUtils hexStringWithData:data]];
    return [XTUtils dataWithHexString:newStr];
}

@end

@implementation XTMF1CardParse

/**
 解析MF1读卡数据

 @param data 帧数据
 @param cardType 卡类型(8:计金额5阶6价、3:计量)
 @param operType 上次业务类型(1开户,2充值,3补卡,4销户,5换表,6红冲,7更正,9重写卡,10挂失,11解挂,12退费,13免费开户,14免费充值,15免费开户,16写应急卡)
 @param error 错误
 @return MF1卡信息
 */
+ (XTMF1CardInfo *)parseMF1Read:(NSData *)data cardType:(int)cardType operType:(int)operType error:(NSError **)error {
    
    if (cardType == 3) {
        //计量
        //1.长度判断
        if (data.length < 16) {
            *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"帧长度错误"}];
            return nil;
        }
        //2.进行校验和校验 0~14个字节累加、取反加1
        NSData *checkData = [XTUtils checkNegationGalOneSumDataWithOriginData:[data subdataWithRange:NSMakeRange(0, 15)]];
        if (![checkData isEqualToData:[data subdataWithRange:NSMakeRange(15, 1)]]) {
            *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"校验和校验失败"}];
            return nil;
        }
        //3.判断是否为用户卡
        NSString *userCardType = [XTUtils hexStringWithData:[data subdataWithRange:NSMakeRange(0, 1)]];
        if (![[userCardType uppercaseString] isEqualToString:@"DA"]) {
            *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"卡类型错误,非用户卡"}];
            return nil;
        }
        
        //5.开始解析
        XTMF1CardInfo *cardInfo = [[XTMF1CardInfo alloc] init];
        cardInfo.originCardData = data;
        //卡类型
        cardInfo.cardType = cardType;
        //卡标志
        cardInfo.cardFlag = [XTUtils hexStringWithData:[data subdataWithRange:NSMakeRange(0, 1)]];
        //系统号
        cardInfo.systemNumber = [XTUtils hexStringWithData:[data subdataWithRange:NSMakeRange(1, 1)]];
        //卡号
        cardInfo.cardNumber = [NSString stringWithFormat:@"%ld", [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(2, 3)]]]];
        //总量
        cardInfo.totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(5, 3)]]];
        //本次量
        cardInfo.thisRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(8, 3)]]];
        //剩余量
        cardInfo.remainedCount = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(11, 3)]]];
        //报警值
        cardInfo.warnCount = [XTUtils longWithData:[data subdataWithRange:NSMakeRange(14, 1)]];
        //是否已刷表
        if (cardInfo.thisRead == 0) {
            cardInfo.isBrushed = YES;
        } else {
            cardInfo.isBrushed = NO;
        }
        
        return cardInfo;
        
    } else if (cardType == 8) {
        //计金额5阶6价
        //da5a1100 00881300 dc0500dc 05004915 14002800 3c005000 64000000 180319a0 01000200 03000300 03000300 000213dc 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
        //1.长度判断
        if (data.length < 96) {
            *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"帧长度错误"}];
            return nil;
        }
        //2.1进行校验和校验 0~15个字节累加、取反加1
        NSData *checkData0 = [XTUtils checkNegationGalOneSumDataWithOriginData:[data subdataWithRange:NSMakeRange(0, 15)]];
        if (![checkData0 isEqualToData:[data subdataWithRange:NSMakeRange(15, 1)]]) {
            *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"块0校验和校验失败"}];
            return nil;
        }
        //2.2进行校验和校验 16~31个字节累加、取反加1
        NSData *checkData1 = [XTUtils checkNegationGalOneSumDataWithOriginData:[data subdataWithRange:NSMakeRange(16, 15)]];
        if (![checkData1 isEqualToData:[data subdataWithRange:NSMakeRange(31, 1)]]) {
            *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"块1校验和校验失败"}];
            return nil;
        }
        //2.3进行校验和校验 32~47个字节累加、取反加1
        NSData *checkData2 = [XTUtils checkNegationGalOneSumDataWithOriginData:[data subdataWithRange:NSMakeRange(32, 15)]];
        if (![checkData2 isEqualToData:[data subdataWithRange:NSMakeRange(47, 1)]]) {
            *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"块2校验和校验失败"}];
            return nil;
        }
        //2.4进行校验和校验 48~63个字节累加、取反加1
        NSData *checkData3 = [XTUtils checkNegationGalOneSumDataWithOriginData:[data subdataWithRange:NSMakeRange(48, 15)]];
        if (![checkData3 isEqualToData:[data subdataWithRange:NSMakeRange(63, 1)]]) {
            *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"N+1扇区块0校验和校验失败"}];
            return nil;
        }
        //2.5进行校验和校验 64~79个字节累加、取反加1
        NSData *checkData4 = [XTUtils checkNegationGalOneSumDataWithOriginData:[data subdataWithRange:NSMakeRange(64, 15)]];
        if (![checkData4 isEqualToData:[data subdataWithRange:NSMakeRange(79, 1)]]) {
            *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"N+1扇区块1校验和校验失败"}];
            return nil;
        }
        //2.6进行校验和校验 80~95个字节累加、取反加1
        NSData *checkData5 = [XTUtils checkNegationGalOneSumDataWithOriginData:[data subdataWithRange:NSMakeRange(80, 15)]];
        if (![checkData5 isEqualToData:[data subdataWithRange:NSMakeRange(95, 1)]]) {
            *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"N+1扇区块2校验和校验失败"}];
            return nil;
        }
        //3.判断是否为用户卡
        NSString *userCardType = [XTUtils hexStringWithData:[data subdataWithRange:NSMakeRange(0, 1)]];
        if (![[userCardType uppercaseString] isEqualToString:@"DA"]) {
            *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"卡类型错误,非用户卡"}];
            return nil;
        }
        
        //5.开始解析
        XTMF1CardInfo *cardInfo = [[XTMF1CardInfo alloc] init];
        cardInfo.originCardData = data;
        //卡类型
        cardInfo.cardType = cardType;
        //卡标志
        cardInfo.cardFlag = [XTUtils hexStringWithData:[data subdataWithRange:NSMakeRange(0, 1)]];
        //系统号
        cardInfo.systemNumber = [XTUtils hexStringWithData:[data subdataWithRange:NSMakeRange(1, 1)]];
        //卡号
        cardInfo.cardNumber = [NSString stringWithFormat:@"%ld", [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(2, 3)]]]];
        //总金额
        cardInfo.totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(5, 3)]]];
        //本次金额
        cardInfo.thisRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(8, 3)]]];
        //报警金额
        cardInfo.warnMoney = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(11, 2)]]];
        //透支金额
        cardInfo.overMoney = [XTUtils longWithData:[data subdataWithRange:NSMakeRange(13, 1)]];
        //分界点1
        cardInfo.devideCount1 = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(16, 2)]]];
        //分界点2
        cardInfo.devideCount2 = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(18, 2)]]];
        //分界点3
        cardInfo.devideCount3 = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(20, 2)]]];
        //分界点4
        cardInfo.devideCount4 = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(22, 2)]]];
        //分界点5
        cardInfo.devideCount5 = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(24, 2)]]];
        //单价1
        cardInfo.price1 = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(32, 2)]]];
        //单价2
        cardInfo.price2 = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(34, 2)]]];
        //单价3
        cardInfo.price3 = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(36, 2)]]];
        //单价4
        cardInfo.price4 = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(38, 2)]]];
        //单价5
        cardInfo.price5 = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(40, 2)]]];
        //单价6
        cardInfo.price6 = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(42, 2)]]];
        //剩余金额
        cardInfo.remainedMoney = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[data subdataWithRange:NSMakeRange(51, 3)]]];
        //刷表时间
        NSString *timeDataStr = [XTUtils hexStringWithData:[data subdataWithRange:NSMakeRange(64, 5)]];
        cardInfo.brushTime = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",[timeDataStr substringWithRange:NSMakeRange(0, 2)], [timeDataStr substringWithRange:NSMakeRange(2, 2)], [timeDataStr substringWithRange:NSMakeRange(4, 2)], [timeDataStr substringWithRange:NSMakeRange(6, 2)], [timeDataStr substringWithRange:NSMakeRange(8, 2)]];
        //是否已刷表
        if ([timeDataStr longLongValue] > 0) {
            cardInfo.isBrushed = YES;
        } else {
            //判断上笔业务是否为重写卡/补卡/换表
            if (operType == 9 || operType == 3 || operType == 5) {
                //重写卡、补卡、换表的情况下，不能以N+1扇区的刷表时间判断，根据N扇区的补卡标志来判断
                NSString *flag = [[XTUtils hexStringWithData:[data subdataWithRange:NSMakeRange(14, 1)]] uppercaseString];
                if ([flag isEqualToString:@"FB"]) {
                    cardInfo.isBrushed = NO;
                } else {
                    cardInfo.isBrushed = YES;
                }
            } else {
                cardInfo.isBrushed = NO;
            }
        }
        return cardInfo;
        
    } else {
        *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"不支持该卡类型"}];
        return nil;
    }
    
}

/**
 获取写卡帧数据
 
 @param cardInfoData 读取的原始帧数据
 @param cardType 卡类型(8:计金额5阶6价、3:计量)
 @param writeInfo 写卡信息
 @param error 错误
 @return 写卡帧数据
 */
+ (NSData *)writeMF1CardWithCardInfoData:(NSData *)cardInfoData cardType:(int)cardType writeInfo:(XTMF1WriteInfo *)writeInfo error:(NSError **)error {
    
    if (cardType == 3) {
        //计量
        
        NSData *resultData = [NSData dataWithData:cardInfoData];
        //替换块0 总量、本次、校验和
        //1.总量range
        NSRange totalRange = NSMakeRange(5, 3);
        //2.本次range
        NSRange thisRange = NSMakeRange(8, 3);
        //3.报警量range,管理系统未替换
        //NSRange warnRange = NSMakeRange(14, 1);
        //4.校验和range
        NSRange checkRange = NSMakeRange(15, 1);
        
        //总量 替换
        long oldTotal = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[cardInfoData subdataWithRange:totalRange]]];
        long newTotal = oldTotal + [writeInfo.rechargeCount longLongValue];
        NSData *newTotalData = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newTotal length:3]];
        resultData = [resultData dataByReplacingCharactersInRange:totalRange withData:newTotalData];
        //本次 替换
        long newThis = [writeInfo.rechargeCount longLongValue];
        NSData *newThisData = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newThis length:3]];
        resultData = [resultData dataByReplacingCharactersInRange:thisRange withData:newThisData];
        //校验和 替换
        NSData *newCheckSumData = [XTUtils checkNegationGalOneSumDataWithOriginData:[resultData subdataWithRange:NSMakeRange(0, 15)]];
        resultData = [resultData dataByReplacingCharactersInRange:checkRange withData:newCheckSumData];
        
        return resultData;
        
        
    } else if (cardType == 8) {
        //计金额5阶6价
        
        NSData *resultData = [NSData dataWithData:cardInfoData];
        //替换N扇区 总金额、本次、校验和等，以及N+1扇区所有重置为0
        //1.总量range
        NSRange totalRange = NSMakeRange(5, 3);
        //2.本次range
        NSRange thisRange = NSMakeRange(8, 3);
        //3.报警金额range
        NSRange warnRange = NSMakeRange(11, 2);
        //4.透支金额range,管理系统未替换
        //NSRange overRange = NSMakeRange(13, 1);
        //5.校验和1range
        NSRange check1Range = NSMakeRange(15, 1);
        //6.分界点
        NSRange divid1Range = NSMakeRange(16, 2);
        NSRange divid2Range = NSMakeRange(18, 2);
        NSRange divid3Range = NSMakeRange(20, 2);
        NSRange divid4Range = NSMakeRange(22, 2);
        NSRange divid5Range = NSMakeRange(24, 2);
        //7.调价日月年
        NSRange dateRange = NSMakeRange(28, 3);
        //8.校验和2range
        NSRange check2Range = NSMakeRange(31, 1);
        //9.单价
        NSRange price1Range = NSMakeRange(32, 2);
        NSRange price2Range = NSMakeRange(34, 2);
        NSRange price3Range = NSMakeRange(36, 2);
        NSRange price4Range = NSMakeRange(38, 2);
        NSRange price5Range = NSMakeRange(40, 2);
        NSRange price6Range = NSMakeRange(42, 2);
        //10.冻结月日
        NSRange freezeRange = NSMakeRange(45, 2);
        //11.校验和3range
        NSRange check3Range = NSMakeRange(47, 1);
        
        /*--块0--*/
        //总量 替换
        long oldTotal = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[cardInfoData subdataWithRange:totalRange]]];
        long newTotal = oldTotal + [writeInfo.rechargeMoney longLongValue];
        NSData *newTotalData = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newTotal length:3]];
        resultData = [resultData dataByReplacingCharactersInRange:totalRange withData:newTotalData];
        //本次 替换
        long newThis = [writeInfo.rechargeMoney longLongValue];
        NSData *newThisData = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newThis length:3]];
        resultData = [resultData dataByReplacingCharactersInRange:thisRange withData:newThisData];
        //报警金额替换
        long newWarn = [writeInfo.warn longLongValue];
        NSData *newWarnData = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newWarn length:2]];
        resultData = [resultData dataByReplacingCharactersInRange:warnRange withData:newWarnData];
        //透支金额不需要替换
        
        //校验和1 替换
        NSData *newCheck1SumData = [XTUtils checkNegationGalOneSumDataWithOriginData:[resultData subdataWithRange:NSMakeRange(0, 15)]];
        resultData = [resultData dataByReplacingCharactersInRange:check1Range withData:newCheck1SumData];
        
        /*--块1--*/
        //分界点
        long newDivid1 = [writeInfo.divid1 longLongValue] * 10;
        NSData *newDivid1Data = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newDivid1 length:2]];
        resultData = [resultData dataByReplacingCharactersInRange:divid1Range withData:newDivid1Data];
        
        long newDivid2 = [writeInfo.divid2 longLongValue] * 10;
        NSData *newDivid2Data = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newDivid2 length:2]];
        resultData = [resultData dataByReplacingCharactersInRange:divid2Range withData:newDivid2Data];
        
        long newDivid3 = [writeInfo.divid3 longLongValue] * 10;
        NSData *newDivid3Data = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newDivid3 length:2]];
        resultData = [resultData dataByReplacingCharactersInRange:divid3Range withData:newDivid3Data];
        
        long newDivid4 = [writeInfo.divid4 longLongValue] * 10;
        NSData *newDivid4Data = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newDivid4 length:2]];
        resultData = [resultData dataByReplacingCharactersInRange:divid4Range withData:newDivid4Data];
        
        long newDivid5 = [writeInfo.divid5 longLongValue] * 10;
        NSData *newDivid5Data = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newDivid5 length:2]];
        resultData = [resultData dataByReplacingCharactersInRange:divid5Range withData:newDivid5Data];
        
        //调价日月年 原2019-10-11T10:01:22 -> 111019
        NSString *newDate = [NSString stringWithFormat:@"%@%@%@", [writeInfo.exeDate substringWithRange:NSMakeRange(8, 2)], [writeInfo.exeDate substringWithRange:NSMakeRange(5, 2)], [writeInfo.exeDate substringWithRange:NSMakeRange(2, 2)]];
        NSData *newDateData = [XTUtils dataWithHexString:newDate];
        resultData = [resultData dataByReplacingCharactersInRange:dateRange withData:newDateData];
        
        //校验和2 替换
        NSData *newCheck2SumData = [XTUtils checkNegationGalOneSumDataWithOriginData:[resultData subdataWithRange:NSMakeRange(16, 15)]];
        resultData = [resultData dataByReplacingCharactersInRange:check2Range withData:newCheck2SumData];
        
        /*--块2--*/
        //单价
        long newPrice1 = [writeInfo.price1 longLongValue];
        NSData *newPrice1Data = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newPrice1 length:2]];
        resultData = [resultData dataByReplacingCharactersInRange:price1Range withData:newPrice1Data];
        
        long newPrice2 = [writeInfo.price2 longLongValue];
        NSData *newPrice2Data = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newPrice2 length:2]];
        resultData = [resultData dataByReplacingCharactersInRange:price2Range withData:newPrice2Data];
        
        long newPrice3 = [writeInfo.price3 longLongValue];
        NSData *newPrice3Data = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newPrice3 length:2]];
        resultData = [resultData dataByReplacingCharactersInRange:price3Range withData:newPrice3Data];
        
        long newPrice4 = [writeInfo.price4 longLongValue];
        NSData *newPrice4Data = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newPrice4 length:2]];
        resultData = [resultData dataByReplacingCharactersInRange:price4Range withData:newPrice4Data];
        
        long newPrice5 = [writeInfo.price5 longLongValue];
        NSData *newPrice5Data = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newPrice5 length:2]];
        resultData = [resultData dataByReplacingCharactersInRange:price5Range withData:newPrice5Data];
        
        long newPrice6 = [writeInfo.price6 longLongValue];
        NSData *newPrice6Data = [XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:newPrice6 length:2]];
        resultData = [resultData dataByReplacingCharactersInRange:price6Range withData:newPrice6Data];
        
        //冻结月日
        NSString *newFreeze = [NSString stringWithFormat:@"%@%@",writeInfo.freezeMonth, writeInfo.freezeDay];
        NSData *newFreezeData = [XTUtils dataWithHexString:newFreeze];
        resultData = [resultData dataByReplacingCharactersInRange:freezeRange withData:newFreezeData];
        
        //校验和3 替换
        NSData *newCheck3SumData = [XTUtils checkNegationGalOneSumDataWithOriginData:[resultData subdataWithRange:NSMakeRange(32, 15)]];
        resultData = [resultData dataByReplacingCharactersInRange:check3Range withData:newCheck3SumData];
        
        //N+1扇区全部置为0
        NSMutableString *zeroStr = [[NSMutableString alloc] init];
        for (int i = 0; i < 48; i ++) {
            [zeroStr appendString:@"00"];
        }
        NSData *zeroData = [XTUtils dataWithHexString:zeroStr];
        resultData = [resultData dataByReplacingCharactersInRange:NSMakeRange(48, 48) withData:zeroData];
        
        return resultData;
        
    } else {
        *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"不支持该卡类型"}];
        return nil;
    }
    
}

@end
