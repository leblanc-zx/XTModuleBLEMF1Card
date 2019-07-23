//
//  XTMF1WriteInfo.h
//  QuickTopUp
//
//  Created by apple on 2019/7/11.
//  Copyright © 2019 新天科技股份有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XTMF1WriteInfo : NSObject

@property (strong,nonatomic) NSString *price1;          //单位分
@property (strong,nonatomic) NSString *price2;          //单位分
@property (strong,nonatomic) NSString *price3;          //单位分
@property (strong,nonatomic) NSString *price4;          //单位分
@property (strong,nonatomic) NSString *price5;          //单位分
@property (strong,nonatomic) NSString *price6;          //单位分
@property (strong,nonatomic) NSString *divid1;          
@property (strong,nonatomic) NSString *divid2;
@property (strong,nonatomic) NSString *divid3;
@property (strong,nonatomic) NSString *divid4;
@property (strong,nonatomic) NSString *divid5;
@property (strong,nonatomic) NSString *freezeDay;       //冻结日
@property (strong,nonatomic) NSString *freezeMonth;     //冻结月
@property (strong,nonatomic) NSString *exeDate;         //调价日期
@property (strong,nonatomic) NSString *rechargeMoney;   //充值金额 单位:分
@property (strong,nonatomic) NSString *rechargeCount;   //充值量 单位:m³
@property (strong,nonatomic) NSString *warn;            //报警值 (如果是金额 单位:分；如果是量 单位:m³)
@property (strong,nonatomic) NSString *over;            //透支 (如果是金额 单位:分；如果是量 单位:m³)

@end

NS_ASSUME_NONNULL_END
