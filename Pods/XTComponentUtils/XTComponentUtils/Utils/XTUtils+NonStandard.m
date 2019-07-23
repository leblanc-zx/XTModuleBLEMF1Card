//
//  XTUtils+NonStandard.m
//  AFNetworking
//
//  Created by apple on 2019/4/28.
//

#import "XTUtils+NonStandard.h"

@implementation XTUtils (NonStandard)

/**
 将Long变成NSData(非标准)（length个字节）
 
 @param value 整数
 @param length 字节长度
 @return NSData
 */
+ (NSData *)dataNonStandardWithLong:(long)value length:(int)length {
    //取绝对值
    long aValue = value >= 0 ? value : -value;
    
    Byte *bot = malloc(length);
    for (int i = 0; i < length; i ++) {
        if (i == length - 1) {
            bot[i] = (Byte) (aValue & 0xff);
        } else {
            bot[i] = (Byte) ((aValue >> ((length-i-1)*8)) & 0xff);
        }
    }
    NSData *data = [NSData dataWithBytes:bot length:length];
    NSString *hexStr = [self hexStringWithData:data];
    NSString *bin = [self binaryStringWithHexString:hexStr];
    
    NSString *highest = value >= 0 ? @"0" : @"1";
    NSString *newBin = [bin stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:highest];
    NSString *newHexStr = [self hexStringWithBinaryString:newBin];
    return [self dataWithHexString:newHexStr];
}

/**
 将NSData转换成Long(非标准) <<可为负数>>
 
 @param data NSData
 @return <<可为负数>>long
 */
+ (long)longNonStandardWithData:(NSData *)data {
    
    NSString *hexStr = [self hexStringWithData:data];
    NSString *bin = [self binaryStringWithHexString:hexStr];
    
    NSString *highest = [bin substringWithRange:NSMakeRange(0, 1)];
    
    NSString *newBin = [bin stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"0"];
    NSString *newHexStr = [self hexStringWithBinaryString:newBin];
    NSData *newData = [self dataWithHexString:newHexStr];
    
    long total = 0;
    for (int i = 0; i < newData.length; i ++) {
        if (i == newData.length-1) {
            int a = (int)[self positiveLongWithData:[newData subdataWithRange:NSMakeRange(i, 1)]];
            total += a;
        } else {
            int a = (int)[self positiveLongWithData:[newData subdataWithRange:NSMakeRange(i, 1)]];
            total += a << ((newData.length-i-1)*8);
        }
    }
    return [highest isEqualToString:@"1"] ? -total : total;
}

/**
 将 16进制字符串 转换为 10进制Long(非标准) <<可为负数>>
 
 @param hexString 16进制字符串
 @return <<可为负数>>10进制Long
 */
+ (long)longNonStandardWithHexString:(NSString *)hexString {
    NSData *data = [self dataWithHexString:hexString];
    return [self longNonStandardWithData:data];
}

@end
