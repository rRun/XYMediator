//
//  XYModuleA.m
//  XYMediator
//
//  Created by Andy on 2016/11/21.
//  Copyright © 2016年 hexy. All rights reserved.
//

#import "XYModuleA.h"

#import "AViewController.h"

@implementation XYModuleA

/**
 * 当前业务组件可导航的URL询问判断
 */
-(BOOL)canOpenURL:(nonnull NSURL *)URL{
    if ([URL.host isEqualToString:@"modulea"]) {
        return YES;
    }
    return NO;
}

/**
 * 业务模块挂接中间件，注册自己能够处理的URL，完成url的跳转；
 * 如果url跳转需要回传数据，则传入实现了数据接收的调用者；
 *  @param URL          跳转到的URL，通常为 productScheme://connector/relativePath
 *  @param params       伴随url的的调用参数
 *  @return
 (1) UIViewController的派生实例，交给中间件present;
 (2) nil 表示不能处理;
 (3) [UIViewController notURLController]的实例，自行处理present;
 (4) [UIViewController paramsError]的实例，参数错误，无法导航;
 */
- (nullable UIViewController *)connectToOpenURL:(nonnull NSURL *)URL params:(nullable NSDictionary *)params{
    if ([URL.host isEqualToString:@"modulea"]) {
        AViewController *VC = [AViewController new];
        VC.view.backgroundColor = [UIColor redColor];
        return VC;
    }
    return nil;
}

@end
