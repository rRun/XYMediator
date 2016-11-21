//
//  XYRouter.m
//  Pods
//
//  Created by 何霞雨 on 2016/11/18.
//
//

#import "XYRouter.h"
#import "XYURLPath.h"
#import "XYURLMediatorCore.h"
#import "LDBusMediatorTipViewController.h"
#import "UIViewController+NavigationTip.h"


@implementation XYRouter

#pragma mark - 配置

+(void)registerDefaultSchema:(NSString *)scheme{
    [[XYURLMediatorCore sharedRouter]registerDefaultSchema:scheme];
}

#pragma mark - 向总控制中心注册挂接点

//connector自load过程中，注册自己
+(void)registerConnector:(nonnull id<XYConnectorPrt>)connector URLString:(NSString *)urlStr{
    [[XYURLMediatorCore sharedRouter] registerURL:urlStr forClass:[connector class]];
}

#pragma mark - 页面跳转接口

//判断某个URL能否导航
+(BOOL)canRouteURL:(nonnull NSURL *)URL{
    id connector = [[XYURLMediatorCore sharedRouter] instanceWithRouteURL:URL];
    if (connector != nil && [connector respondsToSelector:@selector(canOpenURL:)]) {
        if ([connector canOpenURL:URL]) {
            return YES;
        }
        return NO;
    }
    return NO;
}

//跳转
+(BOOL)openURL:(nonnull NSString *)URL{
    return [self openURL:URL withParameters:nil withType:nil animated:NO];
}
+(BOOL)openURL:(nonnull NSString *)URL withParameters:(nullable NSDictionary *)params{
    return [self openURL:URL withParameters:params withType:nil animated:NO];
}
+(BOOL)openURL:(nonnull NSString *)URL withType:(NavigationMode) mode{
    return [self openURL:URL withParameters:nil withType:mode animated:NO];
}
+(BOOL)openURL:(NSString *)URL withParameters:(nullable NSDictionary *)params withType:(NavigationMode)mode animated:(BOOL)animated {
    if (![XYRouter canRouteURL:URL]) {
        return NO;
    }
    BOOL success = NO;
    id connector = [[XYURLMediatorCore sharedRouter] instanceWithRouteURL:URL];
    
    NSMutableDictionary *userParameter = [self parseParmetersWithUrl:URL Parameters:params];

    if (connector != nil && [connector respondsToSelector:@selector(connectToOpenURL:params:)]) {
        UIViewController *controller = [connector connectToOpenURL:URL params:userParameter];
        if (!controller) {
            success = NO;
        }
        
        if ([controller isKindOfClass:[LDBusMediatorTipViewController class]]) {
            LDBusMediatorTipViewController *tipController = (LDBusMediatorTipViewController *)controller;
            if (tipController.isNotURLSupport) {
                success = YES;
            } else {
                success = NO;
#if DEBUG
                [tipController showDebugTipController:URL withParameters:params];
                success = YES;
#endif
            }
        } else if ([controller class] == [UIViewController class]){
            success = YES;
        } else {
            [[LDBusNavigator navigator] hookShowURLController:controller baseViewController:params[kLDRouteViewControllerKey] routeMode:params[kLDRouteModeKey]?[params[kLDRouteModeKey] intValue]:NavigationModePush];
            success = YES;
        }
        
        
#if DEBUG
        if (!success && !controller) {
            [((LDBusMediatorTipViewController *)[UIViewController notFound]) showDebugTipController:URL withParameters:params];
            return NO;
        }
#endif
        
        
    }else{
#if DEBUG
        [((LDBusMediatorTipViewController *)[UIViewController notFound]) showDebugTipController:URL withParameters:params];
        return NO;
#endif
    }
    
    
    return success;
}

//通过URL获取viewController实例
+(nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL{
    [self viewControllerForURL:URL withParameters:nil];
}
+(nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL withParameters:(nullable NSDictionary *)params{
    
    UIViewController *returnObj = nil;
  
    id connector = [[XYURLMediatorCore sharedRouter] instanceWithRouteURL:URL];
    
    NSMutableDictionary *userParameter = [self parseParmetersWithUrl:URL Parameters:params];
    
    if(connector && [connector respondsToSelector:@selector(connectToOpenURL:params:)]){
        returnObj = [connector connectToOpenURL:URL params:userParameter];
    }
    
    
#if DEBUG
    if (!returnObj || !connector) {
        [((LDBusMediatorTipViewController *)[UIViewController notFound]) showDebugTipController:URL withParameters:params];
        return nil;
    }
#endif
    
    
    if (returnObj) {
        if ([returnObj isKindOfClass:[LDBusMediatorTipViewController class]]) {
#if DEBUG
            [((LDBusMediatorTipViewController *)returnObj) showDebugTipController:URL withParameters:params];
#endif
            return nil;
        } else if([returnObj class] == [UIViewController class]){
            return nil;
        } else {
            return returnObj;
        }
    }
    
    return nil;
}

#pragma mark - Tool

//获取所有的参数
+(NSDictionary *)parseParmetersWithUrl:(NSString *)url Parameters:(NSDictionary *)parmeters{
    NSMutableDictionary *userParameter = [NSMutableDictionary dictionaryWithDictionary:parmeters];
    XYURLPath *path = [[XYURLPath alloc]initWithRouterURL:url];
    if (path.params) {
        [userParameter setDictionary:path.params];
    }
    
    return userParameter;
}
@end
