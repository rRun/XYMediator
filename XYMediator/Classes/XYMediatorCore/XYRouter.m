//
//  XYRouter.m
//  Pods
//
//  Created by 何霞雨 on 2016/11/18.
//
//

#import "XYRouter.h"



@implementation XYRouter

#pragma mark - 配置

+(void)registerDefaultSchema:(NSString *)scheme{
    [[XYURLMediatorCore sharedRouter]registerDefaultSchema:scheme];
}

#pragma mark - 向总控制中心注册挂接点

//connector自load过程中，注册自己
+(void)registerConnector:(nonnull id<XYConnectorPrt>)connector URLString:(NSString *)urlStr{
    XYModule *module = [XYModule new];
    module.name = NSStringFromClass([connector class]);
    module.level = 2;
    module.url = urlStr;
    
    [[XYModuleManager sharedManager] addModule:module];
    
    if ([[XYModuleManager sharedManager].BHModules containsObject:module]) {
        [[XYModuleManager sharedManager] registedModule:module];
    }
    
}

//加载本地配置
+(void)loadLocalModulesWithPath:(NSString *)path{
    if (!path) {
        [XYModuleManager sharedManager].modulesConfigFilename = @"XYMediator.bundle/XYRoute";
    }else{
        [XYModuleManager sharedManager].modulesConfigFilename = path;
    }
    [[XYModuleManager sharedManager]loadLocalModules];
}
//网络添加
+(void)loadNetModule:(NSArray *)modules{
    if (!modules) {
        return;
    }
    
    [modules enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *module1Level = (NSNumber *)[obj objectForKey:kModuleInfoLevelKey];
        NSString *classStr = [obj objectForKey:kModuleInfoNameKey];
        NSString *url = [obj objectForKey:kModuleInfoUrlKey];
        
        XYModule *module = [XYModule new];
        module.name = classStr;
        module.level = [module1Level intValue];
        module.url = url;
        
        [[XYModuleManager sharedManager] addModule:module];
        
    }];
}

//获取完module数组后，注册组件
+(void)registedAllModules{
    [[XYModuleManager sharedManager]registedAllModules];
}
#pragma mark - 页面跳转接口

//判断某个URL能否导航
+(BOOL)canRouteURL:(nonnull NSString *)URL{
    id connector = [[XYURLMediatorCore sharedRouter] instanceWithRouteURL:URL];
    if (connector != nil && [connector respondsToSelector:@selector(canOpenURL:)]) {
        NSURL *url = [NSURL URLWithString:URL];
        if ([connector canOpenURL:url]) {
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
    //if (![XYRouter canRouteURL:URL]) {
     //   return NO;
    //}
    BOOL success = NO;
    NSDictionary *parsedParameters = nil;
    id connector = [[XYURLMediatorCore sharedRouter] instanceWithRouteURL:URL parsedParameters:&parsedParameters];
    
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    [tempDic setDictionary:params];
    [tempDic setDictionary:parsedParameters];
    
    if (mode != NavigationModeNone) {
        [tempDic setValue:[NSNumber numberWithInt:mode] forKey:kLDRouteModeKey];
    }

    if (connector != nil && [connector respondsToSelector:@selector(connectToOpenURL:params:)]) {
        NSURL *url = [NSURL URLWithString:URL];
        UIViewController *controller = [connector connectToOpenURL:url params:tempDic];
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
                [tipController showDebugTipController:URL withParameters:tempDic];
                success = YES;
#endif
            }
        } else if ([controller class] == [UIViewController class]){
            success = YES;
        } else {
            [[LDBusNavigator navigator] hookShowURLController:controller baseViewController:tempDic[kLDRouteViewControllerKey] routeMode:tempDic[kLDRouteModeKey]?[tempDic[kLDRouteModeKey] intValue]:NavigationModePush];
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
