//
//  XTMF1CardInfo.h
//  XTBLEMF1Demo
//
//  Created by apple on 2019/6/4.
//  Copyright © 2019 新天科技股份有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XTMF1CardInfo : NSObject

@property (nonatomic, strong) NSData *originCardData;       //卡帧数据
@property (nonatomic, strong) NSString *cardFlag;           //卡标志(DA:用户卡,D5设置卡,D0检查卡...)
@property (nonatomic, assign) int cardType;                 //卡类型(3:MF1卡、6:MF1卡阶梯、8:MF1卡5阶6价、9:MF1卡3阶4价)
@property (nonatomic, strong) NSString *systemNumber;       //系统号
@property (nonatomic, strong) NSString *cardNumber;         //卡号
@property (nonatomic, assign) long totalRead;               //总量(或金额)
@property (nonatomic, assign) long thisRead;                //本次购量(或金额)
@property (nonatomic, assign) BOOL isBrushed;               //是否已刷表

@end

//计量卡信息
@interface XTMF1CardInfo (Amount)

@property (nonatomic, assign) long remainedCount;           //剩余量
@property (nonatomic, assign) long warnCount;               //报警量
@property (nonatomic, assign) long overCount;               //透支量(帧中无此值,一直为0)

@end

//计金额卡信息
@interface XTMF1CardInfo (Money)

@property (nonatomic, assign) long remainedMoney;//剩余金额
@property (nonatomic, assign) long warnMoney;   //报警金额
@property (nonatomic, assign) long overMoney;   //透支金额
@property (nonatomic, assign) long price1;      //价格1
@property (nonatomic, assign) long devideCount1;//分界点1
@property (nonatomic, assign) long price2;      //价格2
@property (nonatomic, assign) long devideCount2;//分界点2
@property (nonatomic, assign) long price3;      //价格3
@property (nonatomic, assign) long devideCount3;//分界点3
@property (nonatomic, assign) long price4;      //价格4
@property (nonatomic, assign) long devideCount4;//分界点4
@property (nonatomic, assign) long price5;      //价格5
@property (nonatomic, assign) long devideCount5;//分界点5
@property (nonatomic, assign) long price6;      //价格6
@property (nonatomic, strong) NSString *brushTime;  //yy-MM-dd HH:mm

@end

NS_ASSUME_NONNULL_END
