//
//  XYRouter.h
//  Pods
//
//  Created by 何霞雨 on 2016/11/18.
//
//

#import <Foundation/Foundation.h>

#import "XYConnectorPrt.h"
#import "LDBusNavigator.h"
#import "UIViewController+NavigationTip.h"

#import "XYModuleManager.h"
#import "XYURLPath.h"
#import "XYURLMediatorCore.h"
#import "LDBusMediatorTipViewController.h"


#define XY_EXPORT_MODULE(url) \
+ (void)load { [XYRouter registerConnector:self URLString:url]]; }

static NSString *__nonnull const kLDRouteViewControllerKey = @"LDRouteViewController";
static NSString *__nonnull const kLDRouteModeKey = @"kLDRouteType";

@interface XYRouter : NSObject
#pragma mark - 配置

//设置默认的sheme,一般为app的url scheme
+(void)registerDefaultSchema:(NSString  * _Nonnull )scheme;

#pragma mark - 向总控制中心注册挂接点

//connector自load过程中，注册自己
+(void)registerConnector:(nonnull id<XYConnectorPrt>)connector URLString:(NSString * _Nonnull)urlStr;

//加载本地配置
+(void)loadLocalModulesWithPath:(NSString *)path;
//网络添加
+(void)loadNetModule:(NSArray *)modules;

//获取完module数组后，注册组件
+(void)registedAllModules;


#pragma mark - 页面跳转接口

//判断某个URL能否导航
+(BOOL)canRouteURL:(nonnull NSString *)URL;

//通过URL直接完成页面跳转
+(BOOL)openURL:(nonnull NSString *)URL;
+(BOOL)openURL:(nonnull NSString *)URL withParameters:(nullable NSDictionary *)params;
+(BOOL)openURL:(nonnull NSString *)URL withType:(NavigationMode) mode;
+(BOOL)openURL:(nonnull NSString *)URL withParameters:(nullable NSDictionary *)params withType:(NavigationMode)mode animated:(BOOL)animated;

//通过URL获取viewController实例
+(nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL;
+(nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL withParameters:(nullable NSDictionary *)params;

@end
