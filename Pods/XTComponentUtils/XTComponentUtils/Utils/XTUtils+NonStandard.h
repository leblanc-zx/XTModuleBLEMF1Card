//
//  XTUtils+NonStandard.h
//  AFNetworking
//
//  Created by apple on 2019/4/28.
//

#import "XTUtils.h"

NS_ASSUME_NONNULL_BEGIN
/*---非标准补码----*/
@interface XTUtils (NonStandard)

/**
 将Long变成NSData(非标准)（length个字节）
 
 @param value 整数
 @param length 字节长度
 @return NSData
 */
+ (NSData *)dataNonStandardWithLong:(long)value length:(int)length;

/**
 将NSData转换成Long(非标准) <<可为负数>>
 
 @param data NSData
 @return <<可为负数>>long
 */
+ (long)longNonStandardWithData:(NSData *)data;

/**
 将 16进制字符串 转换为 10进制Long(非标准) <<可为负数>>
 
 @param hexString 16进制字符串
 @return <<可为负数>>10进制Long
 */
+ (long)longNonStandardWithHexString:(NSString *)hexString;

@end

NS_ASSUME_NONNULL_END
