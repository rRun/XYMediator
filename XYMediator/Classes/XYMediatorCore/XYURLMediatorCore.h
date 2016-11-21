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

/**
 register default schema for router. If schema not found in router url, default schema will be used.
 for example: "/user/:user_id" will be translated into "<defaultSchema>://user/user_id"
 @param the default schema
 **/
- (void)registerDefaultSchema:(NSString *)schema;

/**
 map the URL format to the object class
 @param the router URL format (i.e. "/users/:id")
 @param clazz, the object clazz, which will be initialized in `openURL`
 **/
- (void)registerURL:(NSString *)routeURL forClass:(Class)clazz;

/**
 return an object instance which match the URL
 @param URL to route (i.e. "/users/123)
 @return object instance
 **/
- (id)instanceWithRouteURL:(NSString *)URL;

/**
 return an object instance which match the URL, the parsed parameters will extracted automatically
 @param URL to route (i.e. "/users/123)
 @param parameters, parsed parameters result
 @return object instance
 **/
- (id)instanceWithRouteURL:(NSString *)URL parsedParameters:(NSDictionary **)parameters;


@end


/**
 If you want to setup an instance with the router parameters, conforms this protocol and implement the initialization method
 **/

@protocol XYURLRoutable <NSObject>

- (instancetype)initWithRouterParams:(NSDictionary *)params;

@end
