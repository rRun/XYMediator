//
//  XYURLPath.h
//  Pods
//
//  Created by 何霞雨 on 2016/11/18.
//
//

#import <Foundation/Foundation.h>

@interface XYURLPath : NSObject

@property (nonatomic, strong) NSString *schema;
@property (nonatomic, strong) NSArray *components;
@property (nonatomic, strong) NSDictionary *params;

- (instancetype)initWithRouterURL:(NSString *)URL;

@end
