//
//  XYPatchHelper.m
//  Pods
//
//  Created by 何霞雨 on 16/11/10.
//
//

#import "XYPatchHelper.h"
#import "XYPatchModel.h"

#import "YYCache.h"
#import "JPEngine.h"
#import <AFNetworking/AFNetworking.h>

#include <CommonCrypto/CommonDigest.h>

//弱引用/强引用  可配对引用在外面用MPWeakSelf(self)，block用MPStrongSelf(self)  也可以单独引用在外面用MPWeakSelf(self) block里面用weakself
#define XYCoreWeakSelf(type)  __weak typeof(type) weak##type = type;
#define XYCoreStrongSelf(type)  __strong typeof(type) type = weak##type;

@interface XYPatchHelper()

@property(strong,nonatomic)NSMutableArray *mcPatchs;
@property(strong,nonatomic)NSMutableArray *mcLocalPatchs; //本地补丁的信息
@property (readonly, nonatomic, copy) NSString * mcPatchCacheKey; //!< 补丁缓存时用的key值.

@end

@implementation XYPatchHelper

#pragma mark - Public
//是关于XYPathchModel的数组
- (instancetype)initWithPatchArray:(NSMutableArray *)array{
    self = [super init];
    if (self) {
        self.mcPatchs=array;
    }
    return self;
}

-(void)loadPathchFile
{
    //然后进行安装
    [self mcUpdateAllLocalPatchFiles];
}

#pragma mark - Private Tools
/**
 *
 *  @brief 判断本地是否存在
 *
 *  @param array 本地数组
 *  @param model 新对象
 *
 *  @return YES对象存在 NO对象不存在
 */
-(BOOL)existWithArray:(NSArray *)array model:(XYPatchModel *)model
{
    BOOL result=NO;
    if (array.count==0) {
        return result;
    }
    
    if (!model) {
        return result;
    }
    
    for (XYPatchModel *item in array)
    {
        if ([model.patchId isEqualToString:item.patchId]&&[model.md5 isEqualToString:item.md5]) {
            result=YES;
            break;
        }
    }
    
    return result;
}

/**
 *
 *  @brief 删除文件
 *
 *  @param model
 */
-(BOOL)deleteFileWithJiaPathchModel:(XYPatchModel *)model
{
    if (!model) {
        return NO;
    }
    
    //文件是否存在的路径
    NSString * filePath = [self mcPathForModel:model];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        return [fm removeItemAtPath:filePath error:nil];
    }
    
    return NO;
}

/**
 *  获取某个补丁的本地存储路径.
 *
 *  注意: 此方法仅会根据既定规则计算出补丁应具有的路径,但是该路径下可能暂无对应文件.
 *
 *  @param model 补丁模型.
 *
 *  @return 补丁的本地存储路径.
 */
- (NSString *) mcPathForModel: (XYPatchModel *) model
{
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString * libCachePath = [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
    
    NSString * patchRootPath =  [libCachePath stringByAppendingString:[NSString stringWithFormat:@"/patch/%@", [self mcCurrentVer]]];
    
    if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:patchRootPath] )
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:patchRootPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    
    NSString * path =  [patchRootPath stringByAppendingString:[NSString stringWithFormat:@"/%@", model.patchId]];
    
    return path;
}

/**
 *
 *  @brief 更新单个补丁的补丁文件.
 *
 *  @param patch 补丁模型
 */
- (void) mcUpdatePatchFile: (XYPatchModel *) patch
{
    if (XYPatchModelStatusSuccess==patch.status) {
        return;
    }
    
    NSString * url = patch.url;
    
    NSString * savePath =[self mcPathForModel:patch];
    
    //使用AFNetWork下载在服务器的js文件
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
                                              {
                                                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                                                  if (httpResponse.statusCode==200) {
                                                      patch.status = XYPatchModelStatusUnInstall;
                                                      //保存到本地 Library/Caches目录下
                                                      return [NSURL fileURLWithPath:savePath];
                                                  }
                                                  else
                                                  {
                                                      return nil;
                                                  }
                                              }
                                                            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
                                              {
                                                  if(!error){
                                                      NSLog(@"下载完成 to: %@", filePath);}
                                              }];
    [downloadTask resume];
}

/**
 *  更新本地所有需要更新的补丁的补丁文件.
 *
 *
 *  @return sendNext: 文件已被更新的补丁.
 */
-(void)mcUpdateAllLocalPatchFiles
{
    if (0==self.mcLocalPatchs.count) {
        return;
    }
    XYCoreWeakSelf(self);
    [self.mcLocalPatchs enumerateObjectsUsingBlock:^(XYPatchModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XYCoreStrongSelf(self);
        [self mcInstallPatch:obj];
    }];
}


