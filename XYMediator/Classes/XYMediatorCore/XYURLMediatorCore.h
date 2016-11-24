//
//  XYURLMediator.h
//  Pods
//
//  Created by 何霞雨 on 2016/11/18.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface XYURLMediatorCore : NSObject

+ (instancetype)sharedRouter;

//注册schema
- (void)registerDefaultSchema:(NSString *)schema;

//注册对象
- (void)registerURL:(NSString *)routeURL forClass:(Class)clazz;

//根据URL找到对象
- (id)instanceWithRouteURL:(NSString *)URL;

//根据URL找到对象,parameters直接可用
- (id)instanceWithRouteURL:(NSString *)URL parsedParameters:(NSDictionary **)parameters;


@end

//对象协议
@protocol XYURLRoutable <NSObject>

- (instancetype)initWithRouterParams:(NSDictionary *)params;

@end
