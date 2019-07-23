//
//  XTUtils.h
//  MobileInternetMeterReadingSystem
//
//  Created by apple on 2017/9/27.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTUtils : NSObject

#pragma -mark 进制转换

/**
 NSData 转 16进制字符串
 
 @param data NSData
 @return 16进制字符串
 */
+ (NSString *)hexStringWithData:(NSData *)data;

/**
 16进制字符串 转 NSData
 
 @param hexString 16进制字符串
 @return NSData
 */
+ (NSData *)dataWithHexString:(NSString *)hexString;

/**
 16进制字符串 转 NSData(固定NSData长度)
 
 @param hexString 16进制字符串
 @param length NSData长度(字符串长度不足,高位补0；字符串长度过长,末尾有效)
 @return NSData
 */
+ (NSData *)dataWithHexString:(NSString *)hexString length:(int)length;

/**
 将Long变成NSData（length个字节）
 
 @param value 整数
 @param length 字节长度
 @return NSData
 */
+ (NSData *)dataWithLong:(long)value length:(int)length;

/**
 将NSData转换成Long <<正数>>
 
 @param data NSData
 @return <<正数>>long
 */
+ (long)positiveLongWithData:(NSData *)data;

/**
 将NSData转换成Long <<可为负数>>
 
 @param data NSData
 @return <<可为负数>>long
 */
+ (long)longWithData:(NSData *)data;

/**
 将 16进制字符串 转换为 10进制Long <<可为负数>>
 
 @param hexString 16进制字符串
 @return <<可为负数>>10进制Long
 */
+ (long)longWithHexString:(NSString *)hexString;

/**
 2进制字符串 转 16进制字符串
 
 @param binaryString 2进制字符串
 @return 16进制字符串
 */
+ (NSString *)hexStringWithBinaryString:(NSString *)binaryString;

/**
 16进制字符串 转 2进制字符串
 
 @param hexString 16进制字符串
 @return 2进制字符串
 */
+ (NSString *)binaryStringWithHexString:(NSString *)hexString;

#pragma -mark 校验和

/**
 校验和算法
 
 @param originData 原始Data
 @return NSData校验和
 */
+ (NSData *)checksumDataWithOriginData:(NSData *)originData;

/**
 校验和算法 取反+1
 
 @param originData 原始Data
 @return NSData校验和
 */
+ (NSData *)checkNegationGalOneSumDataWithOriginData:(NSData *)originData;

/**
 校验和算法
 
 @param bytes 帧bytes
 @param startIndex 开始下标
 @param endIndex 结束下标
 @return Int
 */
+ (int)checksumWithBytes:(Byte[])bytes startIndex:(int)startIndex endIndex:(int)endIndex;

#pragma -mark hex & Data otherMethods
/**
 8字节十六进制随机串
 
 @return NSString
 */
+ (NSString *)randomHex8;

/**
 反向NSData <<如：12345678 -> 78563412>>
 
 @param originData 原始NSData
 @return 反向NSData
 */
+ (NSData *)reverseDataWithOriginData:(NSData *)originData;

/**
 反向NSString <<如：12345678 -> 87654321>>
 
 @param originString 原始NSString
 @return 反向NSData
 */
+ (NSString *)reverseStringWithOriginString:(NSString *)originString;

/**
 四元数组 <<四个字符串一组>>
 
 @param originString 原始字符串
 @return 四元数组<<四个字符串一组>>
 */
+ (NSArray *)fourStringArrayWithOriginString:(NSString *)originString;

/**
 异或运算
 
 @param originData 原始NSData
 @return 进行异或运算后的NSData
 */
+ (NSData *)xorWithOriginData:(NSData *)originData;

#pragma -mark utf8

/**
 data转UTF8String

 @param data NSData
 @return UTF8String
 */
+ (NSString *)UTF8StringWithData:(NSData *)data;

/**
 string转UTF8Data
 
 @param string NSString
 @return UTF8Data
 */
+ (NSData *)UTF8DataWithString:(NSString *)string;


@end