/**
 *  安装单个补丁.
 *
 *  @param patch 补丁.
 *
 */
- (void) mcInstallPatch: (XYPatchModel *) patch
{
    // 仅安装为"未安装状态的"补丁.
    if (XYPatchModelStatusUnInstall != patch.status) {
        return;
    }
    
    NSString * path = [self mcPathForModel: patch];
    
    /* 本地补丁是否存在? */
    if (YES != [[NSFileManager defaultManager] fileExistsAtPath: path]) {
        patch.status = XYPatchModelStatusFileNotExit;
        
        return;
    }
    
    /* md5校验,匹配吗? */
    if (YES != [self mcVerify:path Md5: patch.md5]) {
        patch.status = XYPatchModelStatusFileNotMatch;
        
        return;
    }
    
    /* 补丁安装成功了吗?  */
    if (YES != [self mcEvaluateScriptFile: path]) {
        patch.status = XYPatchModelStatusUnKnownError;
        
        return;
    }
    
    patch.status = XYPatchModelStatusSuccess;
}

/**
 *  验证文件的md5值是否与给定的md5匹配.
 *
 *  @param filePath 本地文件路径.
 *  @param md5      应该具有的md5值.
 *
 *  @return YES,文件md5与给定的md5匹配;NO,不匹配或文件不存在.
 */
- (BOOL)mcVerify:(NSString *)filePath Md5: (NSString *)md5
{
    NSString * fileMd5 = [self mcMd5HashOfPath: filePath];
    
    BOOL result = [md5 isEqualToString:fileMd5];
    
    return result;
}

/**
 *  获取文件的md5信息.
 *
 *  @param path 文件路径.
 *
 *  @return 文件的md5值.
 */
-(NSString *)mcMd5HashOfPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 确保文件存在.
    if( [fileManager fileExistsAtPath:path isDirectory:nil] )
    {
        NSData *data = [NSData dataWithContentsOfFile:path];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5( data.bytes, (CC_LONG)data.length, digest );
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        
        for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ )
        {
            [output appendFormat:@"%02x", digest[i]];
        }
        
        return output;
    }
    else
    {
        return @"";
    }
}


/**
 *  执行某个JS文件.
 *
 *  @param path JS文件路径.
 *
 *  @return YES,执行成功;NO,执行失败.
 */
- (BOOL) mcEvaluateScriptFile: (NSString *) path
{
    /* 打开JSPathc引擎. */
    [JPEngine startEngine];
    
    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error: NULL];
    NSLog(@"修复内容：%@",script);
    if (nil != script) {
        [JPEngine evaluateScript:script];
        
        // 修复成功.
        return YES;
    }
    
    return NO;
}
#pragma mark - Setter and Getter

-(void)setMcPatchs:(NSMutableArray *)mcPatchs{
    
    if (0==mcPatchs.count) {
        return;
    }
    
    if (!_mcLocalPatchs) {
        _mcLocalPatchs=[[NSMutableArray alloc]init];
    }
    
    //获得本地缓存的值
    YYCache *myCache=[YYCache cacheWithName:self.mcPatchCacheKey];
    if ([myCache objectForKey:self.mcPatchCacheKey]) {
        _mcLocalPatchs=(NSMutableArray *)[myCache objectForKey:self.mcPatchCacheKey];
    }
    
    //先处理要删除匹配的补丁列表中没有的本地补丁列表文件
    for (XYPatchModel *item in _mcLocalPatchs) {
        if (![self existWithArray:mcPatchs model:item]) {
            //不存在
            if ([self deleteFileWithJiaPathchModel:item]) {
                [_mcLocalPatchs removeObject:item];
            }
        }
    }
    
    //接着对新补丁进行写入
    for (XYPatchModel *item in mcPatchs) {
        item.status=XYPatchModelStatusUnInstall;
        if (![self existWithArray:_mcLocalPatchs model:item]&&[item.ver isEqualToString:[self mcCurrentVer]]) {
            //不存在 要进行下载 并只对正确的版本进行
            [self mcUpdatePatchFile:item];
            [_mcLocalPatchs addObject:item];
        }
    }
    
    //重新赋值
    [myCache setObject:_mcLocalPatchs forKey:self.mcPatchCacheKey];
    
}

- (NSString *)mcPatchCacheKey
{
    return @"mcPatchCacheKey";
}

/**
 *  当前版本号.
 *
 *  @return 当前版本号.
 */
- (NSString *) mcCurrentVer
{
    NSString * ver = [[NSBundle mainBundle].infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];
    
    return ver;
}

@end
