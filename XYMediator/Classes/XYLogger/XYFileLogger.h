//
//  XYFileLogger.h
//  Pods
//
//  Created by 何霞雨 on 16/11/16.
//
//

#import <Foundation/Foundation.h>
#import <CocoaLumberJack/CocoaLumberJack.h>
#import "XYLoggerFormmatter.h"


//日志在本地的位置：~/Library/Caches/Logs
@interface XYFileLogger : NSObject

@property (nonatomic, strong, readwrite) DDFileLogger *fileLogger;

+(XYFileLogger *)sharedManager;

//读取日志压缩成zip附件调用邮件发送
-(void)sendEmail;

//清除日志
-(void)clearLogs;


@end
