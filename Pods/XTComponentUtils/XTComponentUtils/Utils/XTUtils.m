//
//  XTUtils.m
//  MobileInternetMeterReadingSystem
//
//  Created by apple on 2017/9/27.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "XTUtils.h"
#import <sys/utsname.h>
#import <CommonCrypto/CommonDigest.h>

@implementation XTUtils

#pragma -mark 进制转换

/**
 NSData 转 16进制字符串
 
 @param data NSData
 @return 16进制字符串
 */
+ (NSString *)hexStringWithData:(NSData *)data
{
    
    Byte *bytes = malloc(data.length);
    memcpy(bytes, data.bytes, data.length);
    
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i = 0; i < data.length; i++) {
        NSString *hex = [NSString stringWithFormat:@"%x",(bytes[i] & 0xff)];
        //补0
        if (hex.length == 1) {
            [result appendFormat:@"0"];
        }
        [result appendString:hex];
    }
    
    return result;
    
}

/**
 16进制字符串 转 NSData
 
 @param hexString 16进制字符串
 @return NSData
 */
+ (NSData *)dataWithHexString:(NSString *)hexString {
    
    if (hexString.length%2 == 1) {
        hexString = [NSString stringWithFormat:@"0%@",hexString];
    }
    
    int length = (int)hexString.length/2;
    Byte *bytes = (Byte *)malloc(length*2);
    
    for (int i = 0; i < length; i ++) {
        NSString *hexStr = [hexString substringWithRange:NSMakeRange(i*2, 2)];
        bytes[i] = strtoul([hexStr UTF8String], 0, 16) & 0xff;
    }
    
    NSData *data = [NSData dataWithBytes:bytes length:length];
    return data;
    
}

/**
 16进制字符串 转 NSData(固定NSData长度)
 
 @param hexString 16进制字符串
 @param length NSData长度(字符串长度不足,高位补0；字符串长度过长,末尾有效)
 @return NSData
 */
+ (NSData *)dataWithHexString:(NSString *)hexString length:(int)length {
    
    if (hexString.length%2 == 1) {
        hexString = [NSString stringWithFormat:@"0%@",hexString];
    }
    
    int hexLength = (int)hexString.length/2;
    Byte *bytes = (Byte *)malloc(hexLength*2);
    
    for (int i = 0; i < hexLength; i ++) {
        NSString *hexStr = [hexString substringWithRange:NSMakeRange(i*2, 2)];
        bytes[i] = strtoul([hexStr UTF8String], 0, 16) & 0xff;
    }
    
    NSData *data = [NSData dataWithBytes:bytes length:hexLength];
    
    NSMutableData *resultData = [[NSMutableData alloc] init];
    if (data.length < length) {
        //字符串长度不足,高位补0
        for (int m = 0; m < length-data.length; m ++) {
            [resultData appendData:[self dataWithHexString:@"00"]];
        }
        [resultData appendData:data];
    } else if (data.length > length) {
        //字符串长度过长,取末尾数据
        [resultData appendData:[data subdataWithRange:NSMakeRange(data.length-length, length)]];
    } else {
        //正正好
        [resultData appendData:data];
    }
    
    return resultData;
    
}

/**
 将Long变成NSData（length个字节）
 
 @param value 整数
 @param length 字节长度
 @return NSData
 */
+ (NSData *)dataWithLong:(long)value length:(int)length {
    Byte *bot = malloc(length);
    for (int i = 0; i < length; i ++) {
        if (i == length - 1) {
            bot[i] = (Byte) (value & 0xff);
        } else {
            bot[i] = (Byte) ((value >> ((length-i-1)*8)) & 0xff);
        }
    }
    return [NSData dataWithBytes:bot length:length];
}

/**
 将NSData转换成Long <<正数>>
 
 @param data NSData
 @return <<正数>>long
 */
+ (long)positiveLongWithData:(NSData *)data {
    
    NSMutableString *str = [[NSMutableString alloc] init];
    
    for (int m = 0; m < data.length; m++) {
        [str appendString:[self hexStringWithData:[data subdataWithRange:NSMakeRange(m, 1)]]];
    }
    unsigned long long result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    [scanner scanHexLongLong:&result];
    
    return result;
}

/**
 将NSData转换成Long <<可为负数>>
 
 @param data NSData
 @return <<可为负数>>long
 */
+ (long)longWithData:(NSData *)data {
    long total = 0;
    for (int i = 0; i < data.length; i ++) {
        if (i == data.length-1) {
            int a = (int)[self positiveLongWithData:[data subdataWithRange:NSMakeRange(i, 1)]];
            total += a;
        } else {
            int a = (int)[self positiveLongWithData:[data subdataWithRange:NSMakeRange(i, 1)]];
            total += a << ((data.length-i-1)*8);
        }
    }
    return total;
}

/**
 将 16进制字符串 转换为 10进制Long <<可为负数>>
 
 @param hexString 16进制字符串
 @return <<可为负数>>10进制Long
 */
