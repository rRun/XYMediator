//
//  XYFileLogger.h
//  Pods
//
//  Created by 何霞雨 on 16/11/16.
//
//

#import <Foundation/Foundation.h>
#import "XYCocoaLumberJack.h"
#import "XYLoggerFormmatter.h"

//日志在本地的位置：~/Library/Caches/Logs
@interface XYFileLogger : NSObject

@property (nonatomic, strong, readwrite) DDFileLogger *fileLogger;

+(XYFileLogger *)sharedManager;

-(void)sendEmail;
@end
