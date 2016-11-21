//
//  XYURLMediator.m
//  Pods
//
//  Created by 何霞雨 on 2016/11/18.
//
//

#import "XYURLMediatorCore.h"
#import "XYRouterIndexTree.h"
#import "XYURLPath.h"
#import <objc/runtime.h>

@interface XYURLMediatorCore ()

@property (nonatomic, strong) XYRouterIndexTree *tree;

@property (nonatomic, strong) NSString *defaultSchema;

@end

@implementation XYURLMediatorCore

+ (instancetype)sharedRouter {
    static XYURLMediatorCore *_sharedRouter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedRouter = [[XYURLMediatorCore alloc] init];
    });
    return _sharedRouter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _tree = [[XYRouterIndexTree alloc] init];
    }
    return self;
}

- (void)registerDefaultSchema:(NSString *)schema {
    _defaultSchema = schema;
}

- (void)registerURL:(NSString *)routeURL forClass:(Class)clazz {
    XYURLPath *path = [[XYURLPath alloc] initWithRouterURL:routeURL];
    if (!path.schema && _defaultSchema) {
        path.schema = _defaultSchema;
    }
    [self.tree insertNodeWithRoutePath:path forClass:clazz];
}

- (id)instanceWithRouteURL:(NSString *)URL {
    return [self instanceWithRouteURL:URL parsedParameters:nil];
}

- (id)instanceWithRouteURL:(NSString *)URL parsedParameters:(NSDictionary *__autoreleasing *)parameters {
    XYURLPath *path = [[XYURLPath alloc] initWithRouterURL:URL];
    if (!path.schema && _defaultSchema) {
        path.schema = _defaultSchema;
    }
    return [self.tree nodeWithRoutePath:path parsedParameters:parameters];
}

@end
