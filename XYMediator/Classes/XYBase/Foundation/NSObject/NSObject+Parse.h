//
//  NSObject+Parse.h
//  Parser
//
//  Created by huanchi on 16/3/4.
//  Copyright © 2016年 上海欢炽网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Parse)

/**
 *  获取属性列表
 *
 *  @return 属性列表
 */
-(NSArray *)properties;

/**
 *  属性：类型
 *
 *  @return <#return value description#>
 */
+(NSDictionary *)keyValueProperty;
/**
 *  获取类的属性列表
 *
 *  @param clss <#clss description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)propertyOfClass:(Class)clss;

/**
 *  将对象转化成字典 
 *
 *  @return 对象字典
 */
-(NSMutableDictionary *)toDictionary;


/**
 *  将字典转化成对象
 *
 *  @param dictionary 对象字典
 *
 *  @return 对象
 */
-(id)initWithDictionary:(NSDictionary *)dictionary;

/**
 *  将字典解析成对应的类对象
 *
 *  @param clss 要解析成的对象
 *
 *  @return 解析的对象
 */
-(id)parserWithClass:(Class)clss;

@end

