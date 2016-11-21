//
//  XYFileLogger.m
//  Pods
//
//  Created by 何霞雨 on 16/11/16.
//
//

#import "XYFileLogger.h"

@implementation XYFileLogger
#pragma mark - Inititlization
- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self configureLogging];
    }
    return self;
}

#pragma mark 单例模式

static XYFileLogger *sharedManager=nil;

+(XYFileLogger *)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager=[[self alloc]init];
    });
    return sharedManager;
}


#pragma mark - Configuration

- (void)configureLogging
{
    
    // Enable XcodeColors利用XcodeColors显示色彩（不写没效果）
    setenv("XcodeColors", "YES", 0);
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:self.fileLogger];
    
    //设置颜色值
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:DDLogFlagInfo];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor purpleColor] backgroundColor:nil forFlag:DDLogFlagDebug];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:DDLogFlagError];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagVerbose];
    
    //设置输出的LOG样式
    XYLoggerFormmatter* formatter = [[XYLoggerFormmatter alloc] init];
    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];
    
}

#pragma mark - Getters

- (DDFileLogger *)fileLogger
{
    if (!_fileLogger) {
        DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        
        _fileLogger = fileLogger;
    }
    
    return _fileLogger;
}

#pragma mark - 邮件发送
-(void)sendEmail{
    
}

#pragma mark - 崩溃日志
void UncaughtExceptionHandler(NSException *exception){
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSDate* now = [NSDate date];
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateStyle=NSDateFormatterShortStyle;
    fmt.timeStyle=NSDateFormatterShortStyle;
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString* dateString = [fmt stringFromDate:now];
    
    NSString *urlStr = [NSString stringWithFormat:@"mailto://ios@cdfortis.com?subject=%@bug报告&body=感谢您的配合!<br><br><br>"
                        "错误详情:<br>%@<br>--------------------------<br>%@<br>---------------------<br>%@",dateString,
                        name,reason,[arr componentsJoinedByString:@"<br>"]];
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
    
    //或者直接用代码，输入这个崩溃信息，以便在console中进一步分析错误原因
    NSLog(@"CRASH: %@", exception);\
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

// 将NSlog打印信息保存到Document目录下的文件中
- (void)redirectNSlogToDocumentFolder{
    //如果已经连接Xcode调试则不输出到文件
    if(isatty(STDOUT_FILENO)) {
        return;
    }
    
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"]){ //在模拟器不保存到文件中
        return;
    }
    
    //将NSlog打印信息保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.log",dateStr];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSUTF8StringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSUTF8StringEncoding], "a+", stderr);
}
@end
