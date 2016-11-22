//
//  XYFileLogger.m
//  Pods
//
//  Created by 何霞雨 on 16/11/16.
//
//

#import "XYFileLogger.h"

#import "ZipArchive.h"

#import <MessageUI/MessageUI.h>

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
    
    //崩溃日志处理
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
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

#pragma mark - Email
-(void)sendEmail:(NSString *)zipPath{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    // 邮件服务器
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    // 设置邮件代理
    [mailCompose setMailComposeDelegate:self];
    // 设置邮件主题
    [mailCompose setSubject:[NSString stringWithFormat:@"日志_iOS_%@",dateStr]];
    // 设置收件人
    //[mailCompose setToRecipients:@[@"1147626297@qq.com"]];
    // 设置抄送人
    //[mailCompose setCcRecipients:@[@"1229436624@qq.com"]];
    // 设置密抄送
    //[mailCompose setBccRecipients:@[@"shana_happy@126.com"]];
    /**
     *  设置邮件的正文内容
     */
    NSString *emailContent = @"iOS日志，日志随邮件附件，请解压后使用！";
    // 是否为HTML格式
    [mailCompose setMessageBody:emailContent isHTML:NO];
    // 如使用HTML格式，则为以下代码
    //[mailCompose setMessageBody:@"<html><body><p>日志附件如下</p><p>附带为zip，请解压后使用！</p></body></html>" isHTML:YES];
    /**
     *  添加附件
     */
    
    NSData *zip = [NSData dataWithContentsOfFile:zipPath];
    [mailCompose addAttachmentData:zip mimeType:@"zip" fileName:@"日志"];
    
    // 弹出邮件发送视图
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:mailCompose animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled: // 用户取消编辑
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved: // 用户保存邮件
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent: // 用户点击发送
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
    }
    
    // 关闭邮件发送视图
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Crash log
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

#pragma mark - Tool
/**
 *  根据路径将文件压缩为zip到指定路径
 *
 *  @param sourcePath 压缩文件夹路径
 *  @param destZipFile存放路径（保存重命名）
 */
+(void) doZipAtPath:(NSString*)sourcePath to:(NSString*)destZipFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    ZipArchive * zipArchive = [ZipArchive new];
    BOOL isdic;
    //判断sourcePath下是文件夹还是文件
    if(![fileManager fileExistsAtPath:sourcePath isDirectory:&isdic])
        return;//文件不存在，直接返回
    
    [zipArchive CreateZipFile2:destZipFile];
    
    if (isdic)//文件夹
    {
        NSArray *fileList = [fileManager contentsOfDirectoryAtPath:sourcePath error:nil];//文件列表
        for(NSString *filePath in fileList){
            NSString *fileName = [filePath lastPathComponent];//取得文件名
            NSString *path = [sourcePath stringByAppendingString:[NSString stringWithFormat:@"/%@",filePath]];
            [zipArchive addFileToZip:path newname:fileName];
        }
    }else{
        [zipArchive addFileToZip:sourcePath newname:[sourcePath lastPathComponent]];
    }
    
    [zipArchive CloseZipFile2];
}


@end