+ (long)longWithHexString:(NSString *)hexString {
    NSData *data = [self dataWithHexString:hexString];
    return [self longWithData:data];
}

/**
 2进制字符串 转 16进制字符串

 @param binaryString 2进制字符串
 @return 16进制字符串
 */
+ (NSString *)hexStringWithBinaryString:(NSString *)binaryString {
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] init];
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0" forKey:@"0000"];
    [hexDic setObject:@"1" forKey:@"0001"];
    [hexDic setObject:@"2" forKey:@"0010"];
    [hexDic setObject:@"3" forKey:@"0011"];
    [hexDic setObject:@"4" forKey:@"0100"];
    [hexDic setObject:@"5" forKey:@"0101"];
    [hexDic setObject:@"6" forKey:@"0110"];
    [hexDic setObject:@"7" forKey:@"0111"];
    [hexDic setObject:@"8" forKey:@"1000"];
    [hexDic setObject:@"9" forKey:@"1001"];
    [hexDic setObject:@"a" forKey:@"1010"];
    [hexDic setObject:@"b" forKey:@"1011"];
    [hexDic setObject:@"c" forKey:@"1100"];
    [hexDic setObject:@"d" forKey:@"1101"];
    [hexDic setObject:@"e" forKey:@"1110"];
    [hexDic setObject:@"f" forKey:@"1111"];
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (int i = 0; i < binaryString.length; i += 4) {
        NSRange range;
        range.length = 4;
        range.location = i;
        NSString *key = [binaryString substringWithRange:range];
        [hexString appendString:hexDic[key]];
    }
    return hexString;
}

/**
 16进制字符串 转 2进制字符串

 @param hexString 16进制字符串
 @return 2进制字符串
 */
+ (NSString *)binaryStringWithHexString:(NSString *)hexString {
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"a"];
    [hexDic setObject:@"1011" forKey:@"b"];
    [hexDic setObject:@"1100" forKey:@"c"];
    [hexDic setObject:@"1101" forKey:@"d"];
    [hexDic setObject:@"1110" forKey:@"e"];
    [hexDic setObject:@"1111" forKey:@"f"];
    NSMutableString *binaryString = [[NSMutableString alloc] init];
    for (int i = 0; i < [hexString length]; i ++) {
        NSRange range;
        range.length = 1;
        range.location = i;
        NSString *key = [[hexString substringWithRange:range] lowercaseString];
        [binaryString appendString:hexDic[key]];
    }
    return binaryString;
}

#pragma -mark 校验和

/**
 校验和算法
 
 @param originData 原始Data
 @return NSData校验和
 */
+ (NSData *)checksumDataWithOriginData:(NSData *)originData {
    Byte *byteData = (Byte *)malloc(originData.length);
    memcpy(byteData, [originData bytes], originData.length);
    int sum = [self checksumWithBytes:byteData startIndex:0 endIndex:(int)originData.length];
    Byte sumBytes[] = {(Byte)(sum & 0xff)};
    NSData *newData = [NSData dataWithBytes:sumBytes length:1];
    return newData;
}

/**
 校验和算法 取反+1
 
 @param originData 原始Data
 @return NSData校验和
 */
+ (NSData *)checkNegationGalOneSumDataWithOriginData:(NSData *)originData {
    Byte *byteData = (Byte *)malloc(originData.length);
    memcpy(byteData, [originData bytes], originData.length);
    int sum = [self checksumWithBytes:byteData startIndex:0 endIndex:(int)originData.length];
    Byte b1 = (Byte)(sum & 0xff);
    Byte b2 = (Byte)(0xFF - b1 + 1);
    Byte sumBytes[] = {b2};
    NSData *newData = [NSData dataWithBytes:sumBytes length:1];
    return newData;
}

/**
 校验和算法
 
 @param bytes 帧bytes
 @param startIndex 开始下标
 @param endIndex 结束下标
 @return Int
 */
+ (int)checksumWithBytes:(Byte[])bytes startIndex:(int)startIndex endIndex:(int)endIndex {
    int i;
    int temp = 0;
    for (i = startIndex; i < endIndex; i++) {
        int aa = (int)(bytes[i] & 0xff);
        temp += aa;
        //NSLog(@"===%d",temp);
    }
    return temp;
}

#pragma -mark hex & Data otherMethods

/**
 8字节十六进制随机串
 
 @return NSString
 */
+ (NSString *)randomHex8 {
    
    NSMutableString *randomStr = [[NSMutableString alloc] init];
    
    Byte *bytes = malloc(8);
    
    for (int i = 0; i < 8; i ++) {
        int random = arc4random()%256;
        
        bytes[i] = random & 0xff;
        
        NSString *sixTeenRandom = [NSString stringWithFormat:@"%x",(bytes[i] & 0xff)];
        //补0
        if (sixTeenRandom.length == 1) {
            [randomStr appendString:@"0"];
        }
        [randomStr appendString:sixTeenRandom];
    }
    
    return randomStr;
    
}

/**
 反向NSData <<如：12345678 -> 78563412>>
 
 @param originData 原始NSData
 @return 反向NSData
 */
