//
//  XYRouterIndexTree.h
//  Pods
//
//  Created by 何霞雨 on 2016/11/18.
//
//

#import <Foundation/Foundation.h>
#import "XYURLPath.h"


@interface XYRouterIndexTree : NSObject

- (void)insertNodeWithRoutePath:(XYURLPath *)path forClass:(Class)clazz;

- (id)nodeWithRoutePath:(XYURLPath *)path parsedParameters:(NSDictionary **)parameters;

@end
