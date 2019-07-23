//
//  XTMF1CardRequest.m
//  XTBLEMF1Demo
//
//  Created by apple on 2019/6/4.
//  Copyright © 2019 新天科技股份有限公司. All rights reserved.
//

#import "XTMF1CardRequest.h"
#import "XTMF1BLEManager.h"
#import "XTMF1CardParse.h"
#import "XTUtils.h"

@implementation XTMF1CardRequest

static id _instace;

- (id)init
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((obj = [super init])) {
        }
    });
    self = obj;
    return self;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}

+ (id)sharedManager
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    
    return _instace;
}

/**
 读取蓝牙读卡器电压
 
 @param success 成功
 @param failure 失败
 */
- (void)readVoltageSuccess:(void(^)(CGFloat volgateValue))success failure:(void(^)(NSError *error))failure {
    
    XTMF1BLEManager *ble = [XTMF1BLEManager sharedManager];
    [ble readVoltageSuccess:^(CGFloat volgateValue) {
        if (success) {
            success(volgateValue);
        }
    } failure:^(NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**
 上电

 @param type 1读卡 2写卡 3其它
 @param success 成功
 @param failure 失败
 */
- (void)activateCardWithType:(int)type success:(void(^)(NSString *serialNumber))success failure:(void(^)(NSError *error))failure {
    
    XTMF1BLEManager *ble = [XTMF1BLEManager sharedManager];
    [ble activateCardSuccess:^(NSString * _Nonnull serialNumber) {
        if (success) {
            success(serialNumber);
        }
    } failure:^(NSError * _Nonnull error) {
        if (failure) {
            failure([self getNewErrorWithType:type oldError:error]);
        }
    }];
}

/**
 读取MF1卡信息

 @param cardType 卡类型(8:计金额5阶6价、3:计量)
 @param sector 扇区
 @param auth 秘钥
 @param operType 上次业务类型(1开户,2充值,3补卡,4销户,5换表,6红冲,7更正,9重写卡,10挂失,11解挂,12退费,13免费开户,14免费充值,15免费开户,16写应急卡)
 @param success 成功
 @param failure 失败
 */
- (void)readMF1CardWithCardType:(int)cardType sector:(int)sector auth:(NSString *)auth operType:(int)operType success:(void(^)(XTMF1CardInfo *cardInfo))success failure:(void(^)(NSError *error))failure {
    
    XTMF1BLEManager *ble = [XTMF1BLEManager sharedManager];
    
    //1.上电
    [ble activateCardSuccess:^(NSString * _Nonnull serialNumber) {
        
        //2.认证
        [ble authCardWithKeyType:@"A" sector:sector auth:auth success:^{
            
            if (cardType == 3) {
                //3.计量，只需要读取当前扇区块0
                //读取块0
                [ble readCardWithSector:sector rock:0 success:^(NSString * _Nonnull data) {
                    
                    NSError *error;
                    XTMF1CardInfo *cardInfo = [XTMF1CardParse parseMF1Read:[XTUtils dataWithHexString:data] cardType:cardType operType:operType error:&error];
                    
                    if (error) {
                        if (failure) {
                            failure([self getNewErrorWithType:1 oldError:error]);
                        }
                    } else {
                        if (success) {
                            success(cardInfo);
                        }
                    }
                    
                } failure:^(NSError * _Nonnull error) {
                    if (failure) {
                        failure([self getNewErrorWithType:1 oldError:error]);
                    }
                }];
            } else if (cardType == 8) {
                //3.计金额5阶6价，读取当前扇区块0、块1、块2 & 读取扇区+1块0
                //读取块0
                [ble readCardWithSector:sector rock:0 success:^(NSString * _Nonnull data1) {
                    //读取块1
                    [ble readCardWithSector:sector rock:1 success:^(NSString * _Nonnull data2) {
                        //读取块2
                        [ble readCardWithSector:sector rock:2 success:^(NSString * _Nonnull data3) {
                            //认证N+1扇区
                            [ble authCardWithKeyType:@"A" sector:sector+1 auth:auth success:^{
                                //读取N+1扇区块0
                                [ble readCardWithSector:sector+1 rock:0 success:^(NSString * _Nonnull data4) {
                                    //读取N+1扇区块1
                                    [ble readCardWithSector:sector+1 rock:1 success:^(NSString * _Nonnull data5) {
                                        //读取N+1扇区块2
                                        [ble readCardWithSector:sector+1 rock:2 success:^(NSString * _Nonnull data6) {
                                            
                                            NSError *error;
                                            NSString *data = [NSString stringWithFormat:@"%@%@%@%@%@%@", data1, data2, data3, data4, data5, data6];
                                            XTMF1CardInfo *cardInfo = [XTMF1CardParse parseMF1Read:[XTUtils dataWithHexString:data] cardType:cardType operType:operType error:&error];
                                            
                                            if (error) {
                                                if (failure) {
                                                    failure(error);
                                                }
                                            } else {
                                                if (success) {
                                                    success(cardInfo);
                                                }
                                            }
                                            
                                        } failure:^(NSError * _Nonnull error) {
                                            if (failure) {
                                                failure([self getNewErrorWithType:1 oldError:error]);
                                            }
                                        }];
                                        
                                    } failure:^(NSError * _Nonnull error) {
                                        if (failure) {
                                            failure([self getNewErrorWithType:1 oldError:error]);
                                        }
                                    }];
                                    
                                } failure:^(NSError * _Nonnull error) {
                                    if (failure) {
                                        failure([self getNewErrorWithType:1 oldError:error]);
                                    }
                                }];
                            } failure:^(NSError * _Nonnull error) {
                                if (failure) {
                                    failure([self getNewErrorWithType:1 oldError:error]);
                                }
                            }];
                        } failure:^(NSError * _Nonnull error) {
                            if (failure) {
                                failure([self getNewErrorWithType:1 oldError:error]);
                            }
                        }];
                    } failure:^(NSError * _Nonnull error) {
                        if (failure) {
                            failure([self getNewErrorWithType:1 oldError:error]);
                        }
                    }];
                } failure:^(NSError * _Nonnull error) {
                    if (failure) {
                        failure([self getNewErrorWithType:1 oldError:error]);
                    }
                }];
            }
            
            
        } failure:^(NSError * _Nonnull error) {
            if (failure) {
                failure([self getNewErrorWithType:1 oldError:error]);
            }
        }];
        
    } failure:^(NSError * _Nonnull error) {
        if (failure) {
            failure([self getNewErrorWithType:1 oldError:error]);
        }
    }];
    
}

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
- (void)writeMF1CardWithCardInfoData:(NSData *)cardInfoData cardType:(int)cardType sector:(int)sector auth:(NSString *)auth writeInfo:(XTMF1WriteInfo *)writeInfo success:(void (^)(XTMF1CardInfo *cardInfo))success failure:(void (^)(NSError *error))failure {
    
    //请求数据
    NSError *error;
    NSData *sendData = [XTMF1CardParse writeMF1CardWithCardInfoData:cardInfoData cardType:cardType writeInfo:writeInfo error:&error];
    
    //判断请求数据是否正确
    XTMF1CardInfo *tempSendCardInfo = [XTMF1CardParse parseMF1Read:sendData cardType:cardType operType:0 error:&error];
    long recharge = 0;
    if (tempSendCardInfo.cardType == 8) {
        //计金额 5阶6价
        recharge = [writeInfo.rechargeMoney longLongValue];
    } else {
        //计量
        recharge = [writeInfo.rechargeCount longLongValue];
    }
    if (tempSendCardInfo.thisRead != recharge) {
        if (failure) {
            failure([NSError errorWithDomain:@"错误" code:11111 userInfo:@{NSLocalizedDescriptionKey: @"写卡数据错误"}]);
        }
        return;
    }
    if (error) {
        if (failure) {
            failure([self getNewErrorWithType:2 oldError:error]);
        }
        return;
    }
    
    XTMF1BLEManager *ble = [XTMF1BLEManager sharedManager];
    
    //1.上电
    [ble activateCardSuccess:^(NSString * _Nonnull serialNumber) {
        
        //2.认证
        [ble authCardWithKeyType:@"A" sector:sector auth:auth success:^{
            
            if (cardType == 3) {
                //3.计量，只需要写当前扇区块0
                //写块0
                [ble writeCardWithHex:[XTUtils hexStringWithData:sendData] sector:sector rock:0 success:^{
                    
                    if (success) {
                        success(tempSendCardInfo);
                    }
                    
                } failure:^(NSError * _Nonnull error) {
                    if (failure) {
                        failure([self getNewErrorWithType:2 oldError:error]);
                    }
                }];
                
            } else if (cardType == 8) {
                //3.计金额5阶6价，写当前扇区块0、块1、块2 & 写扇区+1块0、块1、块2
                //写块0
                [ble writeCardWithHex:[XTUtils hexStringWithData:[sendData subdataWithRange:NSMakeRange(0, 16)]] sector:sector rock:0 success:^{
                    //写块1
                    [ble writeCardWithHex:[XTUtils hexStringWithData:[sendData subdataWithRange:NSMakeRange(16, 16)]] sector:sector rock:1 success:^{
                        //写块2
                        [ble writeCardWithHex:[XTUtils hexStringWithData:[sendData subdataWithRange:NSMakeRange(32, 16)]] sector:sector rock:2 success:^{
                            //认证N+1扇区
                            [ble authCardWithKeyType:@"A" sector:sector+1 auth:auth success:^{
                                //写N+1扇块0
                                [ble writeCardWithHex:[XTUtils hexStringWithData:[sendData subdataWithRange:NSMakeRange(48, 16)]] sector:sector+1 rock:0 success:^{
                                    //写N+1扇块1
                                    [ble writeCardWithHex:[XTUtils hexStringWithData:[sendData subdataWithRange:NSMakeRange(64, 16)]] sector:sector+1 rock:1 success:^{
                                        //写N+1扇块2
                                        [ble writeCardWithHex:[XTUtils hexStringWithData:[sendData subdataWithRange:NSMakeRange(80, 16)]] sector:sector+1 rock:2 success:^{
                                            if (success) {
                                                success(tempSendCardInfo);
                                            }
                                        } failure:^(NSError * _Nonnull error) {
                                            if (failure) {
                                                failure([self getNewErrorWithType:2 oldError:error]);
                                            }
                                        }];
                                    } failure:^(NSError * _Nonnull error) {
                                        if (failure) {
                                            failure([self getNewErrorWithType:2 oldError:error]);
                                        }
                                    }];
                                } failure:^(NSError * _Nonnull error) {
                                    if (failure) {
                                        failure([self getNewErrorWithType:2 oldError:error]);
                                    }
                                }];
                            } failure:^(NSError * _Nonnull error) {
                                if (failure) {
                                    failure([self getNewErrorWithType:2 oldError:error]);
                                }
                            }];
                        } failure:^(NSError * _Nonnull error) {
                            if (failure) {
                                failure([self getNewErrorWithType:2 oldError:error]);
                            }
                        }];
                    } failure:^(NSError * _Nonnull error) {
                        if (failure) {
                            failure([self getNewErrorWithType:2 oldError:error]);
                        }
                    }];
                } failure:^(NSError * _Nonnull error) {
                    if (failure) {
                        failure([self getNewErrorWithType:2 oldError:error]);
                    }
                }];
            }
            
        } failure:^(NSError * _Nonnull error) {
            if (failure) {
                failure([self getNewErrorWithType:2 oldError:error]);
            }
        }];
        
    } failure:^(NSError * _Nonnull error) {
        if (failure) {
            failure([self getNewErrorWithType:2 oldError:error]);
        }
    }];
    
}

/**
 转换Error

 @param type 类型 1:读卡  2:写卡
 @param oldError 转换前的error
 @return 转换后的error
 */
- (NSError *)getNewErrorWithType:(int)type oldError:(NSError *)oldError {
    if (type == 1) {
        //读卡
        NSError *iError;
        if (oldError.code == -4) {
            iError = [NSError errorWithDomain:@"错误" code:110 userInfo:@{NSLocalizedDescriptionKey: @"读卡超时"}];
        } else if (oldError.code == -36) {
            iError = [NSError errorWithDomain:@"错误" code:110 userInfo:@{NSLocalizedDescriptionKey: @"读卡异常"}];
        } else {
            iError = oldError;
        }
        return iError;
    } else if (type == 2) {
        //写卡
        NSError *iError;
        if (oldError.code == -4) {
            iError = [NSError errorWithDomain:@"错误" code:110 userInfo:@{NSLocalizedDescriptionKey: @"写卡超时"}];
        } else if (oldError.code == -36) {
            iError = [NSError errorWithDomain:@"错误" code:110 userInfo:@{NSLocalizedDescriptionKey: @"写卡异常"}];
        } else {
            iError = oldError;
        }
        return iError;
    } else {
        //其它
        return oldError;
    }
}

@end