+ (NSData *)reverseDataWithOriginData:(NSData *)originData {
    
    NSString *dataStr = [self hexStringWithData:originData];
    
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    for (long i = dataStr.length; i >= 2; i -= 2) {
        [resultStr appendString:[dataStr substringWithRange:NSMakeRange(i-2, 2)]];
    }
    return [self dataWithHexString:resultStr];
}

/**
 反向NSString <<如：12345678 -> 87654321>>
 
 @param originString 原始NSString
 @return 反向NSData
 */
+ (NSString *)reverseStringWithOriginString:(NSString *)originString {
    
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    for (long i = originString.length; i >= 1; i -= 1) {
        [resultStr appendString:[originString substringWithRange:NSMakeRange(i-1, 1)]];
    }
    return resultStr;
}

/**
 四元数组 <<四个字符串一组>>
 
 @param originString 原始字符串
 @return 四元数组<<四个字符串一组>>
 */
+ (NSArray *)fourStringArrayWithOriginString:(NSString *)originString {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < originString.length; i+=4) {
        [array addObject:[originString substringWithRange:NSMakeRange(i, 4)]];
    }
    return array;
}

/**
 异或运算

 @param originData 原始NSData
 @return 进行异或运算后的NSData
 */
+ (NSData *)xorWithOriginData:(NSData *)originData {
    int len = (int)originData.length;
    NSMutableData *resultData = [[NSMutableData alloc] init];
    for (int i = 0; i < len; i ++) {
        int ten = (int)[self longWithData:[originData subdataWithRange:NSMakeRange(i, 1)]];
        int ffTen = (int)[self longWithHexString:@"FF"];
        NSString *xorStr = [NSString stringWithFormat:@"%x",ten^ffTen];
        if (xorStr.length == 1) {
            xorStr = [NSString stringWithFormat:@"0%@",xorStr];
        }
        [resultData appendData:[self dataWithHexString:xorStr]];
    }
    return resultData;
}

#pragma -mark utf8
/**
 data转UTF8String
 
 @param data NSData
 @return UTF8String
 */
+ (NSString *)UTF8StringWithData:(NSData *)data {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (string == nil) {
        string = [[NSString alloc] initWithData:[self UTF8DataWithOriginData:data] encoding:NSUTF8StringEncoding];
    }
    return string;
}

+ (NSData *)UTF8DataWithOriginData:(NSData *)originData {
    //保存结果
    NSMutableData *resData = [[NSMutableData alloc] initWithCapacity:originData.length];
    
    NSData *replacement = [@"�" dataUsingEncoding:NSUTF8StringEncoding];
    
    uint64_t index = 0;
    const uint8_t *bytes = originData.bytes;
    
    long dataLength = (long) originData.length;
    
    while (index < dataLength) {
        uint8_t len = 0;
        uint8_t firstChar = bytes[index];
        
        // 1个字节
        if ((firstChar & 0x80) == 0 && (firstChar == 0x09 || firstChar == 0x0A || firstChar == 0x0D || (0x20 <= firstChar && firstChar <= 0x7E))) {
            len = 1;
        }
        // 2字节
        else if ((firstChar & 0xE0) == 0xC0 && (0xC2 <= firstChar && firstChar <= 0xDF)) {
            if (index + 1 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                if (0x80 <= secondChar && secondChar <= 0xBF) {
                    len = 2;
                }
            }
        }
        // 3字节
        else if ((firstChar & 0xF0) == 0xE0) {
            if (index + 2 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                uint8_t thirdChar = bytes[index + 2];
                
                if (firstChar == 0xE0 && (0xA0 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                } else if (((0xE1 <= firstChar && firstChar <= 0xEC) || firstChar == 0xEE || firstChar == 0xEF) && (0x80 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                } else if (firstChar == 0xED && (0x80 <= secondChar && secondChar <= 0x9F) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                }
            }
        }
        // 4字节
        else if ((firstChar & 0xF8) == 0xF0) {
            if (index + 3 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                uint8_t thirdChar = bytes[index + 2];
                uint8_t fourthChar = bytes[index + 3];
                
                if (firstChar == 0xF0) {
                    if ((0x90 <= secondChar & secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                } else if ((0xF1 <= firstChar && firstChar <= 0xF3)) {
                    if ((0x80 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                } else if (firstChar == 0xF3) {
                    if ((0x80 <= secondChar && secondChar <= 0x8F) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                }
            }
        }
        // 5个字节
        else if ((firstChar & 0xFC) == 0xF8) {
            len = 0;
        }
        // 6个字节
        else if ((firstChar & 0xFE) == 0xFC) {
            len = 0;
        }
        
        if (len == 0) {
            index++;
            [resData appendData:replacement];
        } else {
            [resData appendBytes:bytes + index length:len];
            index += len;
        }
    }
    
    return resData;
}

/**
 string转UTF8Data

 @param string NSString
 @return UTF8Data
 */
+ (NSData *)UTF8DataWithString:(NSString *)string {
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@end
