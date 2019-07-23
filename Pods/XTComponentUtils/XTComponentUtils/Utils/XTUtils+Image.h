//
//  XTUtils+Image.h
//  XTComponentUtils
//
//  Created by apple on 2019/2/27.
//  Copyright © 2019年 新天科技股份有限公司. All rights reserved.
//

#import "XTUtils.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XTUtils (Image)

/**
 压缩图片到指定文件大小(只压缩6次)
 
 @param image 目标图片
 @param size 目标大小（最大值)
 @param limit 限制次数：YES时只压缩6次，NO时一直压缩到压缩不动为止
 @return 返回的图片文件
 */
+ (NSData *)compressOriginalImage:(UIImage *)image toMaxDataSizeKBytes:(CGFloat)size limit:(BOOL)limit;

/**
 给图片添加文字水印
 
 @param originalImage 目标图片
 @param text 文字
 @param point 位置
 @param attributed 文字的样式
 @return 水印图片
 */
+ (UIImage *)waterImageWithOriginalImage:(UIImage *)originalImage text:(NSString *)text textPoint:(CGPoint)point attributedString:(NSDictionary * )attributed;

/**
 给图片添加文字水印
 
 @param originalImage 目标图片
 @param toSize 新图片尺寸
 @param text 文字
 @param point 位置
 @param attributed 文字的样式
 @return 水印图片
 */
+ (UIImage *)waterImageWithOriginalImage:(UIImage *)originalImage toSize:(CGSize)toSize text:(NSString *)text textPoint:(CGPoint)point attributedString:(NSDictionary * )attributed;

@end

NS_ASSUME_NONNULL_END
