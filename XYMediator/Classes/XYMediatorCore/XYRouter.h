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

NSString* const kLDRouteViewControllerKey = @"LDRouteViewController";
NSString *__nonnull const kLDRouteModeKey = @"kLDRouteType";

@interface XYRouter : NSObject
#pragma mark - 配置

//设置默认的sheme,一般为app的url scheme
+(void)registerDefaultSchema:(NSString *)scheme;

#pragma mark - 向总控制中心注册挂接点

//connector自load过程中，注册自己
+(void)registerConnector:(nonnull id<XYConnectorPrt>)connector URLString:(NSString *)urlStr;


#pragma mark - 页面跳转接口

//判断某个URL能否导航
+(BOOL)canRouteURL:(nonnull NSURL *)URL;

//通过URL直接完成页面跳转
+(BOOL)openURL:(nonnull NSString *)URL;
+(BOOL)openURL:(nonnull NSString *)URL withParameters:(nullable NSDictionary *)params;
+(BOOL)openURL:(nonnull NSString *)URL withType:(NavigationMode) mode;
+(BOOL)openURL:(nonnull NSString *)URL withParameters:(nullable NSDictionary *)params withType:(NavigationMode)mode animated:(BOOL)animated;

//通过URL获取viewController实例
+(nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL;
+(nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL withParameters:(nullable NSDictionary *)params;

@end